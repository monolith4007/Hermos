/// @description Draw
var radius = 16;
var sine = dsin(inner_angle) * radius;
var cosine = dcos(inner_angle) * radius;

// First circle
var subimg = frame_table1[image_index mod array_length(frame_table1)];
if (image_index & 1 != 0)
{
	draw_sprite(sprInvincibilityStar, subimg, x + cosine, y - sine);
	draw_sprite(sprInvincibilityStar, subimg + 5, x - cosine, y + sine);
}
else
{
	draw_sprite(sprInvincibilityStar, subimg, x + sine, y + cosine);
	draw_sprite(sprInvincibilityStar, subimg + 5, x - sine, y - cosine);
}

sine = dsin(outer_angle) * radius;
cosine = dcos(outer_angle) * radius;

// Second circle
subimg = frame_table2[image_index mod array_length(frame_table2)];
draw_sprite(sprInvincibilityStar, subimg, circle_ox[0] + cosine, circle_oy[0] - sine);
draw_sprite(sprInvincibilityStar, subimg + 7, circle_ox[0] - cosine, circle_oy[0] + sine);

// Third circle
subimg = frame_table3[image_index mod array_length(frame_table3)];
draw_sprite(sprInvincibilityStar, subimg, circle_ox[1] - sine, circle_oy[1] - cosine);
draw_sprite(sprInvincibilityStar, subimg + 6, circle_ox[1] + sine, circle_oy[1] + cosine);

// Fourth circle
subimg = frame_table4[image_index mod array_length(frame_table4)];
draw_sprite(sprInvincibilityStar, subimg, circle_ox[2] + cosine, circle_oy[2] - sine);
draw_sprite(sprInvincibilityStar, subimg + 5, circle_ox[2] - cosine, circle_oy[2] + sine);