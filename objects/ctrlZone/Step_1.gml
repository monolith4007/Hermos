/// @description Time / Pause
if (time_enabled and ++stage_time == time_limit)
{
	time_over = true;
	with (objPlayer) player_perform(player_is_dead);
}

if (can_pause and input_check_pressed(INPUT.START))
{
	if (not instance_exists(objPause))
	{
		instance_create_layer(0, 0, layer, objPause);
	}
	else instance_destroy(objPause);
}