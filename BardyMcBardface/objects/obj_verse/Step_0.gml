/// @description Deal with drag and drop in verse edit (non-sprite) mode

if (room == rm_verses)
{	
	/// lock inside the poemline if we drop inside the poem line

	// check if we dropped it
	if dragging and mouse_check_button_released(mb_left) {
		dragging = false;
		var collision_list = ds_list_create();
		var collision_num = collision_rectangle_list(x, y, x+sprite_width, y+sprite_height,
													obj_poemline_blank, false, true,
													collision_list, false);
		if collision_num > 0 {
			// figure out which one we were dropped in
			var dropped_in = noone;
			if collision_num == 1 {
				// if we only have one, we are def goign on that one
				dropped_in = ds_list_find_value(collision_list,0);
			} else {
				// if we have more than one, we should find the one that our mouse
				// point intersects with
				dropped_in = collision_point(mouse_x, mouse_y, obj_poemline_blank, false, true);
			}
			// other right now is the poemline_blank, so lock in at the middle
			x = dropped_in.x + dropped_in.xpad;
			y = dropped_in.y + dropped_in.ypad;
			dropped_in.filled_in = true;
			dropped_in.filled_text = verse;
			locked_in_line = dropped_in;
		}
	}
	
	// only drag it around if the mouse is touching it or we're already moving it
	if collision_point(mouse_x, mouse_y, self, false, false) or dragging {
		if mouse_check_button_pressed(mb_left) {
			// on click, save the relative mouse position so we can drag around	
			xx=mouse_x-x;
			yy=mouse_y-y;
			dragging = true;
			// if we are dragging, we definitely don't want to have anything assume we're locked in
			if (locked_in_line != noone) {
				locked_in_line.filled_in = false;
				locked_in_line = noone;
			}
		}
		else if mouse_check_button(mb_left) and dragging {
			// drag appropriately
			x=mouse_x-xx;
			y=mouse_y-yy;
		}
		else {
			dragging = false;
		}
	}
}