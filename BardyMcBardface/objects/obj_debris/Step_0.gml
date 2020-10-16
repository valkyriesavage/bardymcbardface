/// @description Make sure we don't fall below our "bottom"

if (y >= bottom) {
	gravity = 0;
	speed = 0;
	if (bottom_since < 0) {
		bottom_since = current_time;
	} if (bottom_since + remain_for <= current_time)  {
		instance_destroy();	
	}
}