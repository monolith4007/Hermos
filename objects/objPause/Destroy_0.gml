/// @description Cleanup
sprite_delete(snapshot);

audio_resume_all();
instance_activate_layer("ZoneObjects");
part_system_automatic_update(global.sprite_particles.system, true);

if (alarm[0] != -1) ctrlMusic.alarm[0] = alarm[0];
ctrlZone.time_enabled = true;
ctrlWindow.image_speed = 1;