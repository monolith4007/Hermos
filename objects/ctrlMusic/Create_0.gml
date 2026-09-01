/// @description Initialize
image_speed = 0;
playlist = ds_priority_create();
looping_music = [bgmMadGear];
stream = -1;
jingle = -1;

play_music = function (ind)
{
	audio_stop_sound(stream);
	stream = audio_play_sound(ind, 0, array_contains(looping_music, ind), global.volume_music * (jingle == -1));
};

var set_loop_points = function (ind, loop_start, loop_end)
{
	audio_sound_loop_start(ind, loop_start);
	audio_sound_loop_end(ind, loop_end);
	array_push(looping_music, ind);
};