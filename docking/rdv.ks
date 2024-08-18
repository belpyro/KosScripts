@lazyGlobal off.

clearScreen.
clearVecDraws().

local operation to "Preparing Randevouze.".

on operation {
    clearScreen.
    print operation.
}

for n in allNodes {
    remove n.
}

sas off.
rcs off.

local r1 is SHIP:OBT:semimajoraxis.
local r2 is target:OBT:semimajoraxis.
local a is (r1+r2)/2.
local mu is SHIP:BODY:MU.

// Calculate delta-v for Hohmann transfer
local v1 to SQRT(mu / r1).
local v2 to SQRT(mu * (2 / r1 - 1 / a)).
local deltaV1 to v2 - v1.

local time_to_transfer to constant:pi*sqrt(a^3/mu).
local ship_angular to sqrt(mu/r1^3).
local target_angular to sqrt(mu/r2^3).
local target_angle_to_intercept to wrapAngle(target_angular*time_to_transfer*constant:radtodeg).
local target_phase_angle to 180 - target_angle_to_intercept.
local halfBurnTime to getDeltaBurnTime(deltaV1)/2.

until halfBurnTime > 4 {
    decreaseThrustOn(1).
    set halfBurnTime to getDeltaBurnTime(deltaV1)/2.
}

if (target_phase_angle < 0) {
    set target_phase_angle to 360 + target_phase_angle.
}

local lock current_angle to getPhaseAngle().
local lock angle_eta to timeToPhaseAngle().

local nd is node(time:seconds + angle_eta, 0,0, deltaV1).
add nd.

set operation to "Execurig randevouze maneouver.".

local lock burn_eta to nd:eta - halfBurnTime.

lock steering to nd:burnvector.
wait until vAng(nd:burnvector, ship:facing:forevector) <= 0.5.

warpto(time:seconds + nd:eta - 60).

wait until vAng(nd:burnvector, ship:facing:forevector) <= 0.5.

local pid is pidLoop(4.5, 0.04, 0.2, 0, 1).
set pid:setpoint to 1.

wait until burn_eta <= 0.
unlock burn_eta.

local th is 1.
lock throttle to th.

until nd:deltav:mag < 0.1 {
    if(nd:deltav:mag <= 0.1*abs(deltaV1)){
        set th to max(0.0001, pid:update(time:seconds, 1 - abs(nd:deltav:mag/deltaV1))).
    }    
}

set th to 0.
unlock steering.
unlock throttle.
resetEnginesThrust().

local intersect_dist is nd:int:INT1DIST.
local intersect_time is nd:int:INT1UT.

if(nd:int:NUMOFINT > 1) {
    if(nd:int:INT1DIST > nd:int:INT2DIST) {
        set intersect_dist to nd:int:INT2DIST.
        set intersect_time to nd:int:INT2UT.
    }
}

remove nd.

local rel_velocity is (velocityAt(ship, intersect_time):orbit - velocityAt(target, intersect_time):orbit).
local lock tgt_distance to round((target:position - ship:position):mag).

set halfBurnTime to getDeltaBurnTime(rel_velocity:mag)/2.

warpTo(intersect_time - halfBurnTime - 30).

until round(intersect_time-time:seconds) <= halfBurnTime {    
    clearScreen.
    print "Min distance " + round(intersect_dist,1) + " m." at(0,0).
    print "Cur distance " + tgt_distance + " m." at(20,0).
    print "Relative velocity " + round(rel_velocity:mag,1) + " m/s. " at(0,1).
    print "Closest approach after " + printTime(round(intersect_time-time:seconds)) at(0,2).
    print "Burn time is " + round(halfBurnTime * 2) at (0,3).
    wait 0.01.
}

kuniverse:timewarp:cancelwarp().

clearScreen.
print "Closest approach has achieved".

local function decreaseThrustOn {
    parameter coeff.
    for eng in ship:engines {
    if (eng:ignition and not eng:flameout){
        set eng:THRUSTLIMIT to eng:THRUSTLIMIT - coeff.
       }     
    }
}

local function resetEnginesThrust {
    for eng in ship:engines {
    if (eng:ignition and not eng:flameout){
        set eng:THRUSTLIMIT to 100.
       }     
    }
}

local function timeToPhaseAngle {
    local diffAngle is target_phase_angle - getPhaseAngle().
    if (diffAngle < 0) {
        set diffAngle to 360 + diffAngle.
    }
    local waitTime is (diffAngle*constant:degtorad)/(target_angular - ship_angular).
    return waitTime.
}

// Function to calculate the current phase angle between the ship and the target
local function getPhaseAngle {
        // Get the true anomalies of the ship and the target
        local shipLongitude is SHIP:LONGITUDE.
        local targetLongitude is target:LONGITUDE.

        // Convert longitudes to 0-360 degree range
        if shipLongitude < 0 {
            set shipLongitude to shipLongitude + 360.
        }
        if targetLongitude < 0 {
            set targetLongitude to targetLongitude + 360.
        }

    // Calculate the phase angle
    local phaseAngle is wrapAngle(targetLongitude - shipLongitude).
    return phaseAngle.
}

local function printTime {
    parameter totalSeconds.

    // Calculate minutes and remaining seconds
    local minutes is FLOOR(totalSeconds / 60).
    local seconds is totalSeconds - (minutes * 60).

    // Print the result
    return minutes + " minutes and " + round(seconds) + " seconds".
}

local function wrapAngle {
    parameter angle.
    // Операция взятия остатка от деления на 360
    local wrappedAngle is angle - 360 * floor(angle / 360).
    return wrappedAngle.
}

local function getDeltaBurnTime {
    parameter deltaV.
    local dV is abs(deltaV).
    local avgMass is (ship:mass*1000 + getMassAfterBurn(dV))/2.
    local avgAccel is ship:availablethrust*1000/avgMass.
    local bTime is dv/avgAccel.
    return bTime.
}

local function getMassAfterBurn {
    parameter deltaV.
    local dv is abs(deltaV).
    local Isp is 0.
    for eng in ship:engines {
       if (eng:ignition and not eng:flameout){
        set Isp to Isp + eng:isp.
       }     
    }
    return ship:mass * 1000 * constant:e^(-dv/(Isp*constant:g0)).
}


