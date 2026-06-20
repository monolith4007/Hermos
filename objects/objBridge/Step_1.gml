/// @description Bend / Elevate
var mean_node = -1;
with (objPlayer) if (ground_id == other.id)
{
	mean_node = clamp(x - other.bbox_left, 0, other.sprite_width) / other.sprite_width;
}

var base_tension = 0;
if (mean_node != -1)
{
	ratio = mean_node;
	var max_tension = 16;
	base_tension = max_tension * dsin(ratio * 180);
}
if (tension != base_tension)
{
	tension = lerp(tension, base_tension, 0.2) div 1;
	y = ystart + tension;
}