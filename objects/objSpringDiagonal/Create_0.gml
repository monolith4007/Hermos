/// @description Initialize
if (force > 10) sprite_index = sprSpringRedDiagonal;
image_speed = 0;
image_index = 1;

reaction = function (ind)
{
	// Abort if already activated or not intersecting
	if (ind.alarm[0] != -1 or not player_intersect(ind)) exit;
	
	// Bounce
	var rotation_offset = 45 + ind.image_angle - mask_direction;
	x_speed = -dsin(rotation_offset) * ind.force;
	y_speed = -dcos(rotation_offset) * ind.force;
	image_xscale = sign(x_speed);
	
	// Rise, if applicable
	if (y_speed < 0)
	{
		player_animate("rise");
		if (state != player_is_falling)
		{
			player_perform(player_is_falling, false);
			if (on_ground) player_ground(false);
			
			if (rolling)
			{
				rolling = false;
				badnik_chain = 0;
			}
		}
	}
	
	// Animate spring
	ind.image_index = 0;
	ind.alarm[0] = 1;
	
	audio_play_sfx(sfxSpring);
};