/*
	MCC_fnc_configFromString
	Turns a config path written as text, like  configFile >> "CfgGroups" >> "West" >> "BLU_F",
	into a config entry, without compiling it. Only configFile paths are accepted.
	Params:
		0: STRING or CONFIG - the path text. A config is returned as it is.
	Returns: CONFIG - configNull when the text is not a plain configFile path
	Example:
		private _cfg = ["configFile >> ""CfgGroups"" >> ""West"""] call MCC_fnc_configFromString;
*/
params [["_value", "", ["", configNull]]];

if (_value isEqualType configNull) exitWith {_value};

private _parts = (_value splitString ">") apply {_x trim [" ", 0]};
_parts = _parts select {_x != ""};
if (_parts isEqualTo [] || {toLower (_parts select 0) != "configfile"}) exitWith {configNull};

private _cfg = configFile;
private _ok = true;
{
	if (count _x < 2 || {(_x select [0, 1]) != """"} || {(_x select [count _x - 1, 1]) != """"}) exitWith {_ok = false};
	private _name = (_x select [1, count _x - 2]) regexReplace ["""""", """"];
	_cfg = _cfg >> _name;
} forEach (_parts select [1]);

if (_ok) then {_cfg} else {configNull}
