/// @description Draw
for (var log = 0; log < image_xscale; ++log)
{
	var height = tension;
	if (log < log_current)
	{
		height *= log / log_current;
	}
	else if (log > log_current)
	{
		height *= (image_xscale - log) / (image_xscale - log_current);
	}
	
	draw_sprite(sprite_index, 0, x + log * log_width, ystart + height);
}

/*
draw_sprite(sprBridgePost, 0, bbox_left - 16, ystart - 16);
draw_sprite(sprBridgePost, 0, bbox_right, ystart - 16);