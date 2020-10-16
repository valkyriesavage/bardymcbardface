/// @description Insert description here

if (room == rm_verses) {
	draw_verses = true;
	for (var i = 0; i < ds_list_size(verses_collected); i++) {
		with(ds_list_find_value(verses_collected, i)) {
			x = 30;
			y = i*60+100;
			verse_compose_mode = true;
			visible = true;
			// now we also have to make it have a good collision box...
			// and apparently the only way to do that is by setting a new
			// sprite
			sprite_index = spr_verse_dnd;
		}
	}
}
