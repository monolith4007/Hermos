/// @description Move / Animate
if (not instance_in_view())
{
	instance_destroy();
	exit;
}

// Move and collide on separate axes
var dx = gravity_cos * x_speed;
var dy = gravity_sin * x_speed;
x += dx;
y -= dy;

var ind = instance_place(x, y, tilemaps);
if (ind != noone and not place_meeting(xprevious, yprevious, ind))
{
	while (place_meeting(x, y, ind))
	{
		x -= sign(dx);
		y += sign(dy);
	}
	x_speed *= -0.25;
}

dx = gravity_sin * y_speed;
dy = gravity_cos * y_speed;
x += dx;
y += dy;

ind = instance_place(x, y, tilemaps);
if (ind != noone and not place_meeting(xprevious, yprevious, ind))
{
	while (place_meeting(x, y, ind))
	{
		x -= sign(dx);
		y -= sign(dy);
	}
	y_speed *= -0.75;
}
y_speed += 0.09375;

image_speed -= 0.002;
if (alarm[0] < 64) visible ^= 1;