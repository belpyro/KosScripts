// @lazyGlobal off.

clearScreen.

sas off.
rcs off.

if (hasTarget)
{
     set optimalAngle to wrapAngle(calculateOptimalPhaseAngle()).

    //  until ABS(wrapAngle(currentPhaseAngle2() - optimalAngle)) < 1 {
    //     // Get the longitudes of the ship and the target
    //             clearScreen.
    //     print "Optimal phase angle " + round(optimalAngle,1) at(0,0).
    //     print "Current phase angle " + round(currentPhaseAngle2(),1) at(0,2).
    //     wait 1.
    // }

    // kuniverse:timewarp:cancelwarp().

    // print "Optimal phase angle reached. Ready for transfer burn.".

    // lock steering to retrograde.
    set r1 to SHIP:OBT:semimajoraxis.
    set r2 to target:OBT:semimajoraxis.
    set a to (r1+r2)/2.
    set mu to SHIP:BODY:MU.

    // Calculate delta-v for Hohmann transfer
    set v1 to SQRT(mu / r1).
    set v2 to SQRT(mu * (2 / r1 - 1 / a)).
    set deltaV1 to v2 - v1.

    set time_to_transfer to constant:pi*sqrt(a^3/mu).
    set ship_angular to sqrt(mu/r1^3).
    set target_angular to sqrt(mu/r2^3).
    set target_angle_to_intercept to wrapAngle(target_angular*time_to_transfer*constant:radtodeg).
    set target_phase_angle to 180 - target_angle_to_intercept.
    set brnTime to burningTimeWithDelta(abs(deltaV1))/2.

    if (target_phase_angle < 0) {
        set target_phase_angle to 360 + target_phase_angle.
    }

    lock current_angle to currentPhaseAngle2().
    // lock waitTime to (target_phase_angle - current_angle)*constant:degtorad/(target_angular - ship_angular).
    
    // if (waitTime < 0) {
    //     set waitTime to target:obt:period + waitTime.
    // }

    warpto(time:seconds + calcTime() - brnTime*2).
    
    lock steering to ((deltaV1/abs(deltaV1))*prograde:vector):direction.

    until calcTime() <= brnTime {
        clearScreen.
        print "Optimal Angle (wip) " + round(optimalAngle,1) at(0,0).
        print "Ship orbit velocity " + round(v1,1) at(0,1).
        print "Transfer orbit velocity " + round(v2,1) at(0,2).
        print "Time to transfer " + printTime(round(time_to_transfer,3)) at(0,3).
        print "Target orbit period " + printTime(round(target:obt:period,3)) at(0,4).
        print "Target periods " + round(time_to_transfer/target:obt:period,3) at(0,5).
        print "DeltaV " + round(deltaV1,1) at(0,6).
        print "Ship angular " + round(ship_angular,5) at(0,7).
        print "Target angular " + round(target_angular,5) at(0,8).
        print "Target pre-angle " + round(target_angle_to_intercept,2) at(0,9).
        print "Target phase angle " + round(target_phase_angle,2) at(0,10).
        print "Phase angle " + round(current_angle,2) + " and waiting time " + round(calcTime(), 1) + " s." at(0,11).
        print "Burn time " + round(brnTime,2) + "s." at(0,12).
        wait 0.1.
    }

    set pid to pidLoop(0.001, 0, 0, 1, 0).
    set pid:setpoint to 1e-5.

    set th to 1.
    lock throttle to th.

    lock elapsed to round(((ship:obt:period/2)-time_to_transfer)/time_to_transfer,6).

    until elapsed <= 1e-6 {
        clearScreen.
        print "Elapsed " + elapsed.
        //if (elapsed <= 0.01) { set th to elapsed*10. }
        // set th to elapsed.//pid:update(time:seconds, elapsed).
        // log "Th " + th + " . In time " + time:seconds + " when elapsed " + elapsed to "pid.log".
        wait 0.01.
    }

    set th to 0.
    unlock steering.
    unlock throttle.

    set per to 20*60.
    set initialTime to (time:seconds + eta:periapsis - 10*60).
    set shiftTime to 1.
    set elapsedTime to 0.
    set prevPos to (ship:position-target:position):mag.
    
    until per <= 0 {
        set shift to initialTime + elapsedTime + shiftTime.

        set ship_pos to positionAt(ship, shift).
        set tgt_pos to positionAt(target, shift).           

        set elapsedTime to elapsedTime + shiftTime.
        set per to per - shiftTime.     
        
        set dist to (ship_pos-tgt_pos):mag.    
        if(dist < prevPos) { set prevPos to dist.} else { break. }   

        log "Distance " + round(dist,2) + " m, after " + elapsedTime + " s." to "distance.log".
        wait 0.
    }

    set rel_velocity to (velocityAt(ship, initialTime+elapsedTime):orbit - velocityAt(target, initialTime+elapsedTime):orbit).
    // set n to node(round(initialTime+elapsedTime), 0,0,0).
    // set n:prograde to rel_velocity:x.
    // set n:radialout to rel_velocity:z.
    // set n:normal to rel_velocity:y.
    // add n.
    lock steering to (target:velocity:obt:normalized - ship:velocity:obt:normalized):direction.
    warpTo(initialTime+elapsedTime).
    set vel_v to vecDraw().

    clearScreen.
    until false {
        print "Min distance " + round(prevPos,1) + " m." at(0,0).
        print "Relative velocity " + round(rel_velocity:mag,1) + " m/s. " at(0,1).
        print "Closest approach after " + printTime(round(initialTime+elapsedTime-time:seconds)) at(0,2).
        print "Burn time is " + round(burningTimeWithDelta(rel_velocity:mag)) at (0,3).
        set vel_v:vec to (target:velocity:obt:normalized - ship:velocity:obt:normalized)*100.
        set vel_v:show to true.
        wait 1.
    }


    // set n to node(0,0,0,-deltaV1).
    // add n.
    

    // until false {
    //     clearScreen.
    //     print "Optimal phase angle " + round(optimalAngle,1) at(0,0).
    //     print "Current phase angle " + round(currentPhaseAngle(),1) at(0,1).
    //     print "Current phase angle2 " + round(currentPhaseAngle2(),1) at(0,2).
    //     wait 0.1.
    // }
}

function calcTime {
    local diffAngle is target_phase_angle - currentPhaseAngle2().
    if (diffAngle < 0) {
        set diffAngle to 360 + diffAngle.
    }
    local waitTime is (diffAngle)*constant:degtorad/(target_angular - ship_angular).
    return waitTime.
}

declare function currentPhaseAngle{
    return wrapAngle(vAng(body:position-ship:position,body:position-target:position)).
}

// Function to calculate optimal phase angle
function calculateOptimalPhaseAngle {
    /// Get the semi-major axis of the chaser and target orbits
    set r1 to SHIP:OBT:semimajoraxis.
    set r2 to target:OBT:semimajoraxis.

    // Calculate the semi-major axis of the transfer orbit
    set a_transfer to (r1 + r2) / 2.

    // Calculate the orbital period of the transfer orbit
    set mu to SHIP:BODY:MU.
    set T_transfer to 2 * CONSTANT:PI * sqrt(a_transfer^3 / mu).

    // Calculate the angular travel of the target during the transfer time
    set target_orbital_period to 2 * CONSTANT:PI * sqrt(r2^3 / mu).
    set target_travel_angle to (360 * T_transfer) / target_orbital_period.

    // Calculate the optimal phase angle
    set phaseAngle to 180 - target_travel_angle.

    // Ensure the phase angle is between 0 and 360 degrees
    return wrapAngle(phaseAngle).
}


// Function to calculate the current phase angle between the ship and the target
function currentPhaseAngle2 {
        // Get the true anomalies of the ship and the target
        set shipLongitude to SHIP:LONGITUDE.
        set targetLongitude to target:LONGITUDE.

        // Convert longitudes to 0-360 degree range
        if shipLongitude < 0 {
            set shipLongitude to shipLongitude + 360.
        }
        if targetLongitude < 0 {
            set targetLongitude to targetLongitude + 360.
        }

    // Calculate the phase angle
    set phaseAngle to wrapAngle(targetLongitude - shipLongitude).

    return phaseAngle.
}

function printTime {
    parameter totalSeconds.

    // Calculate minutes and remaining seconds
    local minutes to FLOOR(totalSeconds / 60).
    local seconds to totalSeconds - (minutes * 60).

    // Print the result
    return minutes + " minutes and " + round(seconds) + " seconds".
}

function wrapAngle {
    parameter angle.
    // Операция взятия остатка от деления на 360
    set wrappedAngle to angle - 360 * floor(angle / 360).
    return wrappedAngle.
}

function burningTimeWithDelta {
    parameter deltaV.
    local avgMass is (ship:mass*1000 + finalMass(deltaV))/2.
    local avgAccel to ship:availablethrust*1000/avgMass.
    local bTime is deltaV/avgAccel.
    return bTime.
}

function finalMass {
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

//from MechJeb
function getPrograde {
    parameter ut.
    local rel_v is velocityAt(ship, ut).
    local rel_v_xzy is V(rel_v:x, rel_v:z, rel_v:y).
    return rel_v_xzy:normalized.
}

