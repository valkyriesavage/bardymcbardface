/// @description explode into bits and leave a verse
// find where the tiger was standing; this is the lowest y we will use for the debris
var tigerfeet = y + 10;
 
repeat(50) {
	debris = instance_create_layer(x, y, "Instances", obj_debris);
	debris.sprite_index = spr_tiger_debris;
	debris.image_angle = irandom_range(0,359);
	debris.direction = irandom_range(0,359);
	debris.speed = 1;
	debris.gravity = 0.05;
	debris.bottom = tigerfeet;
}


var death_verse = instance_create_layer(x, y, "Instances", obj_verse);
death_verse.verse = "the tiger's sightless eyes";
death_verse.arrived = true; // force it to exist asap

audio_play_sound(snd_big_applause, 3, false);

// if the tiger died, set an alarm to go to the next room
var game = instance_find(obj_game, 0);
game.alarm[1] = room_speed * 8;