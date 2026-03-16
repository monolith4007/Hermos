/// @description Plays the given sound effect, first stopping any existing instances of it.
/// @param {Asset.GMSound} ind Sound effect to play.
/// @returns {Id.Sound}
function audio_play(ind)
{
	audio_stop_sound(ind);
	return audio_play_sound(ind, 1, false, global.volume_sound);
}

/// @description Plays the given music track as a jingle. Background music is muted until the jingle has finished playing.
/// @param {Asset.GMSound} ind Music track to play.
function audio_play_jingle(ind)
{
	with (ctrlMusic)
	{
		if (jingle == -1) audio_sound_gain(music, 0);
		else audio_stop_sound(jingle);
		
		jingle = audio_play_sound(ind, 2, false, global.volume_music);
		alarm[0] = audio_sound_length(ind) * room_speed;
	}
}

/// @description Adds the given music track to the playlist, playing it if it has the highest priority.
/// @param {Asset.GMSound} ind Music track to add.
/// @param {Real} priority Priority value to assign.
function audio_enqueue_music(ind, priority)
{
	with (ctrlMusic)
	{
		if (ds_priority_find_priority(playlist, ind) == undefined)
		{
			ds_priority_add(playlist, ind, priority);
		}
		
		if (ds_priority_find_max(playlist) == ind)
		{
			play_music(ind);
		}
	}
}

/// @description Removes the given music track from the playlist. If it was playing, the next track below is then played.
/// @param {Asset.GMSound} ind Music track to remove.
function audio_dequeue_music(ind)
{
	with (ctrlMusic)
	{
		ds_priority_delete_value(playlist, ind);
		if (audio_is_playing(ind)) play_music(ds_priority_find_max(playlist));
	}
}