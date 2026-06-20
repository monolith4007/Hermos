/// @description Reward / Destroy
if (gravity == 0)
{
	instance_destroy();
	exit;
}

vspeed = 0;
gravity = 0;
alarm[0] = 32;

with (owner) switch (other.image_index)
{
	case ICON.RING:
	{
		player_gain_rings(10);
		break;
	}
	case ICON.SNEAKER:
	{
		superspeed_time = 1200;
		player_refresh_physics();
		break;
	}
	case ICON.INVINCIBILITY:
	{
		if (invincibility_effect == noone)
		{
			invincibility_effect = instance_create_depth(x, y, depth - 1, objInvincibility, { owner: id });
			with (shield) visible = false;
		}
		invincibility_effect.alarm[0] = 1200;
		audio_enqueue_bgm(bgmInvincibility, 1);
		break;
	}
	case ICON.EGGMAN:
	{
		player_damage(self);
		break;
	}
	case ICON.SHIELD:
	{
		if (shield == noone)
		{
			shield = instance_create_depth(x, y, depth - 1, objShield, { visible: invincibility_effect == noone, owner: id });
		}
		audio_play_sfx(sfxShield);
		break;
	}
	case ICON.LIFE:
	{
		player_gain_lives(1);
		break;
	}
}