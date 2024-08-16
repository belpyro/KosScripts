declare parameter period is 1.

sas off.
rcs off.

wait 1.
clearScreen.
print "Deorbiting to period of current body " + round(period, 3).

local direction to retrograde.
lock steering to direction.
wait until vAng(ship:facing:forevector, direction:vector) <= 1.
wait 1.

local expectedPer to round(period*ship:obt:period, 5).
wait 1.
print "Expected period: " + round(expectedPer, 3).

local pid to pidLoop(3, 0.0035, 0.0025, 0.001, 1).
set pid:setpoint to 1e-5.

local thr to 0.
lock throttle to thr.

until ship:obt:period <= expectedPer {
    set thr to pid:update(time:seconds, expectedPer/ship:orbit:period - 1).
    wait 0.001.
}

set thr to 0.

set warpmode to "rails".
warpto(time:seconds + eta:periapsis - 5).

wait until eta:periapsis <= 0.5.

UnlockAllFunc().