/*
	MCC_fnc_remoteTrusted
	Guard for functions that only the mission maker or a Zeus should be able to trigger over the network.
	Works in every Network Security mode. A local call is always allowed. A call that came over the network
	is allowed from the server, admins, Zeus users (MCC_fnc_isTrustedSender) and players allowed to use MCC
	(MCC_fnc_isAuthorizedOwner: the MCC Access Rights module, or everyone when there is none).
	Params:
		0: STRING - this function's name, used in the log
	Returns: BOOL - false means exit without doing anything
	Example:
		if !(["MCC_fnc_cas"] call MCC_fnc_remoteTrusted) exitWith {};
*/
params [["_fnc", "", [""]]];

if (!isRemoteExecuted) exitWith {true};
if ([remoteExecutedOwner] call MCC_fnc_isTrustedSender) exitWith {true};
if ([remoteExecutedOwner] call MCC_fnc_isAuthorizedOwner) exitWith {true};

diag_log format ["MCC network security: refused %1 from owner %2", _fnc, remoteExecutedOwner];
false
