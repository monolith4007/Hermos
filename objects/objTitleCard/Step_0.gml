/// @description Animate
var enter_speed = 16;
var exit_speed = 32;

switch (state)
{
	// Enter setpieces
	case 0:
	{
		// Descend blue backdrop
		if (backdrop_offset < CAMERA_HEIGHT)
		{
			backdrop_offset = min(backdrop_offset + enter_speed, CAMERA_HEIGHT);
		}
		
		// Shift yellow band to the left
		if (band_offset > 0) band_offset = max(band_offset - enter_speed, 0);
		
		// Shift red banner to the right
		// It's 112 pixels wide not accounting for the fold width, and we want it + the yellow band to stop simultaneously
		if (band_offset < 112 + fold_width)
		{
			banner_offset = min(banner_offset + enter_speed, 112);
			if (banner_offset == 112) state = 1;
		}
		break;
	}
	
	// Enter labels
	case 1:
	{
		label_offset = max(label_offset - enter_speed, 0);
		if (label_offset == 0)
		{
			// Display full title card temporarily (blank state, so not included below)
			state = 2;
			alarm[0] = 1.25 * room_speed;
		}
		break;
	}
	
	// Exit red banner to the left
	case 3:
	{
		banner_offset -= exit_speed;
		if (banner_offset <= -fold_width) state = 4;
		break;
	}
	
	// Exit yellow band to the right
	case 4:
	{
		band_offset += exit_speed;
		if (band_offset >= CAMERA_WIDTH) state = 5;
		break;
	}
	
	// Ascend blue backdrop
	case 5:
	{
		backdrop_offset -= exit_speed;
		if (backdrop_offset <= 0)
		{
			// Start stage
			ctrlZone.time_enabled = true;
			instance_activate_layer("ZoneObjects");
			
			// Display labels temporarily (also a blank state)
			state = 6;
			alarm[0] = 1.25 * room_speed;
		}
		break;
	}
	
	// Exit labels
	case 7:
	{
		label_offset += exit_speed;
		if (label_offset >= CAMERA_WIDTH)
		{
			ctrlZone.can_pause = true;
			instance_destroy();
		}
		break;
	}
}