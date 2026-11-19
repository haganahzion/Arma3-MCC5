/*
	MCC_fnc_placeConvoy  (server)
	Checks the sender, then places a convoy of up to 5 vehicles, with or without an HVT (MCC_fnc_s_place_convoy).
	Params: [vehicle1, vehicle2, vehicle3, vehicle4, vehicle5, start, heading, side, VIPclass, VIPcar]
	Example: ["B_MRAP_01_F", "", "", "", "", _start, _heading, "west", "0", ""] remoteExec ["MCC_fnc_placeConvoy", 2];
*/
if (!isServer) exitWith {};
if !(["MCC_fnc_placeConvoy"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_this isEqualType []) exitWith {};
[(_this select 0), (_this select 1), (_this select 2), (_this select 3), (_this select 4), (_this select 5), (_this select 6), (_this select 7), (_this select 8), (_this select 9)] spawn MCC_fnc_s_place_convoy;
