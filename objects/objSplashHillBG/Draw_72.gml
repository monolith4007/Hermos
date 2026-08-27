/// @description Draw
var vx = camera_get_view_x(CAMERA_ID);
var vy = camera_get_view_y(CAMERA_ID) * image_yscale;
var right = vx + CAMERA_WIDTH;
var top = 0;

gpu_set_blendenable(false);

// Clouds and ocean
for (var ox = vx * 0.9 - clouds_offset; ox < right; ox += sprite_width)
{
	draw_sprite_part(sprite_index, 0, 0, top, sprite_width, clouds_height, ox, vy);
}
top += clouds_height;
vy += clouds_height;

// Rocks
for (ox = vx * 0.85; ox < right; ox += sprite_width)
{
	draw_sprite_part(sprite_index, 0, 0, top, sprite_width, rocks_height, ox, vy);
}
top += rocks_height;
vy += rocks_height;

// Bushes
for (ox = vx * 0.8; ox < right; ox += sprite_width)
{
	draw_sprite_part(sprite_index, 0, 0, top, sprite_width, bushes_height, ox, vy);
}
top += bushes_height;
vy += bushes_height;

// Checkerboard
for (ox = vx * 0.75; ox < right; ox += sprite_width)
{
	draw_sprite_part(sprite_index, 0, 0, top, sprite_width, checkered_height, ox, vy);
}

gpu_set_blendenable(true);