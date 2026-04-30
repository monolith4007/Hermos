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
	return mask_direction mod 180 == 0 ?
		collision_rectangle(x_int - xrad, y_int - yrad, x_int + xrad + SUBPIXEL, y_int + yrad + SUBPIXEL, ind, true, false) != noone :
		collision_rectangle(x_int - yrad, y_int - xrad, x_int + yrad + SUBPIXEL, y_int + xrad + SUBPIXEL, ind, true, false) != noone;
};

/// @method player_boxcast
/// @description Checks if the given collider's mask intersects a vertical portion of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Real} ylen Distance to extend the player's mask vertically.
/// @returns {Bool}
player_boxcast = function (ind, ylen)
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	var x1 = x_int - cosine * x_radius;
	var y1 = y_int + sine * x_radius;
	var x2 = x_int + cosine * x_radius + sine * ylen;
	var y2 = y_int - sine * x_radius + cosine * ylen;
	
	// Extend right/bottom sides slightly for tilemaps
	var left = min(x1, x2);
	var top = min(y1, y2);
	var right = max(x1, x2) + SUBPIXEL;
	var bottom = max(y1, y2) + SUBPIXEL;
	
	return collision_rectangle(left, top, right, bottom, ind, true, false) != noone;
};

/// @method player_linecast
/// @description Checks if the given collider's mask intersects the 'arms' of the player's virtual mask.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Real} [xrad] Distance to extend the player's mask horizontally both ways (optional, default is the player's wall radius).
/// @returns {Bool}
player_linecast = function (ind, xrad = x_wall_radius)
{
	var x_int = x div 1;
	var y_int = y div 1;
	
	return mask_direction mod 180 == 0 ?
		collision_line(x_int - xrad, y_int, x_int + xrad, y_int, ind, true, false) != noone :
		collision_line(x_int, y_int - xrad, x_int, y_int + xrad, ind, true, false) != noone;
};

/// @method player_raycast
/// @description Checks if the given collider's mask intersects a line from the player.
/// @param {Asset.GMObject|Id.Instance|Id.TileMapElement|Array} ind Object, instance, or tilemap to check, or an array containing any of these.
/// @param {Real} xoff Distance to offset the line horizontally.
/// @param {Real} ylen Distance to extend the line vertically.
/// @returns {Bool}
player_raycast = function (ind, xoff, ylen)
{
	var x_int = x div 1;
	var y_int = y div 1;
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	var x1 = x_int + cosine * xoff;
	var y1 = y_int - sine * xoff;
	var x2 = x_int + cosine * xoff + sine * ylen;
	var y2 = y_int - sine * xoff + cosine * ylen;
	
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
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	var x1 = x_int - cosine * x_wall_radius - sine * y_radius;
	var y1 = y_int + sine * x_wall_radius - cosine * y_radius;
	var x2 = x_int + cosine * x_wall_radius;
	var y2 = y_int - sine * x_wall_radius;
	
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
	
	// Detect instances intersecting the player's virtual mask
	static instances = ds_list_create();
	ds_list_clear(instances);
	
	var total = sine == 0 ?
		collision_rectangle_list(x_int - x_wall_radius, y_int - y_radius - 1, x_int + x_wall_radius, y_int + y_radius + 1, objZoneObject, true, false, instances, false) :
		collision_rectangle_list(x_int - y_radius - 1, y_int - x_wall_radius, x_int + y_radius + 1, y_int + x_wall_radius, objZoneObject, true, false, instances, false);
	
	// Execute reactions
	for (var n = 0; n < total; ++n)
	{
		var ind = instances[| n];
		script_execute(ind.reaction, ind);
		
		// Register solid instances (exclude semisolids)
		if (not (instance_exists(ind) and object_is_ancestor(ind.object_index, objSolid))) continue;
		if (ind.semisolid and collision_rectangle(x1, y1, x2, y2, ind, true, false) != noone) continue;
		
		array_push(hard_colliders, ind);
		
		// Update current ground
		if (ground_id != ind and y_speed >= 0 and player_boxcast(ind, y_radius + on_ground))
		{
			ground_id = ind;
		}
	}
};

/// @method player_calc_tile_normal
/// @description Calculates the surface normal of the tiles found within the 16x16 area relative to the given point.
/// @param {Real} x x-coordinate of the point.
/// @param {Real} y y-coordinate of the point.
/// @returns {Real}
player_calc_tile_normal = function (ox, oy)
{
	var sine = dsin(mask_direction);
	var cosine = dcos(mask_direction);
	
	// Set up angle sensors, one at each end of a tile
	if (sine == 0)
	{
		var sensor_y = array_create(2, oy);
		var sensor_x = array_create(2, ox - ox mod 16);
		sensor_x[mask_direction == 0] += 15;
	}
	else
	{
		var sensor_x = array_create(2, ox);
		var sensor_y = array_create(2, oy - oy mod 16);
		sensor_y[mask_direction == 270] += 15;
	}
	
	// Extend / regress angle sensors
	for (var n = 0; n < 2; ++n)
	{
		repeat (16)
		{
			if (collision_point(sensor_x[n], sensor_y[n], hard_colliders, true, false) == noone)
			{
				sensor_x[n] += sine;
				sensor_y[n] += cosine;
			}
			else if (collision_point(sensor_x[n] - sine, sensor_y[n] - cosine, hard_colliders, true, false) != noone)
			{
				sensor_x[n] -= sine;
				sensor_y[n] -= cosine;
			}
			else break;
		}
	}
	
	return round(point_direction(sensor_x[0], sensor_y[0], sensor_x[1], sensor_y[1]));
};