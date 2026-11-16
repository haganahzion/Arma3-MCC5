/*
	GAIA_fnc_contactTick
	Brings a GAIA group back to its own job after a fight. Runs where the group is local (server: from
	GAIA_fnc_groupTick, headless client: from GAIA_fnc_perFrame), at most every GAIA_CONTACT_TICK_INTERVAL s.
	Contact = an enemy known within GAIA_CONTACT_RADIUS m with information younger than GAIA_CONTACT_MAX_AGE s.
	A group in COMBAT counts as in contact too until the clock runs out, so a group left in COMBAT is caught.
	When there was no contact for GAIA_CONTACT_CLEAR_TIME s:
		- the group gets GAIA_CONTACT_CALM_BEHAVIOUR back if it is still in COMBAT. GAIA only gives new orders
		  to groups that are not in COMBAT, so this is what lets zone groups get their zone orders again.
		- task-following groups go back to their task: GAIA_contactEnded is set for MCC_fnc_gaiaTaskTick, which
		  runs right away on the server and within one task loop pass for headless client groups.
		- rides: GAIA_fnc_vehicleTick re-mounts when the objective is still far.
	Sets GAIA_inContact (BOOL, public on change), GAIA_lastContact (time, local) and GAIA_contactEnded
	(BOOL, public, task-following groups only, cleared by MCC_fnc_gaiaTaskTick).
	Task march (GAIA_taskMarch, set by MCC_fnc_gaiaTaskTick): a group on its way to a task stays in march mode
	(GAIA_fnc_marchAI) and only fights properly while enemies are known within GAIA_MARCH_ENGAGE_RADIUS m.
	GAIA_MARCH_CALM_TIME s after the last close enemy it goes back to march mode and keeps walking.
	Leaves alone: groups led by a player, FORTIFY and garrison groups, groups on LAMBS task waypoints.
	Params:
		0: GROUP
	Returns: nothing
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]]];

if (isNull _group) exitWith {};
if (time < (_group getVariable ["GAIA_contactNext", 0])) exitWith {};
_group setVariable ["GAIA_contactNext", time + GAIA_CONTACT_TICK_INTERVAL];

private _leader = leader _group;
if (!alive _leader || {!local _leader} || {isPlayer _leader}) exitWith {};

private _intend = _group getVariable ["GAIA_ZONE_INTEND", []];
if (_intend isEqualTo [] || {(_intend param [1, ""]) == "FORTIFY"}) exitWith {};
if (_group getVariable ["Garrisoning", false]) exitWith {};
if ([_group] call GAIA_fnc_hasLambsWaypoint) exitWith {};

// Task march: march mode unless enemies are close, back to normal once the group is there
private _marchAI = _group getVariable ["GAIA_marchAI", false];
if (_group getVariable ["GAIA_taskMarch", false]) then {
	if (count (_leader targets [true, GAIA_MARCH_ENGAGE_RADIUS, [], GAIA_CONTACT_MAX_AGE]) > 0) then {
		_group setVariable ["GAIA_marchCloseAt", time];
	};
	private _wantMarch = (time - (_group getVariable ["GAIA_marchCloseAt", -1e6])) > GAIA_MARCH_CALM_TIME;
	if (_wantMarch isNotEqualTo _marchAI) then {
		[_group, _wantMarch] call GAIA_fnc_marchAI;
		// Public: the server's task watchdog (MCC_fnc_gaiaTaskTick) must not re-path a group that is fighting,
		// also when the group lives on a headless client
		_group setVariable ["GAIA_marchFighting", !_wantMarch, true];
	};
} else {
	if (_marchAI) then {[_group, false] call GAIA_fnc_marchAI};
	if (!isNil {_group getVariable "GAIA_marchFighting"}) then {_group setVariable ["GAIA_marchFighting", nil, true]};
};

private _contact = count (_leader targets [true, GAIA_CONTACT_RADIUS, [], GAIA_CONTACT_MAX_AGE]) > 0;
private _was = _group getVariable ["GAIA_inContact", false];

// COMBAT alone counts as contact, except right after GAIA calmed the group down (the engine flips it back to COMBAT
// for old enemies, which would loop AWARE / COMBAT and keep GAIA's orders blocked)
private _combatCounts = (time - (_group getVariable ["GAIA_calmedAt", -1e6])) > GAIA_CONTACT_CALM_COOLDOWN;
if (_contact || {!_was && {_combatCounts} && {behaviour _leader == "COMBAT"}}) exitWith {
	_group setVariable ["GAIA_lastContact", time];
	if (!_was) then {_group setVariable ["GAIA_inContact", true, true]};
};
if (!_was) exitWith {};
if (time - (_group getVariable ["GAIA_lastContact", 0]) < GAIA_CONTACT_CLEAR_TIME) exitWith {};

// The fight is over
_group setVariable ["GAIA_inContact", false, true];
if (behaviour _leader == "COMBAT") then {
	_group setBehaviour GAIA_CONTACT_CALM_BEHAVIOUR;
	_group setVariable ["GAIA_calmedAt", time];
};

if (_group getVariable ["GAIA_followTasks", false]) then {
	_group setVariable ["GAIA_contactEnded", true, true];
	if (isServer && {!isNil "MCC_fnc_gaiaTaskTick"}) then {[_group] call MCC_fnc_gaiaTaskTick};
};

if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
	diag_log format ["GAIA contact: %1 out of contact, back to %2 (order %3)", _group, _intend, _group getVariable ["GAIA_Order", ""]];
};
