/*
	MCC_fnc_gaiaTaskTick  (server)
	For a group with GAIA_followTasks: picks the nearest unfinished task of the group's side that has a destination,
	makes sure an MCC zone covers it (creating one if needed) and points GAIA at that zone. When the task is done,
	the next call moves the group on to the next task. With no tasks left, the group patrols its last zone (or the nearest one).
	Params:
		0: GROUP
*/
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
};

// Keep the current task while it's open, else the nearest open one
private _task = if (_current in _tasks) then {_current} else {
	private _withDist = _tasks apply {
		[_leader distance2D (_x call _fnc_taskPos), _x]
	};
	_withDist sort true;
	(_withDist select 0) select 1
};
if (_task == _current && {(_group getVariable ["GAIA_ZONE_INTEND", []]) isNotEqualTo []}) exitWith {};

private _dest = _task call _fnc_taskPos;

private _zone = [_dest, 400] call MCC_fnc_gaiaNearestZone;
if (_zone < 1) then {
	_zone = [] call MCC_fnc_MWnextZoneNumber;
	[_zone, _dest, [200, 200]] call MCC_fnc_MWUpdateZone;
};

_group setVariable ["GAIA_followTask", _task, true];
_group setVariable ["GAIA_ZONE_INTEND", [str _zone, "MOVE"], true];
[_group] call GAIA_fnc_removeWaypoints;
[_group] call GAIA_fnc_registerGroup;

if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
	diag_log format ["GAIA tasks: %1 -> task %2, zone %3 at %4", _group, _task, _zone, _dest];
};
