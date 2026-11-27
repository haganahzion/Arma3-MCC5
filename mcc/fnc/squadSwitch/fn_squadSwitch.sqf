/*
	MCC_fnc_squadSwitch  (scheduled, on the player's machine)
	Puts the player into the nearest AI of their own squad after they die. When the squad is gone it
	takes the nearest friendly AI instead. With "Avoid Leadership Role" on it prefers soldiers who
	don't lead a group, and when you land in a group you'd end up leading it hands the lead to an AI.
	Afterwards it clears the blur and input lock that ACE (or the MCC medic system) left on screen.
	Params:
		0: OBJECT - the dead player unit
		1: GROUP  - their group
		2: SIDE   - their side
		3: ARRAY  - where they died (ATL)
	Example:
		[_dead, group _dead, side group _dead, getPosATL _dead] spawn MCC_fnc_squadSwitch;
*/
#define MCC_SWITCH_SETTLE_TIME		0.3
#define MCC_SWITCH_MAX_DAMAGE		0.9
#define MCC_SWITCH_ACE_TIMEOUT		5
#define MCC_SWITCH_LEADER_WAIT		10

params [["_dead", objNull, [objNull]], ["_grp", grpNull, [grpNull]], ["_side", sideUnknown, [sideUnknown]], ["_pos", [0,0,0], [[]]]];

private _avoidLead = missionNamespace getVariable ["MCC_squadSwitchAvoidLeader", false];

private _fnc_canTake = {
	alive _this
	&& {!isPlayer _this}
	&& {_this isKindOf "CAManBase"}
	&& {simulationEnabled _this}
	&& {damage _this < MCC_SWITCH_MAX_DAMAGE}
	&& {lifeState _this != "INCAPACITATED"}
	&& {!(_this getVariable ["ACE_isUnconscious", false])}
	&& {isNull (_this getVariable ["bis_fnc_moduleRemoteControl_owner", objNull])}
};

// Nearest first. With the leader option on, anyone who doesn't lead a group goes ahead of the leaders.
private _fnc_pick = {
	params ["_list"];
	if (_list isEqualTo []) exitWith {objNull};
	private _sorted = _list apply {
		private _leadPenalty = [0, 1] select (_avoidLead && {leader group _x == _x});
		[_leadPenalty, _x distance _pos, _x]
	};
	_sorted sort true;
	(_sorted select 0) select 2
};

// A mortar can kill several men in the same frame, so give it a moment to settle
uiSleep MCC_SWITCH_SETTLE_TIME;

// Something else (respawn, Zeus, another switch) already moved the player
if (player != _dead) exitWith {};

private _pick = [(units _grp) select {_x call _fnc_canTake}] call _fnc_pick;
private _msg = "Switched to squadmate";

if (isNull _pick) then {
	_pick = [allUnits select {side group _x == _side && {_x call _fnc_canTake}}] call _fnc_pick;
	_msg = "Squad is gone, switched to nearest ally";
};

if (isNull _pick) exitWith {systemChat "No friendlies left to switch to"};

// If this one dies too, the EntityKilled handler runs again for him
selectPlayer _pick;
systemChat format ["%1: %2", _msg, name _pick];

// Landed as the leader of a group with AI in it: give the lead to the next AI.
// When the dead player led the group the engine needs a few seconds to pick the new leader first.
if (_avoidLead) then {
	private _until = time + MCC_SWITCH_LEADER_WAIT;
	waitUntil {uiSleep 0.5; alive leader group player || {time > _until}};
};
if (_avoidLead && {leader group player == player} && {local group player}) then {
	private _others = (units group player) select {alive _x && {!isPlayer _x} && {lifeState _x != "INCAPACITATED"}};
	if (_others isNotEqualTo []) then {
		(group player) selectLeader (_others select 0);
		systemChat format ["%1 has the lead", name (_others select 0)];
	};
};

// MCC medic: the bleeding blur of the dead body stays on, its handler stopped when the body died
{
	private _fx = missionNamespace getVariable [_x, -1];
	if (_fx isEqualType 0 && {_fx >= 0}) then {_fx ppEffectEnable false};
} forEach ["MCC_medicBleedingPPEffectColor", "MCC_medicBleedingPPEffectBlur"];

// ACE: when you die while unconscious its fade-in blur and input lock stay with you. Its own
// player-changed handler only fades the effect, so turn it off at once when ACE sees the new unit.
if (!isNil "ace_medical_feedback_fnc_effectUnconscious") then {
	[{
		!isNil "ACE_player" && {ACE_player isEqualTo player}
	}, {
		private _uncon = player getVariable ["ACE_isUnconscious", false];
		if (!_uncon) then {
			[false, 0] call ace_medical_feedback_fnc_effectUnconscious;
			["unconscious", false] call ace_common_fnc_setDisableUserInputStatus;
			[true, player] call ace_common_fnc_setVolume;
			["ace_medical_feedback", 1, false] call ace_common_fnc_setHearingCapability;
		};
		[true] call ace_medical_feedback_fnc_handleEffects;
	}, [], MCC_SWITCH_ACE_TIMEOUT] call CBA_fnc_waitUntilAndExecute;
};
