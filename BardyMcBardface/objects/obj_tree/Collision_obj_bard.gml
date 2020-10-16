/// @description Don't let bard go into tree

if (other.x < x) {
	other.x = bbox_left - other.sprite_width/2;
}
if (other.x > x) {
	other.x = bbox_right + other.sprite_width/2;
}
if (other.y > y) {
	other.y = bbox_bottom;
}
if (other.y < y) {
	other.y = bbox_top;
}