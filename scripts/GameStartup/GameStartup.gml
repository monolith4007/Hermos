// Constants
#macro CAMERA_ID view_camera[0]
#macro CAMERA_PADDING 64
#macro CAMERA_WIDTH 400
#macro CAMERA_HEIGHT 224

#macro SUBPIXEL 0.00390625

enum INPUT
{
	UP, DOWN, LEFT, RIGHT, ACTION
}

enum PHASE
{
	ENTER, STEP, EXIT
}

enum ICON
{
	RING, SNEAKER, INVINCIBILITY, EGGMAN, SUPER, SHIELD, LIGHTNING, FIRE, BUBBLE, LIFE
}

// Misc.
display_set_sleep_margin(1);
surface_depth_disable(true);
gc_target_frame_time(-100);
show_debug_overlay(true);
randomize();

// Audio
audio_channel_num(10);
volume_sound = 1;
volume_music = 1;

// Player values
score = 0;
lives = 3;
rings = 0;
rings_for_life = 99;

// Fonts
font_hud = font_add_sprite(sprFontHUD, ord("0"), false, 1);
font_lives = font_add_sprite(sprFontLives, ord("0"), false, 0);
font_title = font_add_sprite(sprFontTitle, ord("A"), true, 0);

// Particles
sprite_particles = {};
with (sprite_particles)
{
	system = part_system_create();
	
	brake_dust = part_type_create();
	part_type_life(brake_dust, 16, 16);
	part_type_sprite(brake_dust, sprBrakeDust, true, true, false);
	
	ring_sparkle = part_type_create();
	part_type_life(ring_sparkle, 24, 24);
	part_type_sprite(ring_sparkle, sprRingSparkle, true, true, false);
	
	explosion = part_type_create();
	part_type_life(explosion, 30, 30);
	part_type_sprite(explosion, sprExplosion, true, true, false);
	
	exhaust = part_type_create();
	part_type_life(exhaust, 16, 16);
	part_type_sprite(exhaust, sprExhaust, true, true, false);
	
	points = part_type_create();
	part_type_life(points, 32, 32);
	part_type_sprite(points, sprPoints, false, false, false);
	part_type_direction(points, 90, 90, 0, 0);
	part_type_gravity(points, 0.09375, 270);
	part_type_speed(points, 3, 3, 0, 0);
}

// Start the game!
call_later(1, time_source_units_frames, room_goto_next);