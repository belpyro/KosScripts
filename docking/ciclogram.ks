@lazyGlobal off.

declare parameter tgt_name is "".

if (not hasTarget) { set target to vessel(tgt_name). }
if (ship:body:name <> target:body:name){
    clearScreen. 
    print "Target has not the same Body. System will reboot after 3 sec.".
    wait 3.
    reboot.
}

run rdv.
run distance.
run dock.

clearScreen.
print "Ciclogram has completed.".
wait 3.

