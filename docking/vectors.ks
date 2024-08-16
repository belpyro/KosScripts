@lazyGlobal off.

sas off.
rcs off.

// local vel_v is vecDraw().
// local pos_v is vecDraw().
// lock rel_v to ship:velocity:obt - target:velocity:obt.
// lock rel_pos to target:position - ship:position.
// lock test_dir to (rel_pos/20 - rel_v).
// lock steering to (test_dir):direction.
// local dv is calculateDeltaVToTarget().
// // lock steering to dv:direction.

// until false {
//     clearScreen.
//     print "Rel velocity is " + round(rel_v:mag,2) + " m/s. And rel speed " + round(vDot(rel_v, prograde:forevector),2) at(0,0). 
//     print "Distance is " + round(rel_pos:mag,2) at(0,1). 
//     print "Rel angle " + vAng(rel_pos, rel_v) + " and correction is " + test_dir:mag at(0,2). 
//     set vel_v:vec to rel_v*20.
//     set vel_v:show to true.
//     set pos_v:vec to rel_pos.
//     set pos_v:show to true.
//     set pos_v:color to rgba(255,0,0, 255).
//     wait 0.1.
// }

//Вектор на цель
LOCK TargetVector TO Target:ORBIT:POSITION-SHIP:ORBIT:POSITION.
//Вектор относительной скорости
LOCK RelativeVelocity TO SHIP:VELOCITY:ORBIT-Target:VELOCITY:ORBIT.

//Выполняем в цикле до сближения на 80м
UNTIL (TargetVector:MAG<80)
{
    //Скорость сближения должна быть примерно равна расстоянию / 20 
	local DesiredVelocityVector TO TargetVector/20.
	//Но не более 100 м/с
	IF (DesiredVelocityVector:MAG>100)
	{
		SET DesiredVelocityVector TO DesiredVelocityVector:NORMALIZED*100.
	}
	//Коррекционный вектор, прицеливаемся вдоль него
	local CorrectionVector TO DesiredVelocityVector - RelativeVelocity.
	LOCK STEERING TO CorrectionVector:direction.
	// Если прицелились +- 5град, то прожиг
	IF (VANG(CorrectionVector,SHIP:FACING:FOREVECTOR)<5)
	{
		LOCK THROTTLE TO MIN(CorrectionVector:MAG/20,1).
	}
	ELSE
	{
		LOCK THROTTLE TO 0.
	}
	//выводим относ. скорость и расстояние на экран
	clearscreen.
	print "Approach Velocity: " + VDOT(RelativeVelocity,TargetVector:NORMALIZED).
	print "Target Distance: " + TargetVector:MAG.
}
//Если есть сближение на 80м
//выключаем тягу, прицеливаемся против вектора относительной скорости
//ждем 3 сек.
LOCK THROTTLE TO 0.
LOCK STEERING TO -RelativeVelocity.
WAIT 3.
//гасим относительную скорость почти в 0.
UNTIL (RelativeVelocity:MAG<0.01)
{
	LOCK THROTTLE TO MIN(RelativeVelocity:MAG/20,1).
}

//Сближение выполнено, гашение относительной скорости выполнено, можно переходить к стыковке
LOCK THROTTLE TO 0.
UNLOCK STEERING.
SET SHIP:CONTROL:PILOTMAINTHROTTLE TO 0.
clearscreen.
print "APPROACH COMPLETE.".