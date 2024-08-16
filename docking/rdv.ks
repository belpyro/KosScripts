@lazyGlobal off.

clearScreen.
clearVecDraws().

if (not hasTarget) {
    print "Ship has no target. System will reboot after 3 sec.".
    wait 3.
    reboot.
}

for n in allNodes {
    remove n.
}

sas off.
rcs off.

// lock steering to retrograde.
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

if (target_phase_angle < 0) {
    set target_phase_angle to 360 + target_phase_angle.
}

local lock current_angle to getPhaseAngle().
local lock angle_eta to timeToPhaseAngle().


local nd is node(time:seconds + angle_eta, 0,0, deltaV1).
add nd.

clearScreen.
print "Node INT" + nd:int.
wait 5.

//warpto(time:seconds + timeToPhaseAngle() - brnTime*2 - 10).
local lock burn_eta to angle_eta - halfBurnTime.

lock steering to nd:burnvector.//.((deltaV1/abs(deltaV1))*prograde:vector):direction.
wait until vAng(nd:burnvector, ship:facing:forevector) <= 0.5.

warpto(time:seconds + nd:eta - 60).

wait until vAng(nd:burnvector, ship:facing:forevector) <= 0.5.
//unlock steering.

//until timeToPhaseAngle() <= brnTime {
until burn_eta < 1 {
    clearScreen.
    // print "Ship orbit velocity " + round(v1,1) at(0,1).
    // print "Transfer orbit velocity " + round(v2,1) at(0,2).
    // print "Time to transfer " + printTime(round(time_to_transfer,3)) at(0,3).
    // print "Target orbit period " + printTime(round(target:obt:period,3)) at(0,4).
    // print "Target periods " + round(time_to_transfer/target:obt:period,3) at(0,5).
    print "DeltaV " + round(deltaV1,1) at(0,0).
    // print "Ship angular " + round(ship_angular,5) at(0,7).
    // print "Target angular " + round(target_angular,5) at(0,8).
    // print "Target pre-angle " + round(target_angle_to_intercept,2) at(0,9).
    print "Target phase angle " + round(target_phase_angle,2) at(0,1).
    print "Phase angle " + round(current_angle,2) + " and waiting time " + round(angle_eta, 1) + " s." at(0,2).
    print "Burn time " + round(halfBurnTime,2) + "s." at(0,3).
    print "ETA burn " + round(nd:eta - halfBurnTime) + "s." at(0,4).
    wait 0.01.
}

local pid is pidLoop(4.5, 0.04, 0.2, 0, 1).
set pid:setpoint to 1.

wait until burn_eta <= 0.

local th is 1.
lock throttle to th.

//lock elapsed to round(((ship:obt:period/2)-time_to_transfer)/time_to_transfer,6).

until nd:deltav:mag <= 0.01 {
    if(nd:deltav:mag <= 0.1*abs(deltaV1)){
        set th to max(0.01, pid:update(time:seconds, 1 - abs(nd:deltav:mag/deltaV1))).
    }    
    wait 0.01.
}

set th to 0.
//remove nd.

// unlock steering.
// unlock throttle.

local per is 20*60.
local initialTime is (time:seconds + eta:periapsis - 10*60).
local shiftTime is 1.
local elapsedTime is 0.
local prevPos is (ship:position-target:position):mag.

until per <= 0 {
    local shift to initialTime + elapsedTime + shiftTime.

    local ship_pos is positionAt(ship, shift).
    local tgt_pos is positionAt(target, shift).           

    set elapsedTime to elapsedTime + shiftTime.
    set per to per - shiftTime.     
    
    local dist is (ship_pos-tgt_pos):mag.    
    if(dist < prevPos) { set prevPos to dist.} else { break. }   

    //log "Distance " + round(dist,2) + " m, after " + elapsedTime + " s." to "distance.log".
    wait 0.
}

remove nd.

local rel_velocity is (velocityAt(ship, initialTime+elapsedTime):orbit - velocityAt(target, initialTime+elapsedTime):orbit).
// set n to node(round(initialTime+elapsedTime), 0,0,0).
// set n:prograde to rel_velocity:x.
// set n:radialout to rel_velocity:z.
// set n:normal to rel_velocity:y.
// add n.


lock steering to (target:velocity:obt:normalized - ship:velocity:obt:normalized):direction.
//warpTo(initialTime+elapsedTime).
// local vel_v is vecDraw().

local lock tgt_distance to round((target:position - ship:position):mag).
warpTo(initialTime+elapsedTime).

until tgt_distance <= prevPos + 2000 {    
    clearScreen.
    print "Min distance " + round(prevPos,1) + " m." at(0,0).
    print "Cur distance " + tgt_distance + " m." at(20,0).
    print "Relative velocity " + round(rel_velocity:mag,1) + " m/s. " at(0,1).
    print "Closest approach after " + printTime(round(initialTime+elapsedTime-time:seconds)) at(0,2).
    print "Burn time is " + round(getDeltaBurnTime(rel_velocity:mag)) at (0,3).
    wait 0.01.
}

kuniverse:timewarp:cancelwarp().
wait 1.

local lock rel_vel to target:velocity:obt - ship:velocity:obt.
local relv_initial is rel_vel:mag.
lock steering to rel_vel:normalized.

until rel_vel:mag <= 0.01 { 
    set th to max(0.01, pid:update(time:seconds, 1 - abs(rel_vel:mag/relv_initial))).
    wait 0.01.
 }

set th to 0.
unlock steering.
unlock throttle.

run vectors.

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


