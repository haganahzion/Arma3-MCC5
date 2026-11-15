/*
	GAIA_fnc_vehicleTick
	Per-group vehicle logic, called by the GAIA scheduler for every registered group. Throttles itself
	to once every GAIA_VEH_TICK_INTERVAL seconds per group and exits fast for groups it does not handle.
	AI-led groups with players in them are handled; the players are never waited for or forced in or out.
	What it does:
		1. Long trip on foot  -> look for an empty vehicle nearby (GAIA_fnc_findRide).
		2. Close to objective  -> whole group gets out, leader included (GAIA_fnc_dismount).
		3. Boarding took too long -> stop waiting: players are left to it, AI stragglers walk as their own group.
		4. After a fight       -> if the objective is still far, get back in the same vehicle (GAIA_fnc_remount).
		5. Vehicle not GAIA_STUCK_PROGRESS m closer to the objective in GAIA_STUCK_TIME s -> re-path; after
		   GAIA_STUCK_TRIES tries, continue on foot.
		   (Off when HBQ Advanced Driving AI is loaded: it does its own unstuck/route recovery.)
		LAMBS Danger: groups on LAMBS task waypoints are left alone; contact dismounts are LAMBS's call,
		GAIA only re-mounts after the fight.
		6. Vehicle lost        -> forget it (a new ride may be found later).
	Params:
		0: GROUP
	Settings (missionNamespace, CBA "MCC GAIA" category):
		MCC_GAIA_vehiclesEnabled (true), MCC_GAIA_rideDistance (500 m), MCC_GAIA_dismountDistance (400 m),
		MCC_GAIA_rideSearchRadius (300 m). A ride is taken when the objective is further than the ride distance
		and at least GAIA_RIDE_MIN_DRIVE m past the dismount distance.
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]]];

if (isNull _group) exitWith {};
if (time < (_group getVariable ["GAIA_vehNext", 0])) exitWith {};
_group setVariable ["GAIA_vehNext", time + GAIA_VEH_TICK_INTERVAL];

if !(missionNamespace getVariable ["MCC_GAIA_vehiclesEnabled", true]) exitWith {};
if (_group getVariable ["GAIA_noVehicles", false]) exitWith {};

private _leader = leader _group;
if (!alive _leader || {!local _leader}) exitWith {};
// Groups led by a player are left alone; AI-led groups with players in them (e.g. a player squad member) are handled
if (isPlayer _leader) exitWith {};

private _intend = _group getVariable ["GAIA_ZONE_INTEND", []];
if (_intend isEqualTo [] || {(_intend param [1, ""]) == "FORTIFY"}) exitWith {};
if (_group getVariable ["Garrisoning", false]) exitWith {};
// GAIA's own transport system (a transporter group carrying another group) handles these
if ((_group getVariable ["GAIA_Order", ""]) == "DoTransport") exitWith {};

// Groups running a LAMBS task waypoint are LAMBS's job
if (["LAMBS"] call GAIA_fnc_compat && {(waypoints _group) findIf {"lambs_wp" in toLowerANSI (waypointScript _x)} > -1}) exitWith {};

private _class = _group getVariable ["GAIA_class", ""];
if (_class in ["Helicopter", "Autonomous", "Ship", "Artillery", "Mortar"]) exitWith {};

private _objective = [_group] call GAIA_fnc_groupObjective;
if (_objective isEqualTo []) exitWith {};
private _dist = _leader distance2D _objective;

private _rideDist = missionNamespace getVariable ["MCC_GAIA_rideDistance", GAIA_RIDE_DIST_DEFAULT];
private _dismountDist = missionNamespace getVariable ["MCC_GAIA_dismountDistance", GAIA_DISMOUNT_DIST_DEFAULT];
private _remountDist = (_dismountDist * 2) max GAIA_REMOUNT_MIN_DIST;

// Contact = an enemy known close by, counted over ticks. COMBAT behaviour alone is not contact: groups can stay
// in COMBAT long after the fight (GAIA_fnc_contactTick brings them back).
private _inCombat = count (_leader targets [true, GAIA_CONTACT_RADIUS, [], GAIA_CONTACT_MAX_AGE]) > 0;
private _calm = if (_inCombat) then {0} else {(_group getVariable ["GAIA_calmTicks", 0]) + 1};
_group setVariable ["GAIA_calmTicks", _calm];

private _veh = [_group] call GAIA_fnc_groupVehicle;

// 6. Vehicle lost
if (!isNull _veh && {!alive _veh || {!canMove _veh}}) then {
	_veh setVariable ["GAIA_claimedBy", grpNull, true];
	_group setVariable ["GAIA_groupVehicle", objNull];
	_group setVariable ["GAIA_isRide", false];
	_group setVariable ["GAIA_boardUntil", -1];
	_group leaveVehicle _veh;
	_veh = objNull;
};

// Pure crew groups (tanks, armed cars without passengers) are not dismounted: they fight from the vehicle.
// GAIA_fnc_unstick handles their stuck vehicles.
if (!isNull _veh && {!(_group getVariable ["GAIA_isRide", false])} && {(units _group) findIf {toLowerANSI ((assignedVehicleRole _x) param [0, ""]) == "cargo"} == -1} && {(units _group) findIf {alive _x && {vehicle _x == _x}} == -1}) exitWith {};

// AI that can walk to a vehicle: players decide for themselves, unconscious units (ACE or vanilla) can't move
private _onFoot = (units _group) select {
	alive _x && {vehicle _x == _x} && {!isPlayer _x}
	&& {lifeState _x != "INCAPACITATED"} && {!(_x getVariable ["ACE_isUnconscious", false])}
};
private _aiInVeh = (units _group) findIf {alive _x && {!isPlayer _x} && {vehicle _x != _x}} > -1;
private _mounted = !isNull _veh && {vehicle _leader == _veh};
private _boardUntil = _group getVariable ["GAIA_boardUntil", -1];

// 1. Long trip on foot: find a ride
if (isNull _veh) exitWith {
	if (
		!_inCombat
		&& {_dist > (_rideDist max (_dismountDist + GAIA_RIDE_MIN_DRIVE))}
		&& {_leader in _onFoot}
		&& {!_aiInVeh}
		&& {time > (_group getVariable ["GAIA_noRideUntil", 0])}
	) then {
		[_group, _objective, _onFoot] call GAIA_fnc_findRide;
	};
};

// 2. Close to the objective: everybody out, leader included
if (_mounted && {_dist < _dismountDist} && {!(_group getVariable ["GAIA_dismounted", false])}) exitWith {
	[_group, _veh] call GAIA_fnc_dismount;
	_group setVariable ["GAIA_stuck", nil];
	_group setVariable ["GAIA_boardUntil", -1];
};

// 3. Boarding took too long: drive off without the ones still outside (the assigned driver is always waited for)
if (_boardUntil > 0 && {time > _boardUntil}) then {
	_group setVariable ["GAIA_boardUntil", -1];
	private _late = (units _group) select {
		alive _x && {vehicle _x == _x} && {_x != _leader} && {assignedVehicle _x == _veh}
		&& {toLowerANSI ((assignedVehicleRole _x) param [0, ""]) != "driver"}
	};
	if (_late isNotEqualTo []) then {
		{unassignVehicle _x} forEach _late;
		_late orderGetIn false;
		private _lateAI = _late select {!isPlayer _x};
		if (_lateAI isNotEqualTo []) then {[_group, _lateAI] call GAIA_fnc_splitGroup};
		_onFoot = _onFoot - _lateAI;
	};
	_boardUntil = -1;
};

// 4. Fight is over and the objective is still far: back in the vehicle (not while the group is still getting in)
if (_onFoot isNotEqualTo [] && {_boardUntil < 0} && {_calm >= GAIA_CALM_TICKS} && {_dist > _remountDist} && {time > (_group getVariable ["GAIA_noRideUntil", 0])}) exitWith {
	if !([_group, _veh, _onFoot] call GAIA_fnc_remount) then {
		// Vehicle can't take everyone any more: let it go, walk or find another ride later
		_veh setVariable ["GAIA_claimedBy", grpNull, true];
		_group setVariable ["GAIA_groupVehicle", objNull];
		_group setVariable ["GAIA_isRide", false];
		_group leaveVehicle _veh;
	};
};

// 5. Driving but not getting closer (stuck, or wandering around the map): re-path, after GAIA_STUCK_TRIES tries continue on foot
// Skipped when HBQ Advanced Driving AI is loaded: it has its own unstuck and route recovery.
if (_mounted && {!_inCombat} && {!(["HBQ"] call GAIA_fnc_compat)}) then {
	private _stuck = _group getVariable ["GAIA_stuck", [time, _dist, 0]];
	_stuck params ["_since", "_lastDist", "_tries"];
	if (_dist < _lastDist - GAIA_STUCK_PROGRESS) then {
		_group setVariable ["GAIA_stuck", [time, _dist, 0]];
	} else {
		if (time - _since > GAIA_STUCK_TIME) then {
			if (_tries >= GAIA_STUCK_TRIES) then {
				[_group, _veh] call GAIA_fnc_dismount;
				_group setVariable ["GAIA_noRideUntil", time + GAIA_NO_RIDE_COOLDOWN];
				_group setVariable ["GAIA_stuck", nil];
			} else {
				// Re-setting the waypoint position makes the driver plan a new route
				private _wp = [_group, currentWaypoint _group];
				private _wpPos = waypointPosition _wp;
				if ([_wpPos] call GAIA_fnc_isValidPos) then {_wp setWaypointPosition [_wpPos, 0]} else {_group move _objective};
				_group setVariable ["GAIA_stuck", [time, _dist, _tries + 1]];
			};
		};
	};
} else {
	if (_mounted) then {_group setVariable ["GAIA_stuck", [time, _dist, 0]]};
};
