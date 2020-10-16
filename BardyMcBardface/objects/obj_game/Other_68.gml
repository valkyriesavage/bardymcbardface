/// @description Receive poem shit from the pythonz
show_debug_message("Received network message");
show_debug_message(json_encode(async_load));
var eventid = async_load[? "id"];

var type = async_load[? "type"];
switch (type) {
    case network_type_connect:
	case network_type_non_blocking_connect:
        show_debug_message("Connected to server");
        connected = true;
        connecting = false;
        break;
   
    case network_type_disconnect:
        show_debug_message("Disconnected from server");
        connected = false;
        break;
   
    case network_type_data:
        show_debug_message("Received data from server:");
		le_verse = buffer_read(async_load[? "buffer"], buffer_string);
		show_debug_message(le_verse);
		nu_verse = instance_create_layer(irandom_range(sprite_get_width(spr_verse),
														   room_width-sprite_get_width(spr_verse)),
											 irandom_range(sprite_get_height(spr_verse),
														   room_height-sprite_get_height(spr_verse)),
											"Instances", obj_verse);
		nu_verse.verse = le_verse;
        break;
   
    default:
        show_debug_message("Unexpected network type [" + string(type) + "]");
        break;
}