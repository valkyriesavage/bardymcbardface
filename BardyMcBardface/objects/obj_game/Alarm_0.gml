/// @description Create new verses every so often

if (room != rm_grassland or !instance_exists(obj_tiger)) {
	exit;
}

show_debug_message("Sending data to server");
buf = buffer_create(1, buffer_grow, 1);
topic = choose("tree","bush","eyes","tiger","grass","sun","bird","insect","breeze","hero","beast","flower","adventure","peril");
buffer_write(buf, buffer_string, topic);
network_send_raw(socket, buf, buffer_tell(buf));
buffer_delete(buf);

/*instance_create_layer(irandom_range(sprite_get_width(spr_verse),room_width-sprite_get_width(spr_verse)),
					  irandom_range(sprite_get_height(spr_verse),room_height-sprite_get_height(spr_verse)),
					  "Instances", obj_verse);*/
	
alarm[0] = room_speed * 4;