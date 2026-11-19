/*
	MCC_fnc_simpleSpawn  (server or headless client)
	Checks the sender, then spawns one unit, vehicle or object from the MCC 3D placer (MCC_fnc_s_simple_spawn).
	Params: [pos, dir, name, type, faction, withCrew, init, objName, hc]
	Example: [_pos, _dir, "", "B_Soldier_F", "BLU_F", false, "", "", false] remoteExec ["MCC_fnc_simpleSpawn", 0];
*/
if (!isServer && {!(missionNamespace getVariable ["MCC_isLocalHC", false])}) exitWith {};
if !(["MCC_fnc_simpleSpawn"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_this isEqualType []) exitWith {};
[(_this select 0), (_this select 1), (_this select 2), (_this select 3), (_this select 4), (_this select 5), (_this select 6), (_this select 7), (_this select 8)] spawn MCC_fnc_s_simple_spawn;
