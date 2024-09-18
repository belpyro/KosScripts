@lazyGlobal off.

declare parameter exAlt is 6000, speed is 200.
wait until ship:unpacked and controlConnection:isconnected.

clearScreen.
sas off.
rcs off.

local way to heading(90, 90).
lock steering to way.

local thr to 1.
lock throttle to thr.

hudtext("Starting launch", 2, 2, 15, green, true).
wait 1.

hudtext("3", 1, 2, 15, green, true).
wait 1.
hudtext("2", 1, 2, 15, green, true).
wait 1.
hudtext("1", 1, 2, 15, green, true).
wait 1.

hudtext("Launch!!!", 1, 2, 15, green, true).

when maxThrust <= 0 then {
    stage.
    preserve.
}

clearScreen.

local pid to pidLoop(15, 0.0015, 0, 0, 1, 0.002).
set pid:setpoint to 0.1.

until ship:altitude >= exAlt {
    print "Orbit Velocity: " + ship:velocity:orbit:mag at(1,1).
    print "Vertical Velocity: " + ship:verticalspeed at(1,2).
    print "Horizontal Velocity: " + ship:groundspeed at(1,3).
    set thr to pid:update(time:seconds, ship:verticalspeed/speed - 1).
    wait 0.1.
}

set thr to 0.
stage.

unlock throttle.
unlock steering.
set ship:control:pilotmainthrottle to 0.

