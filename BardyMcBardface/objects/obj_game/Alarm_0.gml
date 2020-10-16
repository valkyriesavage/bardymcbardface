/// @description Create new verses every so often

if (room != rm_grassland or !instance_exists(obj_tiger)) {
	exit;
}

instance_create_layer(irandom_range(sprite_get_width(spr_verse),room_width-sprite_get_width(spr_verse)),
					  irandom_range(sprite_get_height(spr_verse),room_height-sprite_get_height(spr_verse)),
					  "Instances", obj_verse);
	
alarm[0] = room_speed * 5;