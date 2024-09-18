clearScreen.

when maxThrust <= 0 then {
    stage.
    preserve.
}

set nd to nextnode.
//print out node's basic parameters - ETA and deltaV
print "Node in: " + round(nd:eta) + ", DeltaV: " + round(nd:deltav:mag).

//calculate ship's max acceleration
set max_acc to ship:maxthrust/ship:mass.

// Now we just need to divide deltav:mag by our ship's max acceleration
// to get the estimated time of the burn.
//
// Please note, this is not exactly correct.  The real calculation
// needs to take into account the fact that the mass will decrease
// as you lose fuel during the burn.  In fact throwing the fuel out
// the back of the engine very fast is the entire reason you're able
// to thrust at all in space.  The proper calculation for this
// can be found easily enough online by searching for the phrase
//   "Tsiolkovsky rocket equation".
// This example here will keep it simple for demonstration purposes,
// but if you're going to build a serious node execution script, you
// need to look into the Tsiolkovsky rocket equation to account for
// the change in mass over time as you burn.
//
set burn_duration to nd:deltav:mag/max_acc.
print "Crude Estimated burn duration: " + round(burn_duration) + "s".

warpto(time:seconds+nd:eta - (burn_duration/2 + 60)).
wait until nd:eta <= (burn_duration/2 + 60).

set np to nd:deltav. //points to node, don't care about the roll direction.
lock steering to np.

//now we need to wait until the burn vector and ship's facing are aligned
wait until vang(np, ship:facing:vector) < 0.25.

//the ship is facing the right direction, let's wait for our burn time
wait until nd:eta <= (burn_duration/2).

//we only need to lock throttle once to a certain variable in the beginning of the loop, and adjust only the variable itself inside it
set tset to 0.
lock throttle to tset.

set done to False.
//initial deltav
set dv0 to nd:deltav.
until done
{
    //recalculate current max_acceleration, as it changes while we burn through fuel
    set max_acc to ship:maxthrust/ship:mass.

    //throttle is 100% until there is less than 1 second of time left to burn
    //when there is less than 1 second - decrease the throttle linearly
    set tset to min(nd:deltav:mag/max_acc, 1).

    //here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
    //this check is done via checking the dot product of those 2 vectors
    if vdot(dv0, nd:deltav) < 0
    {
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        lock throttle to 0.
        break.
    }

    //we have very little left to burn, less then 0.1m/s
    if nd:deltav:mag < 0.1
    {
        print "Finalizing burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        //we burn slowly until our node vector starts to drift significantly from initial vector
        //this usually means we are on point
        wait until vdot(dv0, nd:deltav) < 0.5.

        lock throttle to 0.
        print "End burn, remain dv " + round(nd:deltav:mag,1) + "m/s, vdot: " + round(vdot(dv0, nd:deltav),1).
        set done to True.
    }
}
unlock steering.
unlock throttle.
wait 1.

//we no longer need the maneuver node
remove nd.

//set throttle to 0 just in case.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.

// set BurnTime to (Node:deltav:mag*mass)/availablethrust.
// set NodedV0 to Node:deltav.

// clearscreen.

// //display info
// set running to true.
// when running = true then {
//     print "Total maneuver delta-V: "+ round(NodedV0:mag,1)+" m/s       " at (0,3).
//     print "Remaining maneuver delta-V: "+round(Node:deltav:mag,1)+" m/s       " at (0,4).
//     print "Running: uExeNode" at (0,6).
//     preserve.
// }


// rcs on.
// sas off.
// set throttle to 0.


// //staging
// set InitialStageThrust to maxthrust.
// when maxthrust<InitialStageThrust then {
// 	wait 1.
// 	stage.
// 		if maxthrust > 0 {
// 		set InitialStageThrust to maxthrust.
// 	}
// 	preserve.
// }


// wait 1.
// lock steering to Node:deltav.
// set warpmode to "rails".
// print "Warping to burn point" at (0,0).
// set BurnMoment to time:seconds + Node:eta.
// warpto(BurnMoment-BurnTime/2-WarpStopTime).

// wait until vang(ship:facing:forevector,steering) <  1 and time:seconds > BurnMoment-BurnTime/2.
// 	lock throttle to 1.
//     print "Burn started                  " at (0,0).

// wait until Node:deltav:mag/NodedV0:mag < 0.05.
//     lock throttle to 0.1.

// wait until vdot(NodedV0, Node:deltav) < 0.
//    	lock throttle to 0.
//     print "Burn completed" at (0,0).

//     rcs off.
//     sas on.
// 	unlock steering.
// 	lock throttle to 0. 
//     unlock throttle.
//     remove Node.
//     set running to false.
// 	clearscreen.
//     set ship:control:pilotmainthrottle to 0.