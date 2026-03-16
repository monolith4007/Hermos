/// @description Stop
audio_stop_all();
ds_priority_clear(playlist);
if (jingle != -1)
{
	jingle = -1;
	alarm[0] = -1;
}