/// @description Move le bard around

motion_set(0,0);
var keydown = false;
if (keyboard_check(vk_left)) {
	motion_add(-180, move_speed);
	keydown = true;
} if (keyboard_check(vk_right)) {
	motion_add(0, move_speed);	
	keydown = true;
} if (keyboard_check(vk_up)) {
	motion_add(90, move_speed);	
	keydown = true;
} if (keyboard_check(vk_down)) {
	motion_add(-90, move_speed);	
	keydown = true;
}
if (keydown) {
	speed = move_speed;
}
if (x <= 0) x = 0;
if (x >= room_width) x = room_width;
if (y <= 0) y = 0;
if (y >= room_width) y = room_width;

//no wrap! move_wrap(true, true, 0);