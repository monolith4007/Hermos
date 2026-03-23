/// @description Initialize
image_speed = 0;

// Timing
stage_time = 0;
time_limit = 36000;
time_over = false;
time_enabled = true;

// Location
switch (room)
{
	case rmTest:
	{
		name = "DEMONSTRATION";
		act = 1;
		audio_enqueue_bgm(bgmMadGear, 0);
		break;
	}
}

// Tilemaps
tilemaps =
[
	layer_tilemap_get_id("CollisionMain"),
	layer_tilemap_get_id("CollisionPath0"),
	layer_tilemap_get_id("CollisionPath1"),
	layer_tilemap_get_id("CollisionSemisolid")
];

if (tilemaps[3] == -1) array_pop(tilemaps);
if (tilemaps[1] == -1) array_delete(tilemaps, 1, 2);

// Zone controller must be at the top of the Instance Creation Order to access this array without error.

// Create UI elements
instance_create_layer(0, 0, "Master", objHUD, { image_speed: 0 });