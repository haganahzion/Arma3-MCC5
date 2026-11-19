/*
	MCC_fnc_setAllowedPlayers  (server only, never over the network)
	Sets who may use MCC: stores the server's own copy in localNamespace (what MCC_fnc_isAuthorizedOwner reads)
	and shares MCC_allowedPlayers / MCC_allowAdmin with the clients for their menus.
	Params:
		0: ARRAY of STRING - player UIDs, or ["all"]
		1: BOOL - admins and the host may use MCC (optional, default: keep the current value)
	Example:
		[["76561198000000000"], true] call MCC_fnc_setAllowedPlayers;
*/
params [["_names", [], [[]]], ["_allowAdmin", localNamespace getVariable ["MCC_allowAdmin_server", true], [true]]];

if (!isServer || {isRemoteExecuted}) exitWith {};

_names = (_names apply {if (_x isEqualType 0) then {str _x} else {_x}}) select {_x isEqualType ""};

localNamespace setVariable ["MCC_accessFixed", true];
localNamespace setVariable ["MCC_allowedPlayers_server", _names];
localNamespace setVariable ["MCC_allowAdmin_server", _allowAdmin];
missionNamespace setVariable ["MCC_allowedPlayers", _names];
missionNamespace setVariable ["MCC_allowAdmin", _allowAdmin];
publicVariable "MCC_allowedPlayers";
publicVariable "MCC_allowAdmin";
