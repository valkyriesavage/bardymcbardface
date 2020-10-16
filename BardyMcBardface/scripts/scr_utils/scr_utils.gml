//  Returns an array of strings parsed from a given 
//  string of elements separated by a delimiter.
//
//      delimiter   delimiter character, string
//      string      group of elements, string
//
/// GMLscripts.com/license
function explode(string,delimiter)
{
    var arr;
    string = string + delimiter;
    var len = string_length(delimiter);
    var ind = 0;
    repeat (string_count(delimiter, string)) {
        var pos = string_pos(delimiter, string) - 1;
        arr[ind] = string_copy(string, 1, pos);
        string = string_delete(string, 1, pos + len);
        ind++;
    }
    return arr;
}