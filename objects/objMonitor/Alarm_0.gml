/// @description Land
if (vspeed > 0 and place_meeting(x, y + vspeed, tilemap))
{
	while (not place_meeting(x, y + 1, tilemap))
	{
		++y;
	}
	vspeed = 0;
	gravity = 0;
}
else alarm[0] = 1;