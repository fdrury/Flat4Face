//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.Math as Math;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.ActivityMonitor;

// This implements an analog watch face
// Original design by Austen Harbour
class AnalogView extends Ui.WatchFace
{
    var isAwake = false;
    var screenShape;
    var fwIcon;

    function initialize() {
        WatchFace.initialize();
        screenShape = Sys.getDeviceSettings().screenShape;
    }

    function onLayout(dc) {
        fwIcon = new Ui.Bitmap({
        	:rezId=>Rez.Drawables.FlatWorldIcon,
        	:locX=>(dc.getWidth() - 200) / 2,
        	:locY=>dc.getHeight() * 0.4
        });
    }

    // Draw the watch hand
    // @param dc Device Context to Draw
    // @param angle Angle to draw the watch hand
    // @param length Length of the watch hand
    // @param width Width of the watch hand
    function drawHand(dc, angle, length, width) {
        // Map out the coordinates of the watch hand
        var coords = [[-(width / 2),0], [-(width / 2), -length], [width / 2, -length], [width / 2, 0]];
        var result = new [4];
        var centerX = dc.getWidth() / 2;
        var centerY = dc.getHeight() / 2;
        var cos = Math.cos(angle);
        var sin = Math.sin(angle);

        // Transform the coordinates
        for (var i = 0; i < 4; i += 1) {
            var x = (coords[i][0] * cos) - (coords[i][1] * sin);
            var y = (coords[i][0] * sin) + (coords[i][1] * cos);
            result[i] = [centerX + x, centerY + y];
        }

        // Draw the polygon
        //dc.setClip(result[0], result[1], result[2] - result[0], result[3] - result[1]);
        dc.fillPolygon(result);
    }

    // Handle the update event
    function onUpdate(dc) {
        var width;
        var height;
        var screenWidth = dc.getWidth();
        var flatWorldWidth = fwIcon.getDimensions()[0];
        var clockTime = Sys.getClockTime();
        var hourHand;
        var hourTail;
        var minuteHand;
        var minuteTail;
        var secondHand;
        var secondTail;

        width = dc.getWidth();
        height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);

        // Clear the screen
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());

        // Draw the date
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.drawText(width / 2, height - 32, Gfx.FONT_XTINY, dateStr, Gfx.TEXT_JUSTIFY_CENTER);
        
        //steps progress
        //TODO: account for null step info
        var stepMult = 0.0;
        var activityInfo = ActivityMonitor.getInfo();
        if(activityInfo.steps != null && activityInfo.stepGoal != null && activityInfo.stepGoal != 0){
        	stepMult = (activityInfo.steps + 0.0) / (activityInfo.stepGoal + 0.0);
        	if(stepMult > 1.0){
        		stepMult = 1.0;
        	}
        }
        //stepMult = 0.7; //FOR SCREENSHOT
        //0.5 is to adjust for truncation.
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
        dc.fillRectangle(fwIcon.locX, fwIcon.locY, fwIcon.width * stepMult + 0.5, fwIcon.height);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_WHITE);
        dc.fillRectangle(fwIcon.locX + fwIcon.width * stepMult + 0.5, fwIcon.locY, fwIcon.width * (1.0 - stepMult) + 0.5, fwIcon.height);
        
        // Draw the flat world icon
        if (null != fwIcon) {
            fwIcon.draw(dc);
        }

        // Draw the hour. Convert it to minutes and compute the angle.
        hourHand = (((clockTime.hour % 12) * 60) + clockTime.min);
        hourHand = hourHand / (12 * 60.0);
        hourHand = hourHand * Math.PI * 2;
        hourTail = hourHand - Math.PI;
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        drawHand(dc, hourHand, 65, 5);
        drawHand(dc, hourTail, 15, 5);

        // Draw the minute
        minuteHand = (clockTime.min / 60.0) * Math.PI * 2;
        minuteTail = minuteHand - Math.PI;
        drawHand(dc, minuteHand, 95, 5);
        drawHand(dc, minuteTail, 15, 5);

        // Draw the arbor (now done with second hand)
        /*dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, 6);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, 4);*/
        
        // Draw the second and corresponding arbor
        if (Toybox.WatchUi.WatchFace has :onPartialUpdate || isAwake) {
	        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
	        secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
	        secondTail = secondHand - Math.PI;
	        drawHand(dc, secondHand, 95, 2);
	        drawHand(dc, secondTail, 25, 2);
	        
	        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
	        dc.fillCircle(width / 2, height / 2, 6);
	        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
	        dc.fillCircle(width / 2, height / 2, 4);
        }
        else {
	        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_BLACK);
	        dc.fillCircle(width / 2, height / 2, 6);
	        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
	        dc.fillCircle(width / 2, height / 2, 4);
        }
    }
    
    function onPartialUpdate(dc){
    	//dc.setClip(...);
    	Ui.requestUpdate();
    	//dc.clearClip();
    	
    	/*var clockTime = Sys.getClockTime();
        var secondHand;
        var secondTail;
        var width = dc.getWidth();
        var height = dc.getHeight();
    	
    	//second hand
    	dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_TRANSPARENT);
        secondHand = (clockTime.sec / 60.0) * Math.PI * 2;
        secondTail = secondHand - Math.PI;
        drawHand(dc, secondHand, 95, 2);
        drawHand(dc, secondTail, 25, 2);
        
        //draw the arbour
        dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, 6);
        dc.setColor(Gfx.COLOR_BLACK,Gfx.COLOR_BLACK);
        dc.fillCircle(width / 2, height / 2, 4);*/
    }

    function onEnterSleep() {
        isAwake = false;
        Ui.requestUpdate();
    }

    function onExitSleep() {
        isAwake = true;
    }
}

class AnalogDelegate extends Ui.WatchFaceDelegate {
    // The onPowerBudgetExceeded callback is called by the system if the
    // onPartialUpdate method exceeds the allowed power budget. If this occurs,
    // the system will stop invoking onPartialUpdate each second, so we set the
    // partialUpdatesAllowed flag here to let the rendering methods know they
    // should not be rendering a second hand.
    function onPowerBudgetExceeded(powerInfo) {
        System.println( "Average execution time: " + powerInfo.executionTimeAverage );
        System.println( "Allowed execution time: " + powerInfo.executionTimeLimit );
        partialUpdatesAllowed = false;
    }
}
