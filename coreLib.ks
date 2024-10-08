function transfernode {
  parameter tgt.
  parameter phitotgt is 0. // при запуске без аргументов выводим на траекторию столкновения с Муном
  
  // расчёт dV
  local newsma to tgt:orbit:semimajoraxis.
  local r0 to orbit:semimajoraxis.
  local v0 to velocity:orbit:mag.
  
  local a1 to (newsma + r0)/2. // большая полуось переходной орбиты
  local Vpe to sqrt( body:mu * ( 2/r0 - 1/a1 ) ).
  local deltav to Vpe - v0.
  
  // расчёт точки манёвра
  local t12 to constant:pi * a1^1.5 / body:mu^0.5. // время прохождения от перицентра до апоцентра
  local tomega to 360/tgt:orbit:period.
  local phitrans to phitotgt + tomega*t12 - 180. // под этим углом нужно начинать манёвр
  
  local phinow to 180 - vang( body:position, tgt:position - body:position ).
  if vcrs( body:position, tgt:position ):y > 0 { set phinow to 360 - phinow. }
  local omegaeff to 360/orbit:period - tomega.  // угловая скорость, с которой мы движемся относительно цели
  local etatrans to ( phitrans - phinow ) / omegaeff. // когда должен быть манёвр

  // если нет времени на манёвр, он переносится на следующий период
  if etatrans < (deltav * mass / ship:availablethrust + 30) { set etatrans to etatrans + (360/abs(omegaeff)). }
  
  print "Transfer burn: " + round(v0) + " -> " + round(Vpe) + "m/s".
  set nd to node(time:seconds + etatrans, 0, 0, deltav).
  add nd.
  return list(phitrans, etatrans, deltav).
}

FUNCTION apoBurnFunc
{
	local Vh to VXCL(Ship:UP:vector, ship:velocity:orbit):mag.	//Считаем горизонтальную скорость
	local Vz to ship:verticalspeed. // это вертикальная скорость
	local Rad to ship:Body:radius+ship:altitude. // Радиус орбиты.
	local Vorb to sqrt(ship:Body:Mu/Rad). //Это 1я косм. на данной высоте.
	local g_orb to ship:Body:Mu/Rad^2. //Ускорение своб. падения на этой высоте.
	//set ThrIsp to ship:availablethrust. //EngThrustIsp возвращает суммарную тягу и средний Isp по всем активным двигателям.
	local AThr to 1.
  if Throttle > 0
		set AThr to ship:availableThrust*Throttle/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 
	else
		set AThr to ship:availableThrust/(ship:mass). //Ускорение, которое сообщают ракете активные двигатели при тек. массе. 
	local ACentr to Vh^2/Rad. //Центростремительное ускорение.
	local DeltaA to g_orb-ACentr-Max(Min(Vz,2),-2). //Уск своб падения минус центр. ускорение с поправкой на гашение вертикальной скорости.
  local divA to DeltaA/AThr.
	local Fi to arcsin(max(min(divA, 0.707), -0.707)). // Считаем угол к горизонту так, чтобы держать вертикальную скорость = 0.
	local dVh to Vorb-Vh. //Дельта до первой косм.
	RETURN LIST(Fi, divA, dVh).	//Возвращаем лист с данными.
}

function unlockAllFunc {
  unlock throttle.
  unlock steering.
  set ship:control:pilotmainthrottle to 0.
}

function openAllAntenas {
  local modules to ship:modulesnamed("ModuleDeployableAntenna").
  for module in modules
  {
    module:doevent("Раскрыть антенну").
  }  
}

function testPartFunc {
  parameter tag.
  local testModuleName to "ModuleTestSubject".
  local parts to ship:partstagged(tag).
  for part in parts{
    if (part:hasmodule(testModuleName)){
      part:modulesnamed(testModuleName)[0]:doevent("Провести испытание").
    }
  }
}

function doScienceFunc {
  local scienceModuleName to "ModuleScienceExperiment".
  local modules to ship:modulesnamed(scienceModuleName).
  for md in modules{
      md:deploy.
      wait until md:hasdata.
      md:transmit.    
  }
}


function doScienceByTagFunc {
  parameter tag.
  parameter isSend is true.
  local scienceModuleName to "ModuleScienceExperiment".
  local part to ship:partstagged(tag)[0].
  local module to part:getmodule(scienceModuleName).
  module:deploy.
  wait until module:hasdata.
  if (isSend) {
    module:transmit. 
  } 
}

function copyFile {
    parameter fName.
    switch to 0.
    run my.
    copyPath(fName, "1:").
    switch to 1.
}

function calculateAscentAngle {
    local parameter neededAngle.
    local parameter neededAlt.
    local percentOfAlt to ship:altitude/neededAlt.
    local pushAngle to 90-neededAngle.
    return max(0, round(90 - pushAngle*(percentOfAlt^(1/2)),1)).
}

function calculateRadius
{
    parameter expectedPeriod is 0.
    local coreBody to ship:body.
    local radius to ((expectedPeriod^2*ship:obt:semimajoraxis^3)/(ship:obt:period^2))^(1/3) - coreBody:radius.
    return radius.
}

set apoBurn to apoBurnFunc@.
set transferNodeFunc to transfernode@.
set unlockAll to unlockAllFunc@.
set openAntennas to openAllAntenas@.
set cp to copyFile@.
set calcAscAngle to calculateAscentAngle@.
set testPart to testPartFunc@.
set doScience to doScienceFunc@.
set doScienceByTag to doScienceByTagFunc@.
set calcRadius to calculateRadius@.

