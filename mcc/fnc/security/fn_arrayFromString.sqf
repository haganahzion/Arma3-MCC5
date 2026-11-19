/*
	MCC_fnc_arrayFromString
	Reads a data array written as text (module attributes, saved settings) without compiling it.
	Text without double quotes may use single quotes, so ['a','b'] works too. Only plain data is read:
	numbers, strings, booleans and nested arrays (see parseSimpleArray).
	Params:
		0: STRING or ARRAY - the text. An array is returned as it is.
		1: ARRAY - returned when the text is empty or not an array (default [])
	Returns: ARRAY
	Example:
		MCC_breacingAmmo = [_module getVariable ["breachingAmmo", "[]"]] call MCC_fnc_arrayFromString;
*/
params [["_value", "", ["", []]], ["_default", [], [[]]]];

if (_value isEqualType []) exitWith {_value};

private _text = _value trim [" ", 0];
if ((_text select [0, 1]) != "[" || {(_text select [count _text - 1, 1]) != "]"}) exitWith {_default};

if ((_text find """") < 0) then {_text = _text regexReplace ["'", """"]};
private _result = parseSimpleArray _text;
if (_result isEqualType []) then {_result} else {_default}
