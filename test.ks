// sas off.
// rcs off.

// Initial conditions
set deltaTime to 10. // Time step in seconds
set mainAlt to alt:radar. // Initial altitude
set mainSpeed to ship:verticalspeed. // Initial vertical speed
// set mass to ship:mass. // Initial mass of the spacecraft

// Calculate effective exhaust velocity
lock g to body:mu / (body:radius + mainAlt)^2.

// Function to update position and velocity using Euler method
function eulerStep {
    parameter currentAlt, currentSpeed, dt.

    // Update velocity and position
    set newVerticalSpeed to currentSpeed - g * dt.
    set newAltitude to currentAlt + newVerticalSpeed * dt.

    return list(newAltitude, newVerticalSpeed).
}

// Main loop to calculate impact time
print "Calculating impact time...".

set timeElapsed to 0.

until mainAlt <= 0 {
    if(mainAlt <= 10000) set deltaTime to 1.

    // Update position and velocity using Euler method
    set result to eulerStep(mainAlt, mainSpeed, deltaTime).
    set mainAlt to result[0].
    set mainSpeed to result[1].

    // Increment time
    set timeElapsed to timeElapsed + deltaTime.

    // Print status
    print "Time: " + round(timeElapsed, 1) + "s, Altitude: " + round(mainAlt, 2) + "m, Vertical Speed: " + round(mainSpeed, 2) + "m/s".

    wait 0.1.
}

print "Impact time: " + round(timeElapsed, 1) + " seconds.".
set fVel to velocityAt(ship, time:seconds + timeElapsed).
print "Surface Vel " + fVel:surface:mag + " m/s".
print "Orbit Vel " + fVel:orbit:mag + " m/s".