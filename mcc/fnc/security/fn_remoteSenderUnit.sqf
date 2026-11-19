/*
	MCC_fnc_remoteSenderUnit
	Server: returns the player unit of the machine that sent the current remoteExec call.
	Params: none
	Returns: OBJECT - the sender's unit, objNull for a local call or when the sender has no unit
	Example:
		private _unit = [] call MCC_fnc_remoteSenderUnit;
*/
if (!isRemoteExecuted) exitWith {objNull};
private _owner = remoteExecutedOwner;
private _unit = objNull;
{
	private _info = getUserInfo _x;
	if ((_info param [1, -1]) == _owner) exitWith {_unit = _info param [10, objNull]};
} forEach allUsers;
_unit
