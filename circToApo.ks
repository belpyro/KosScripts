clearScreen.
sas off.
rcs off.

show("Start Circ.").
wait 1.

when eta:apoapsis <= 60 then { 
    if (warp > 0)
    {
       set warp to 0. 
    }
    preserve. 
}

warpto(time:seconds + eta:apoapsis - 60).

local lock V1 to ship:velocity:orbit.
local lock V2 to vxcl(ship:up:vector, V1):normalized * sqrt(ship:body:mu/(ship:body:radius + ship:altitude)).
local lock V3 to V2 - V1.

lock steering to V3.
show("Waiting steering with V3 " + round(V3:mag) + " deltaV").
wait until vAng(ship:facing:forevector, V3) <= 0.5.

if(eta:apoapsis > 10)
{
    warpto(time:seconds + eta:apoapsis - 10).
}

local pid to pidLoop(3, 0.0015, 0, 0.0001, 1).
set pid:setpoint to 1e-5.

local mtR to 0.
lock throttle to mtR.

show("Waiting APO").
wait until eta:apoapsis <= 0.5.

show("Start Burn").
until obt:eccentricity <= 1e-5
{
    set mtR to pid:update(time:seconds, -obt:eccentricity).
    wait 0.01.
}

set mtR to 0.
UnlockAllFunc().
rcs off.

show("End Circularization!").
wait 3.

function show{
    parameter m.

    clearScreen.
    print m at(1,1).
}