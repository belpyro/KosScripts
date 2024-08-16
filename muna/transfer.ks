declare parameter targetBodyName is "Mun", transToNextPath is false.

sas off.
rcs off.
clearscreen.

local targetBody to Body(targetBodyName).
local calculatedAngle to calculateNeededAngle.

when maxThrust = 0 then 
{
    wait 0.1.
    stage.
    preserve.
}

local gamma to 360 - calculatedAngle.
local betta to calculateCurrentAngle.
local tetta to 0.

if(betta < calculatedAngle){
    set tetta to gamma + betta.
}
if(betta > 0 and betta > calculatedAngle){
    set tetta to gamma - betta.
}

local dTime to ((tetta-1) * ship:obt:period)/360.
warpTo(time:seconds + dTime).

until false
{
   local current to calculateCurrentAngle(). 
   printData(current, calculatedAngle).
   local delta to (current - calculatedAngle).
   print "Current delta angle: " + delta at(1,3).
   if (delta <= 1 and delta > 0)
   {
        set warp to 0.
        clearScreen.
        print "Start burn!".
        break.
   }
   wait 0.01.
}

lock steering to prograde.
wait until vAng(ship:facing:forevector, prograde:vector) <= 0.5.

local throttleVal to 0.
lock throttle to throttleVal.

local mpid to pidLoop(3, 0.0035, 0, 1e-4, 1).
set mpid:setpoint to 1e-9.
local lock diff to ((ship:obt:apoapsis - targetBody:altitude)/targetBody:altitude).

until ship:orbit:apoapsis >= targetBody:altitude
{
    set throttleVal to mpid:update(time:seconds, diff).
    print "Burning" at (1,1).
    print "APO: " + round(ship:orbit:apoapsis,4) at(1,2).
    wait 0.01.
}

set throttleVal to 0.

wait 1.

clearScreen.

print "Finished Burn".
wait 3.

if(ship:obt:hasnextpatch and transToNextPath){
    local t to ship:obt:nextpatcheta.
    if (t > 10)
    {
        warpTo(time:seconds + t - 10).
    }
}

unlock steering.
unlock throttle.

function calculateNeededAngle
{
    local A1 to (targetBody:altitude + kerbin:radius*2 + ship:altitude)/2.
    local A2 to (targetBody:altitude + kerbin:radius).
    local neededAngle to 180*(1-((sqrt(A1^3/A2^3)))).
    return neededAngle.
}

function calculateCurrentAngle{
    local shipPosition to (ship:position - kerbin:position):normalized.
    local bodyPosition to (targetBody:position - kerbin:position):normalized.
    local shipRelBodyPos to (targetBody:position - ship:position):normalized.
    local shipHorSpeed to vxcl(ship:up:vector, ship:velocity:obt):normalized.
    local shipRelBodyAngle to vAng(shipRelBodyPos, shipHorSpeed).
    local shipPositionAngle to vAng(bodyPosition, shipPosition).
    if(shipRelBodyAngle >= 90){
        set shipPositionAngle to -shipPositionAngle.
    }
    return shipPositionAngle.
}

function printData
{
   parameter currentAngle, neededAngle.
    
   print "Current Ship Angle: " + round(currentAngle,4) at (3, 1).
   print "Needed Angle: " + round(neededAngle,4) at (3, 2).
}