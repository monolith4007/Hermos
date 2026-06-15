/// @description Draw
var offset = ratio * sprite_width;
for (var n = 0; n < sprite_width; n += node_width)
{
	// Get relative tension
	var height = tension;
	if (n < offset)
	{
		height *= dsin((n / offset) * 90);
	}
	else if (n > offset)
	{
		height *= dsin(((sprite_width - n) / (sprite_width - offset)) * 90);
	}
	
	// Logs
	draw_sprite(sprite_index, 0, bbox_left + n, ystart + height);
}

// Posts
draw_sprite(sprBridgePost, 0, bbox_left - 16, ystart - 16);
draw_sprite(sprBridgePost, 0, bbox_right, ystart - 16);