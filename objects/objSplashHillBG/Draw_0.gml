/// @description Draw
var vx = camera_get_view_x(CAMERA_ID);
var vy = camera_get_view_y(CAMERA_ID);
var right = vx + CAMERA_WIDTH;
var ratio = CAMERA_WIDTH / surface_get_width(application_surface);
var top = 0;

gpu_set_blendenable(false);

// Note: horizontal tiling to the left has not been added, so if a section scrolls to the right past the camera's x-position, it will not be drawn to the left.
// This can be addressed by appending `mod sprite_width - sprite_width` when assigning to `left`.

// Clouds + ocean
var left = vx * 0.9 - clouds_offset;
for (var ox = round(left / ratio) * ratio; ox < right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, clouds_height, ox, vy, 1, image_yscale, c_white, 1);
}
top += clouds_height;
vy += clouds_height * image_yscale;

// Rocks
left = vx * 0.85;
for (ox = round(left / ratio) * ratio; ox < right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, rocks_height, ox, vy, 1, image_yscale, c_white, 1);
}
top += rocks_height;
vy += rocks_height * image_yscale;

// Bushes
left = vx * 0.8;
for (ox = round(left / ratio) * ratio; ox < right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, bushes_height, ox, vy, 1, image_yscale, c_white, 1);
}
top += bushes_height;
vy += bushes_height * image_yscale;

// Checkerboard
left = vx * 0.75;
for (ox = round(left / ratio) * ratio; ox < right; ox += sprite_width)
{
	draw_sprite_part_ext(sprite_index, 0, 0, top, sprite_width, checkered_height, ox, vy, 1, image_yscale, c_white, 1);
}

gpu_set_blendenable(true);