/// @description Setters

/// @method player_escape_wall
/// @description Moves the player's wall sensor out of collision with any walls.
/// @returns {Real|Undefined} Sign of the wall from the player, or undefined on failure to reposition.
player_escape_wall = function ()
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	var ind = hard_colliders; //instance_place(x_int, y_int, hard_colliders);
	
	if (collision_point(x_int, y_int, ind, true, false) == noone)
	{
		for (var ox = x_wall_radius - 1; ox > -1; --ox)
		{
			if (player_linecast(ind, ox)) continue;
			
			if (collision_point(x_int + cosine * (ox + 1), y_int - sine * (ox + 1), ind, true, false) != noone)
			{
				x -= cosine * (x_wall_radius - ox);
				y += sine * (x_wall_radius - ox);
				return 1;
			}
			else if (collision_point(x_int - cosine * (ox + 1), y_int + sine * (ox + 1), ind, true, false) != noone)
			{
				x += cosine * (x_wall_radius - ox);
				y -= sine * (x_wall_radius - ox);
				return -1;
			}
		}
	}
	else for (var ox = 1; ox <= x_wall_radius; ++ox)
	{
		if (collision_point(x_int + cosine * ox, y_int - sine * ox, ind, true, false) == noone)
		{
			x += cosine * (x_wall_radius + ox);
			y -= sine * (x_wall_radius + ox);
			return -1;
		}
		else if (collision_point(x_int - cosine * ox, y_int + sine * ox, ind, true, false) == noone)
		{
			x -= cosine * (x_wall_radius + ox);
			y += sine * (x_wall_radius + ox);
			return 1;
		}
	}
	
	return undefined;
};

/// @method player_ground
/// @description Aligns the player to the ground and updates their angle values, if applicable; detaches them otherwise.
/// @param {Bool} attach Whether to stick to the ground.
player_ground = function (attach)
{
	if (not attach)
	{
		on_ground = false;
		objCamera.on_ground = false;
		mask_direction = gravity_direction;
		exit;
	}
	
	// Reposition
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	repeat (y_radius + 1)
	{
		if (player_boxcast(hard_colliders, y_radius))
		{
			x -= sine;
			y -= cosine;
		}
		else break;
	}
	
	repeat (y_snap_distance - 1)
	{
		if (not player_boxcast(hard_colliders, y_radius + 1))
		{
			x += sine;
			y += cosine;
		}
		else break;
	}
	
	// Update current ground and angle values
	ground_id = instance_place(x div 1 + sine, y div 1 + cosine, hard_colliders);
	if (not instance_exists(ground_id))
	{
		ground_id = noone;
		player_detect_angle();
	}
};

/// @method player_detect_angle
/// @description Sets the player's angle values.
player_detect_angle = function ()
{
	// Check for contact with the ground
	var edge = 0;
	if (player_raycast(hard_colliders, -x_radius, y_radius + 1)) edge |= 1;
	if (player_raycast(hard_colliders, x_radius, y_radius + 1)) edge |= 2;
	if (player_raycast(hard_colliders, 0, y_radius + 1)) edge |= 4;
	
	if (edge == 0) exit;
	
	// Set new angle values
	if (edge & (edge - 1) == 0) // Check for only one point (power of 2 calculation)
	{
		// Calculate contact point
		var sine = dsin(mask_direction);
		var cosine = dcos(mask_direction);
		var ox = x div 1 + sine * y_radius;
		var oy = y div 1 + cosine * y_radius;
		
		if (edge == 1)
		{
			ox -= cosine * x_radius;
			oy += sine * x_radius;
		}
		else if (edge == 2)
		{
			ox += cosine * x_radius;
			oy -= sine * x_radius;
		}
		direction = player_calc_tile_normal(ox, oy);
	}
	else direction = mask_direction;
	local_direction = angle_wrap(direction - gravity_direction);
};

/// @method player_rotate_mask
/// @description Updates the direction of the player's virtual mask on slopes.
player_rotate_mask = function ()
{
	if (rotation_lock_time > 0 and not landed)
	{
		--rotation_lock_time;
		exit;
	}
	
	var diff = angle_difference(direction, mask_direction);
	if (abs(diff) > 45)
	{
		mask_direction = angle_wrap(mask_direction + 90 * sign(diff));
		rotation_lock_time = (not landed) * max(16 - abs(x_speed * 2) div 1, 0);
	}
};

/// @method player_keep_in_bounds
/// @description Confines the player within the bounds of the camera.
/// @returns {Bool} Whether the player is above the 'bottom' bound relative to their gravity direction.
player_keep_in_bounds = function ()
{
	with (objCamera)
	{
		var left = bound_left;
		var top = bound_top;
		var right = bound_right;
		var bottom = bound_bottom;
	}
	
	if (gravity_direction mod 180 == 0)
	{
		var limit = median(left + x_radius, x, right - x_radius);
		if (x != limit)
		{
			x = limit;
			x_speed = 0;
		}
		
		if (y - y_radius > bottom and gravity_direction == 0)
		{
			y = bottom + y_radius;
			return false;
		}
		else if (y + y_radius < top and gravity_direction == 180)
		{
			y = top - y_radius;
			return false;
		}
	}
	else
	{
		var limit = median(top + x_radius, y, bottom - x_radius);
		if (y != limit)
		{
			y = limit;
			x_speed = 0;
		}
		
		if (x - y_radius > right and gravity_direction == 90)
		{
			x = right + y_radius;
			return false;
		}
		else if (x + y_radius < left and gravity_direction == 270)
		{
			x = left - y_radius;
			return false;
		}
	}
	
	return true;
};

/// @method player_perform
/// @description Switches the player's state to the given function.
/// @param {Function} action State function to switch to.
player_perform = function (action)
{
	state(PHASE.EXIT);
	state = action;
	state_changed = true;
	state(PHASE.ENTER);
};

/// @method player_refresh_physics
/// @description Resets the player's physics variables back to their default values, applying any modifiers afterward.
player_refresh_physics = function ()
{
	// Speed values
	speed_cap = 6;
	acceleration = 0.046875;
	deceleration = 0.5;
	air_acceleration = 0.09375;
	roll_deceleration = 0.125;
	roll_friction = 0.0234375;
	
	// Aerial values
	gravity_cap = 16;
	gravity_force = 0.21875;
	recoil_gravity = 0.1875;
	jump_height = 6.5;
	jump_release = 4;
	
	// Superspeed modification
	if (superspeed_time > 0)
	{
		speed_cap *= 2;
		acceleration *= 2;
		air_acceleration *= 2;
		roll_friction *= 2;
	}
};

player_refresh_physics();

/// @method player_resist_slope
/// @description Applies slope friction to the player's horizontal speed, if appropriate.
/// @param {Real} force Friction value to use.
player_resist_slope = function (force)
{
	// Abort if moving along a shallow floor or ceiling
	if (local_direction < 22.5 or local_direction > 337.5) exit;
	if (local_direction >= 135 and local_direction <= 225) exit;
	
	x_speed -= dsin(local_direction) * force;
};

/// @method player_animate
/// @description Records the player's animation as the given string and sets the corresponding timeline from their `animations` struct.
/// @param {String} name Name of the animation.
player_animate = function (name)
{
	animation = name;
	timeline_index = animations[$ name];
	timeline_position = 0;
};