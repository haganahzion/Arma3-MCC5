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

private _contact = count (_leader targets [true, GAIA_CONTACT_RADIUS, [], GAIA_CONTACT_MAX_AGE]) > 0;
private _was = _group getVariable ["GAIA_inContact", false];

if (_contact || {!_was && {behaviour _leader == "COMBAT"}}) exitWith {
	_group setVariable ["GAIA_lastContact", time];
	if (!_was) then {_group setVariable ["GAIA_inContact", true, true]};
};
if (!_was) exitWith {};
if (time - (_group getVariable ["GAIA_lastContact", 0]) < GAIA_CONTACT_CLEAR_TIME) exitWith {};

// The fight is over
_group setVariable ["GAIA_inContact", false, true];
if (behaviour _leader == "COMBAT") then {_group setBehaviour GAIA_CONTACT_CALM_BEHAVIOUR};

if (_group getVariable ["GAIA_followTasks", false]) then {
	_group setVariable ["GAIA_contactEnded", true, true];
	if (isServer && {!isNil "MCC_fnc_gaiaTaskTick"}) then {[_group] call MCC_fnc_gaiaTaskTick};
};

if (missionNamespace getVariable ["MCC_GAIA_debug", false]) then {
	diag_log format ["GAIA contact: %1 out of contact, back to %2 (order %3)", _group, _intend, _group getVariable ["GAIA_Order", ""]];
};
