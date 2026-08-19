/// @description Initialize
image_speed = 0.125;
reaction = function (ind)
{
	// Abort if damaged or not intersecting
	if (recovery_time > 90 or state == player_is_hurt or not player_intersect(ind)) exit;
	
	// Collect
	player_gain_rings(1);
	with (ind)
	{
		particle_spawn("ring_sparkle", x, y);
		instance_destroy();
	}
};