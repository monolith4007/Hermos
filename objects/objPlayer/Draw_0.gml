/// @description Draw
var x_int = x div 1;
var y_int = y div 1;

// Sprite
if (sprite_index != -1)
{
	shader_set(shdPaletteSwap);
	
	var samp_targets = shader_get_sampler_index(shdPaletteSwap, "samp_targets");
	texture_set_stage(samp_targets, sprite_get_texture(sprSonicPalette, 0));
	
	draw_sprite_ext(sprite_index, image_index, x_int, y_int, image_xscale, 1, image_angle, c_white, image_alpha);
	
	shader_reset();
}

// Dash smoke
if (state == player_is_spindashing or state == player_is_peelouting)
{
	draw_sprite_ext(sprDashSmoke, ctrlWindow.image_index div 2, x_int, y_int, image_xscale, 1, mask_direction, c_white, 1);
}

// Virtual mask
if (mask_sin == 0)
{
	draw_rectangle_color(x_int - x_radius, y_int - y_radius, x_int + x_radius, y_int + y_radius, c_lime, c_lime, c_lime, c_lime, true);
	draw_line_color(x_int - x_wall_radius, y_int, x_int + x_wall_radius, y_int, c_white, c_white);
}
else
{
	draw_rectangle_color(x_int - y_radius, y_int - x_radius, x_int + y_radius, y_int + x_radius, c_lime, c_lime, c_lime, c_lime, true);
	draw_line_color(x_int, y_int - x_wall_radius, x_int, y_int + x_wall_radius, c_white, c_white);
}
draw_line_color(x_int, y_int, x_int + mask_sin * y_radius, y_int + mask_cos * y_radius, c_white, c_white);