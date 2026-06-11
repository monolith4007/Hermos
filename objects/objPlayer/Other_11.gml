/// @description Collision

/// @method player_intersect
/// @description Checks if the given collider's mask intersects the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Real} [xrad] Distance to extend the player's mask horizontally both ways (optional, default is the player's x-radius).
/// @param {Real} [yrad] Distance to extend the player's mask vertically both ways (optional, default is the player's y-radius).
/// @returns {Bool}
player_intersect = function (ind, xrad = x_radius, yrad = y_radius)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	// Extend right/bottom sides slightly for tilemaps (see: https://github.com/YoYoGames/GameMaker-Bugs/issues/14294)
	return mask_sin == 0 ?
		collision_rectangle(x_int - xrad, y_int - yrad, x_int + xrad + SUBPIXEL, y_int + yrad + SUBPIXEL, ind, true, false) != noone :
		collision_rectangle(x_int - yrad, y_int - xrad, x_int + yrad + SUBPIXEL, y_int + xrad + SUBPIXEL, ind, true, false) != noone;
};

/// @method player_boxcast
/// @description Checks if the given collider's mask intersects a vertical portion of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Real} ylen Distance to extend the player's mask vertically.
/// @param {Bool} [get_id] Whether to return the id of the collider found (optional, default is false).
/// @returns {Bool|Id.Instance|Id.TileMapElement}
player_boxcast = function (ind, ylen, get_id = false)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	var x1 = x_int - mask_cos * x_radius;
	var y1 = y_int + mask_sin * x_radius;
	var x2 = x_int + mask_cos * x_radius + mask_sin * ylen;
	var y2 = y_int - mask_sin * x_radius + mask_cos * ylen;
	
	// Extend right/bottom sides slightly for tilemaps
	var left = min(x1, x2);
	var top = min(y1, y2);
	var right = max(x1, x2) + SUBPIXEL;
	var bottom = max(y1, y2) + SUBPIXEL;
	
	ind = collision_rectangle(left, top, right, bottom, ind, true, false);
	return get_id ? ind : ind != noone;
};

/// @method player_linecast
/// @description Checks if the given collider's mask intersects the 'arms' of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Bool} [get_id] Whether to return the id of the collider found (optional, default is false).
/// @returns {Bool|Id.Instance|Id.TileMapElement}
player_linecast = function (ind, get_id = false)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	ind = mask_sin == 0 ?
		collision_line(x_int - x_wall_radius, y_int, x_int + x_wall_radius, y_int, ind, true, false) :
		collision_line(x_int, y_int - x_wall_radius, x_int, y_int + x_wall_radius, ind, true, false);
	
	return get_id ? ind : ind != noone;
};

/// @method player_raycast
/// @description Checks if the given collider's mask intersects a line from the player.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Real} xoff Distance to offset the line horizontally.
/// @param {Real} ylen Distance to extend the line vertically.
/// @returns {Bool}
player_raycast = function (ind, xoff, ylen)
{
	var x1 = x div 1 + mask_cos * xoff;
	var y1 = y div 1 - mask_sin * xoff;
	var x2 = x1 + mask_sin * ylen;
	var y2 = y1 + mask_cos * ylen;
	
	return collision_line(x1, y1, x2, y2, ind, true, false) != noone;
};

/// @method player_get_collisions
/// @description Refreshes the player's local solids, and executes the reaction of instances intersecting the player's virtual mask.
player_get_collisions = function ()
{
	// Delist solid instances
	array_resize(hard_colliders, tilemap_count);
	
	// Calculate the area of the upper half of the player's virtual mask
	var x_int = x div 1;
	var y_int = y div 1;
	
	var x1 = x_int - mask_cos * x_wall_radius - mask_sin * y_radius;
	var y1 = y_int + mask_sin * x_wall_radius - mask_cos * y_radius;
	var x2 = x_int + mask_cos * x_wall_radius;
	var y2 = y_int - mask_sin * x_wall_radius;
	
	// Register semisolid tilemap
	if (semisolid_tilemap != -1)
	{
		var left = min(x1, x2);
		var top = min(y1, y2);
		var right = max(x1, x2) + SUBPIXEL;
		var bottom = max(y1, y2) + SUBPIXEL;
		
		if (collision_rectangle(left, top, right, bottom, semisolid_tilemap, true, false) == noone)
		{
			array_push(hard_colliders, semisolid_tilemap);
		}
	}
	
	// Detect instances intersecting a minimum bounding rectangle centered on the player
	// The area of the rectangle must be coordinated with the distances used for collision checking elsewhere
	static instances = ds_list_create();
	var total = collision_rectangle_list(x1, y1, x2 + mask_sin * (y_radius + 2), y2 + mask_cos * (y_radius + 2), objZoneObject, true, false, instances, false);
	
	// Execute reactions
	repeat (total)
	{
		var ind = instances[| --total];
		script_execute(ind.reaction, ind);
		if (total == 0) ds_list_clear(instances);
		
		// Register solid instances (exclude semisolids)
		if (not (instance_exists(ind) and object_is_ancestor(ind.object_index, objSolid))) continue;
		if (ind.semisolid and collision_rectangle(x1, y1, x2, y2, ind, true, false) != noone) continue;
		
		array_push(hard_colliders, ind);
	}
};

/// @method player_calculate_angle
/// @description Calculates the angle of the terrain found within a 16x16 area at the given point relative to the player's mask direction.
/// @param {Real} x x-coordinate of the point.
/// @param {Real} y y-coordinate of the point.
/// @returns {Real}
player_calculate_angle = function (ox, oy)
{
	var ind = hard_colliders;
	
	// Set up angle sensors, one at each end of a tile
	if (mask_sin == 0)
	{
		oy = array_create(2, oy div 1);
		ox = array_create(2, ox - ox mod 16);
		var right_sensor = mask_direction == 0; // 'Right' is absolute, not relative
		ox[right_sensor] += 15;
		
		// Clamp sensors to ground instance bounds, if applicable
		if (ground_id != noone)
		{
			ind = ground_id;
			ox[not right_sensor] = max(ox[not right_sensor], ind.bbox_left);
			ox[right_sensor] = min(ox[right_sensor], ind.bbox_right);
		}
	}
	else
	{
		ox = array_create(2, ox div 1);
		oy = array_create(2, oy - oy mod 16);
		var bottom_sensor = mask_direction == 270;
		oy[bottom_sensor] += 15;
		
		if (ground_id != noone)
		{
			ind = ground_id;
			oy[not bottom_sensor] = max(oy[not bottom_sensor], ind.bbox_top);
			oy[bottom_sensor] = min(oy[bottom_sensor], ind.bbox_bottom);
		}
	}
	
	// Extend / regress angle sensors
	for (var n = 0; n < 2; ++n)
	{
		repeat (16)
		{
			if (collision_point(ox[n], oy[n], ind, true, false) == noone)
			{
				ox[n] += mask_sin;
				oy[n] += mask_cos;
			}
			else if (collision_point(ox[n] - mask_sin, oy[n] - mask_cos, ind, true, false) != noone)
			{
				ox[n] -= mask_sin;
				oy[n] -= mask_cos;
			}
			else break;
		}
	}
	
	return round(point_direction(ox[0], oy[0], ox[1], oy[1]));
};