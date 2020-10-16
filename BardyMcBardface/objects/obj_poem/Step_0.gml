/// @description check if all lines are filled

all_filled = true;

for (var i = 0; i < ds_list_size(lines); i++) {
	var line = ds_list_find_value(lines, i);
	all_filled = all_filled and line.blank_filled;
}

if (all_filled) {
	var done_button = instance_create_layer(450,700,"Instances",obj_ui_button);
	done_button.sprite_index = spr_button_done;
}