wait until ship:unpacked and controlConnection:isconnected.

switch to 1.
clearScreen.
copyPath("0:/coreLib.ks","1:").
copyPath("0:/ascent.ks","1:").

runOncePath("coreLib").

//циклограмма
//1 - вывод на орбиту
//2 - скругление
runPath("ascent").

set th to 0.
lock throttle to th.
lock steering to prograde:forevector.

wait until vAng(ship:facing:forevector, prograde:forevector) <= 0.25.

set th to 1.
wait until ship:obt:hasnextpatch = true and ship:obt:nextpatch:body:name = "kerbol".

set th to 0.
stage.

unlockAll().

