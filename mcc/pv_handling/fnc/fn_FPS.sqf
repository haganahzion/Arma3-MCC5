/*
	MCC_fnc_FPS  (server or headless client)
	Starts the FPS benchmark that reports the server's frame rate (MCC_fnc_s_fps_benchmark).
	Params: [mode]
	Example: [1] remoteExec ["MCC_fnc_FPS", 0];
*/
if (!isServer && {!(missionNamespace getVariable ["MCC_isLocalHC", false])}) exitWith {};
if !(["MCC_fnc_FPS"] call MCC_fnc_remoteAllowed) exitWith {};
if !(_this isEqualType []) exitWith {};
[(_this select 0)] spawn MCC_fnc_s_fps_benchmark;
