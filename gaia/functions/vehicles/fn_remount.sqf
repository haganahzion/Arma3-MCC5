/*
	GAIA_fnc_remount
	Puts the group back into its vehicle after a fight or when its next objective is far away,
	instead of walking there. Every AI on foot must fit; players get a seat when one is left.
	Params:
		0: GROUP
		1: OBJECT - the vehicle
		2: ARRAY  - (optional) AI units to put in, default: alive AI on foot
	Returns: BOOL - true if the order was given
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]], ["_veh", objNull, [objNull]], ["_foot", [], [[]]]];

if (!alive _veh || {!canMove _veh} || {fuel _veh < GAIA_REMOUNT_MIN_FUEL}) exitWith {false};

if (_foot isEqualTo []) then {
	_foot = (units _group) select {alive _x && {!isPlayer _x} && {vehicle _x == _x}};
};
if (_foot isEqualTo []) exitWith {false};

private _seats = [_veh] call GAIA_fnc_rideSeats;
private _hasDriver = alive (driver _veh);
if (!_hasDriver && {(_seats findIf {(_x select 0) == "driver"}) == -1}) exitWith {false};
if (count _seats < count _foot) exitWith {false};

_veh setVariable ["GAIA_claimedBy", _group, true];
private _players = (units _group) select {alive _x && {isPlayer _x} && {vehicle _x == _x}};
[_group, _veh, _foot + _players] call GAIA_fnc_boardRide;

_group setVariable ["GAIA_dismounted", false];

if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
	diag_log format ["GAIA vehicles: %1 re-mounts %2", _group, typeOf _veh];
};
true
