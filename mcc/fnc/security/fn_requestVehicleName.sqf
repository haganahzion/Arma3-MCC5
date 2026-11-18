/*
	MCC_fnc_requestVehicleName
	Server: checks the sender and the name, then runs MCC_fnc_setVehicleName on every machine (JIP too).
	Accepted from the server, an admin, or an MCC user who is Zeus right now (MCC_fnc_isTrustedSender).
	The name must be a plain variable name, must not use a mod prefix and must not replace a variable
	that holds something other than an object.
	Params:
		0: ARRAY - [netId, object]
		1: STRING - the new name
	Example:
		[[netId _unit, _unit], "hvt_1"] remoteExec ["MCC_fnc_requestVehicleName", 2];
*/
#define MCC_NAME_PATTERN "[A-Za-z_][A-Za-z0-9_]{0,63}"
#define MCC_RESERVED_PREFIXES ["mcc_","gaia_","bis_","cba_","ace_","zen_","bin_","lambs_","rhs_","cup_","a3_"]

params [["_ref", [], [[]]], ["_name", "", [""]]];

if (!isServer) exitWith {};
if (isRemoteExecuted && {!([remoteExecutedOwner] call MCC_fnc_isTrustedSender)}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_requestVehicleName from owner %1", remoteExecutedOwner];
};
if !(_name regexMatch MCC_NAME_PATTERN) exitWith {
	diag_log format ["MCC: refused object name %1 (not a plain variable name)", str _name];
};
private _lower = toLower _name;
if ((MCC_RESERVED_PREFIXES findIf {(_lower find _x) == 0}) >= 0) exitWith {
	diag_log format ["MCC: refused object name %1 (reserved prefix)", _name];
};
private _old = missionNamespace getVariable _name;
if (!isNil "_old" && {!(_old isEqualType objNull)}) exitWith {
	diag_log format ["MCC: refused object name %1 (name already used)", _name];
};

[_ref, _name] remoteExec ["MCC_fnc_setVehicleName", 0, true];
