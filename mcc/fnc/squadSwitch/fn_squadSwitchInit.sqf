/*
	MCC_fnc_squadSwitchInit  (postInit, players only)
	Adds the death handler for Squad Switch. The handler is always there and reads the
	MCC_squadSwitch setting when you die, so the setting can be changed during the mission.
*/
if (!hasInterface) exitWith {};

addMissionEventHandler ["EntityKilled", {
	params ["_dead"];
	if (_dead != player) exitWith {};
	if !(missionNamespace getVariable ["MCC_squadSwitch", false]) exitWith {};
	// Remote controlling a unit (MCC Unit Manage / RTS): its own Killed handler takes you back to your body
	if (!isNil "MCC_Prev_Player" && {alive MCC_Prev_Player} && {MCC_Prev_Player != _dead}) exitWith {};
	[_dead, group _dead, side group _dead, getPosATL _dead] spawn MCC_fnc_squadSwitch;
}];
