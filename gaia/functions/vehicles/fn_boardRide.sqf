/*
	GAIA_fnc_boardRide
	Gives units seats in a vehicle and orders them in. An AI unit drives: anyone but the leader when possible,
	never a player. Then the leader, the other AI and players last fill cargo, FFV/turret seats, gunner and
	commander. Starts the boarding timer read by GAIA_fnc_vehicleTick (players and stragglers that are not in
	by then are not waited for).
	Params:
		0: GROUP
		1: OBJECT - vehicle
		2: ARRAY  - units to seat (alive, on foot)
	Returns: ARRAY - units that got no seat
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]], ["_veh", objNull, [objNull]], ["_units", [], [[]]]];

if (isNull _group || {isNull _veh} || {_units isEqualTo []}) exitWith {_units};

private _leader = leader _group;
private _seats = [_veh] call GAIA_fnc_rideSeats;
private _ai = _units select {!isPlayer _x};
private _players = _units - _ai;

private _driver = objNull;
if ((_seats findIf {(_x select 0) == "driver"}) > -1) then {
	_driver = (_ai - [_leader]) param [0, _ai param [0, objNull]];
};

private _sorted = [];
{
	private _role = _x;
	_sorted append (_seats select {(_x select 0) == _role});
} forEach GAIA_RIDE_SEAT_ORDER;

private _order = (([_leader] arrayIntersect _ai) + (_ai - [_leader]) + _players) - [_driver];
private _seated = [];
private _left = [];

if (!isNull _driver) then {
	_driver assignAsDriver _veh;
	_seated pushBack _driver;
};
{
	if (_forEachIndex < count _sorted) then {
		(_sorted select _forEachIndex) params ["_role", "_turret"];
		switch (_role) do {
			case "cargo": {_x assignAsCargo _veh};
			case "gunner": {_x assignAsGunner _veh};
			case "commander": {_x assignAsCommander _veh};
			default {_x assignAsTurret [_veh, _turret]};
		};
		_seated pushBack _x;
	} else {
		_left pushBack _x;
	};
} forEach _order;

if (_seated isNotEqualTo []) then {
	_group addVehicle _veh;
	_seated allowGetIn true;
	_seated orderGetIn true;
	_group setVariable ["GAIA_boardUntil", time + GAIA_RIDE_BOARD_TIMEOUT];
};

_left
