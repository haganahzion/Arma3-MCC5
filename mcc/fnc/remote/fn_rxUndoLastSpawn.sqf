//==================================================================MCC_fnc_rxUndoLastSpawn===============================================================================
// Delete the last entry of MCC_lastSpawn (an object, or [object, [objects]]) and remove it from the list. Runs on every machine.
// Clients send it to the server (trusted senders only), which passes it on to every client.
// Called by mcc\general_scripts\delete\undo.sqf.
// Example: [] remoteExec ["MCC_fnc_rxUndoLastSpawn", [2, 0] select isServer];
// <IN>
//		Nothing
//
// <OUT>
//		Nothing
//===========================================================================================================================================================================
private ["_last"];

if !(["MCC_fnc_rxUndoLastSpawn"] call MCC_fnc_remoteTrusted) exitWith {};
// An MCC user's client sends this to the server, which passes it on to every client.
if (isServer && {isRemoteExecuted} && {!(remoteExecutedOwner in [2, clientOwner])}) then {_this remoteExec ["MCC_fnc_rxUndoLastSpawn", -2]};

if (isNil "MCC_lastSpawn") exitWith {};

if ((count MCC_lastSpawn)>0) then
{
	_last = MCC_lastSpawn select ((count MCC_lastSpawn)-1);
	if (typeName _last == "ARRAY") then
	{
		deleteVehicle (_last select 0);
		{deleteVehicle _x} forEach (_last select 1);
	}
	else
	{
		deleteVehicle _last;
	};

	MCC_lastSpawn resize ((count MCC_lastSpawn)-1);
};
