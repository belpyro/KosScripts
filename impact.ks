function getG {
    parameter currentAlt.
    return body:mu/((body:radius + currentAlt)^2).
}

// Function to calculate time to impact using numerical integration
function timeToImpact {
    parameter timeStep.
    // Get initial conditions
    set altitude_exp to alt:radar.
    local impactTime is 0.

    // Main integration loop
    until altitude_exp <= 0 {
        set shiftTime to time:seconds + impactTime + timeStep.
        // Update altitude based on vertical speed
        set altitude_exp to (body:position - positionAt(ship, shiftTime)):mag - body:radius.
        // Accumulate time
        set impactTime to impactTime + timeStep.
        // If vertical speed is zero or positive (ascending), exit loop
        if vSpeed >= 0 {
            return -1.
        }
        // Wait for time step duration (for simulation purposes)
        wait 0.
    }
    return impactTime.
}

declare function timeToImpactTrajectory {
    // Solve the quadratic equation for time to impact
    // h(t) = h_0 + v_0 t - 1/2 g t^2
    // 0 = h_0 + v_0 t - 1/2 g t^2
    // a = -1/2 g, b = v_0, c = h_0
    set a to -0.5 * getG(0).
    set b to verticalSpeed.
    set c to alt:radar.

    // Calculate the discriminant
    set discriminant to b^2 - 4 * a * c.

    // If discriminant is negative, no real roots (no impact)
    if discriminant < 0 {
        print "No impact (discriminant < 0).".
        return -1.
    }

    // Calculate the two potential impact times
    set t1 to (-b + sqrt(discriminant)) / (2 * a).
    set t2 to (-b - sqrt(discriminant)) / (2 * a).
    print "t1 " + t1 + " t2 " + t2.
    return max(0, max(t1,t2)).
}

// Function to convert seconds into minutes and seconds and print the result
function printTime {
    parameter totalSeconds.

    // Calculate minutes and remaining seconds
    local minutes to FLOOR(totalSeconds / 60).
    local seconds to totalSeconds - (minutes * 60).

    // Print the result
    return minutes + " minutes and " + seconds + " seconds".
}

// Main loop
clearscreen.
print "Calculating time to impact...".
set impactTime to timeToImpact().
set impactVelocity to velocityAt(ship, impactTime - 1):surface:mag.
print "Time to impact: " + printTime(impactTime - 1) + " With speed " + impactVelocity + " m/s".
warpto(time:seconds + impactTime - 10).