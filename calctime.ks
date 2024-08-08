clearScreen.


sas off.
rcs off.

set th to 0.
lock throttle to th.

if(periapsis > 0){
    print "Start deorbiting.".
    lock steering to retrograde.
    wait until vAng(ship:facing:vector, retrograde:vector) <= 0.5.

    set th to 1.
    wait until periapsis <= -100.
    set th to 0.
    clearScreen.
    print "End de-orbiting.".
    wait 1.
}

lock steering to (-ship:velocity:surface):direction.
local g is round(body:mu/(body:radius^2),3).

set initialTime to time:seconds.
set expTime to timeToImpact(60).
// set expVelocity to velocityAt(ship, initialTime + expTime).
// set terrHeight to body:geopositionof(positionAt(ship, initialTime+expTime)):terrainheight.

// clearScreen.
// print "Touchdown after " + printTime(expTime) at(1,0).
// print "With Surface speed " + round(expVelocity:surface:mag,2) at(1,1).
// print "With Surface height " + round(terrHeight,2) at(1,2).

// wait 5.

when ship:velocity:surface:mag <= 2 then {
    lock steering to up.    
}

when alt:radar <= 100 then {
    gear on.
}

lock deltaTimeToImpact to (verticalSpeed + sqrt(verticalSpeed^2 + 2 * g * (altitude - ship:geoposition:terrainheight)))/g.
lock brnTime to burningTimeWithDelta(ship:velocity:surface:mag).

set pid to pidLoop(0.2, 0.5, 0.002, 0, 1, 0.01).
set pid:setpoint to 0.1.
clearScreen.
print "Start warp to impact".

warpTo(initialTime + expTime).

until (deltaTimeToImpact - brnTime) <= 60 {
    clearScreen.
    print "Impact time " + round(deltaTimeToImpact) + "s. Burn time " + round(brnTime,2) + "s.".
    wait 0.01.
}

kuniverse:timewarp:cancelwarp().

wait until vAng((-ship:velocity:surface):normalized, ship:facing:vector) <= 1.

until ship:status = "LANDED" {
    if(alt:radar <= 100){
        set pid:setpoint to -3.
        set th to pid:update(time:seconds, verticalSpeed).
    }  else {
        set th to pid:update(time:seconds, deltaTimeToImpact-brnTime).  
    }    
    clearScreen.
    print "Setpoint is " + round(pid:setpoint, 2) at(0,0).
    print "VerticalSpeed is " + round(verticalSpeed,2) at(0,1).
    print "Th is " + round(th,2) at(0,2).
    print "Time to impact " + round(deltaTimeToImpact,2) at(0,3).
    print "Burn Time current max speed " + round(brnTime,2) at(0,4).
    print "Burn Time current vertical speed " + round(burningTimeVerticalSpeed(abs(verticalSpeed)),2) at(0,5).
    wait 0.1.
}

set th to 0.
unlock throttle.
unlock steering.

sas on.
rcs on.

declare function finalMass {
    declare parameter deltaV.
    list engines in shipEngines.
    local Isp is 0.
    for eng in shipEngines {
       if (eng:ignition and not eng:flameout){
        set Isp to Isp + eng:isp.
       }     
    }
    return ship:mass * 1000 * constant:e^(-deltaV/(Isp*constant:g0)).
}

declare function burningTimeWithDelta {
    parameter deltaV.
    local avgMass is (ship:mass*1000 + finalMass(deltaV))/2.
    local avgAccel to ship:availablethrust*1000/avgMass.
    local bTime is deltaV/avgAccel.
    return bTime.
}

declare function burningTimeVerticalSpeed {
    parameter vSpeed.
    local avgMass is (ship:mass*1000 + finalMass(vSpeed))/2.
    local pitch is ship:velocity:surface:direction:pitch.
    set verticalThrust to ship:availablethrust*1000 * COS(pitch).
    local avgAccel to verticalThrust/avgMass.
    local bTime is vSpeed/avgAccel.
    return bTime.
}

declare function printTime {
    parameter totalSeconds.

    // Calculate minutes and remaining seconds
    local minutes to FLOOR(totalSeconds / 60).
    local seconds to totalSeconds - (minutes * 60).

    // Print the result
    return minutes + " minutes and " + seconds + " seconds".
}

declare function timeToImpact {
    parameter timeStep. //default is 1 minute
    // Get initial conditions
    set altitude_exp to alt:radar.
    local impactTime is 0.

    // Main integration loop
    until altitude_exp <= 0 {
        // set timeStep to max(0.1, timeStep * (altitude_exp/basicAlt)).
        set shiftTime to initialTime + impactTime + timeStep.
        // Update altitude based on vertical speed
        set altitude_exp to (body:position - positionAt(ship, shiftTime)):mag - body:radius.
        // Accumulate time
        set impactTime to impactTime + timeStep.
        // Wait for time step duration (for simulation purposes)    
        wait 0.
    }
    return impactTime.
}