/// @description Attach
x = owner.x div 1;
y = owner.y div 1;

if (owner.animation != "roll")
{
	var ang = owner.image_angle;
	x -= dsin(ang) * 4;
	y -= dcos(ang) * 4;
}