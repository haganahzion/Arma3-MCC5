/*
	GAIA_fnc_splitGroup
	Moves AI units out of a GAIA group into a new group of the same side with the same GAIA orders (zone,
	task following, vehicle use, caching) and waypoints, so the ones a ride can't carry walk on by themselves.
	Players and the leader never move.
	Params:
		0: GROUP
		1: ARRAY - units to move
	Returns: GROUP - the new group, grpNull if nothing was moved
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]], ["_units", [], [[]]]];

if (isNull _group) exitWith {grpNull};
private _leader = leader _group;
_units = _units select {alive _x && {group _x == _group} && {!isPlayer _x} && {_x != _leader}};
if (_units isEqualTo []) exitWith {grpNull};

private _new = createGroup [side _group, true];
if (isNull _new) exitWith {grpNull};

{unassignVehicle _x} forEach _units;
_units orderGetIn false;
_units joinSilent _new;
_new copyWaypoints _group;

{
	private _value = _group getVariable _x;
	if (!isNil "_value") then {_new setVariable [_x, _value, true]};
} forEach GAIA_SPLIT_VARS;

if (isServer) then {[_new] call GAIA_fnc_registerGroup};

if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
	diag_log format ["GAIA vehicles: %1 splits %2 unit(s) into %3 to walk", _group, count _units, _new];
};
_new
