/// @description Bounce
if (vspeed >= 0)
{
	if (y >= ystart)
	{
		vspeed = -5;
		image_speed = 0.125;
	}
	else if (image_speed != 0)
	{
		image_speed = 0;
		image_index = 0;
	}
}