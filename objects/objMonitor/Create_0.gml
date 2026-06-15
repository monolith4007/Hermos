/// @description Initialize
event_inherited();
reaction = function (ind)
{
	if (not rolling) exit;
	
	if (y_speed < 0)
	{
		if (player_boxcast(ind, -y_radius) and not player_linecast(ind)) then with (ind)
		{
			tilemap = ctrlZone.tilemaps[0];
			vspeed = -2;
			gravity = 0.21875;
			alarm[0] = 1;
		}
	}
	else if (player_intersect(ind, x_wall_radius))
	{
		y_speed *= -1;
		audio_play_sfx(sfxDestroy);
		
		with (ind)
		{
			particle_spawn("explosion", x, y);
			instance_create_layer(x, y, layer, objMonitorBroken, { image_speed: 0 });
			instance_create_layer(x, y - 5, layer, objMonitorIcon,
			{
				image_speed: 0,
				image_index: icon,
				vspeed: -3,
				gravity: 0.09375,
				alarm: 32, // Defaults to Alarm 0 (using [] in struct entries is not permitted)
				owner: other.id
			});
			instance_destroy();
		}
	}
};