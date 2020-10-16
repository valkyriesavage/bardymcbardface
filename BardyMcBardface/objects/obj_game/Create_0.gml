/// @description initialize vars

lives = 3;

draw_set_font(fnt_title);

network_set_config(network_config_use_non_blocking_socket, 1);
POEM_PIECE = 2;
REQUEST_POEM_PIECE = 3;
connected = false;
connecting = false;
sent = false;