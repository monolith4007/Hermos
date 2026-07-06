/// @description Initialize
image_speed = 0;
snapshot = sprite_create_from_surface(application_surface, 0, 0, surface_get_width(application_surface), surface_get_height(application_surface), false, false, 0, 0);

audio_pause_all();
instance_deactivate_object(ctrlMusic);
instance_deactivate_layer("ZoneObjects");
part_system_automatic_update(global.sprite_particles.system, false);

ctrlZone.time_enabled = false;
ctrlWindow.image_speed = 0;