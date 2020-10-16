// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

/// @function collect_verse(_verse);
/// @param {obj_verse} _verse The Verse to collect

function collect_verse(_verse)
{
	versebook = instance_find(obj_versebook, 0);
	ds_list_add(versebook.verses_collected, _verse);
	_verse.visible = false;
	_verse.collected = true;
}


/// @function clear_verses();

function clear_verses()
{
	versebook = instance_find(obj_versebook, 0);
	ds_list_clear(versebook.verses_collected);
}