/*
	MCC_fnc_requestGlobalExecute
	Server: checks the sender, then runs MCC_fnc_globalExecute on every machine. Used by the mission maker
	command line ("Global"). Code is only accepted from the server, an admin, or an MCC user who is Zeus
	right now (MCC_fnc_isTrustedSender), in every Network Security mode.
	Params:
		0: NUMBER - mode: 0 clients only, 1 server only, 2 clients and server
		1: CODE - code to run
	Example:
		[2, compile _string] remoteExec ["MCC_fnc_requestGlobalExecute", 2];
*/
params [["_mode", 2, [0]], ["_code", {}, [{}]]];

if (!isServer) exitWith {};
if !(["MCC_fnc_requestGlobalExecute"] call MCC_fnc_remoteTrusted) exitWith {};

[_mode, _code] remoteExec ["MCC_fnc_globalExecute", 0];
