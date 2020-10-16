/// @description if you collide with another fighter, roll damage

if (other.id == self) {
	return; // do nothing if we are "colliding" with ourself.	
}

var can_strike = striked_at < 0 or striked_at + strike_time < current_time;
if (can_strike) {
	var given_damage = roll_damage(damage_str);
	other.char_health -= given_damage;
	other.damaged_val = string(given_damage);
	other.damaged_at = current_time;
	striked_at = current_time;
}