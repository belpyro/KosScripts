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
lock intersectInfo to rdzv:INTINFO(ship:obt, target:obt).

set point to intersectInfo:int1dist.
set dt to intersectInfo:int1ut.

if (intersectinfo:int2dist > 0 and intersectInfo:int2dist < point){
    set point to intersectInfo:int2dist.
    set dt to intersectInfo:int2ut.
}

print point.
print dt - time:seconds.

set tillTime to round(dt - time:seconds).
set warpmode to "RAILS".

if (tillTime > 60) { warpTo(time:seconds + tillTime - 60).}

set mtr to 0.
lock throttle to mtr.

wait until warp = 0.

lock targetVector to target:obt:position - ship:obt:position.
lock relVelocity to ship:velocity:obt - target:velocity:obt.

set warpmode to "PHYSICS".
set warp to 3.
wait until (dt - time:seconds) <= 1.
set warp to 0.

until targetVector:mag < 100 {
    set desiredVector to targetVector/20.

    if (desiredVector:mag > 100){ set desiredVector to desiredVector:normalized*100. }

    set correctionVector to desiredVector - relVelocity.
    lock steering to correctionVector.
    if vAng(ship:facing:forevector, correctionVector) < 1 {
        set mtr to min(correctionVector:mag/20, 1).
    } else {
        set mtr to 0.
    }
    wait 0.01.
}

set mtr to 0.
lock steering to -relVelocity.

wait until vAng(ship:facing:forevector, -relVelocity) < 1.
until relVelocity:mag < 0.01 {
    set mtr to min(relVelocity:mag/20, 1).
    wait 0.01.
}

set mtr to 0.
set ship:control:pilotmainthrottle to 0.
unlock throttle.
unlock steering.

sas on.

