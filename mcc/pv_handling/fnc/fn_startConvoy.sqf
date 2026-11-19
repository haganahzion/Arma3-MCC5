/*
	MCC_fnc_startConvoy  (server)
	Checks the sender, then drives the convoy through the given waypoints (MCC_fnc_s_start_convoy_execute).
	Params: [[wp1, wp2, ...], isVIP]; isVIP "0" means no VIP
	Example: [[_wp1, _wp2], "0"] remoteExec ["MCC_fnc_startConvoy", 2];
*/
if (!isServer) exitWith {};
if !(["MCC_fnc_startConvoy"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_this isEqualType []) exitWith {};
[(_this select 0), (_this select 1)] spawn MCC_fnc_s_start_convoy_execute;
