/*
	MCC_fnc_operationIntroStart  (server)
	Starts the operation intro: every AI group on every side goes to hold fire, the intro plays for the players of a
	side, and when those players have seen it (or the time limit runs out) every group gets its old combat mode back.
	Players watching the intro can't fire either (MCC_fnc_operationIntro).
	Params:
		0: ARRAY - intro data, see MCC_fnc_operationIntro
		1: SIDE  - players who see the intro, sideUnknown for everyone
	Returns: nothing
	Example: [["OPERATION", "Silver Arrow", "Kavala", "CSAT", ["Destroy the cache"], getMarkerPos "ao", "LeadTrack01_F", true], west] call MCC_fnc_operationIntroStart;
*/
#define HOLD_MIN_TIME 8
#define HOLD_NO_PLAYERS_TIME 40
#define HOLD_MAX_TIME 90
#define HOLD_CHECK_EVERY 1
#define HOLD_MODE "BLUE"
#define JIP_ID "MCC_opIntro"

if (!isServer) exitWith {};
params [["_data", [], [[]]], ["_side", sideUnknown, [sideUnknown]]];
if (missionNamespace getVariable ["MCC_opIntroRunning", false]) exitWith {};
MCC_opIntroRunning = true;

private _id = (missionNamespace getVariable ["MCC_opIntroId", 0]) + 1;
missionNamespace setVariable ["MCC_opIntroId", _id, true];

[_data, _side, _id] spawn {
	params ["_data", "_side", "_id"];

	private _fnc_setMode = {
		params ["_group", "_mode"];
		if (local _group) then {
			_group setCombatMode _mode;
		} else {
			[_group, _mode] remoteExec ["setCombatMode", groupOwner _group];
		};
	};

	// [group, combat mode before the intro]
	private _held = [];
	private _fnc_holdAll = {
		{
			private _group = _x;
			if (side _group != sideLogic
				&& {(units _group) findIf {!isPlayer _x && {alive _x}} > -1}
			) then {
				private _i = _held findIf {(_x select 0) isEqualTo _group};
				if (_i < 0) then {
					_held pushBack [_group, combatMode _group];
					[_group, HOLD_MODE] call _fnc_setMode;
				} else {
					// Something (GAIA, a waypoint) changed it during the intro: hold again
					if (combatMode _group != HOLD_MODE) then {[_group, HOLD_MODE] call _fnc_setMode};
				};
			};
		} forEach allGroups;
	};

	call _fnc_holdAll;
	missionNamespace setVariable ["MCC_opIntroHold", true, true];
	[_data, _side, _id] remoteExec ["MCC_fnc_operationIntro", [0, -2] select isDedicated, JIP_ID];

	private _start = time;
	waitUntil {
		sleep HOLD_CHECK_EVERY;
		call _fnc_holdAll;
		private _elapsed = time - _start;
		private _viewers = allPlayers select {
			!(_x isKindOf "HeadlessClient_F") && {_side == sideUnknown || {side group _x == _side}}
		};
		private _allDone = _viewers isNotEqualTo [] && {_viewers findIf {(_x getVariable ["MCC_opIntroDone", 0]) != _id} < 0};
		(_allDone && {_elapsed > HOLD_MIN_TIME})
		|| {_viewers isEqualTo [] && {_elapsed > HOLD_NO_PLAYERS_TIME}}
		|| {_elapsed > HOLD_MAX_TIME}
	};

	{
		_x params ["_group", "_mode"];
		if (!isNull _group && {combatMode _group == HOLD_MODE}) then {
			[_group, _mode] call _fnc_setMode;
		};
	} forEach _held;

	missionNamespace setVariable ["MCC_opIntroHold", false, true];
	MCC_opIntroRunning = false;
};
