addons:astrogator:create(kerbin).

// perform the transfers then once in the SOI of minmus,
// the following will create a circular orbit at Periapsis
//addons:astrogator:create(Minmus).


// calculate the burns to Dres
set bms to addons:astrogator:calculateBurns(mun).

print bms.
////LIST of 2 items:
//[0] = "BurnModel(attime: 22003501.7260593, prograde: 1668.01710042658, normal: 0, radial: 0, totaldv: 1668.01710042658, duration: -3)"
//[1] = "BurnModel(attime: 26711517.2636837, prograde: -11.3082556944201, normal: -379.003641740976, radial: 6.3296734686348, totaldv: 379.225133484046, duration: 52.803860349922)"

// Create a Maneuver node from the first BurnModel:
//set n0 to bms[0]:toNode.

// inspecting in the map view will note the DV requirement is too great for the ship being used, this is indicated by duration = -3.

// Values are standard kOS scalable values that can be used in calculations:
//print bms[0]:totalDV / 1024.