/* ----------------------------------------------------------------------------
Function: GAIA_fnc_prioritizeCAs

Description:
	Ranks one side's conflict areas (CAs) so the worst fights get handled first.
	Ground attacks, mortars, artillery, support calls and air support all walk the
	list in this order.

	score = enemy points x threat weight x contact factor / distance factor

	Threat weight comes from the CA class (GAIA_THREAT_WEIGHTS): a tank column
	outranks the same points of riflemen. The contact factor is 1 when none of our
	groups are fighting there; when some are, it rises with how badly they are
	outnumbered, so 15 against 2 jumps the queue. Fights far from our zones lose
	some weight, nearby ones don't.

Parameters:
	0: SIDE
	1: ARRAY - CA positions
	2: CODE  - CA cost lookup, [caPos] call -> [class, ?, points] (issueOrders' per cycle cache)
	3: ARRAY - GAIA groups of the side

Returns:
	ARRAY - [CA positions sorted best first, HASHMAP caPos -> [score, class, enemy points, own points in contact]]

Example:
	([_side, _CA, _fnc_caCost, _sideGroups] call GAIA_fnc_prioritizeCAs) params ["_sorted", "_info"];
---------------------------------------------------------------------------- */
#include "..\gaiaDefines.hpp"

params [
	["_side", sideUnknown, [sideUnknown]],
	["_caList", [], [[]]],
	["_fnc_cost", {[]}, [{}]],
	["_groups", [], [[]]]
];

private _info = createHashMap;
if (_caList isEqualTo []) exitWith {[[], _info]};

private _contactRange = missionNamespace getVariable ["MCC_GAIA_SUPPORT_CONTACT_RANGE", 600];
private _weights = createHashMapFromArray GAIA_THREAT_WEIGHTS;

// Leaders in a fight, looked up once instead of once per CA
private _fighting = (_groups select {alive leader _x && {behaviour leader _x == "COMBAT"}}) apply {
	[getPosATL leader _x, _x getVariable ["GAIA_points", 0]]
};

// Sorted as [score, index]: two positions are never compared when scores tie
private _index = -1;
private _scored = _caList apply {
	_index = _index + 1;
	private _caPos = _x;
	private _cost = [_caPos] call _fnc_cost;
	if (isNil "_cost" || {!(_cost isEqualType [])} || {count _cost < 3}) then {_cost = ["Infantry", 0, 0]};
	private _class = _cost select 0;
	private _enemy = _cost select 2;

	private _own = 0;
	private _inContact = 0;
	{
		_x params ["_pos", "_points"];
		if ((_pos distance2D _caPos) < _contactRange) then {
			_own = _own + _points;
			_inContact = _inContact + 1;
		};
	} forEach _fighting;

	private _contact = 1;
	if (_inContact > 0) then {
		_contact = GAIA_PRIORITY_CONTACT_BONUS + ((_enemy / (_own max 1)) min GAIA_PRIORITY_OUTNUMBER_CAP);
	};

	private _dist = ([_side, _caPos] call GAIA_fnc_getDistanceToClosestZone) min GAIA_PRIORITY_DISTANCE_CAP;
	private _score = (_enemy max 1) * (_weights getOrDefault [_class, 1]) * _contact / (1 + _dist / GAIA_PRIORITY_DISTANCE_SCALE);

	_info set [_caPos, [_score, _class, _enemy, _own]];
	[_score, _index]
};

_scored sort false;
[_scored apply {_caList select (_x select 1)}, _info]
