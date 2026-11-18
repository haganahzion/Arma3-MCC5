/*
	MCC_fnc_securityInit  (postInit, server only)
	Keeps the clients' list of authorized owners up to date for Strict network security, so clients can check
	who is allowed to send them MCC commands.
*/
if (!isServer || {!isMultiplayer}) exitWith {};

// Kept in localNamespace: a missionNamespace variable could be overwritten by any client with publicVariable.
localNamespace setVariable ["MCC_securityRefresh", {
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
