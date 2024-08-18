@lazyGlobal off.

if(hasNode){
    local nd is nextNode.

    until false {
        clearScreen.
        print nd:int.
        wait 0.01.
    }    
} else {
    local nd is node(time:seconds + 60, 0, 0, 0).
    add nd.

    clearScreen.
    print nd:int.
}

wait 5.