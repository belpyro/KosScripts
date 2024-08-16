@lazyGlobal off.

for n in allNodes {
    remove n.
}

local dv is 100.
local mnv is node(time:seconds + 30, 0, 0, dv).
add mnv.

lock steering to mnv:burnvector:normalized.
wait until vAng(ship:facing:forevector, mnv:burnvector) < 1.

local pid is pidLoop(4.5, 0.04, 0.2, 0, 1).
set pid:setpoint to 1.

local th is 1.
lock throttle to th.

until mnv:deltav:mag <= 0.01 {
    set th to max(0.01, pid:update(time:seconds, 1 - mnv:deltav:mag/dv)).
    printStatus().    
    wait 0.01.
}

set th to 0.
unlock throttle.
unlock steering.

local function printStatus {
    clearScreen.
    print "Th " + th at(0,0).
    print "DeltaV " + mnv:deltav:mag at(0,1). 
}
