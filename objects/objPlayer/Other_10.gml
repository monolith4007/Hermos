/// @description Movement

/// @method player_move_on_ground
/// @description Updates the player's position on the ground and checks for collisions.
player_move_on_ground = function ()
{
	// Ride moving platforms
	with (ground_id)
	{
		var dx = x - xprevious;
		var dy = y - yprevious;
		if (dx != 0) other.x += dx;
		if (dy != 0) other.y += dy;
	}
	
	wall_sign = 0;
	
	// Calculate movement steps
	var total_steps = 1 + abs(x_speed) div 13;
	var step = x_speed / total_steps;
	
	var floor_reach = y_radius + min(2 + abs(x_speed) div 1, y_snap_distance);
	
	repeat (total_steps)
	{
		x += dcos(direction) * step;
		y -= dsin(direction) * step;
		player_keep_in_bounds();
		
		// Detect colliders
		player_get_collisions();
		
		// Detect walls
		var ind = player_linecast(hard_colliders, true);
		if (ind != noone)
		{
			wall_sign = player_escape_wall(ind) ?? 0;
			if (sign(x_speed) == wall_sign) x_speed = 0;
		}
		
		// Detect floor
		if (player_boxcast(hard_colliders, floor_reach))
		{
			player_ground(true);
			player_rotate_mask();
		}
		else on_ground = false;
		
		// Abort if stopped or airborne
		if (x_speed == 0 or not on_ground) break;
	}
};

/// @method player_move_in_air
/// @description Updates the player's position in the air and checks for collisions.
player_move_in_air = function ()
{
	wall_sign = 0;
	
	// Calculate movement steps
	var total_steps = 1 + abs(x_speed) div 13 + abs(y_speed) div 13;
	var x_step = x_speed / total_steps;
	var y_step = y_speed / total_steps;
	
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	repeat (total_steps)
	{
		x += cosine * x_step + sine * y_step;
		y += -sine * x_step + cosine * y_step;
		player_keep_in_bounds();
		
		// Detect colliders
		player_get_collisions();
		
		// Detect walls
		var ind = player_linecast(hard_colliders, true);
		if (ind != noone)
		{
			wall_sign = player_escape_wall(ind) ?? 0;
			if (sign(x_speed) == wall_sign) x_speed = 0;
		}
		
		// Detect floors / ceilings
		if (y_speed >= 0)
		{
			if (player_boxcast(hard_colliders, y_radius))
			{
				landed = true;
				player_ground(true);
				player_rotate_mask();
			}
		}
		else if (player_boxcast(hard_colliders, -y_radius))
		{
			// Flip mask and land on the ceiling
			mask_direction = (mask_direction + 180) mod 360;
			landed = true;
			player_ground(true);
			
			// Abort if rising slowly or the ceiling is too shallow
			if (y_speed > -4 or (local_direction >= 135 and local_direction <= 225))
			{
				// Slide against it
				sine = dsin(local_direction);
				cosine = dcos(local_direction);
				var g_speed = cosine * x_speed - sine * y_speed;
				x_speed = cosine * g_speed;
				y_speed = -sine * g_speed;
				
				// Revert mask rotation and abort
				mask_direction = gravity_direction;
				landed = false;
				break;
			}
		}
		
		// Land
		if (landed)
		{
			// Calculate new horizontal speed
			if (local_direction >= 23 and local_direction <= 337 and abs(x_speed) <= abs(y_speed))
			{
				x_speed = local_direction < 180 ? -y_speed : y_speed;
				if (mask_direction == gravity_direction) x_speed *= 0.5;
			}
			
			// Stop falling, and abort
			y_speed = 0;
			landed = false;
			on_ground = true;
			objCamera.on_ground = true;
			if (rolling) rolling = false;
			break;
		}
	}
};