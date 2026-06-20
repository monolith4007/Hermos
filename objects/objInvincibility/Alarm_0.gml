/// @description Destroy
owner.invincibility_effect = noone;
with (owner.shield) visible = true;
audio_dequeue_bgm(bgmInvincibility);
instance_destroy();