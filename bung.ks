//@lazyGlobal off.

// Функция для решения квадратного уравнения
function solveQuadratic {
    parameter a, b, c.
    set discriminant to b^2 - 4*a*c.
    if discriminant < 0 {
        return list().
    } else {
        set t1 to (-b + sqrt(discriminant)) / (2*a).
        set t2 to (-b - sqrt(discriminant)) / (2*a).
        return list(t1, t2).
    }
}

// Главная программа
clearscreen.
print "Вычисление вектора импульса для перехвата цели...".

// Исходные данные
set P_A to ship:position.  // Положение снаряда (корабль A)
set P_B to target:position.  // Положение цели (корабль B)
set V_A to ship:velocity:obt.  // Скорость пушки (корабль A) - заменим на реальную скорость
set V_B to target:velocity:obt.  // Скорость цели (корабль B)
set V_projectile to 20.0.  // Скорость снаряда (величина)

// Разность положения
set P_rel to P_B - P_A.

// Разность скорости
set V_rel to V_B - V_A.

// Квадрат скорости снаряда
set V_projectile_squared to V_projectile^2.

// Квадрат относительной скорости цели
set V_target_squared to V_rel:X^2 + V_rel:Y^2 + V_rel:Z^2.

// Скалярное произведение относительного положения и относительной скорости
set P_dot_V to VDOT(P_rel, V_rel).

// Решаем квадратное уравнение для времени перехвата
set a to V_projectile_squared - V_target_squared.
set b to 2 * P_dot_V.  // Исправленный знак
set c to -VDOT(P_rel, P_rel).  // Исправленный знак

set solutions to solveQuadratic(a, b, c).
if solutions:LENGTH = 0 {
    print "Нет реального решения для времени перехвата.".
} else {
    set t1 to solutions[0].
    set t2 to solutions[1].
    
    // Выбираем положительное время перехвата
    if t1 > 0 and t2 > 0 {
        set t_intercept to min(t1, t2).
    } else {
        set t_intercept to max(t1, t2).
    }
    
    // Положение цели через время перехвата
    set P_intercept to P_B + V_B * t_intercept.
    
    // Вектор скорости снаряда для попадания в точку перехвата
    set V_required to (P_intercept - P_A) / t_intercept.
    
    print "Время до перехвата: " + round(t_intercept, 2) + " секунд".
    print "Точка перехвата: " + P_intercept.
    print "Требуемая скорость снаряда: " + V_required:mag.
    
    // Направление выстрела
    lock STEERING to V_required:direction.
    
    // // Выполнение маневра
    // lock THROTTLE to 1.
    // wait 1.
    // lock THROTTLE to 0.
    // unlock STEERING.
    // print "Выстрел произведен в направлении цели.".
}

until false { wait 1.}