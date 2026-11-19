/*
	MCC_fnc_isTrustedSender
	Checks whether a machine may send requests that run init code or name objects (MCC_fnc_requestVehicleInit,
	MCC_fnc_requestVehicleName). Applies in every Network Security mode.
	Server rules: the server itself, a logged-in admin, or a player who is allowed to use MCC and is Zeus right now.
	Client rules: only the server and this machine.
	Params:
		0: NUMBER - owner id, usually remoteExecutedOwner
	Returns: BOOL
	Example:
		if !([remoteExecutedOwner] call MCC_fnc_isTrustedSender) exitWith {};
*/
params [["_owner", -1, [0]]];

// remoteExecutedOwner is 0 in single player and for calls from a headless client.
if (!isMultiplayer || {_owner in [0, 2, clientOwner]}) exitWith {true};
if (!isServer) exitWith {false};
if ((admin _owner) > 0) exitWith {true};
if !([_owner] call MCC_fnc_isAuthorizedOwner) exitWith {false};

private _unit = objNull;
{
	private _info = getUserInfo _x;
	if ((_info param [1, -1]) == _owner) exitWith {_unit = _info param [10, objNull]};
} forEach allUsers;

!isNull _unit && {!isNull (getAssignedCuratorLogic _unit)}
