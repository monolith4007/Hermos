function player_is_ready(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			break;
		}
		case PHASE.STEP:
		{
			timeline_running = true;
			player_perform(player_is_standing);
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

function player_is_standing(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			// Check if on a cliff
			var height = y_radius + y_snap_distance;
			if (not player_raycast(hard_colliders, 0, height))
			{
				cliff_sign = player_raycast(hard_colliders, -x_radius, height) -
					player_raycast(hard_colliders, x_radius, height);
			}
			else cliff_sign = 0;
			
			// Animate
			player_animate(cliff_sign == 0 ? "idle" : "teeter");
			timeline_speed = 1;
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_running);
			}
			
			// Run
			if ((input_check(INPUT.LEFT) xor input_check(INPUT.RIGHT)) or x_speed != 0)
			{
				return player_perform(player_is_running);
			}
			
			// Look / crouch
			if (cliff_sign == 0)
			{
				if (input_check(INPUT.UP)) return player_perform(player_is_looking);
				if (input_check(INPUT.DOWN)) return player_perform(player_is_crouching);
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

function player_is_running(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Handle ground motion
			var can_brake = animation == "brake";
			var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
			
			if (control_lock_time == 0)
			{
				if (input_sign != 0)
				{
					// Decelerate
					if (sign(x_speed) == -input_sign)
					{
						can_brake = true;
						x_speed += deceleration * input_sign;
						if (sign(x_speed) == input_sign) x_speed = deceleration * input_sign; // Reverse direction
					}
					else
					{
						// Accelerate
						can_brake = false;
						image_xscale = input_sign;
						if (abs(x_speed) < speed_cap)
						{
							x_speed = min(abs(x_speed) + acceleration, speed_cap) * input_sign;
						}
					}
				}
				else
				{
					// Friction (same value as acceleration)
					x_speed -= min(abs(x_speed), acceleration) * sign(x_speed);
				}
			}
			
			// Slope friction
			player_resist_slope(0.125);
			
			// Roll
			if (input_sign == 0 and abs(x_speed) >= roll_threshold and input_check(INPUT.DOWN))
			{
				audio_play_sfx(sfxRoll);
				return player_perform(player_is_rolling);
			}
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground) return player_perform(player_is_falling);
			
			// Slide down steep slopes
			if (abs(x_speed) < slide_threshold and local_direction >= 45 and local_direction <= 315)
			{
				if (local_direction >= 90 and local_direction <= 270)
				{
					return player_perform(player_is_falling);
				}
				control_lock_time = slide_duration;
			}
			
			// Stand
			if (x_speed == 0 and input_sign == 0) return player_perform(player_is_standing);
			
			// Brake
			if (can_brake and mask_direction == gravity_direction and abs(x_speed) >= 4 and animation != "brake")
			{
				player_animate("brake");
				timeline_speed = 1;
				image_angle = gravity_direction;
				image_xscale = -input_sign;
				audio_play_sfx(sfxBrake);
			}
			
			// Animate
			if (can_brake and animation == "brake" and mask_direction == gravity_direction and timeline_position <= timeline_max_moment(timeline_index))
			{
				if (timeline_position mod 4 == 0)
				{
					// Kick up dust
					var offset = y_radius - 6;
					var px = x + dsin(direction) * offset;
					var py = y + dcos(direction) * offset;
					particle_spawn("brake_dust", px, py);
				}
			}
			else
			{
				var speed_int = abs(x_speed) div 1;
				var new_anim = speed_int < 6 ? "walk" : "run";
				if (animation != new_anim) player_animate(new_anim);
				timeline_speed = 1 / max(8 - speed_int, 1);
				
				// Update visual angle
				var target_angle = local_direction >= 34 and local_direction <= 326 ? direction : gravity_direction;
				image_angle += angle_difference(target_angle, image_angle) / (speed_int < 6 ? 4 : 2);
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

function player_is_looking(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			player_animate("look");
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_running);
			}
			
			// Run
			if (x_speed != 0) return player_perform(player_is_running);
			
			// Stand
			if (not input_check(INPUT.UP)) return player_perform(player_is_standing);
			
			// Ascend camera
			if (camera_look_time > 0)
			{
				--camera_look_time;
			}
			else with (objCamera)
			{
				if (y_offset > -104) y_offset -= 2;
			}
			break;
		}
		case PHASE.EXIT:
		{
			camera_look_time = camera_look_delay;
			break;
		}
	}
}

function player_is_crouching(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			player_animate("crouch");
			break;
		}
		case PHASE.STEP:
		{
			// Spindash
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_spindashing);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_running);
			}
			
			// Run
			if (x_speed != 0) return player_perform(player_is_running);
			
			// Stand
			if (not input_check(INPUT.DOWN)) return player_perform(player_is_standing);
			
			// Descend camera
			if (camera_look_time > 0)
			{
				--camera_look_time;
			}
			else with (objCamera)
			{
				if (y_offset < 88) y_offset += 2;
			}
			break;
		}
		case PHASE.EXIT:
		{
			camera_look_time = camera_look_delay;
			break;
		}
	}
}

function player_is_rolling(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = true;
			player_animate("roll");
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Jump
			if (input_check_pressed(INPUT.ACTION)) return player_perform(player_is_jumping);
			
			// Decelerate
			if (control_lock_time == 0)
			{
				var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
				if (input_sign != 0)
				{
					if (sign(x_speed) != input_sign)
					{
						x_speed += roll_deceleration * input_sign;
						if (sign(x_speed) == input_sign) x_speed = roll_deceleration * input_sign;
					}
					else image_xscale = input_sign;
				}
			}
			
			// Friction
			x_speed -= min(abs(x_speed), roll_friction) * sign(x_speed);
			
			// Slope friction
			var slope_friction = sign(x_speed) == sign(dsin(local_direction)) ? 0.078125 : 0.3125; // Uphill / downhill
			player_resist_slope(slope_friction);
			
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground) return player_perform(player_is_falling);
			
			// Slide down steep slopes
			if (abs(x_speed) < slide_threshold and local_direction >= 45 and local_direction <= 315)
			{
				if (local_direction >= 90 and local_direction <= 270)
				{
					return player_perform(player_is_falling);
				}
				control_lock_time = slide_duration;
			}
			
			// Unroll
			if (abs(x_speed) < roll_threshold) return player_perform(player_is_running);
			
			// Animate
			timeline_speed = 1 / max(5 - abs(x_speed) div 1, 1);
			break;
		}
		case PHASE.EXIT:
		{
			if (on_ground) rolling = false;
			break;
		}
	}
}

function player_is_spindashing(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = true;
			spindash_charge = 0;
			player_animate("spindash");
			audio_play_sfx(sfxSpinRev);
			break;
		}
		case PHASE.STEP:
		{
			// Move
			player_move_on_ground();
			if (state_changed) exit;
			
			// Fall
			if (not on_ground or (local_direction >= 90 and local_direction <= 270))
			{
				return player_perform(player_is_falling);
			}
			
			// Slide down steep slopes
			if (local_direction >= 45 and local_direction <= 315)
			{
				control_lock_time = slide_duration;
				return player_perform(player_is_rolling);
			}
			
			// Release
			if (not input_check(INPUT.DOWN))
			{
				x_speed = image_xscale * (8 + spindash_charge div 2);
				objCamera.alarm[0] = 16;
				audio_stop_sound(sfxSpinRev);
				audio_play_sfx(sfxSpinDash);
				return player_perform(player_is_rolling);
			}
			
			// Charge / atrophy
			if (input_check_pressed(INPUT.ACTION))
			{
				spindash_charge = min(spindash_charge + 2, 8);
				var rev_sfx = audio_play_sfx(sfxSpinRev);
				audio_sound_pitch(rev_sfx, 1 + spindash_charge * 0.0625);
			}
			else spindash_charge *= 0.96875;
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}