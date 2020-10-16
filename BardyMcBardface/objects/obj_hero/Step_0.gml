/// @description Move le hero around

// figure out if the hero is paused or cussing
is_cussing = (started_cussing_at > 0) and (started_cussing_at + cuss_time >= current_time)
is_stopped = (started_cussing_at > 0) and (started_cussing_at + stop_time >= current_time)
is_drawing_damage = (damaged_at > 0) and (damaged_at + damage_display_time >= current_time)

// follow the tiger if it exists
if (instance_exists(obj_tiger) and not is_stopped) {
	var tiger_enemy = instance_nearest(x, y, obj_tiger);
	move_follow(tiger_enemy, move_speed);
} else {
	// stop
	speed = 0;
}