/// @description Label some shit
var big_scale = 2;
switch(room) {
	case rm_splash:
		draw_set_halign(fa_center);
		draw_text_transformed_color(room_width/2,room_height/2,"Ye Bardy McBardface",
									big_scale, big_scale, 0, c_white, c_aqua, c_green, c_aqua, 1);
		draw_text(room_width/2, room_height/2 + 100, ">> Press enter to bard <<");
		draw_set_halign(fa_left);
		break;
	case rm_grassland:
		draw_text(20,20,"Ye Bardy McBardface");
		if (!instance_exists(obj_bard)) { // bard is dead
			draw_set_halign(fa_center);
			draw_text_transformed_color(room_width/2,room_height/2,"U DIED",
									big_scale, big_scale, 0, c_white, c_black, c_black, c_red, 1);
			draw_text(room_width/2, room_height/2 + 100, ">> Press enter to bard <<");
			draw_set_halign(fa_left);
		}
		break;
	case rm_verses:
		// we want to draw the bard's inventory
		obj_bard.visible = false;
		obj_hero.visible = false;
		break;
}