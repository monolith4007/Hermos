/// @description Initialize
image_speed = 0;

// State machine
state = player_is_ready;
state_changed = false;

rolling = false;
spindash_charge = 0;
peelout_time = 0;

// Timers
control_lock_time = 0;
recovery_time = 0;
superspeed_time = 0;

camera_look_delay = 120;
camera_look_time = camera_look_delay;

// Movement and collision
x_speed = 0;
y_speed = 0;

slide_threshold = 2.5;
slide_duration = 30;

air_drag_threshold = 0.125;
air_drag = 0.96875;

roll_threshold = 0.5;

x_radius = 8;
x_wall_radius = 10;

y_radius = 15;
y_snap_distance = 14;

landed = false;
on_ground = true;
ground_id = noone;

direction = 0;
gravity_direction = 0;
local_direction = 0;
mask_direction = 0;
mask_sin = 0;
mask_cos = 1;

wall_sign = 0;
cliff_sign = 0;

hard_colliders = variable_clone(ctrlZone.tilemaps, 0);
tilemap_count = array_length(hard_colliders);

// Validate semisolid tilemap
if (tilemap_count & 1 == 0)
{
	semisolid_tilemap = array_pop(hard_colliders);
	--tilemap_count;
}
else semisolid_tilemap = -1;

// Delist "CollisionPath1" layer tilemap
if (tilemap_count == 3)
{
	array_pop(hard_colliders);
	--tilemap_count;
	collision_path = 0;
}

// Methods
var n = 0;
repeat (4) event_user(n++);

// Misc.
instance_create_layer(x, y, layer, objCamera, { gravity_direction });
badnik_chain = 0;
shield = noone;
invincibility_effect = noone;

// Animations
animations =
{
	idle: animSonicIdle,
	walk: animSonicWalk,
	run: animSonicRun,
	sprint: animSonicSprint,
	roll: animSonicRoll,
	look: animSonicLook,
	crouch: animSonicCrouch,
	spindash: animSonicSpindash,
	teeter: animSonicTeeter,
	brake: animSonicBrake,
	rise: animSonicRise,
	hurt: animSonicHurt,
	push: animSonicPush,
	dead: animSonicDead
};