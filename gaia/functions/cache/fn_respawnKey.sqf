/* ----------------------------------------------------------------------------
Function: GAIA_fnc_respawnKey

Description:
	Server. Returns the missionNamespace variable name that holds the respawn
	data of a group. The name uses a unique GAIA id stored on the group
	(GAIA_UID), so groups with the same callsign never share respawn data.
	A group without an id gets the next one, or the given id (restored groups
	keep the id of the group they were cached from).

Parameters:
	0: GROUP
	1: NUMBER - (optional) id to give the group when it has none, default -1 (next free id)

Returns:
	STRING - variable name, "" for a null group
---------------------------------------------------------------------------- */
#define GAIA_RESPAWN_PREFIX "GAIA_RESPAWN_"
#define GAIA_UID_VAR "GAIA_UID"

params [["_group", grpNull, [grpNull]], ["_useId", -1, [0]]];
if (isNull _group) exitWith {""};

private _id = _group getVariable [GAIA_UID_VAR, -1];
if (_id < 0) then {
	if (_useId >= 0) then {
		_id = _useId;
	} else {
		_id = missionNamespace getVariable ["GAIA_UID_COUNTER", 0];
		missionNamespace setVariable ["GAIA_UID_COUNTER", _id + 1];
	};
	_group setVariable [GAIA_UID_VAR, _id];
};

GAIA_RESPAWN_PREFIX + str _id
