/// @description Draw
var vx = camera_get_view_x(CAMERA_ID);
var vy = camera_get_view_y(CAMERA_ID);
var right = vx + CAMERA_WIDTH + sprite_width;
var top = 0;

// Clouds + ocean
var left = vx + ((vx / 1.1 - clouds_offset - vx) mod sprite_width) - sprite_width;
for (var ox = left; ox <= right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, clouds_height, ox, vy, 1, image_yscale, c_white, 1);
}
top += clouds_height;
vy += clouds_height * image_yscale;

// Rocks
left = vx + ((vx / 1.15 - vx) mod sprite_width) - sprite_width;
for (ox = left; ox <= right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, rocks_height, ox, vy, 1, image_yscale, c_white, 1);
}
top += rocks_height;
vy += rocks_height * image_yscale;

// Bushes
left = vx + ((vx / 1.2 - vx) mod sprite_width) - sprite_width;
for (ox = left; ox <= right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, bushes_height, ox, vy, 1, image_yscale, c_white, 1);
}
top += bushes_height;
vy += bushes_height * image_yscale;

// Checkerboard
left = vx + ((vx / 1.25 - vx) mod sprite_width) - sprite_width;
for (ox = left; ox <= right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, checkered_height, ox, vy, 1, image_yscale, c_white, 1);
}