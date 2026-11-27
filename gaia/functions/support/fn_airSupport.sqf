/* ----------------------------------------------------------------------------
Function: GAIA_fnc_airSupport

Description:
	Turns GAIA's own armed helicopters and planes into air support for their side
	(server, once per side per cycle, called by GAIA_fnc_issueOrders).

	Each aircraft that can still fight takes the best fight in range: the CA score
	from GAIA_fnc_prioritizeCAs, lowered with distance. It flies a search and destroy
	there, and every enemy the side has spotted around that CA is revealed to its crew
	so it actually engages (AI pilots ignore what they haven't seen themselves).
	A fight gets one aircraft, two when it is heavy (GAIA_HEAVY_CLASSES) or our troops
	there are badly outnumbered. Helicopters stay away from AA fights and from air CAs.
	An aircraft keeps its fight unless another scores GAIA_AIR_STICKY times higher.

	Aircraft with no ammo, low fuel, a player aboard, transport orders or LAMBS task
	waypoints are left to the normal GAIA orders, and so is everything when the
	MCC_GAIA_AIR_SUPPORT setting is off.

Parameters:
	0: SIDE
	1: ARRAY   - CA positions, best first (GAIA_fnc_prioritizeCAs)
	2: HASHMAP - caPos -> [score, class, enemy points, own points] (GAIA_fnc_prioritizeCAs)
	3: ARRAY   - GAIA groups of the side

Returns:
	ARRAY - groups flying air support this cycle (issueOrders gives them no other orders)
---------------------------------------------------------------------------- */
#include "..\gaiaDefines.hpp"

params [
	["_side", sideUnknown, [sideUnknown]],
	["_caList", [], [[]]],
	["_prio", createHashMap, [createHashMap]],
	["_groups", [], [[]]]
];

if (!isServer) exitWith {[]};

// Keep the waypoints when someone else (LAMBS, a player aboard) just took the group over
private _fnc_release = {
	params ["_grp", ["_keepWaypoints", false]];
	if (!_keepWaypoints) then {[_grp] call GAIA_fnc_removeWaypoints};
	_grp setVariable ["GAIA_Order", "", false];
	_grp setVariable ["GAIA_airTarget", nil, false];
};

if !(missionNamespace getVariable ["MCC_GAIA_AIR_SUPPORT", true]) exitWith {
	{if ((_x getVariable ["GAIA_Order", ""]) == GAIA_AIR_ORDER) then {[_x] call _fnc_release}} forEach (groups _side);
	[]
};

private _heliRange	= missionNamespace getVariable ["MCC_GAIA_AIR_RANGE", 4000];
private _caSize		= missionNamespace getVariable ["MCC_GAIA_CA_SIZE", 200];
private _suffix		= [_side] call GAIA_fnc_sideSuffix;
private _infoVar	= GAIA_TARGET_INFO_VAR + _suffix;
private _known		= missionNamespace getVariable [GAIA_KNOWN_TARGETS_VAR + _suffix, []];

private _air = _groups select {
	private _veh = vehicle leader _x;
	alive leader _x
	&& {_veh isKindOf "Air"}
	&& {canFire _veh}
	&& {someAmmo _veh}
	&& {fuel _veh > GAIA_AIR_MIN_FUEL}
	&& {((units _x) findIf {isPlayer _x}) < 0}
	&& {((_x getVariable ["GAIA_Order", ""]) find "Transport") < 0}
	&& {!([_x] call GAIA_fnc_hasLambsWaypoint)}
};

// Aircraft that can't fly support any more go back to the normal orders. Every group of the side,
// so one that left GAIA (zone removed) doesn't keep the flag that makes the other GAIA phases skip it.
{
	if ((_x getVariable ["GAIA_Order", ""]) == GAIA_AIR_ORDER && {!(_x in _air)}) then {
		private _takenOver = ([_x] call GAIA_fnc_hasLambsWaypoint) || {((units _x) findIf {isPlayer _x}) >= 0};
		[_x, _takenOver] call _fnc_release;
	};
} forEach (groups _side);

if (_air isEqualTo []) exitWith {[]};

// Air CAs are out: GAIA helicopters can't do much against jets or enemy helicopters
private _fights = _caList select {!(((_prio getOrDefault [_x, [0, "Infantry"]]) select 1) in ["Helicopter", "Autonomous"])};

private _fnc_reveal = {
	params ["_grp", "_caPos"];
	private _seen = _known select {
		alive _x && {(((_x getVariable [_infoVar, []]) param [1, [0,0,0]]) distance2D _caPos) < _caSize}
	};
	if (_seen isNotEqualTo []) then {[_grp, _seen select [0, GAIA_AIR_REVEAL_MAX]] call GAIA_fnc_groupReveal};
};

private _fnc_task = {
	params ["_grp", "_caPos"];
	[_grp] call GAIA_fnc_removeWaypoints;
	[_grp, "setCombatMode", "RED"] call GAIA_fnc_groupSet;
	[_grp, "setBehaviour", "AWARE"] call GAIA_fnc_groupSet;
	[_grp, _caPos, "SAD"] call GAIA_fnc_addAttackWaypoint;
	_grp setVariable ["GAIA_Order", GAIA_AIR_ORDER, false];
	_grp setVariable ["GAIA_OrderPosition", _caPos, false];
	_grp setVariable ["GAIA_airTarget", _caPos, false];
	if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
		diag_log format ["GAIA air support %1: %2 (%3) -> %4 %5", _side, _grp, typeOf vehicle leader _grp, _caPos, _prio getOrDefault [_caPos, []]];
	};
};

private _taken = createHashMap;
private _tasked = [];

// Aircraft already on a fight choose first, so they keep it while it is still worth it
private _order = [_air, [], {[1, 0] select ((_x getVariable ["GAIA_airTarget", []]) isNotEqualTo [])}, "ASCEND"] call BIS_fnc_sortBy;

{
	private _grp = _x;
	private _veh = vehicle leader _grp;
	private _isHeli = _veh isKindOf "Helicopter";
	private _range = [_heliRange * GAIA_AIR_PLANE_RANGE_FACTOR, _heliRange] select _isHeli;
	private _current = _grp getVariable ["GAIA_airTarget", []];

	private _best = [];
	private _bestScore = -1;
	{
		private _caPos = _x;
		(_prio getOrDefault [_caPos, [1, "Infantry", 0, 0]]) params ["_score", "_class", "_enemy", "_own"];
		private _heavy = (_class in GAIA_HEAVY_CLASSES) || {_own > 0 && {_enemy > GAIA_PRIORITY_OUTNUMBERED * _own}};
		private _max = [GAIA_AIR_PER_FIGHT, GAIA_AIR_PER_HEAVY_FIGHT] select _heavy;
		private _dist = _veh distance2D _caPos;
		if (
			_dist < _range
			&& {(_taken getOrDefault [_caPos, 0]) < _max}
			&& {!(_isHeli && {_class == "AA"})}
		) then {
			private _s = _score / (1 + _dist / GAIA_AIR_DISTANCE_SCALE);
			if (_caPos isEqualTo _current) then {_s = _s * GAIA_AIR_STICKY};
			if (_s > _bestScore) then {_bestScore = _s; _best = _caPos};
		};
	} forEach _fights;

	if (_best isEqualTo []) then {
		if ((_grp getVariable ["GAIA_Order", ""]) == GAIA_AIR_ORDER) then {[_grp] call _fnc_release};
	} else {
		_taken set [_best, (_taken getOrDefault [_best, 0]) + 1];
		_tasked pushBack _grp;
		private _onIt = _best isEqualTo _current
			&& {(_grp getVariable ["GAIA_Order", ""]) == GAIA_AIR_ORDER}
			&& {(count waypoints _grp) > currentWaypoint _grp};
		if (!_onIt) then {[_grp, _best] call _fnc_task};
		_grp setVariable ["GAIA_OrderTime", time, false];
		// Every cycle: the side keeps spotting new enemies there
		[_grp, _best] call _fnc_reveal;
	};
} forEach _order;

_tasked
