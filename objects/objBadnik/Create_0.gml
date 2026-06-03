/// @description Initialize
image_speed = 0;
reaction = function (ind)
{
	// Abort if not intersecting
	if (not player_intersect(ind)) exit;
	
	// Take damage if not in an attacking state
	if (not (rolling or invincibility_time > 0))
	{
		return player_damage(ind);
	}
	
	// Rebound
	if (y_speed > 0 and not player_boxcast(ind, -y_radius))
	{
		y_speed *= -1;
	}
	else y_speed -= sign(y_speed);
	
	// Score
	var bonus = 100;
	var subimg = 1;
	
	if (rolling)
	{
		if (++badnik_chain > 15)
		{
			bonus = 10000;
			subimg = 5;
		}
		else if (badnik_chain > 3)
		{
			bonus = 1000;
			subimg = 4;
		}
		else if (badnik_chain == 3)
		{
			bonus = 500;
			subimg = 3;
		}
		else if (badnik_chain == 2)
		{
			bonus = 200;
			subimg = 2;
		}
	}
	
	player_gain_score(bonus);
	part_type_subimage(global.sprite_particles.points, subimg);
	with (ind)
	{
		particle_spawn("points", x, y);
		particle_spawn("explosion", x, y);
		instance_destroy();
	}
	
	audio_play_sfx(sfxDestroy);
};