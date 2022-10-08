wait until ship:unpacked and controlConnection:isconnected.

until false
{
    print "Wait message".
    wait until not ship:messages:empty.
    local msg to ship:messages:pop.
    local mContent to msg:content.
    
    print "Message recieved " + mContent:tostring at(1,1).

    if(mContent:istype("lexicon")){
        if (mcontent:haskey("execute")){
            local fName to mContent["execute"].
            print "Run script " + fName at(1,2).
            if(exists(fName)){
                print "Run script " + fName at(1,2).
                runPath(fname).        
            } else {
                wait until controlConnection:isconnected.
                if(exists("0:/"+fName)){
                    copyPath("0:/"+fName,"").
                    runPath(fName).
                }
            }
        }
        if (mcontent:haskey("reboot")){ reboot. }
    }
    
    wait 1.    
}