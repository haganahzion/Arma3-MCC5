/*
	MCC_fnc_requestVehicleInit
	Server: checks the sender, then runs MCC_fnc_setVehicleInit on the given targets.
	Init code is only accepted from the server, an admin, or an MCC user who is Zeus right now
	(MCC_fnc_isTrustedSender), in every Network Security mode.
	Params:
		0: ARRAY - the MCC_fnc_setVehicleInit arguments: [[netId, object], init string, save (optional)]
		1: NUMBER/OBJECT/SIDE/ARRAY - remoteExec targets (default 0 = everyone)
		2: BOOL - add to the JIP queue (default false)
	Example:
		[[[netId _unit, _unit], "_this allowDamage false"], 0, true] remoteExec ["MCC_fnc_requestVehicleInit", 2];
*/
params [["_args", [], [[]]], ["_targets", 0], ["_jip", false, [false]]];

if (!isServer) exitWith {};
if (isRemoteExecuted && {!([remoteExecutedOwner] call MCC_fnc_isTrustedSender)}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_requestVehicleInit from owner %1", remoteExecutedOwner];
};
if (count _args < 2 || {!((_args select 1) isEqualType "")}) exitWith {};

_args remoteExec ["MCC_fnc_setVehicleInit", _targets, _jip];
