/// @description Initialize
image_speed = 0.3;
reaction = function (ind)
{
	if (on_ground and ind.alarm[0] == -1 and collision_point(x, y, ind, false, false) != noone)
	{
		if (ind.force_roll and state != player_is_rolling)
		{
			player_perform(player_is_rolling);
		}
		
		audio_play_sfx(sfxPeelout);
		image_xscale = ind.image_xscale;
		control_lock_time = 16;
		
		x_speed = max(abs(x_speed), 12) * image_xscale;
		ind.alarm[0] = ind.sprite_width / x_speed; // Lock reaction until no longer intersecting
	}
};