/*
	MCC_fnc_remoteOwnsUnit
	Guard for player features reached over the network: the sender must be the machine that controls the
	given unit. Use on the server (owner only works there). A local call is always allowed, and so is a
	trusted sender (MCC_fnc_isTrustedSender).
	Params:
		0: OBJECT - the unit the request acts on
		1: STRING - the calling function's name, used in the log
	Returns: BOOL - false means exit without doing anything
	Example:
		if !([_unit, "MCC_fnc_setVariable"] call MCC_fnc_remoteOwnsUnit) exitWith {};
*/
params [["_unit", objNull, [objNull]], ["_fnc", "", [""]]];

if (!isRemoteExecuted) exitWith {true};
private _sender = remoteExecutedOwner;
if (!isNull _unit && {(owner _unit) == _sender}) exitWith {true};
if ([_sender] call MCC_fnc_isTrustedSender) exitWith {true};

diag_log format ["MCC network security: refused %1 from owner %2 (not the unit's owner)", _fnc, _sender];
false
