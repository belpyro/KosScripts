declare parameter targetName, targetAngle is 0.

sas off.
rcs off.
clearscreen.

when maxThrust = 0 then 
{
    wait 0.1.
    stage.
    preserve.
}

wait 1.

list targets in trgList.

local vExists to false.
for v in trgList{
    if(v:name = targetName){
        set vExists to true.
        break.
    }
}

if (vExists){  

    if (targetAngle < 0){
        set targetAngle to 180 + targetAngle.
    }

    local targetVessel to vessel(targetName).
    local calculatedAngle to calculateNeededAngle.

    // local dTime to ((tetta-1) * ship:obt:period)/360.
    // warpTo(time:seconds + dTime).

    clearScreen.

    until false
    {
        clearScreen.
        printData(calculateCurrentAngle(calculatedAngle)[0], calculatedAngle).
        local delta to round(calculateCurrentAngle(calculatedAngle)[0] - calculatedAngle).
        print "Target: " + round(targetVessel:longitude,1) + " Ship: " + round(ship:longitude,1) at(1,5).
        print "Locla diff: " + delta at(1,4).
        if(delta <= 3 and delta > 0){
            set warp to 0.
            print "Prepare to burn" at (1,7).
            break.
        }
        wait 0.01.
    }

    wait until calculateCurrentAngle(calculatedAngle)[1].

    local prg to prograde.
    lock steering to prg.
    wait until vAng(ship:facing:forevector, prg:vector) <= 0.1.

    local throttleVal to 0.
    lock throttle to throttleVal.

    local mpid to pidLoop(3, 0.0035, 0, 1e-4, 1).
    set mpid:setpoint to 1e-9.
    local lock diff to ((ship:obt:apoapsis - targetVessel:altitude)/targetVessel:altitude).

    until ship:orbit:apoapsis >= targetVessel:altitude
    {
        set throttleVal to mpid:update(time:seconds, diff).
        print "Burning" at (1,1).
        print "APO: " + round(ship:orbit:apoapsis,4) at(1,2).
        wait 0.01.
    }

    set throttleVal to 0.
    set ship:control:pilotmainthrottle to 0.

    wait 1.

    clearScreen.

    print "Finished Burn".
    wait 3.

    unlock steering.
    unlock throttle.

    print "Current Ang: " + vAng((ship:position - kerbin:position):normalized,(targetVessel:position - kerbin:position):normalized) at(1,5).
    wait 5.

function ISH {
    parameter a.
    parameter b.
    parameter ishness.
    return a - ishness < b and a + ishness > b.
}

    function calculateNeededAngle
    {
        local A1 to (targetVessel:altitude + ship:body:radius*2 + ship:altitude)/2.
        local A2 to (targetVessel:obt:semimajoraxis).
        return 180*(1-((sqrt(A1^3/A2^3)))) - targetAngle.
    }

    function calculateCurrentAngle{
        parameter exAngle.
        local tgtLng to targetVessel:longitude.
        local shipLng to ship:longitude.

        // if tgtLng < 0 { set tgtLng to tgtLng + 360. }
        // if shipLng < 0 { set shipLng to shipLng + 360. }
        local deltaAngle to mod(tgtLng - shipLng + 720, 360). //(tgtLng - shipLng).
        // if (deltaAngle < 0) {
        //     set deltaAngle to 360 + deltaAngle.
        // }

        local canBurn to abs(round(deltaAngle - exAngle)) <= 0.1.
        return list(deltaAngle, canBurn).
    }

    function printData
    {
        parameter currentAngle, neededAngle.
            
        print "Current Ship Angle: " + round(currentAngle,4) at (3, 1).
        print "Needed Angle: " + round(neededAngle,4) at (3, 2).
    }
} else 
{
    clearScreen.
    print "Vessel with name not exists".
    wait 3.
}