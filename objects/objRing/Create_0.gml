/// @description Initialize
image_speed = 0.125;
reaction = function (ind)
{
	// Abort if not intersecting
	if (not player_intersect(ind)) exit;
	
	// Collect
	player_gain_rings(1);
	with (ind)
	{
		particle_spawn("ring_sparkle", x, y);
		instance_destroy();
	}
};