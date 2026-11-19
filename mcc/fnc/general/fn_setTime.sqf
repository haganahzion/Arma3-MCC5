//==================================================================MCC_fnc_setTime======================================================================================
// Setstime on all clients
// Example: [[year, month, day, hour, minute]] remoteExec ["MCC_fnc_setTime", [2, 0] select isServer];
//	year: number, YYYY
//	month: number, MM
//	day: number, DD
//	hour: number, HH
// 	minute: number, mm
//==============================================================================================================================================================================	

private ["_time"];

if !(["MCC_fnc_setTime"] call MCC_fnc_remoteTrusted) exitWith {};
// An MCC user's client sends this to the server, which passes it on to every client.
if (isServer && {isRemoteExecuted} && {!(remoteExecutedOwner in [2, clientOwner])}) then {_this remoteExec ["MCC_fnc_setTime", -2]};

_time = _this select 0;
setDate _time;
