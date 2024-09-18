declare parameter finalTouchDownSpeed is 2, pointOfVerticalSpeed is 100.

clearScreen.

if (not addons:available("KE")){
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

lock suicideBurnCountdown to addons:ke:suicideBurnCountdown. 
lock steering to srfRetrograde.


wait until suicideBurnCountdown > 0.

warpTo(time:seconds + suicideBurnCountdown - 60).

until suicideBurnCountdown <= 1
{
   print "Suicide DeltaV: " + addons:ke:suicideBurnDeltaV at(1,1). 
   print "Suicide Burn Length: " + addons:ke:suicideBurnLength at(1,2). 
   print "Suicide Countdown: " + suicideBurnCountdown at(1,3). 
   print "Suicide Altitude: " + addons:ke:suicideBurnAltitude at(1,4). 
   print "Vessel Altitude: " + ship:altitude at(1,5). 
   wait 0.1.
}

clearScreen.
print "Start Landing" at(1,1).

lock throttle to mtR.

clearScreen.
print "Wait vertical speed" + pointOfVerticalSpeed + "m/s" at(1,1).
wait until ship:verticalspeed >= -pointOfVerticalSpeed or suicideBurnCountdown <= 1.

local pid to pidLoop(3, 0, 0.0035, 0, 1).
set pid:setpoint to 0.5. 
local landingStep to 1.

until ship:status = "LANDED"
{
    if (landingStep = 1)
    {
      set mtR to pid:update(time:seconds, suicideBurnCountdown).  
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
unlock suicideBurnCountdown.

rcs on.
sas on.

clearScreen.
print "Landed!!!".
wait 3.

