/// @description Destroy
owner.invincibility = noone;
with (owner.shield) visible = true;
audio_dequeue_bgm(bgmInvincibility);
instance_destroy();