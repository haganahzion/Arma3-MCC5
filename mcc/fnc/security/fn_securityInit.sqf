/*
	MCC_fnc_securityInit  (postInit, server only)
	Keeps the clients' list of authorized owners up to date for Strict network security, so clients can check
	who is allowed to send them MCC commands.
*/
if (!isServer || {!isMultiplayer}) exitWith {};

// Who may use MCC: the server keeps its own copy in localNamespace. MCC_fnc_setAllowedPlayers sets it directly.
// Missions that set MCC_allowedPlayers / MCC_allowAdmin themselves on the server are followed by the copy below,
// until MCC_fnc_setAllowedPlayers is used. A value broadcast by any other machine is put back at once.
#define MCC_ACCESS_VARS [["MCC_allowedPlayers", ["all"]], ["MCC_allowAdmin", true]]
localNamespace setVariable ["MCC_accessCopy", {
	if (localNamespace getVariable ["MCC_accessFixed", false]) exitWith {};
	{
		_x params ["_name", "_default"];
		localNamespace setVariable [_name + "_server", missionNamespace getVariable [_name, _default]];
	} forEach MCC_ACCESS_VARS;
}];
call (localNamespace getVariable "MCC_accessCopy");
{
	(_x select 0) addPublicVariableEventHandler {
		params ["_name"];
		private _default = if (_name == "MCC_allowAdmin") then {true} else {["all"]};
		missionNamespace setVariable [_name, localNamespace getVariable [_name + "_server", _default]];
		publicVariable _name;
		diag_log format ["MCC network security: a client changed %1; restored the server's value", _name];
	};
} forEach MCC_ACCESS_VARS;

// Kept in localNamespace: a missionNamespace variable could be overwritten by any client with publicVariable.
localNamespace setVariable ["MCC_securityRefresh", {
	call (localNamespace getVariable "MCC_accessCopy");
	private _owners = [];
	{
		private _owner = (getUserInfo _x) param [1, -1];
		if (_owner > 0 && {[_owner] call MCC_fnc_isAuthorizedOwner}) then {_owners pushBackUnique _owner};
	} forEach allUsers;
	_owners sort true;
	if !(_owners isEqualTo (localNamespace getVariable ["MCC_authorizedOwnersLast", []])) then {
		localNamespace setVariable ["MCC_authorizedOwnersLast", _owners];
		// Sent with remoteExec, not publicVariable, so clients can check it came from the server.
		[_owners] remoteExec ["MCC_fnc_setAuthorizedOwners", -2, "MCC_authorizedOwnersJIP"];
	};
}];

addMissionEventHandler ["PlayerConnected", {[] spawn {sleep 1; call (localNamespace getVariable "MCC_securityRefresh")}}];
addMissionEventHandler ["PlayerDisconnected", {call (localNamespace getVariable "MCC_securityRefresh")}];

// Admin logins and MCC access-rights changes have no event, so also refresh every 10 seconds.
[] spawn {
	while {true} do {
		call (localNamespace getVariable "MCC_securityRefresh");
		sleep 10;
	};
};
