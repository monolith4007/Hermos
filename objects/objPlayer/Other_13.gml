/// @description Misc.

/// @method player_gain_score
/// @description Increases the player's score count by the given amount.
/// @param {Real} num Amount of points to give.
player_gain_score = function (num)
{
	var previous_num = score div 50000;
	score = min(score + num, 999999);
	
	// Gain lives
	num = score div 50000;
	if (num != previous_num) player_gain_lives(num - previous_num);
};

/// @method player_gain_rings
/// @description Increases the player's ring count by the given amount.
/// @param {Real} num Amount of rings to give.
player_gain_rings = function (num)
{
	global.rings = min(global.rings + num, 999);
	audio_play_sfx(sfxRing);
	
	// Gain lives
	if (global.rings > global.rings_for_life)
	{
		num = global.rings div 100;
		player_gain_lives(num - global.rings_for_life div 100);
		global.rings_for_life = num * 100 + 99;
	}
};

/// @method player_gain_lives
/// @description Increases the player's life count by the given amount.
/// @param {Real} num Amount of lives to give.
player_gain_lives = function (num)
{
	lives = min(lives + num, 99);
	audio_play_jingle(bgmLife);
};

/// @method player_damage
/// @description Evaluates the player's condition after taking a hit.
/// @param {Id.Instance} ind Instance to recoil from.
player_damage = function (ind)
{
	// Abort if invulnerable
	if (recovery_time > 0 or state == player_is_hurt or invincibility_effect != noone) exit;
	
	if (shield != noone)
	{
		audio_play_sfx(sfxDeath);
		instance_destroy(shield);
		shield = noone;
	}
	else if (global.rings == 0)
	{
		return player_perform(player_is_dead);
	}
	else player_drop_rings();
	
	// Recoil
	player_perform(player_is_hurt);
	
	x_speed = 2 * sign(x - ind.x);
	if (x_speed == 0) x_speed = 2;
	y_speed = -4;
	
	if (rolling)
	{
		rolling = false;
		badnik_chain = 0;
	}
};

/// @method player_drop_rings
/// @description Spawns up to 32 dropped rings in circles of 16 at the player's position, and reduces their ring count by the former amount.
player_drop_rings = function ()
{
	var total = min(global.rings, 32);
	global.rings -= total;
	audio_play_sfx(sfxRingLoss);
	
	var tilemaps = ctrlZone.tilemaps; // Initialized here to reduce the number of dot operator usages
	var gravity_sin = dsin(gravity_direction);
	var gravity_cos = dcos(gravity_direction);
	var spd = 4;
	var dir = 101.25;
	
	repeat (total)
	{
		var ind = instance_create_layer(x, y, layer, objRingDropped,
		{
			tilemaps, gravity_direction,
			gravity_sin, gravity_cos,
			x_speed: lengthdir_x(spd, dir),
			y_speed: lengthdir_y(spd, dir)
		});
		
		if (total & 1 != 0)
		{
			ind.x_speed *= -1;
			dir += 22.5;
		}
		
		if (--total == 16)
		{
			spd = 2;
			dir = 101.25;
		}
	}
};