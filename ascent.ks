@lazyGlobal off.

declare parameter exAlt is 80000, exH is 25000, exAng to 30, azimuth is 90, stopAtSubOrbital is false.
wait until ship:unpacked and controlConnection:isconnected.

clearScreen.
sas off.
rcs off.

local way to heading(90, 90).
lock steering to way.

local thr to 1.
lock throttle to thr.

hudtext("Starting launch", 2, 2, 15, green, true).
wait 1.

hudtext("3", 1, 2, 15, green, true).
wait 1.
hudtext("2", 1, 2, 15, green, true).
wait 1.
hudtext("1", 1, 2, 15, green, true).
wait 1.

hudtext("Launch!!!", 1, 2, 15, green, true).
//stage.

when maxThrust <= 0 then {
    stage.
    preserve.
}

local pid to pidLoop(15, 0.0015, 0, 0, 1, 0.002).
set pid:setpoint to 0.001.

clearScreen.
until ship:status = "SUB_ORBITAL" {
    if(ship:verticalspeed >= 50){
        local head to calcAscAngle(exAng, exH).
        print "Heading angle is: " + head at(1,2).
        print "Expected ship APO: " + round(ship:apoapsis, 3) at(1,3).
        print "Current orbit ECC: " + round(ship:obt:inclination, 2) at(1,4).
        set way to heading(azimuth, head).
    }
    // print "Ship Q: " + ship:q at(1,3).
    set thr to pid:update(time:seconds, ship:apoapsis/exAlt - 1).
    wait 0.01.
}

set thr to 0.

clearScreen.
print "Waiting apo " + round(eta:apoapsis, 2) + " sec." at(1,1).
wait 1.

set way to heading(azimuth,0).
wait until vAng(ship:facing:forevector, way:vector) <= 0.1.

if(not stopAtSubOrbital) {
    warpto(time:seconds+eta:apoapsis-10).
    wait until eta:apoapsis <= 1.
    set warp to 0.

    set pid:minoutput to 0.
    set pid:setpoint to 0.
    set pid:kp to 3.
    set pid:kd to 0.0065.
    set pid:epsilon to 0.

    local circInfo to apoBurn().
    local neededDelta to circInfo[2].
    local initDelta to neededDelta.
    print "Circ DeltaV is: " + neededDelta.

    // circularize orbit on Apo
    until neededDelta <= 0 {
        set circInfo to apoBurn().
        set neededDelta to circInfo[2].
        clearScreen.
        print "Circ DeltaV is: " + neededDelta.
        set way to heading(azimuth, circInfo[0]).
        if(neededDelta <= 0.2*initDelta) {
            set thr to pid:update(time:seconds, round(neededDelta/initDelta, 3) - 1).
        } else {
            set thr to 1.
        }
        
        wait 0.01.
    }

    clearScreen.
    print "Circularization ended!".

    set thr to 0.
    wait 1.
    unlockAll().    
} else {
    clearScreen.
    print "Sub-Orbit Achived".
}



