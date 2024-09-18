wait until ship:unpacked and controlConnection:isconnected.

switch to 1.
clearScreen.
copyPath("0:/coreLib.ks","1:").
copyPath("0:/ascent.ks","1:").
copyPath("0:/makeOrbit.ks","1:").
copyPath("0:/circToApo.ks","1:").

runOncePath("coreLib").

//циклограмма
//1 - вывод на орбиту
//2 - скругление
runPath("ascent",80000, 25000, 30, 0).
runPath("makeOrbit", 252000).
runPath("circToApo").
shutdown.