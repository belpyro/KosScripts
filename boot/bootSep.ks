wait until ship:unpacked and controlConnection:isconnected and ship:status = "ORBITING".

clearScreen.
print "Start staging test".
sas off.
rcs off.

lock steering to heading(90,90).
wait 10.
stage.
print "Stage launched".

wait 1.

when ship:maxthrust <= 0 then {
    local engines to ship:modulesnamed("ModuleEngines").
    for engine in engines { engine:doevent("Вкл. двигатель"). }
}

wait 3.
print "Down grade!!".
lock steering to ship:retrograde.
wait until vAng(ship:facing:forevector, ship:retrograde:vector) <= 5.
lock throttle to 1.
wait until ship:periapsis <= 10000.
lock throttle to 0.
shutdown.


//циклограмма
//1 - вывод на орбиту
//2 - скругление
//3 - идеальное скругление
//4 - отстрел первого спутника и передача команды на выход на орбиту
//5 - ожидание сигнала от спутника
//6 - отстрел второго и передача команды выхода на орбиту 120 градусов по отношению к первому
//7 - ожидание сигнала от спутника, что все в порядке
//8 - отстрел последнего спутника и передача сигнала п.6
//9 - уничтожение базового модуля