/// @description Destroy
with (owner)
{
	invincibility_effect = noone;
	with (shield) visible = true;
}
audio_dequeue_bgm(bgmInvincibility);
instance_destroy();