/// @description Elevate
var current = -1;
with (objPlayer) if (ground_id == other.id)
{
	current = (x - other.x) / other.log_width;
}

var base_tension = 0;
if (current != -1)
{
	log_current = current;
	base_tension = max_tension * dsin(current / image_xscale * 180);
}

if (tension != base_tension)
{
	tension = lerp(tension, base_tension, 0.2) div 1;
	y = ystart + tension;
}