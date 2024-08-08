runOncePath("coreLib").

clearScreen.
print "Wait target".

wait until ship:unpacked and hastarget and ship:status = "orbiting".

clearScreen.

if (not addons:available("KER")){
  print "KER Addon NOT installed!!!" at (1,1).
  wait 3.
  reboot.
}

sas off.
rcs off.

set rdzv to addons:ker:rdzv.
set n to nextNode.
// set ts to timespan(n:bt + time:seconds).

until false {
  if (hasTarget){
    print "RELATIVE INC: " + ship:obt:relinc at(0,0).
    print "ANGLE OF AN:  " + ship:obt:angofan at(0,1).
    print "ANGLE OF DN:  " + ship:obt:angofdn at(0,2).
    print "RELATIVE INC: " + ship:obt:relinc at(0,3).
    print "INTERSECT INFO: " + n:int at(0,4).
  }
  wait 0.02.
}

// lock steering to TargetVelMinus:direction.
set mtr to 0.
lock throttle to mtr.

// wait until vAng(ship:facing:forevector, TargetVelMinus) < 0.5.



// warpTo(time:seconds + rdzv:TIMETILENCOUNTER - 30).

// make transfer orbit 200km
set expectedAPO to 200 * 1000.
set pid to pidLoop(5, 0.015, 0.025, 0.001, 1, 1e-5).
set pid:setpoint to 0.



set mtr to 0.
lock throttle to mtr.
// shutdown.

// until not canContinue {
//     printData.
//     until RelativeVel <= 0.1 {
//             set mtr to pid:update(time:seconds, -RelativeVel).
//             wait 0.01.
//     }
//     set mtr to 0. 
//     set canContinue to false.
// }

// set neededVector to TargetPlus - prograde:vector.
// lock steering to neededVector:direction.

// wait until vAng(neededVector, ship:facing:forevector) <= 0.5.

set timeEncounter to round(rdzv:TIMETOTRANS).

// if (timeEncounter > 600) { warpTo(time:seconds + timeEncounter - 600). }

// lock steering to retrograde.
// set intialDeltaPE to round(obt:periapsis - target:obt:periapsis).

// set deltaPh to 180 - rdzv:pha.
// set tgtTime to (360/target:obt:period)*deltaPh.

//set anomal to 

// wait until round(rdzv:TIMETOTRANS) <= 600.

set timeEncounter to round(rdzv:TIMETOTRANS).

set n to node(time:seconds + timeEncounter, 0,0,0).
add n.

lock info to rdzv:INTINFO(n:obt, target:obt).

set D1 to info:int1dist.
set D2 to V(0,0,0).
set canContinue to true.
set startBurn to false.
set datalex to lexicon().

until not canContinue {
  if (n:obt:periapsis <= 71 * 1000) { set canContinue to false. break. }

if(info:int1dist > 50000 and info:int1dist > 0){
  set n:prograde to n:prograde - 1.
  } else {
    set n:prograde to n:prograde - 0.1.
  }  
    
  if(info:int1dist < 30000 and info:int1dist > 0){
    set datalex[round(info:int1dist)] to n:prograde.    
  }

  if (info:int2dist > 0 and info:int2dist < 30000) {
    set datalex[round(info:int2dist)] to n:prograde.
  }
    
  // printData.
  wait 0.01.
}

if (datalex:length <= 0) reboot.

set keys to datalex:keys.

set minVal to keys[0].
for key in keys {
  if (key < minVal) {
    set minVal to key.
  }
}

clearScreen.
set burnVector to datalex[minVal].
print "MinVal is " + minVal.
print "Retrograde is " + burnVector.

remove n.
set n to node(time:seconds + round(rdzv:TIMETOTRANS),0,0, burnVector).
add n. 

runPath("exeNode").
runPath("rndz").
//set n:deltav to datalex[minVal].
wait 3.

// remove n.


// set D2 to info:int2dist.

// set oldTime to time:seconds.


// when periapsis <= 71 * 1000 then {
//   set canContinue to false.
// }

// when rdzv:INTINFO:numofint > 1 then {
//   set D2 to rdzv:INTINFO:int2dist.
//   print "Initial D2: " + round(D2) at (0,11).
// }

// when round(rdzv:TIMETOTRANS) <= 0.5 then {
//   set startBurn to true.
// }

// // when (info:int1ut - time:seconds) < 1 then {
// //   set canContinue to false.
// // }

// until not canContinue {
//     printData.

//     if( info:int1dist > 50000 and startBurn ) { set mtr to 1. } else if ( startBurn ) { set mtr to 0.1. }
//     // set mtr to 0.1.

//     // if (D1 > info:int1dist) { set D1 to info:int1dist. }// else if (D1 < D2) { set canContinue to false. }
//     // if (D2 > info:int2dist) { set D2 to info:int2dist. }// else if (D2 > 0 and D2 < D1) { set canContinue to false. }

//     // // set minDist to D1.
//     // if (info:numofint > 1) {
//     //   set minDist to min(D1, D2).
//     //   print "MinDist: " + round(minDist) at(0, 11).
//     // } 

//     // set canContinue to minDist > 2000.
//     // until round(obt:periapsis - target:obt:periapsis)/intialDeltaPE <= 1e-3 {
//     //   set mtr to pid:update(time:seconds, -round(obt:periapsis - target:obt:periapsis)/intialDeltaPE).
//     //   wait 0.01.
//     // }   
    
//     // set mtr to 0.
//     //unlock throttle.

//     wait 0.01.
// } 

// set canContinue to true.

// until not canContinue {
//   set VRel to ship:velocity:obt - target:velocity:obt.
//   set VDes to (target:obt:position - ship:obt:position)/20.
//   set VCor to VDes - VRel.
//   lock steering to VCor.

//   set mtr to 0.1.
//   wait 0.1.
// }

set mtr to 0.
unlock throttle.
unlock steering.

// until targetDistance <= 50 {
//    until RelativeVel >= 10 {
//       set mtr to 0.1.
//       wait 0.01.   
//    }
//    set mtr to 0.
// }


function printData {
   clearScreen.
   print "Phase Angle:              " + round(rdzv:pha,1) at(0, 1). 
   print "Transfer Angle:           " + round(rdzv:INTERCEPTANGLE,2) at(0, 2). 
   print "Count of intersects:      " + info:numofint at(0, 3). 
   print "Time to Intersect 1:      " + (info:int1ut - time:seconds) at(0, 4). 
   print "Dist on Intersect 1:      " + info:int1dist at(0, 5). 
   print "Time to Intersect 2:      " + info:int2ut at(0, 6). 
   print "Dist on Intersect 2:      " + info:int2dist at(0, 7). 
   print "Next closest distance:    " + round(rdzv:encsep) at(0, 8). 
   print "Elapsed Time Encounter:   " + round(rdzv:TIMETILENCOUNTER) at(0, 9). 
   print "Time till transfer angle: " + round(rdzv:TIMETOTRANS,2) at(0, 10). 
   print "D1: " + D1 at(0, 11). 
   print "D2: " + D2 at(0, 12). 
}



