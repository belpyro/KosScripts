runOncePath("coreLib").
clearScreen.

sas off.
rcs off.

print "Start Circ.".
wait 1.

set warp to 0.
set delta to eta:periapsis - 60.
if (delta < 0) { set delta to obt:period - 60 - eta:periapsis. }

warpto(time:seconds + delta).

local lock V1 to ship:velocity:orbit.
local lock V2 to vxcl(ship:up:vector, V1):normalized * sqrt(ship:body:mu/(ship:body:radius + ship:altitude)).
local lock V3 to V1 - V2.
clearScreen.
print "V3 Current: " + round(V3:mag,4) at(0,0).


lock steering to -V3.
wait until vAng(ship:facing:forevector, -V3) <= 0.5.
set warp to 0.
warpTo(time:seconds + eta:periapsis - 5).

local pid to pidLoop(5, 0, 0, 0.0001, 1, 1e-3).
set pid:setpoint to 0.

local mtR to 0.
lock throttle to mtR.

print "Waiting PE".
wait until eta:periapsis <= 0.5.
set warp to 0.

print "Start Burn".
set startV3 to V3:mag.

until V3:mag <= 1e-3
{
    clearScreen.
    print "V3 Current: " + round(V3:mag,4) at(0,0).
    print "V3 Start:   " + round(startV3,4) at(0,1).
    set mtR to pid:update(time:seconds, -(V3:mag/startV3)).
    wait 0.01.
}

set mtR to 0.
UnlockAllFunc().

print "End Circularization!".
wait 2.

