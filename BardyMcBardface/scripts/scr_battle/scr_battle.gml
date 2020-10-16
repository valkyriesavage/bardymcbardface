// parse out the damage, then "roll" the "dice"
// argument : damage_str , which is a string in the form of "xdy"
function roll_damage(damage_str){
	// split dat
	data_arr = explode(damage_str, "d");
	// parse out the number of dice and dice value
	num_dice = real(data_arr[0]);
	dice_val = real(data_arr[1]);
	
	var total_damage = 0;
	for (var i=0; i < random_range(0,num_dice); i++) {
		total_damage += random_range(1,	dice_val);
	}
	return total_damage;
}