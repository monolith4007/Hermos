/// @description Initialize
instance_deactivate_layer("ZoneObjects");
state = 0;

// Setpieces
backdrop_offset = 0;
band_offset = CAMERA_WIDTH;
fold_width = sprite_get_width(sprTitleCardFold);
banner_offset = -fold_width;

// Labels
draw_set_font(global.font_title);
var border = CAMERA_WIDTH * 0.1;
name_ox = CAMERA_WIDTH - string_width(name) - border;
zone_ox = CAMERA_WIDTH - string_width("ZONE") - sprite_get_width(sprActNumber) - border;
label_offset = CAMERA_WIDTH;