wait until ship:status = "ORBITING" and ship:unpacked and controlConnection:isconnected.

copypath("0:/transfer.ks","").
copypath("0:/land.ks","").
wait 3.

clearScreen.

print "Select mode" at (1,1).
print "Start transfer: 1" at(1,2).
print "Start landing: 2" at(1,3).
print "Start all: 3" at(1,4).
set flag to terminal:input:getchar().

if(flag = "1"){
    run transfer.
}

if(flag = "2"){
    run land.
}

if(flag = "3"){
    run transfer("Mun", true).
    run land.
}
