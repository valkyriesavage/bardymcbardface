/// @description if we are dead, die. calc if we need to draw damage.

is_drawing_damage = damaged_at > 0 and damaged_at + damage_display_time < current_time;

if (char_health <= 0) {
	instance_destroy();
}