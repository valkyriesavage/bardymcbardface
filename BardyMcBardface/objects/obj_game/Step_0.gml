/// @description transition rooms with keys/buttons

if (keyboard_check_pressed(vk_enter)) {
	if (room == rm_splash) { // starting first time
		// go to game
		room_goto(rm_grassland);
	}
	if (room == rm_grassland and !instance_exists(obj_bard)) { // bard is dead, restart
		room_restart();
	}
}

if (room == rm_verses) {
	// in the verse room, we want to check for pressing the "done" button
	if (mouse_check_button_pressed(mb_left)) {
		// TODO! it... won't go well if we don't check which button it is LOL
		// but this is ok for now when we don't have any other buttons
		if (collision_point(mouse_x,mouse_y,obj_ui_button,false,false)) {
			// remove any existing verses as we start over lol
			instance_destroy(obj_verse);
			// when we click done, something else should happen instead of restart, but eh
			room_goto(rm_splash);
		}
	}
}

if (!connected && !connecting) {
    show_debug_message("Connecting to server");
    socket = network_create_socket(network_socket_tcp);
    network_connect_raw(socket, "127.0.0.1", 65432);
    connecting = true;
}

if (connected && !sent) {
    show_debug_message("Sending data to server");
    buf = buffer_create(1, buffer_grow, 1);
    for (var i = 0; i < 20; i++) {
        buffer_write(buf, buffer_u8, 10+i*10);
    }
    network_send_raw(socket, buf, buffer_tell(buf)+1);
    buffer_delete(buf);
    sent = true;
}