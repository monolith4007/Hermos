/// @description Fade
var r = min(image_index * 4, 1);
var g = min(image_index * 2, 1);
var b = min(image_index, 1);
var color = make_color_rgb(r * 255, g * 255, b * 255);

gpu_set_blendmode(bm_subtract);
draw_rectangle_color(0, 0, CAMERA_WIDTH, CAMERA_HEIGHT, color, color, color, color, false);
gpu_set_blendmode(bm_normal);

if (b == 1) room_goto(target_room);