function player_is_falling(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			// Rise
			y_speed = -dsin(local_direction) * x_speed;
			x_speed *= dcos(local_direction);
			
			// Detach from ground
			player_ground(false);
			
			// Animate
			if (animation == "brake" or animation == "push")
			{
				var velocity = abs(x_speed) div 1;
				player_animate(velocity < 6 ? "walk" : "run");
				timeline_speed = 1 / max(8 - velocity, 1);
			}
			break;
		}
		case PHASE.STEP:
		{
			// Accelerate
			var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
			if (input_sign != 0)
			{
				image_xscale = input_sign;
				if (abs(x_speed) < speed_cap or sign(x_speed) != input_sign)
				{
					x_speed += air_acceleration * input_sign;
					if (abs(x_speed) > speed_cap and sign(x_speed) == input_sign)
					{
						x_speed = speed_cap * input_sign;
					}
				}
			}
			
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground) return player_perform(x_speed != 0 ? player_is_running : player_is_standing);
			
			// Curl up
			if (not rolling and input_check_pressed(INPUT.ACTION))
			{
				rolling = true;
				jump_action = y_speed >= 0 ? 3 : 1;
				
				player_animate("roll");
				timeline_speed = 1 / max(5 - abs(x_speed) div 1, 1);
				image_angle = gravity_direction;
				
				return player_perform(player_is_jumping, false);
			}
			
			// Apply air resistance
			if (y_speed < 0 and y_speed > -4 and abs(x_speed) > air_drag_threshold)
			{
				x_speed *= air_drag;
			}
			
			// Fall
			if (y_speed < gravity_cap) y_speed = min(y_speed + gravity_force, gravity_cap);
			
			// Animate
			if (animation == "rise" and y_speed >= 0)
			{
				player_animate("walk");
				timeline_speed = 0.125;
			}
			if (image_angle != direction)
			{
				var diff = angle_difference(direction, image_angle);
				image_angle += min(2.8125, abs(diff)) * sign(diff);
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

function player_is_jumping(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			rolling = true;
			jump_action = 3;
			audio_play_sfx(sfxJump);
			
			// Leap
			var sine = dsin(local_direction);
			var cosine = dcos(local_direction);
			var g_speed = x_speed;
			x_speed = cosine * g_speed - sine * jump_height;
			y_speed = -sine * g_speed - cosine * jump_height;
			
			// Detach from ground
			player_ground(false);
			
			// Animate
			player_animate("roll");
			timeline_speed = 1 / max(5 - abs(g_speed) div 1, 1);
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Accelerate
			var input_sign = input_check(INPUT.RIGHT) - input_check(INPUT.LEFT);
			if (input_sign != 0)
			{
				image_xscale = input_sign;
				if (abs(x_speed) < speed_cap or sign(x_speed) != input_sign)
				{
					x_speed += air_acceleration * input_sign;
					if (abs(x_speed) > speed_cap and sign(x_speed) == input_sign)
					{
						x_speed = speed_cap * input_sign;
					}
				}
			}
			
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground) return player_perform(x_speed != 0 ? player_is_running : player_is_standing);
			
			// Homing attack / Air dash
			if (jump_action & 1 != 0)
			{
				var target_found = instance_exists(objReticle);
				var ind = collision_rectangle(x, y, x + 96 * image_xscale, y + 64, target_found ? objReticle.target : [objBadnik, objMonitor], false, false);
				if (ind != noone)
				{
					if (not target_found)
					{
						target_found = true;
						instance_create_depth(ind.x, ind.y, depth - 1, objReticle, { owner: id, target: ind });
					}
				}
				else if (target_found)
				{
					target_found = false;
					instance_destroy(objReticle);
				}
				
				if (input_check_pressed(INPUT.ACTION))
				{
					audio_play_sfx(sfxSpinDash);
					particle_spawn("burst", x, y);
					if (target_found) return player_perform(player_is_homing);
					
					jump_action = 2;
					x_speed = 8 * image_xscale;
					y_speed = 0;
				}
			}
			
			// Reduce height
			if (jump_action & 2 != 0 and y_speed < -jump_release and not input_check(INPUT.ACTION))
			{
				y_speed = -jump_release;
			}
			
			// Apply air resistance
			if (y_speed < 0 and y_speed > -4 and abs(x_speed) > air_drag_threshold)
			{
				x_speed *= air_drag;
			}
			
			// Fall
			if (y_speed < gravity_cap) y_speed = min(y_speed + gravity_force, gravity_cap);
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}

function player_is_homing(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			jump_action = 1;
			break;
		}
		case PHASE.STEP:
		{
			// Lock on
			var dir = point_direction(x, y, objReticle.x, objReticle.y);
			x_speed = lengthdir_x(12, dir);
			y_speed = lengthdir_y(12, dir);
			
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground) return player_perform(player_is_running);
			break;
		}
		case PHASE.EXIT:
		{
			instance_destroy(objReticle);
			break;
		}
	}
}

function player_is_hurt(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			if (on_ground) player_ground(false);
			
			// Animate
			player_animate("hurt");
			timeline_speed = 1;
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Move
			player_move_in_air();
			if (state_changed) exit;
			
			// Land
			if (on_ground)
			{
				x_speed = 0;
				return player_perform(player_is_standing);
			}
			
			// Fall
			if (y_speed < gravity_cap) y_speed = min(y_speed + recoil_gravity, gravity_cap);
			break;
		}
		case PHASE.EXIT:
		{
			recovery_time = 120;
			break;
		}
	}
}

function player_is_dead(phase)
{
	switch (phase)
	{
		case PHASE.ENTER:
		{
			y_speed = -7;
			with (ctrlZone)
			{
				time_enabled = false;
				can_pause = false;
			}
			instance_destroy(objCamera);
			audio_play_sfx(sfxDeath);
			
			// Animate
			player_animate("dead");
			image_angle = gravity_direction;
			break;
		}
		case PHASE.STEP:
		{
			// Move
			x += dsin(image_angle) * y_speed;
			y += dcos(image_angle) * y_speed;
			y_speed += gravity_force;
			
			// Restart
			if (y_speed >= 4 and not instance_in_view())
			{
				if (--lives == 0 or ctrlZone.time_over)
				{
					instance_create_layer(0, 0, "Master", objGameOver);
				}
				else call_later(1, time_source_units_seconds, function ()
				{
					instance_create_layer(0, 0, "Master", objFade, { target_room: room });
				});
				instance_destroy(invincibility_effect);
				instance_destroy(shield);
				instance_destroy();
			}
			break;
		}
		case PHASE.EXIT:
		{
			break;
		}
	}
}