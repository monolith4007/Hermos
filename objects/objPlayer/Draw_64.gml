/// @description Debug
var text = $"State: {script_get_name(state)}\n";
text += $"Speed: {string_format(x_speed, 3, 2)} | {string_format(y_speed, 3, 2)}\n";
text += $"Direction: {string_format(direction, 3, 0)} | {string_format(local_direction, 3, 0)}\n";
text += $"Mask Direction: {mask_direction}\n";
text += $"Control Lock: {control_lock_time}\n";
text += $"Rolling: {rolling}\n";
text += $"Ground Instance: {real(ground_id)}";

draw_set_font(-1);
draw_set_halign(fa_right);
draw_text_transformed_color(CAMERA_WIDTH - 10, 10, text, 0.5, 0.5, 0, c_fuchsia, c_fuchsia, c_fuchsia, c_fuchsia, 1);
draw_set_halign(fa_left);