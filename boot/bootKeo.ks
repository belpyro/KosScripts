wait until ship:unpacked and controlConnection:isconnected.

copyPath("0:/coreLib.ks","1:").
copyPath("0:/circToApo.ks","1:").
copyPath("0:/ascent.ks","1:").
copyPath("0:/makeOrbit.ks","1:").
copyPath("0:/byP.ks","1:").
copyPath("0:/deorbit.ks","1:").

switch to 1.

runOncePath("coreLib").

wait 1.
clearScreen.

run ascent.
// launch and circ
// todo
wait 1.

print "Deploy panels and antennas".

panels on.
//openAntennas().

// wait 1.
// run circToApo.

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

    if(x = 3){
        // print "Deorbit and kill".
        // wait 3.
        // deadVessel().
        wait 1.
        print "Bye Bye!".
        shutdown.
    }

    wait 3.
    print "Start to deorbit of 2/3 current period".
    runPath("deorbit", 2/3).

    clearScreen.
    wait 1.
    print "Deorbit finished. Start circularization".   
    runPath("circToApo").
}

// function deadVessel {
//     lock steering to retrograde.
//     wait until vAng(ship:facing:forevector, retrograde:vector) <= 1.
//     lock throttle to 1.
//     wait until ship:obt:periapsis <= 30000.
//     lock throttle to 0.
//     UnlockAllFunc().
// }

function deployProbe {
    local direction to prograde + r(0,90,0).
    lock steering to direction.
    wait until vAng(ship:facing:forevector, direction:vector) <= 1.
    wait 1.
    stage.
    unlock steering.
}





