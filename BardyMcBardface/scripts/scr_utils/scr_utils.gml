//  Returns an array of strings parsed from a given 
//  string of elements separated by a delimiter.
//
//      delimiter   delimiter character, string
//      str      group of elements, string
//
/// GMLscripts.com/license
function explode(str,delimiter)
{
    var arr;
    str = str + delimiter;
    var len = string_length(delimiter);
    var ind = 0;
    repeat (string_count(delimiter, str)) {
        var pos = string_pos(delimiter, str) - 1;
        arr[ind] = string_copy(str, 1, pos);
        str = string_delete(str, 1, pos + len);
        ind++;
    }
    return arr;
}

/// bytes_to_bin(str)
//
//  Returns a string of binary digits, 1 bit each.
//
//      str         raw bytes, 8 bits each, string
//
/// GMLscripts.com/license
function str_to_bytes(str)
{
    var bin, p, byte;
    str = argument0;
    bin = "";
    p = string_length(str);
    repeat (p) {
        byte = ord(string_char_at(str,p));
        repeat (8) {
            if (byte & 1) bin = "1" + bin else bin = "0" + bin;
            byte = byte >> 1;
        }
        p -= 1;
    }
	show_debug_message("transformed " + str + " to " + bin);
    return bin;
}