// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

// some defs
globalvar enum DIRECTIONS {
	RIGHT = 0,
	DOWNRIGHT = 1,
	DOWN = 2,
	DOWNLEFT = 3,
	LEFT = 4,
	UPLEFT = 5,
	UP = 6,
	UPRIGHT = 7
}

/// @function move_follow(object, speed);
/// @param {index} object The Object to follow
/// @param {real}  speed  The speed to follow at

function move_follow(_object, _speed)
{
	if (point_distance(x, y, _object.x, _object.y) > 0)
	{
		direction = point_direction(x, y, _object.x, _object.y);
		speed = _speed;
	}
	else speed = 0;
}

/// @function move_wander(speed);
/// @param {real} speed The speed to wander at

function move_wander(_speed)
{
	// if we're close to the edge, don't be random, go away from it.
	var _edge_thresh = 100;
	var forbidden_directions = [false,false,false,false,false,false,false,false];
	forbidden_directions[DIRECTIONS.LEFT] = x < _edge_thresh;
	forbidden_directions[DIRECTIONS.RIGHT] = room_width - _edge_thresh < x;
	forbidden_directions[DIRECTIONS.UP] = y < _edge_thresh;
	forbidden_directions[DIRECTIONS.DOWN] = room_height - _edge_thresh < y;
	var forbidden = true;
	var segment = DIRECTIONS.LEFT;
	while(forbidden) {
		segment = choose(DIRECTIONS.RIGHT,DIRECTIONS.DOWNRIGHT,DIRECTIONS.DOWN,DIRECTIONS.DOWNLEFT,
					      DIRECTIONS.LEFT,DIRECTIONS.UPLEFT,DIRECTIONS.UP,DIRECTIONS.UPRIGHT);
		forbidden = false;
		if ((segment == DIRECTIONS.LEFT or
			 segment == DIRECTIONS.UPLEFT or
			 segment == DIRECTIONS.DOWNLEFT) and forbidden_directions[DIRECTIONS.LEFT]) {
				 forbidden = true;
			 }
		
		if ((segment == DIRECTIONS.RIGHT or
			 segment == DIRECTIONS.UPRIGHT or
			 segment == DIRECTIONS.DOWNRIGHT) and forbidden_directions[DIRECTIONS.RIGHT]) {
				 forbidden = true;
			 }
		
		if ((segment == DIRECTIONS.UP or
			 segment == DIRECTIONS.UPLEFT or
			 segment == DIRECTIONS.UPRIGHT) and forbidden_directions[DIRECTIONS.UP]) {
				 forbidden = true;
			 }
		
		if ((segment == DIRECTIONS.DOWN or
			 segment == DIRECTIONS.DOWNLEFT or
			 segment == DIRECTIONS.DOWNRIGHT) and forbidden_directions[DIRECTIONS.DOWN]) {
				 forbidden = true;
			 }
	}

	direction = irandom_range(segment*90-45,segment*90+45);
	speed = _speed;
}