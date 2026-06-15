/// @description Initialize
event_inherited();
reaction = function (ind)
{
	// Get orientation relative to mask direction
	var rotation_offset = angle_wrap(ind.image_angle - mask_direction);
	
	if (player_linecast(ind))
	{
		if ((rotation_offset == 90 and x_speed > 0) or (rotation_offset == 270 and x_speed < 0))
		{
			player_damage(ind);
		}
	}
	else if (y_speed >= 0)
	{
		if (rotation_offset == 0 and player_boxcast(ind, y_radius + on_ground))
		{
			player_damage(ind);
		}
	}
	else if (rotation_offset == 180 and player_boxcast(ind, -y_radius))
	{
		player_damage(ind);
	}
};