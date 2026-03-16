/// @description Initialize
image_speed = 0;

playlist = ds_priority_create();
looped_music = [];
music = -1;
jingle = -1;

/// @method set_music_loop
/// @description Sets loop points for the given music track.
/// @param {Asset.GMSound} ind Music track to set loop points for.
/// @param {Real} loop_start Start point of the loop in seconds.
/// @param {Real} loop_end End point of the loop in seconds.
var set_music_loop = function (ind, loop_start, loop_end)
{
	audio_sound_loop_start(ind, loop_start);
	audio_sound_loop_end(ind, loop_end);
	array_push(looped_music, ind);
};

// Define music loop points here; looped music w/o loop points should be inserted into the `looped_music` array.

/// @method play_music
/// @description Plays the given music track, muting it if a jingle is playing.
/// @param {Asset.GMSound} ind Music track to play.
play_music = function (ind)
{
	audio_stop_sound(music);
	music = audio_play_sound(ind, 0, array_contains(looped_music, ind), global.volume_music * (jingle == -1));
};