/// @description Randomly walk around

// figure out if we need to draw damage
is_drawing_damage = (damaged_at > 0) and (damaged_at + damage_display_time >= current_time)


if (changed_dir_at < 0 or (changed_dir_at + change_dir_time) <= current_time) {
	// change direction
	move_wander(move_speed);
	changed_dir_at = current_time;
}
var _edge_thresh = 100;
if (x < _edge_thresh) or (x + _edge_thresh > room_width) or
   (y < _edge_thresh) or (y + _edge_thresh > room_height) {
	move_wander(move_speed);
	changed_dir_at = current_time;
}