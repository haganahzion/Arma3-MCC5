/*
	GAIA_fnc_findRide
	Looks for an empty land vehicle near the group leader, claims it and orders the group in. Any side's
	vehicle will do (an empty vehicle has no side), mod trucks included: seats are counted with fullCrew.
	The nearest vehicle that carries all the AI wins; else the nearest that carries most of them, and the
	AI that don't fit walk on as their own GAIA group. An AI unit drives (not the leader when possible).
	Players in the group get a seat when one is left; the AI don't wait for them.
	Params:
		0: GROUP
		1: ARRAY - objective position (remembered for the dismount)
		2: ARRAY - (optional) AI units to carry, default: alive AI on foot
	Returns: BOOL - true if a ride was found
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]], ["_objective", [], [[]]], ["_units", [], [[]]]];

private _leader = leader _group;
if (_units isEqualTo []) then {
	_units = (units _group) select {alive _x && {!isPlayer _x} && {vehicle _x == _x}};
};
if (_units isEqualTo []) exitWith {false};

private _radius = missionNamespace getVariable ["MCC_GAIA_rideSearchRadius", GAIA_RIDE_SEARCH_DEFAULT];
private _need = count _units;
private _minFit = (ceil (_need * GAIA_RIDE_MIN_FILL)) max (2 min _need);

private _candidates = ((_leader nearEntities [GAIA_RIDE_KINDS, _radius]) select {!(_x isKindOf "StaticWeapon")}) apply {[_leader distance _x, _x]};
_candidates sort true;

private _ride = objNull;
private _partial = objNull;
{
	private _v = _x select 1;
	private _claim = _v getVariable ["GAIA_claimedBy", grpNull];
	if (
		alive _v
		&& {canMove _v}
		&& {fuel _v > GAIA_RIDE_MIN_FUEL}
		&& {locked _v != GAIA_RIDE_LOCKED}
		&& {({alive _x} count crew _v) == 0}
		&& {isNull _claim || {_claim isEqualTo _group} || {({alive _x} count units _claim) == 0}}
		&& {!(_v getVariable ["GAIA_noRide", false])}
		// Seats assigned to units of another group: someone else's vehicle
		&& {(fullCrew [_v, "", true]) findIf {private _a = _x param [5, objNull]; !isNull _a && {alive _a} && {group _a != _group}} == -1}
	) then {
		private _seats = [_v] call GAIA_fnc_rideSeats;
		if ((_seats findIf {(_x select 0) == "driver"}) > -1) then {
			if (count _seats >= _need) then {_ride = _v};
			if (isNull _partial && {count _seats >= _minFit}) then {_partial = _v};
		};
	};
	if (!isNull _ride) exitWith {};
} forEach _candidates;

if (isNull _ride) then {_ride = _partial};
if (isNull _ride) exitWith {false};

_ride setVariable ["GAIA_claimedBy", _group, true];
_group setVariable ["GAIA_groupVehicle", _ride];
_group setVariable ["GAIA_isRide", true];
_group setVariable ["GAIA_rideObjective", _objective];
_group setVariable ["GAIA_dismounted", false];

private _players = (units _group) select {alive _x && {isPlayer _x} && {vehicle _x == _x}};
private _left = [_group, _ride, _units + _players] call GAIA_fnc_boardRide;
private _leftAI = _left select {!isPlayer _x};
if (_leftAI isNotEqualTo []) then {[_group, _leftAI] call GAIA_fnc_splitGroup};

if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
	diag_log format ["GAIA vehicles: %1 takes %2 to %3 (%4 m), %5 left to walk", _group, typeOf _ride, _objective, round (_leader distance2D _objective), count _leftAI];
};
true
