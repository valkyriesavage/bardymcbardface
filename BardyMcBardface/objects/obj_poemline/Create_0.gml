/// @description Initialize line

line_preblank = choose("the day had",
					   "I saw",
					   "upon",
					   "with",
					   "the",
					   "")
line_postblank = choose("was cool",
					    "was lame",
					    "around it",
						"of legend",
						"")
						
var BLANK = "________"
						
has_blank = true;
blank_filled = false;

my_full_line = line_preblank + BLANK + line_postblank;

hitbox_x_offset = string_length(line_preblank) * 19;
hitbox_y_offset = 0;
hitbox_obj = instance_create_layer(x + hitbox_x_offset, y + hitbox_y_offset,
								   "Instances", obj_poemline_blank);