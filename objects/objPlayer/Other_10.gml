/// @description Movement

/// @method player_move_on_ground
/// @description Updates the player's position on the ground and checks for collisions.
player_move_on_ground = function ()
{
	// Ride moving platform
	with (ground_id)
	{
		var dx = x - xprevious;
		var dy = y - yprevious;
		if (dx != 0) other.x += dx;
		if (dy != 0) other.y += dy;
	}
	
	wall_sign = 0;
	
	// Divide the player's speed into smaller steps; ensures they don't miss intersections when moving fast
	var total_steps = 1 + abs(x_speed) div 15;
	var step = x_speed / total_steps;
	var floor_reach = y_radius + min(2 + abs(x_speed) div 1, y_snap_distance);
	
	// Iterate over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += dcos(direction) * step;
		y -= dsin(direction) * step;
		player_keep_in_bounds();
		
		// Detect colliders
		player_get_collisions();
		
		// Detect walls
		var ind = player_linecast(hard_colliders, true);
		if (ind != noone)
		{
			wall_sign = player_escape_wall(ind);
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
	
	// Divide the player's speeds into smaller steps
	var total_steps = 1 + abs(x_speed) div 15 + abs(y_speed) div 15;
	var x_step = x_speed / total_steps;
	var y_step = y_speed / total_steps;
	
	// Iterate over the number of steps
	repeat (total_steps)
	{
		// Move by a single step
		x += mask_cos * x_step + mask_sin * y_step;
		y += -mask_sin * x_step + mask_cos * y_step;
		
		// Die if out of bounds
		if (not player_keep_in_bounds()) return player_perform(player_is_dead);
		
		// Detect colliders
		player_get_collisions();
		
		// Detect walls
		var ind = player_linecast(hard_colliders, true);
		if (ind != noone)
		{
			wall_sign = player_escape_wall(ind);
			if (sign(x_speed) == wall_sign)
			{
				x_speed = 0;
				x_step = 0;
			}
		}
		
		// Detect floor / ceiling
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
			// Flip mask
			mask_direction = (mask_direction + 180) mod 360;
			mask_sin *= -1;
			mask_cos *= -1;
			
			// Land on the ceiling
			landed = true;
			player_ground(true);
			
			// Abort if rising slowly or the ceiling is too shallow
			if (y_speed > -4 or (local_direction >= 135 and local_direction <= 225))
			{
				// Slide against it
				var sine = dsin(local_direction);
				var cosine = dcos(local_direction);
				x_step = cosine * x_speed - sine * y_speed;
				x_speed = cosine * x_step;
				y_speed = -sine * x_step;
				
				// Revert mask rotation and abort
				mask_direction = gravity_direction;
				mask_sin *= -1;
				mask_cos *= -1;
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
			if (rolling)
			{
				rolling = false;
				badnik_chain = 0;
			}
			break;
		}
	}
};