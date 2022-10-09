declare parameter apo is 0.

local continue to apo > 0.

if (continue){
    clearScreen.
    print "Prepare burning".
    sas off.
    rcs off.

    when maxThrust <= 0 then {
            stage.
            preserve.
        }

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
