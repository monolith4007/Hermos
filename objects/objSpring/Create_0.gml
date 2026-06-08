/// @description Initialize
if (force > 10) sprite_index = sprSpringRed;
image_speed = 0;
image_index = 1;

reaction = function (ind)
{
	// Get orientation relative to mask direction
	var rotation_offset = angle_wrap(ind.image_angle - mask_direction);
	var type = 0;
	
	// React if touching the correct side
	if (player_linecast(ind))
	{
		if ((rotation_offset == 90 and x_speed > 0) or (rotation_offset == 270 and x_speed < 0))
		{
			type = 1;
		}
	}
	else if (player_boxcast(ind, y_radius))
	{
		if (rotation_offset == 0 and y_speed >= 0)
		{
			type = 2;
		}
	}
	else if (rotation_offset == 180 and y_speed < 0 and player_boxcast(ind, -y_radius))
	{
		type = 3;
	}
	
	if (type == 0) exit;
	
	// Bounce
	if (type == 1)
	{
		image_xscale = -sign(x_speed);
		x_speed = ind.force * image_xscale;
		control_lock_time = 16;
	}
	else if (type == 2)
	{
		player_perform(player_is_falling);
		player_animate("rise");
		y_speed = -ind.force;
		rolling = false;
		badnik_chain = 0;
	}
	else y_speed = ind.force;
	
	// Animate spring
	ind.image_index = 0;
	ind.alarm[0] = 1;
	
	audio_play_sfx(sfxSpring);
};