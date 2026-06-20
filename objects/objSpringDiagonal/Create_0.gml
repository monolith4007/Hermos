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
	image_xscale = sign(x_speed);
	
	// Falling state sets the player's y-speed; switch to it before rising
	var y_spring_speed = -dcos(rotation_offset) * ind.force;
	if (y_spring_speed < 0)
	{
		player_perform(player_is_falling);
		player_animate("rise");
		
		if (rolling)
		{
			rolling = false;
			badnik_chain = 0;
		}
	}
	y_speed = y_spring_speed;
	
	// Animate spring
	ind.image_index = 0;
	ind.alarm[0] = 1;
	
	audio_play_sfx(sfxSpring);
};