@lazyGlobal off.
declare parameter finalTouchDownSpeed is 2, pointOfVerticalSpeed is 100.

clearScreen.

if (not addons:available("KER")){
  print "KER Addon NOT installed!!!" at (1,1).
  shutdown.
}

sas off.
rcs off.

when maxThrust <= 0 then { stage. preserve. }

local mtR to 1.

if (ship:status = "orbiting") {
  lock steering to retrograde.
  wait until vAng(ship:facing:forevector, retrograde:vector) <= 1.
  local vel to ship:velocity:orbit:mag.
  wait 3.
  clearScreen.
  print "Start landing burn".
  lock throttle to mtR.
  wait until ship:velocity:orbit:mag <= 0.1*vel.
  set mtR to 0.
}

local suicide to addons:ker:suicide. 
lock steering to srfRetrograde.

wait 3.
wait until suicide:countdown > 0.
wait 1.

warpTo(time:seconds + suicide:countdown - 15).

until suicide:countdown <= 1
{
   print "Suicide DeltaV: " + suicide:deltav at(1,1). 
   print "Suicide Burn Length: " + suicide:length at(1,2). 
   print "Suicide Countdown: " + suicide:countdown at(1,3). 
   wait 0.1.
}

clearScreen.
print "Start Landing" at(1,1).

lock throttle to mtR.

clearScreen.
print "Wait vertical speed" + pointOfVerticalSpeed + "m/s" at(1,1).
wait until ship:verticalspeed >= -pointOfVerticalSpeed or suicide:countdown <= 1.

local pid to pidLoop(3, 0, 0.0035, 0, 1).
set pid:setpoint to 0.5.
local landingStep to 1.

until ship:status = "LANDED"
{
    if (landingStep = 1)
    {
      set mtR to pid:update(time:seconds, suicide:countdown).  
      if (alt:radar <= 100){
        set landingStep to 2.
        set pid:setpoint to -finalTouchDownSpeed.
        gear on.
      }
    }

    if(landingStep = 2){
      set mtR to pid:update(time:seconds, ship:verticalspeed).  
    }
    
    print "Vertical speed: " + ship:verticalspeed at(1,2).
    print "Delta pid: " + round(mtR,4) at(1,3).
    print "ALT: " + round(alt:radar,4) at(1,4).
    wait 0.01.
}

set mtR to 0.
set ship:control:pilotmainthrottle to 0.
unlock throttle.
unlock steering.

rcs on.
sas on.

clearScreen.
print "Landed!!!".
wait 3.

