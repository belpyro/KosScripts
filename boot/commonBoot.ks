wait until ship:unpacked and controlConnection:isconnected.

switch to 1.
clearScreen.
copyPath("0:/coreLib.ks","1:").
copyPath("0:/ascent.ks","1:").
copyPath("0:/makeOrbit.ks","1:").
copyPath("0:/circToApo.ks","1:").
copyPath("0:/transfer.ks","1:").
copyPath("0:/land.ks","1:").

runOncePath("coreLib").

LOCAL doneYet is FALSE.
LOCAL g IS GUI(200).

local orbitHeightBox is g:addtextfield("80000").
local orbitIncBox is g:addtextfield("90").
local stopOnApoBox is g:addcheckbox("Stop On Apo", false).
// b1 is a normal button that auto-releases itself:
// Note that the callback hook, myButtonDetector, is
// a named function found elsewhere in this same program:
LOCAL b1 IS g:ADDBUTTON("Ascent").
SET b1:ONCLICK TO myButtonDetector@.

// // b2 is also a normal button that auto-releases itself,
// // but this time we'll use an anonymous callback hook for it:
LOCAL b2 IS g:ADDBUTTON("Muna Transfer").
SET b2:ONCLICK TO { run transfer. }.

LOCAL b2 IS g:ADDBUTTON("Land").
SET b2:ONCLICK TO { run land. }.
// // b3 is a toggle button.
// // We'll use it to demonstrate how ONTOGGLE callback hooks look:
// LOCAL b3 IS g:ADDBUTTON("button 3").
// set b3:style to g:skin:button.
// SET b3:TOGGLE TO TRUE.
// SET b3:ONTOGGLE TO myToggleDetector@.

// b4 is the exit button.  For this we'll use another
// anonymous function that just sets a boolean variable
// to signal the end of the program:
LOCAL b4 IS g:ADDBUTTON("EXIT").
SET b4:ONCLICK TO { set doneYet to true. }.

g:show(). // Start showing the window.

wait until doneYet. // program will stay here until exit clicked.

g:hide(). // Finish the demo and close the window.

shutdown.
//END.

function myButtonDetector {    
  run ascent(orbitHeightBox:text:tonumber(80000), orbitIncBox:text:tonumber(0), false, 25000, 30).
}

function myToggleDetector {
  parameter newState.
  print "Button Three has just become " + newState.
}