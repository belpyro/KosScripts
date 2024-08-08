@lazyGlobal off.

sas off.
rcs off.

local vel_v is vecDraw().
local pos_v is vecDraw().
lock rel_v to ship:velocity:obt - target:velocity:obt.
lock rel_pos to target:position - ship:position.
lock test_dir to (rel_pos/20 - rel_v):normalized.
lock steering to (test_dir):direction.
local dv is calculateDeltaVToTarget().
// lock steering to dv:direction.

until false {
    clearScreen.
    print "Rel velocity is " + round(rel_v:mag,2) + " m/s. And rel speed " + vDot(rel_v, prograde:forevector) at(0,0). 
    print "Distance is " + rel_pos:mag at(0,1). 
    print "DeltaV is " + dv:mag at(0,2). 
    set vel_v:vec to rel_v.
    set vel_v:show to true.
    set pos_v:vec to rel_pos.
    set pos_v:show to true.
    set pos_v:color to rgba(255,0,0, 255).
    wait 0.1.
}

// Функция для вычисления вектора направления на цель
function calculateDirectionToTarget {
    // Получить позицию цели и вашего корабля
    local targetPosition to target:POSITION.
    local shipPosition to SHIP:POSITION.

    // Вычислить вектор направления на цель
    local directionToTarget to targetPosition - shipPosition.

    // Нормализовать вектор направления (сделать его единичным)
    set directionToTarget to directionToTarget:NORMALIZED.

    return directionToTarget.
}

function calculateDeltaVToTarget {
    // Получить текущий вектор скорости корабля
    local currentVelocity to SHIP:VELOCITY:ORBIT.
    // Получить относительный вектор скорости
    local relativeVelocity to target:velocity:obt-ship:velocity:obt.

    // Вычислить вектор направления на цель
    local directionToTarget to calculateDirectionToTarget().

    // Проецировать текущую скорость на направление к цели
    local projectedVelocity to VDOT(currentVelocity, directionToTarget) * directionToTarget.

    // Вычислить требуемый вектор скорости (должен совпадать с направлением на цель)
    local requiredVelocity to relativeVelocity + projectedVelocity.

    // Вычислить вектор изменения скорости (delta-v)
    local deltaV to requiredVelocity - currentVelocity.

    return deltaV.
}