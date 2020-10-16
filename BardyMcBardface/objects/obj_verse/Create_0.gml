/// @description set the verse, start the countdown

verse = choose("the green of the tiger's eyes",
			   "the green of the grasslands",
			   "the suaveness of the hero",
			   "the springy tang of the air",
			   "the blue of the sky",
			   "the buzz of the bees",
			   "the glint of the sun on her sword",
			   "the wind in her hair",
			   "the smell of leaves",
			   "the dew long-burned");

// show where it will drop
sprite_index = spr_verse_coming;
alarm[0] = room_speed * warning_seconds;
			   
audio_play_sound(snd_sparkle, 1, false);