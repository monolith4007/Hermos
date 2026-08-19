/// @description Fade
var r = min(image_index * 5, 1) * 255;
var g = min(image_index * 2.5, 1) * 255;
var b = min(image_index * 1.25, 1) * 255;
var color = make_color_rgb(r, g, b);

gpu_set_blendmode(bm_subtract);
draw_rectangle_color(0, 0, CAMERA_WIDTH, CAMERA_HEIGHT, color, color, color, color, false);
gpu_set_blendmode(bm_normal);

if (image_index >= 1) room_goto(target_room);