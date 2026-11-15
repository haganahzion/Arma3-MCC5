/*
	MCC_fnc_curatorAllAddons
	Names of every loaded CfgPatches addon, worked out once and kept in MCC_curatorAllAddons. MCC curators get all
	of them (like a Game Master module set to "All addons, including unofficial ones"), so the Zeus Modules and
	Objects lists show other mods' modules too: CAS, support, LZ and reinforcement mods, ZEN, and so on.
	Params: none
	Returns: ARRAY of STRING
*/
if (isNil "MCC_curatorAllAddons") then {
	MCC_curatorAllAddons = ("true" configClasses (configFile >> "CfgPatches")) apply {configName _x};
};
+MCC_curatorAllAddons
