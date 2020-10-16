/// @description create necessary stuff when entering room

if (room == rm_splash) {
	// initialize hero and bard
	if (!instance_exists(obj_bard)) {
		// create a bard!! in the top middle
		bard = instance_create_layer(irandom_range(room_width/4,3*room_width/4),
							  irandom_range(100,room_height/2-100),
							  "Instances", obj_bard);
		bard.visible = false;		  
	}
	if (!instance_exists(obj_hero)) {
		// create a hero somewhere in the top half
		hero = instance_create_layer(irandom_range(0,room_width),
							  irandom_range(0,room_height/2),
							  "Instances", obj_hero);
		hero.visible = false;
	}
}

if (room == rm_grassland) {
	if (audio_is_playing(snd_music)) {
		audio_stop_sound(snd_music);
	}
	audio_play_sound(snd_music,2,true);
	
	if (!instance_exists(obj_tiger)) {
		// create a tiger somewhere in the bottom half
		instance_create_layer(irandom_range(0,room_width),
							  irandom_range(room_height/2,room_height),
							  "Instances", obj_tiger);
	}
						  
	// put the bard in a good-ish place
	bard = instance_find(obj_bard,0);
	bard.x = irandom_range(room_width/4,3*room_width/4);
	bard.y = irandom_range(100,room_height/2-100);
	bard.visible = true;
	// clear the bard's collected verses
	ds_list_clear(bard.verse_book.verses_collected);
	
	// put the hero in a good-ish place
	hero = instance_find(obj_hero,0);
	hero.x = irandom_range(0,room_width);
	hero.y = irandom_range(0,room_height/2);
	hero.visible = true;
	
	// put the tiger in a good-ish place
	tiger = instance_find(obj_tiger,0);
	tiger.x = irandom_range(0,room_width);
	tiger.y = irandom_range(room_height/2,room_height);
	tiger.visible = true;
	
	// remove any existing verses
	instance_destroy(obj_verse);
	// create a verse
	instance_create_layer(irandom_range(sprite_get_width(spr_verse),room_width-sprite_get_width(spr_verse)),
						  irandom_range(sprite_get_height(spr_verse),room_height-sprite_get_height(spr_verse)),
						  "Instances", obj_verse);
	
	alarm[0] = room_speed * 5;
}

if (room == rm_verses) {
	if (audio_is_playing(snd_music)) {
		audio_stop_sound(snd_music);
	}
	audio_play_sound(snd_compose, 2, false);
	// make a poem
	instance_create_layer(0, 0, "Instances", obj_poem);
	// remove all the non-collected verses
	for (var v = 0; v < instance_number(obj_verse); v += 1) {
		verse = instance_find(obj_verse,v);
		if (!verse.collected) {
			instance_destroy(verse);
		}
	}
}