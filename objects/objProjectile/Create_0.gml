/// @description Initialize
image_speed = 0;
reaction = function (ind)
{
	if (player_intersect(ind)) player_damage(ind);
};