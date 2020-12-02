/// @description draw sprite or text

if (room = rm_verses) {
	sprite_index = spr_verse_dnd;
	// draw a different way
	draw_sprite(spr_verse_dnd, 0, x, y);
	var small_scale = .5;
	draw_text_transformed_color(x,y,verse,
								small_scale, small_scale, 0,
								c_olive, c_olive, c_olive, c_olive, 1);
	// draw the bonuses it gives
	draw_text_transformed_color(x,y+10,bonus_string,
								small_scale, small_scale, 0,
								c_maroon, c_maroon, c_maroon, c_maroon, 1);
} else {
	draw_marker_to(c_aqua);
	if (arrived) { sprite_index = spr_verse; }
	else { sprite_index = spr_verse_coming; }
	draw_self();
}
	
	