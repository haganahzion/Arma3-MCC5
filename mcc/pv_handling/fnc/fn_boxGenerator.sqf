/*
	MCC_fnc_boxGenerator  (server)
	Checks the sender, then creates a box with the given weapons and items (MCC_fnc_s_box_spawn).
	Params: [pos, dir, weapons, magazines, items, rucks]; each list is [[classes], [amounts]]
	Example: [_pos, _dir, _weapons, _magazines, _items, _rucks] remoteExec ["MCC_fnc_boxGenerator",0];
*/
if (!isServer) exitWith {};
if !(["MCC_fnc_boxGenerator"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_this isEqualType []) exitWith {};
[(_this select 0), (_this select 1), (_this select 2), (_this select 3), (_this select 4)] spawn MCC_fnc_s_box_spawn;
