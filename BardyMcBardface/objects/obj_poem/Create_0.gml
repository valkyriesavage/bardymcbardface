/// @description initialize blanks and structure

enum POEM_TYPES {
	BALLAD,
	ROCK_AND_ROLL,
	TRAGEDY
};


for (var i = 0; i < 4; i++) {
	line = instance_create_layer(450,120 + i*30,"Instances",obj_poemline);
	line.visible = true;
	ds_list_add(lines, line);
}