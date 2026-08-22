/// @description Initialize
event_inherited();
log_current = -1;
log_width = sprite_get_width(sprite_index);
tension = 0;
max_tension = image_xscale + image_xscale mod 2;