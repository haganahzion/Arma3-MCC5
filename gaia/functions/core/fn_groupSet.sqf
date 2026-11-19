/* ----------------------------------------------------------------------------
Function: GAIA_fnc_groupSet

Description:
	Runs a group command that needs a local group (setSpeedMode, setBehaviour,
	setCombatMode, setFormation, setFormDir). Runs it here when the group is
	local, else the server forwards it to the group owner (headless client),
	unless the group already has that value.
	Only the server may remote execute it.

Parameters:
	0: GROUP
	1: STRING - command: "setSpeedMode", "setBehaviour", "setCombatMode",
	            "setFormation" or "setFormDir"
	2: STRING or NUMBER - value for the command

Returns:
	BOOL - true when run here or forwarded to the owner

Example:
	[_group, "setSpeedMode", "FULL"] call GAIA_fnc_groupSet;
---------------------------------------------------------------------------- */
#define GAIA_GROUPSET_COMMANDS ["setSpeedMode", "setBehaviour", "setCombatMode", "setFormation", "setFormDir"]
#include "..\gaiaDefines.hpp"

params [
	["_group", grpNull, [grpNull]],
	["_command", "", [""]],
	["_value", "", ["", 0]]
];

if (isRemoteExecuted && {remoteExecutedOwner != GAIA_SERVER_OWNER}) exitWith {false};
if (isNull _group || {!(_command in GAIA_GROUPSET_COMMANDS)}) exitWith {false};

if (!local _group) exitWith {
	if (isServer && {!isRemoteExecuted}) then {
		//Nothing to send when the owner already runs the group that way (behaviour, modes and formation are synced)
		private _current = switch (_command) do {
			case "setSpeedMode":	{speedMode _group};
			case "setBehaviour":	{behaviour (leader _group)};
			case "setCombatMode":	{combatMode _group};
			case "setFormation":	{formation _group};
			default					{""};
		};
		if (_value isEqualType "" && {(toUpper _current) isEqualTo (toUpper _value)}) exitWith {true};
		[_group, _command, _value] remoteExecCall ["GAIA_fnc_groupSet", groupOwner _group];
		true
	} else {
		false
	};
};

if (_command == "setFormDir") exitWith {
	if !(_value isEqualType 0) exitWith {false};
	_group setFormDir _value;
	true
};

if !(_value isEqualType "") exitWith {false};
switch (_command) do {
	case "setSpeedMode":	{_group setSpeedMode _value};
	case "setBehaviour":	{_group setBehaviour _value};
	case "setCombatMode":	{_group setCombatMode _value};
	case "setFormation":	{_group setFormation _value};
};
true
