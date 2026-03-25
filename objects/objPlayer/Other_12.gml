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
	
	repeat (y_tile_reach - 1)
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
	// Check for points of collision with the ground
	var edge = 0;
	if (player_raycast(hard_colliders, -x_radius, y_radius + 1)) edge |= 1;
	if (player_raycast(hard_colliders, x_radius, y_radius + 1)) edge |= 2;
	if (player_raycast(hard_colliders, 0, y_radius + 1)) edge |= 4;
	
	if (edge == 0) exit;
	
	// Set new angle values
	if (edge & (edge - 1) == 0) // Check for only one point (power of 2 calculation)
	{
		// Calculate offset point, and reposition it if applicable
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
	
	var new_mask_dir = round(direction / 90) mod 4 * 90;
	if (mask_direction != new_mask_dir)
	{
		mask_direction = new_mask_dir;
		rotation_lock_time = (not landed) * max(16 - abs(x_speed * 2) div 1, 0);
	}
};

/// @method player_keep_in_bounds
/// @description Confines the player within the bounds of the camera.
/// @returns {Bool} Whether the player is above the bottom bound relative to their gravity direction.
player_keep_in_bounds = function ()
{
	// Calculate area of virtual mask and bounds
	var vertical = gravity_direction mod 180 == 0;
	if (vertical)
	{
		var x1 = x - x_radius;
		var y1 = y - y_radius;
		var x2 = x + x_radius;
		var y2 = y + y_radius;
	}
	else
	{
		var x1 = x - y_radius;
		var y1 = y - x_radius;
		var x2 = x + y_radius;
		var y2 = y + x_radius;
	}
	
	with (objCamera)
	{
		var left = bound_left;
		var top = bound_top;
		var right = bound_right;
		var bottom = bound_bottom;
	}
	
	// Check if already inside (early out)
	if (rectangle_in_rectangle(x1, y1, x2, y2, left, top, right, bottom) == 1)
	{
		return true;
	}
	
	// Reposition
	if (vertical)
	{
		if (x1 < left)
		{
			x = left + x_radius;
			x_speed = 0;
		}
		else if (x2 > right)
		{
			x = right - x_radius;
			x_speed = 0;
		}
		
		if (y1 > bottom and gravity_direction == 0)
		{
			y = bottom + y_radius;
			return false;
		}
		else if (y2 < top and gravity_direction == 180)
		{
			y = top - y_radius;
			return false;
		}
	}
	else
	{
		if (y1 < top)
		{
			y = top + x_radius;
			x_speed = 0;
		}
		else if (y2 > bottom)
		{
			y = bottom - x_radius;
			x_speed = 0;
		}
		
		if (x1 > right and gravity_direction == 90)
		{
			x = right + y_radius;
			return false;
		}
		else if (x2 < left and gravity_direction == 270)
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
	// Abort if moving along a ceiling
	if (local_direction >= 135 and local_direction <= 225) exit;
	
	// Apply (Sonic 3 method)
	var slope_factor = dsin(local_direction) * force;
	if (abs(slope_factor) >= 0.05078125) x_speed -= slope_factor;
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