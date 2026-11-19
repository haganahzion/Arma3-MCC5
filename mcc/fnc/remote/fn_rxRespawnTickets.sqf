/*
	MCC_fnc_rxRespawnTickets
	Server: adds respawn tickets to a side with BIS_fnc_respawnTickets.
	Remote calls are accepted only from the server, admins and MCC users who are Zeus (MCC_fnc_remoteTrusted).
	Params:
		0: SIDE - west, east, resistance or civilian
		1: NUMBER - tickets to add
	Example:
		[west, 200] remoteExec ["MCC_fnc_rxRespawnTickets", 2];
*/
params [["_side", sideUnknown, [west]], ["_tickets", 0, [0]]];

if (!isServer) exitWith {};
if !(["MCC_fnc_rxRespawnTickets"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_side in [west, east, resistance, civilian]) exitWith {};

[_side, _tickets] call BIS_fnc_respawnTickets;
