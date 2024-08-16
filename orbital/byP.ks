declare parameter expectedPeriod is 0.

local continue to expectedPeriod > 0.

if(continue)
{
    clearScreen.
    sas off.
    rcs off.
    
    local result to calculateRadius(expectedPeriod).
    print "Result is: " + result at(1,1).
    print "Result is: " + timespan(expectedPeriod):full at(1,2).   
    wait 3.
    run makeOrbit(result).
    run circToApo. 
}

function calculateRadius
{
    parameter P.
    local coreBody to ship:body.
    local radius to ((P^2*ship:obt:semimajoraxis^3)/(ship:obt:period^2))^(1/3) - coreBody:radius.
    return radius.
}



