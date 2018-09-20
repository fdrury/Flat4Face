//
// Copyright 2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.Graphics as Gfx;
using Toybox.Lang as Lang;
using Toybox.System as Sys;
using Toybox.Time as Time;
using Toybox.Time.Gregorian as Calendar;
using Toybox.WatchUi as Ui;
using Toybox.Application as App;

// This implements a Goal View for the Analog face
class AnalogGoalView extends Ui.View {
    var goalString;
    var screenShape;
    var carIcon = null;
    var animationTimer = new Timer.Timer();
    var theGoal;

    function initialize(goal) {
        View.initialize();
        screenShape = Sys.getDeviceSettings().screenShape;
        theGoal = goal;

        if(goal == App.GOAL_TYPE_STEPS) {
            goalString = "STEPS";
        }
        else if(goal == App.GOAL_TYPE_FLOORS_CLIMBED) {
            goalString = "STAIRS";
        }
        else if(goal == App.GOAL_TYPE_ACTIVE_MINUTES) {
            goalString = "ACTIVE";
        }
    }

    //! Load the resources required for the watch face
    function onLayout(dc) {
        if(theGoal == App.GOAL_TYPE_STEPS) {
            carIcon = new Ui.Bitmap({:rezId=>Rez.Drawables.RallyCarIcon,:locX=>dc.getWidth() / 2 - 75,:locY=>dc.getHeight() / 2 - 10});
        }
        else if(theGoal == App.GOAL_TYPE_FLOORS_CLIMBED) {
            carIcon = new Ui.Bitmap({:rezId=>Rez.Drawables.SportsCarIcon,:locX=>dc.getWidth() / 2 - 75,:locY=>dc.getHeight() / 2 - 10});
        }
        else if(theGoal == App.GOAL_TYPE_ACTIVE_MINUTES) {
            carIcon = new Ui.Bitmap({:rezId=>Rez.Drawables.PunchBuggyIcon,:locX=>dc.getWidth() / 2 - 70,:locY=>dc.getHeight() / 2 - 10});
        }
    }
    
    function onExitSleep(){
    }
    
    function onEnterSleep(){
    	//animationTimer.stop();
    }

    function onShow() {
    }
    
    function performUpdate(){
    	Ui.requestUpdate();
    }

    //! Update the clock face graphics during update
    function onUpdate(dc) {
        var width;
        var height;
        var clockTime = Sys.getClockTime();

        width = dc.getWidth();
        height = dc.getHeight();

        var now = Time.now();
        var info = Calendar.info(now, Time.FORMAT_LONG);

        var dateStr = Lang.format("$1$ $2$ $3$", [info.day_of_week, info.month, info.day]);

        // Clear the screen
        dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_WHITE);
        dc.fillRectangle(0, 0, width, height);

        // Draw the Goal
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_TRANSPARENT);
        dc.drawText(width / 2, (height / 2) - 50, Gfx.FONT_MEDIUM, goalString, Gfx.TEXT_JUSTIFY_CENTER);
        dc.drawText(width / 2, (height / 2) + 50, Gfx.FONT_MEDIUM, "GOAL!", Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the rally car icon
        if (null != carIcon) {
            carIcon.draw(dc);
        }
    }
}
