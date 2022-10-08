declare parameter finalTouchDownSpeed is 2, pointOfVerticalSpeed is 100.

clearScreen.

if (not addons:available("KER")){
  print "KER Addon NOT installed!!!" at (1,1).
  shutdown.
}

sas off.
rcs off.

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

local mtR to 1.
lock throttle to mtR.

clearScreen.
print "Wait vertical speed 100 m/s" at(1,1).
wait until ship:verticalspeed >= -pointOfVerticalSpeed.

local pid to pidLoop(3, 0, 0.0035, 0.00001, 1).
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

lock throttle to 0.

clearScreen.
print "Landed!!!".
wait 3.

unlock throttle.
unlock steering.