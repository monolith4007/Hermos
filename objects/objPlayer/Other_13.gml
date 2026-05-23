/// @description Misc.

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
	if (recovery_time > 0 or state == player_is_hurt) exit;
	
	// Recoil / Die
	if (global.rings > 0)
	{
		player_perform(player_is_hurt);
		if (not on_ground) rolling = false;
	
		x_speed = 2 * sign(x - ind.x);
		if (x_speed == 0) x_speed = 2;
		y_speed = -4;
	}
	else player_perform(player_is_dead);
};