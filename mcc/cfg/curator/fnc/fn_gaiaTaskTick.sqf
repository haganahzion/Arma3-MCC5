/*
	MCC_fnc_gaiaTaskTick  (server, every 15 s from the task loop and when a fight ends)
	For a group with GAIA_followTasks: picks the nearest unfinished task of the group's side that has a destination,
	makes sure an MCC zone covers it (creating one if needed) and points GAIA at that zone.
	The task comes first. Until the group is at the task (GAIA_TASK_ARRIVE_RADIUS m or inside the task zone) it
	"marches" (GAIA_taskMarch):
		- GAIA gives it no other orders (GAIA_fnc_issueOrders leaves marching groups alone), so it is never sent
		  off to another fight, a clear spot or a transport job, and its march order never times out.
		- march mode (GAIA_fnc_marchAI, switched by GAIA_fnc_contactTick): return fire and keep walking; only
		  enemies within GAIA_MARCH_ENGAGE_RADIUS m make it stop and fight.
		- watchdog: the march waypoint is put back when it is gone or points elsewhere, and set again when the
		  group gets no closer on foot for GAIA_MARCH_STUCK_TIME s. Rides: GAIA_fnc_vehicleTick.
	At the task the march ends and GAIA runs the group in the task zone (attack what is there, patrol).
	An arrived group that gets more than GAIA_TASK_LEAVE_RADIUS m away and leaves the zone marches back.
	When the task is done, the next call moves the group on to the next task. With no tasks left, the group
	patrols its last zone (or the nearest one).
	Params:
		0: GROUP
*/
#include "..\..\..\..\gaia\functions\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]]];
if (!isServer || {isNull _group}) exitWith {};
private _leader = leader _group;
if (!alive _leader || {isPlayer _leader}) exitWith {};

// Task destination as a position: BIS_fnc_taskDestination returns a position, an object, [object, precision]
// or objNull (no destination / unknown task). Returns [] when there is no usable destination.
private _fnc_taskPos = {
	private _d = [_this] call BIS_fnc_taskDestination;
	if (_d isEqualType [] && {_d isNotEqualTo []} && {(_d select 0) isEqualType objNull}) then {_d = _d select 0};
	if (_d isEqualType objNull) then {_d = if (isNull _d) then {[]} else {getPosATL _d}};
	if (!(_d isEqualType []) || {count _d < 2} || {(_d select 0) isEqualTo 0 && {(_d select 1) isEqualTo 0}}) then {_d = []};
	_d
};

private _current = _group getVariable ["GAIA_followTask", ""];
// Tasks of the leader; AI units may not hold task data, so also use the server's list of MCC tasks for this side
private _all = [_leader] call BIS_fnc_tasksUnit;
{
	_x params ["_id", "_owner"];
	if ((_owner isEqualType west && {_owner == side _group}) || {_owner isEqualType [] && {side _group in _owner}}) then {_all pushBackUnique _id};
} forEach (missionNamespace getVariable ["MCC_taskRegistry", []]);
private _tasks = _all select {
	!([_x] call BIS_fnc_taskCompleted) && {(_x call _fnc_taskPos) isNotEqualTo []}
};
// No open tasks: patrol. Keep the current zone, or take the nearest one (or make one around the group).
if (_tasks isEqualTo []) exitWith {
	if ((_group getVariable ["GAIA_ZONE_INTEND", []]) isEqualTo []) then {
		private _zone = [getPosATL _leader] call MCC_fnc_gaiaNearestZone;
		if (_zone < 1) then {
			_zone = [] call MCC_fnc_MWnextZoneNumber;
			[_zone, getPosATL _leader, [300, 300]] call MCC_fnc_MWUpdateZone;
		};
		_group setVariable ["GAIA_ZONE_INTEND", [str _zone, "MOVE"], true];
		[_group] call GAIA_fnc_registerGroup;
	};
	_group setVariable ["GAIA_followTask", "", true];
	// Was on its way to a task that is now done: stop and let GAIA run it in the zone
	if (_group getVariable ["GAIA_taskMarch", false]) then {
		_group setVariable ["GAIA_taskMarch", nil, true];
		[_group] call GAIA_fnc_removeWaypoints;
	};
};

// Keep the current task while it's open, else the nearest open one
private _task = if (_current in _tasks) then {_current} else {
	private _withDist = _tasks apply {
		[_leader distance2D (_x call _fnc_taskPos), _x]
	};
	_withDist sort true;
	(_withDist select 0) select 1
};
private _intend = _group getVariable ["GAIA_ZONE_INTEND", []];
if (_group getVariable ["GAIA_contactEnded", false]) then {_group setVariable ["GAIA_contactEnded", nil, true]};
private _dest = _task call _fnc_taskPos;
private _debug = missionNamespace getVariable ["MCC_GAIA_debug", false];

// Send the group to the task: one MOVE waypoint, march order. The order is a patrol with the task as its
// position, so GAIA's vehicle logic sees the destination and the group isn't counted as busy with a fight.
private _fnc_march = {
	params ["_group", "_dest"];
	[_group] call GAIA_fnc_removeWaypoints;
	private _wp = _group addWaypoint [_dest, 0];
	_wp setWaypointType "MOVE";
	_wp setWaypointBehaviour (["UNCHANGED", GAIA_MARCH_BEHAVIOUR] select (behaviour leader _group != "COMBAT"));
	_wp setWaypointCombatMode GAIA_MARCH_COMBAT_MODE;
	_wp setWaypointSpeed GAIA_MARCH_SPEED;
	_wp setWaypointCompletionRadius GAIA_MARCH_WP_RADIUS;
	_group setCurrentWaypoint _wp;
	_group setVariable ["GAIA_Order", "DoPatrol", false];
	_group setVariable ["GAIA_OrderTime", time, false];
	_group setVariable ["GAIA_OrderPosition", _dest, false];
	_group setVariable ["GAIA_marchProgress", [time, (leader _group) distance2D _dest]];
	_group setVariable ["GAIA_taskMarch", true, true];
};

// At the task: close enough. Arriving needs the leader near the task itself (an existing zone can be big);
// staying also counts the whole task zone, so GAIA can patrol it without the group marching back.
private _fnc_arrived = {
	params ["_group", "_dest", "_radius", ["_zoneCounts", false]];
	private _zone = (_group getVariable ["GAIA_ZONE_INTEND", []]) param [0, ""];
	((leader _group) distance2D _dest) < _radius
	|| {_zoneCounts && {_zone != ""} && {[getPosATL leader _group, _zone] call GAIA_fnc_inZone}}
};

// New task (or no zone yet): zone at the task, march there
if (_task != _current || {_intend isEqualTo []}) exitWith {
	private _zone = [_dest, GAIA_TASK_ZONE_SEARCH] call MCC_fnc_gaiaNearestZone;
	if (_zone < 1) then {
		_zone = [] call MCC_fnc_MWnextZoneNumber;
		[_zone, _dest, GAIA_TASK_ZONE_SIZE] call MCC_fnc_MWUpdateZone;
	};
	_group setVariable ["GAIA_followTask", _task, true];
	_group setVariable ["GAIA_ZONE_INTEND", [str _zone, "MOVE"], true];
	[_group] call GAIA_fnc_registerGroup;

	if ([_group, _dest, GAIA_TASK_ARRIVE_RADIUS] call _fnc_arrived) then {
		_group setVariable ["GAIA_taskMarch", nil, true];
		[_group] call GAIA_fnc_removeWaypoints;
	} else {
		[_group, _dest] call _fnc_march;
	};
	if (_debug) then {diag_log format ["GAIA tasks: %1 -> task %2, zone %3 at %4", _group, _task, _zone, _dest]};
};

private _marching = _group getVariable ["GAIA_taskMarch", false];

// Not marching: at the task, GAIA runs it in the zone. March back when it got pulled far away.
if (!_marching) exitWith {
	if !([_group, _dest, GAIA_TASK_LEAVE_RADIUS, true] call _fnc_arrived) then {
		[_group, _dest] call _fnc_march;
		if (_debug) then {diag_log format ["GAIA tasks: %1 too far from task %2, marching back", _group, _task]};
	};
};

// Marching and there: hand over to GAIA in the task zone
if ([_group, _dest, GAIA_TASK_ARRIVE_RADIUS] call _fnc_arrived) exitWith {
	_group setVariable ["GAIA_taskMarch", nil, true];
	_group setVariable ["GAIA_marchProgress", nil];
	[_group] call GAIA_fnc_removeWaypoints;
	if (_debug) then {diag_log format ["GAIA tasks: %1 reached task %2", _group, _task]};
};

// Marching: the waypoint must still lead to the task (it can be gone after a fight, or the task moved)
private _wps = waypoints _group;
private _wpOk = (
	count _wps > 0
	&& {currentWaypoint _group < count _wps}
	&& {((waypointPosition (_wps select (count _wps - 1))) distance2D _dest) < GAIA_MARCH_WP_TOLERANCE}
);
if (!_wpOk) exitWith {
	[_group, _dest] call _fnc_march;
	if (_debug) then {diag_log format ["GAIA tasks: %1 march waypoint to task %2 set again", _group, _task]};
};

// Marching on foot but getting no closer: new path. Not while getting into a ride, driving (GAIA_fnc_vehicleTick
// handles stuck vehicles) or fighting close enemies.
private _dist = _leader distance2D _dest;
(_group getVariable ["GAIA_marchProgress", [time, _dist]]) params ["_since", "_lastDist"];
if (_dist < _lastDist - GAIA_MARCH_PROGRESS) exitWith {
	_group setVariable ["GAIA_marchProgress", [time, _dist]];
};
private _busy = (
	vehicle _leader != _leader
	|| {(_group getVariable ["GAIA_boardUntil", -1]) > 0}
	|| {_group getVariable ["GAIA_marchFighting", false]}
);
if (_busy) exitWith {_group setVariable ["GAIA_marchProgress", [time, _dist]]};
if (time - _since > GAIA_MARCH_STUCK_TIME) then {
	[_group, _dest] call _fnc_march;
	{if (!isPlayer _x && {local _x}) then {_x doFollow leader _group}} forEach (units _group);
	if (_debug) then {diag_log format ["GAIA tasks: %1 stuck on the way to task %2, new path", _group, _task]};
};
