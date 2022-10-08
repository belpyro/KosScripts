declare parameter exAlt is 80000, exH is 25000, exAng to 30.
wait until ship:unpacked and controlConnection:isconnected.

clearScreen.
sas off.
rcs off.

local way to up.
lock steering to way.

local thr to 1.
lock throttle to thr.

hudtext("Starting launch", 2, 2, 15, green, true).
wait 5.

hudtext("3", 1, 2, 15, green, true).
wait 1.
hudtext("2", 1, 2, 15, green, true).
wait 1.
hudtext("1", 1, 2, 15, green, true).
wait 1.

hudtext("Launch!!!", 1, 2, 15, green, true).
stage.

when maxThrust <= 0 then {
    stage.
    preserve.
}

local pid to pidLoop(15, 0.0015, 0, 0, 1, 0.002).
set pid:setpoint to 0.001.

clearScreen.
until ship:status = "SUB_ORBITAL"{
    if(ship:verticalspeed >= 50){
        local head to calculateAscentAngle(exAng, exH).
        print "Heading angle is: " + head at(1,2).
        set way to heading(90, head).
    }
    print "Ship Q: " + ship:q at(1,3).
    set thr to pid:update(time:seconds, ship:apoapsis/exAlt - 1).
    wait 0.01.
}

set thr to 0.

clearScreen.
print "Waiting apo" at(1,1).
wait 1.

set way to heading(90,0).
wait until vAng(ship:facing:forevector, way:vector) <= 0.1.

warpto(time:seconds+eta:apoapsis-10).
wait until eta:apoapsis <= 1.
set warp to 0.

set pid:minoutput to 0.001.
set pid:setpoint to 1e-5.
set pid:kp to 3.
set pid:kd to 0.0065.
set pid:epsilon to 0.

local lastTime to time:seconds.
local circInfo to ApoBurnFunc().
local startDeltaV to circInfo[2].

// circularize orbit on Apo
until startDeltaV <= 0 {
    set circInfo to ApoBurnFunc().
    set startDeltaV to circInfo[2].
    set way to heading(90, circInfo[0]).
    set thr to pid:update(time:seconds, -ship:obt:eccentricity).
    if(time:seconds - lastTime >= 1){
        set lastTime to time:seconds.
        log circInfo[1] to circLog.
    }
    wait 0.01.
}

set thr to 0.
UnlockAllFunc().

copyPath("1:/circLog","0:/circLog.txt").

function calculateAscentAngle {
    local parameter neededAngle.
    local parameter neededAlt.
    local percentOfAlt to ship:altitude/neededAlt.
    local pushAngle to 90-neededAngle.
    return max(0, round(90 - pushAngle*(percentOfAlt^(1/2)),1)).
}

