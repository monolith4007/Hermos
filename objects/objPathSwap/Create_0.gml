/// @description Initialize
image_speed = 0;
reaction = function (ind)
{
	if (collision_point(x, y, ind, false, false) != noone and x != xprevious)
	{
		collision_path = sign(ind.image_xscale) == sign(x - xprevious);
		hard_colliders[1] = ctrlZone.tilemaps[collision_path + 1];
	}
};