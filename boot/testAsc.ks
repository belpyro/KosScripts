wait until ship:unpacked and controlConnection:isconnected.

clearScreen.
copyPath("0:/coreLib.ks","").
copyPath("0:/ascent.ks","").
copyPath("0:/circToApo.ks","").

wait 3.
runOncePath("coreLib").
runPath("ascent").
runPath("circToApo").