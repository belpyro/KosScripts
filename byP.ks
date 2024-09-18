@lazyGlobal off.

declare parameter expectedPeriod is 0.

local continue to expectedPeriod > 0.

runOncePath("coreLib").

if(continue)
{
    clearScreen.
    sas off.
    rcs off.
    
    local result to calcRadius(expectedPeriod).
    print "Result is: " + result at(1,1).
    print "Result is: " + timespan(expectedPeriod):full at(1,2).   
    wait 3.
    run makeOrbit(result).
    run circToApo. 
}



