/// @description Move
if (offset > 0)
{
	offset = max(offset - 16, 0);
	if (offset == 0) call_later(audio_sound_length(bgmGameOver), time_source_units_seconds, function ()
	{
		instance_create_layer(0, 0, layer, objFade, { target_room: room });
	});
}