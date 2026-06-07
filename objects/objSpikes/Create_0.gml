/// @description Initialize
image_speed = 0;
reaction = function (ind)
{
	// Get orientation relative to mask direction
	var rotation_offset = angle_wrap(ind.image_angle - mask_direction);
	var damage = false;
	
	// Take damage
	if (player_linecast(ind))
	{
		if ((rotation_offset == 90 and x_speed > 0) or (rotation_offset == 270 and x_speed < 0))
		{
			damage = true;
		}
	}
	else if (player_boxcast(ind, y_radius + on_ground))
	{
		if (rotation_offset == 0 and y_speed >= 0)
		{
			damage = true;
		}
	}
	else if (player_boxcast(ind, -y_radius) and rotation_offset == 180 and y_speed < 0)
	{
		damage = true;
	}
	
	if (damage) player_damage(ind);
};