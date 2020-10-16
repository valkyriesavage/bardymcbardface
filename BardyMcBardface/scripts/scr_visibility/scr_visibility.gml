// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function visible_to_camera(){
	return x > camera_get_view_x(view_camera[0]) and
	   x < camera_get_view_x(view_camera[0]) + camera_get_view_width(view_camera[0]) and
	   y > camera_get_view_y(view_camera[0]) and
	   y < camera_get_view_y(view_camera[0]) + camera_get_view_height(view_camera[0]);
}

function draw_marker_to(_marker_colour) {
	if (instance_exists(obj_bard)) {
		if (!visible_to_camera()) {
			// draw a placeholder sprite
			// what is the right angle to the object?
			var bard = instance_find(obj_bard,0);
			var angle_from_bard = point_direction(bard.x, bard.y, x, y);
			var draw_x = bard.x + lengthdir_x(200,angle_from_bard);
			var draw_y = bard.y + lengthdir_y(200,angle_from_bard);
			draw_sprite_ext(spr_offscreen,0,
							draw_x,
							draw_y,
							1,1,angle_from_bard,_marker_colour,1)
		}
	}
}