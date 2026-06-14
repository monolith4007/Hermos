/// @description Draw
var vx = camera_get_view_x(CAMERA_ID);
var vy = camera_get_view_y(CAMERA_ID);
var limit = vx / sprite_width + CAMERA_WIDTH / sprite_width;
var top = 0;

// Clouds + ocean
for (var n = -1; n < limit; ++n)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, clouds_height, vx / 1.1 mod sprite_width + sprite_width * n, vy, 1, scale_factor, c_white, 1);
}
top += clouds_height;
vy += clouds_height * scale_factor;

// Rocks
for (n = -1; n < limit; ++n)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, rocks_height, vx / 1.15 mod sprite_width + sprite_width * n, vy, 1, scale_factor, c_white, 1);
}
top += rocks_height;
vy += rocks_height * scale_factor;

// Bushes
for (n = -1; n < limit; ++n)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, bushes_height, vx / 1.2 mod sprite_width + sprite_width * n, vy, 1, scale_factor, c_white, 1);
}
top += bushes_height;
vy += bushes_height * scale_factor;

// Checkerboard
for (n = -1; n < limit; ++n)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, checkered_height, vx / 1.25 mod sprite_width + sprite_width * n, vy, 1, scale_factor, c_white, 1);
}