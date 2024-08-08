runOncePath("coreLib").

declare parameter apo is 0.

set apo to apo * 1000. //convert to metters

local continue to apo > 0.

if (continue) {

    clearScreen.
    print "Prepare burning".
    sas off.
    rcs off.

    when maxThrust <= 0 then {
            stage.
            preserve.
        }

// if (IsRange(obt:apoapsis, obt:periapsis, expectedAPO)){
//     run makeOrbit(expectedAPO).
//     run circToApo.
// } else if (obt:apoapsis > expectedAPO) {
//     if (obt:periapsis <= expectedAPO) {
//         warpTo(time:seconds + eta:apoapsis - 35).
//         wait until eta:apoapsis <= 30.

//         lock steering to prograde.
//         wait until vAng(ship:facing:forevector, prograde:vector) < 0.5.        
//         wait until eta:apoapsis <= 1.
//         set warp to 0.

//         set canContinue to ship:obt:periapsis < expectedAPO.

//         until not canContinue {
//             set mtr to pid:update(time:seconds, ship:obt:periapsis).    
//             set canContinue to ship:obt:periapsis < expectedAPO.
//             wait 0.01.
//         }

//     } else {
//         set pid:setpoint to 0.
//         set canBurn to true.

//         if (obt:eccentricity >= 1e-3){
//           set canBurn to false.
//           set deltaTime to eta:apoapsis - 60.
//           if (deltaTime <= 0) { set deltaTime to obt:period - 60 + eta:apoapsis. }
//           warpTo(time:seconds + deltaTime).
//           wait until eta:apoapsis <= 60.
//         }       

//         set warp to 0.
//         lock steering to retrograde.
//         wait until vAng(ship:facing:forevector, retrograde:vector) < 0.5.        
//         wait until eta:apoapsis <= 1 or canBurn.
//         set warp to 0.
//         set canBurn to false.
//         set canContinue to true.
//         set startDeltaPE to ship:obt:periapsis - expectedAPO. 
//         until not canContinue {
//             set currentPercent to (expectedAPO - ship:obt:periapsis)/startDeltaPE.
//             set mtr to pid:update(time:seconds, currentPercent).    
//             set canContinue to abs(currentPercent) >= 1e-3.

//             clearScreen.
//             print "Current Percent:  " + round(currentPercent,4) at(0,0).
//             print "Current Throttle: " + round(mtr,4) at(0,1).
//             print "CanContinue:      " + canContinue at(0,3).

//             wait 0.01.
//         }
//     }  

//     set mtr to 0.
//     set ship:control:pilotmainthrottle to 0.
//     unlock steering.
//     unlock throttle.

//     run circToPe.  
// }

    local pid to pidLoop(3, 0.0015, 0, 0.0001, 1).
    set pid:setpoint to 1e-6.

    local pgd to prograde.
    lock steering to pgd.

    print "Set burning vector".
    wait until vAng(ship:facing:forevector, pgd:vector) <= 0.1.
    print "Start burning".
    wait 1.    

    local mTr to 0.
    lock throttle to mTr.

    until apo <= ship:apoapsis{
        set mTr to pid:update(time:seconds, (ship:apoapsis - apo)/apo).
        wait 0.001.
    }

    set mTr to 0.
    set ship:control:pilotmainthrottle to 0.

    unlock throttle.
    unlock steering.

    print "Finished!" at(1,1).
    print "APO: " + ship:apoapsis at(1,2).

    wait 5.
}

// pe > input -> ap > input 300km - 100km - 200 km -> down PE -> circToPE 
// pe < input -> ap > input 300km - 100rm - 80km -> up PE -> circToPE
// ap < input -> pe < input 80km - 100 km - 80 km -> up APO -> circToApo

function downPeriapsisAndCirc {

}

function upPeriapsisAndCirc {

}

function upApoapsisAndCirc {

}
