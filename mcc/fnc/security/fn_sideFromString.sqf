/*
	MCC_fnc_sideFromString
	Turns a side name received as text into a side, without compiling it.
	Params:
		0: STRING or SIDE - "WEST"/"BLUFOR", "EAST"/"OPFOR", "GUER"/"RESISTANCE"/"INDEPENDENT", "CIV"/"CIVILIAN",
		   "LOGIC", "EMPTY", "ENEMY", "FRIENDLY" (any case). A side is returned as it is.
		1: SIDE - returned when the text is not a known side (default sideUnknown)
	Returns: SIDE
	Example:
		private _side = ["WEST"] call MCC_fnc_sideFromString;
*/
params [["_value", "", ["", west]], ["_default", sideUnknown, [west]]];

if (_value isEqualType west) exitWith {_value};

switch (toUpper (_value trim [" ", 0])) do {
	case "WEST";
	case "BLUFOR": {west};
	case "EAST";
	case "OPFOR": {east};
	case "GUER";
	case "RESISTANCE";
	case "INDEPENDENT": {resistance};
	case "CIV";
	case "CIVILIAN": {civilian};
	case "LOGIC";
	case "SIDELOGIC": {sideLogic};
	case "EMPTY";
	case "SIDEEMPTY": {sideEmpty};
	case "ENEMY";
	case "SIDEENEMY": {sideEnemy};
	case "FRIENDLY";
	case "SIDEFRIENDLY": {sideFriendly};
	default {_default};
}
