wait until ship:unpacked and controlConnection:isconnected and ship:status = "ORBITING".

copyPath("0:/coreLib.ks","").
copyPath("0:/ascent.ks","").
copyPath("0:/circToApo.ks","").
copyPath("0:/ascent.ks","").
copyPath("0:/makeOrbit.ks","").
copyPath("0:/byP.ks","").
copyPath("0:/deorbit.ks","").

runOncePath("coreLib").

wait 1.
clearScreen.

// launch and circ
// todo

print "Deploy panels and antennas".

panels on.
openAntennas().

wait 3.

when ship:maxthrust <= 0 then {
    stage.
}

// go to keo
print "Run transfer to keo-stationary orbit".
runPath("byP", ship:body:rotationPeriod).

wait 1.

print "Circularization finished".
wait 1.

FROM {local x is 1.} UNTIL x = 4 STEP {set x to x+1.} DO {
    clearScreen.

    print "Deploy " + x + " probe".
    deployProbe().

    wait 3.
    print "Start to deorbit of 2/3 current period".
    runPath("deorbit", 2/3).

    clearScreen.
    wait 1.
    print "Deorbit finished. Start circularization".   
    runPath("circToApo").
}

function deployProbe {
    local direction to prograde + r(0,90,0).
    lock steering to direction.
    wait until vAng(ship:facing:forevector, direction:vector) <= 1.
    wait 1.
    stage.
    unlock steering.
}





