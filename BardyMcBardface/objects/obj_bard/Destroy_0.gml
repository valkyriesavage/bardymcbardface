/// @description explode the bard into debris

// find where the bard was standing; this is the lowest y we will use for the debris
var bardfeet = y + 10;
 
repeat(50) {
	var debris = instance_create_layer(x, y, "Instances", obj_debris);
	debris.image_angle = irandom_range(0,359);
	debris.direction = irandom_range(0,359);
	debris.speed = 1;
	debris.gravity = 0.05;
	debris.bottom = bardfeet;
}

audio_play_sound(snd_die, 1, false);