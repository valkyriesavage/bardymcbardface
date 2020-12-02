/// @description set the verse, start the countdown

verse = choose("the green of the tiger's eyes",
			   "the green of the grasslands",
			   "the suaveness of the hero",
			   "the springy tang of the air",
			   "the blue of the sky",
			   "the buzz of the bees",
			   "the glint of the sun on her sword",
			   "the wind in her hair",
			   "the smell of leaves",
			   "the dew long-burned");

// show where it will drop
sprite_index = spr_verse_coming;
alarm[0] = room_speed * warning_seconds;
			   
audio_play_sound(snd_sparkle, 1, false);

// set up bonuses
SPEED = "speed";
DAMAGE = "damage";
DEFENSE = "defense";
CHARISMA = "charisma";
possible_bonuses = ds_list_create();
ds_list_add(possible_bonuses, SPEED);
ds_list_add(possible_bonuses, DAMAGE);
ds_list_add(possible_bonuses, DEFENSE);
ds_list_add(possible_bonuses, CHARISMA);

// create a random bonus associated with this verse
num_bonuses = choose(1,1,1,1,1,2) // small chance to get an extra bonus
for (var i = 0; i < num_bonuses; i++) {
	bonus_type = possible_bonuses[| irandom(ds_list_size(possible_bonuses)-1)]
	bonus_magnitude = choose(1,2,3)
	show_debug_message(format("{} +{}",bonus_type, bonus_magnitude))
	if (not ds_map_exists(bonus_map, bonus_type)) {
		bonus_map[? bonus_type] = 0
	}
	bonus_map[? bonus_type] += bonus_magnitude
}
// now build the string of it for later display
bonus_string = "";
bonus_type = ds_map_find_first(bonus_map);
for (var i = 0; i < ds_map_size(bonus_map); i++) {
	bonus_string += format("+{} {}",bonus_map[? bonus_type], bonus_type);
	bonus_type = ds_map_find_next(bonus_map, bonus_type);
}