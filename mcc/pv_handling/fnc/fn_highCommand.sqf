/*
	MCC_fnc_highCommand  (server)
	Checks the sender, then sets up high command for a commander (MCC_fnc_s_hc_server).
	Params:
		0: ARRAY - [netId, commander]
		1: NUMBER - 0 make new commander, 1 remove all groups from the commander, 2 add group to the commander
	Example: [[netID _commander,_commander],_action] remoteExec ["MCC_fnc_highCommand",0];
*/
if (!isServer) exitWith {};
if !(["MCC_fnc_highCommand"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_this isEqualType []) exitWith {};
[(_this select 0), (_this select 1)] spawn MCC_fnc_s_hc_server;
