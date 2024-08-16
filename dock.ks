@lazyGlobal off.
declare parameter tgt_name.

set target to vessel(tgt_name).

clearScreen.
print "Looking for proper Docking ports".
wait 3.

local ship_port is "".//ship:dockingports[0].
local target_port is "".//target:dockingports[0].
local hasShipPort is false.
local hasTgtPort is false.

for s_port in ship:dockingports {
    if(s_port:state:contains("Ready")){
        set ship_port to s_port.
        set hasShipPort to true.
        break.
    }
}

for t_port in target:dockingports {
    if(t_port:state:contains("Ready")){
        set target_port to t_port.
        set hasTgtPort to true.
        break.
    }
}

if not (hasShipPort and hasTgtPort) {
    clearScreen.
    print "Active and Ready Docking Port has not found! System will be rebooted after 3 sec.".
    wait 3.
    reboot.
}

reset().

local port_distance is target_port:position - ship_port:position.
local delta_vel is target:velocity:obt - ship:velocity:obt.

lock steering to lookDirUp(-target_port:facing:vector, target_port:facing:upvector).

local vz_pid is pidLoop(1.2, 8.4, 0.04, -1, 1).
local vy_pid is pidLoop(0.8, 8.4, 0.04, -1, 1).
local vx_pid is pidLoop(0.8, 8.4, 0.04, -1, 1).

local deltaX is round(vDot(port_distance, ship_port:facing:starvector),2).
local deltaY is round(vDot(port_distance, ship_port:facing:upvector),2).
local deltaZ is round(vDot(port_distance, ship_port:facing:forevector),2).
local speedX is round(vDot(delta_vel, ship_port:facing:starvector),2).
local speedY is round(vDot(delta_vel, ship_port:facing:upvector),2).
local speedZ is round(vDot(delta_vel, ship_port:facing:forevector),2).
local facing_angle is round(vAng(ship:facing:forevector, port_distance),2).
local top_angle is round(vAng(ship:facing:topvector, target:facing:topvector),2).
local operation is "Initial".

local max_speed TO 2.0.  // Максимальная скорость 2 м/с
local coefficient TO 0.1.  // Коэффициент экспоненциального уменьшения
local target_speed_x IS max_speed * (1 - constant:e^(-coefficient * abs(deltaX))).
local target_speed_y IS max_speed * (1 - constant:e^(-coefficient * abs(deltaY))).

rcs on.

until ( deltaZ - 10 >= 0 ) { // задняя полусфера. двигаемся до пересечения с 10 m
        set operation to "Correction Z distance".

        updateData().
        printStatus().

        set ship:control:fore to vz_pid:update(time:seconds, 10 - deltaZ).
   
        set ship:control:starboard to vx_pid:update(time:seconds, -speedX).
        set ship:control:top to vy_pid:update(time:seconds, -speedY). //speedY*10.
        
        wait 0.01.
}

set ship:control:starboard to 0.
set ship:control:fore to 0.
set ship:control:top to 0.

vx_pid:reset().
vy_pid:reset().
vz_pid:reset().

wait 1.

until ship_port:state:contains("Docked") {

    updateData().
    printStatus().
    
    set target_speed_x to max_speed * (1 - constant:e^(-coefficient * abs(deltaX)))*SIGN(deltaX).
    set vx_pid:setpoint to target_speed_x.

    set target_speed_y to max_speed * (1 - constant:e^(-coefficient * abs(deltaY)))*SIGN(deltaY).
    set vy_pid:setpoint to target_speed_y.

    if ( facing_angle <= 5 and top_angle <= 5) {
        set ship:control:fore to vz_pid:update(time:seconds, -(speedZ + 0.5 + deltaZ/100)).
        // set ship:control:starboard to speedX*10.
        // set ship:control:top to speedY*10. //speedY*10.
        set operation to "Move to forward".
    } else {
        // set ship:control:starboard to vx_pid:update(time:seconds, -speedX).//-(speedX/4 + (1*deltaX)/100)).
        // set ship:control:top to vy_pid:update(time:seconds, -speedY).//-(speedY/4 + (1*deltaY)/100)). //speedY*10.
        set ship:control:fore to speedZ*10.
        set operation to "Docking".
    }    
    
    set ship:control:starboard to vx_pid:update(time:seconds, -speedX).//-(speedX/4 + (1*deltaX)/100)).
    set ship:control:top to vy_pid:update(time:seconds, -speedY).//-(speedY/4 + (1*deltaY)/100)). //speedY*10.

    wait 0.01.
}

reset().
unlock steering.

sas on.
clearScreen.
print "Docking finished".

local function reset {
    clearScreen.
    sas off.
    rcs off.

    set ship:control:fore to 0.
    set ship:control:starboard to 0.
    set ship:control:top to 0.

    clearVecDraws().
}

local function updateData {
    set port_distance to target_port:position - ship_port:position.
    set delta_vel to target:velocity:obt - ship:velocity:obt.
    set deltaX to round(vDot(port_distance, ship_port:facing:starvector),2).
    set deltaY to round(vDot(port_distance, ship_port:facing:upvector),2).
    set deltaZ to round(vDot(port_distance, ship_port:facing:forevector),2).
    set speedX to round(vDot(delta_vel, ship_port:facing:starvector),2).
    set speedY to round(vDot(delta_vel, ship_port:facing:upvector),2).
    set speedZ to round(vDot(delta_vel, ship_port:facing:forevector),2).
    set facing_angle to round(vAng(ship:facing:forevector, port_distance),2).
    set top_angle to round(vAng(ship:facing:topvector, target:facing:topvector),2).
}

// Function to determine the sign of a number
local FUNCTION SIGN {
    PARAMETER X.
    IF X > 0 {
        RETURN 1.
    } ELSE IF X < 0 {
        RETURN -1.
    } ELSE {
        RETURN 0.
    }
}

local FUNCTION ISBETWEEN {
    PARAMETER value.  // The value to check
    PARAMETER lowerBound.  // The lower bound of the range
    PARAMETER upperBound.  // The upper bound of the range
    
    IF value >= lowerBound AND value <= upperBound {
        RETURN TRUE.
    } ELSE {
        RETURN FALSE.
    }
}

local function printStatus {
    clearScreen.
    print "Distance is " + round(port_distance:mag,2) + " m." at(0,0).
    print "Delta X " + deltaX + " m." at(0,2).
    print "Delta Y " + deltaY + " m." at(0,3).
    print "Delta Z " + deltaZ + " m." at(0,4).
    print "Delta Vel X " + speedX + " m/s." at(20,2).
    print "Delta Vel Y " + speedY + " m/s." at(20,3).
    print "Delta Vel Z " + speedZ + " m/s." at(20,4).
    print "X pid " + round(vx_pid:output,2)  at(0,6).
    print "Z pid " + round(vz_pid:output,2)  at(12,6).
    print "Y pid " + round(vy_pid:output,2)  at(24,6).
    print "Face angle: " + facing_angle at(0,8).
    print "Top angle: " + top_angle at(24,8).

    print "Target speed X " + round(target_speed_x,2) at(0,9).
    print "Target speed Y " + round(target_speed_y,2) at(22,9).

    print "Operation: " + operation at(0, 11).
}