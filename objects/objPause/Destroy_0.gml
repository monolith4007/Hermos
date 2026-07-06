/// @description Cleanup
sprite_delete(snapshot);

audio_resume_all();
instance_activate_object(ctrlMusic);
instance_activate_layer("ZoneObjects");
part_system_automatic_update(global.sprite_particles.system, true);

ctrlZone.time_enabled = true;
ctrlWindow.image_speed = 1;