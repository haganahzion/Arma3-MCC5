/*
	MCC_fnc_rxEndMission
	Server: ends the mission for everyone with BIS_fnc_endMissionServer.
	Remote calls are accepted only from the server, admins and MCC users who are Zeus (MCC_fnc_remoteTrusted).
	Params:
		0: STRING - "everyonewon" or "everyonelost"
	Example:
		["everyonewon"] remoteExec ["MCC_fnc_rxEndMission", 2];
*/
params [["_type", "", [""]]];

if (!isServer) exitWith {};
if !(["MCC_fnc_rxEndMission"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_type in ["everyonewon", "everyonelost"]) exitWith {};

[_type] call BIS_fnc_endMissionServer;
