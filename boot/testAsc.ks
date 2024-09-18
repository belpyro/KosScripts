// SET CONFIG:STAT TO TRUE.
wait until ship:unpacked and controlConnection:isconnected.

switch to 1.
clearScreen.
copyPath("0:/coreLib.ks","1:").
copyPath("0:/ascent.ks","1:").
copyPath("0:/circToApo.ks","1:").
copyPath("0:/byP.ks","1:").
// copyPath("0:/ciklogramm.ks","").

// when ship:altitude >= 50000 then { ag1 on. }
// when ship:SOLIDFUEL <= 0.1 then { stage. }

wait 3.
runOncePath("coreLib").

//циклограмма
//1 - вывод на орбиту
//2 - скругление
runPath("ascent").

wait 1.

// go to keo
print "Run transfer to keo-stationary orbit".
runPath("byP", ship:body:rotationPeriod).
//openAntennas().

// if(ship:obt:eccentricity > 1e-5)
// {
//     //3 - идеальное скругление
//     runPath("circToApo").
// }

// addons:astrogator:create(mun).

// until hasNode = false {
//   runPath("execNode").  
// }

// clearScreen.
// print "NextPath ETA: " + ship:obt:nextpatcheta at(1,1).

// if ship:obt:nextpatcheta > 60 {
//     warpTo(time:seconds + ship:obt:nextpatcheta - 10).
// }

// wait until ship:body:name = "Mun".
// addons:astrogator:create(mun).
// runPath("execNode").

// wait 1.
// run transfer.
// lock steering to heading(90,90).


// wait 1.
// panels on.

// wait until vAng(ship:facing:forevector, heading(90,90):vector) <= 5.
// runPath("ciklogramm", "sat1").

// wait 5.
// stage.

// wait 5.
// stage.

// wait 5.
// lock steering to retrograde.
// wait vAng(ship:facing:forevector, retrograde:vector) <= 0.5.

// lock throttle to 1.
// when ship:liquidfuel <= 0.1 then { shutdown. }

// LOG PROFILERESULT() TO profile.csv.
// copyPath("profile.csv", "0:/profile.csv").

// until false {}
