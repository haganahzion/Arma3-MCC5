/*
	GAIA_fnc_isValidPos
	Checks that a computed position is safe to send a group to.
	Rejects [] and the world center (BIS_fnc_findSafePos failure value), either of which would send AI
	driving across the map.
	Params:
		0: ARRAY - position to check
	Returns: BOOL
*/
params [["_pos", [], [[]]]];

if (count _pos < 2) exitWith {false};
if !((_pos select 0) isEqualType 0 && {(_pos select 1) isEqualType 0}) exitWith {false};
if ((_pos select 0) <= 0 && {(_pos select 1) <= 0}) exitWith {false};
if ((_pos select 0) > worldSize || {(_pos select 1) > worldSize} || {(_pos select 0) < 0} || {(_pos select 1) < 0}) exitWith {false};

if (isNil "GAIA_worldCenter") then {
	GAIA_worldCenter = getArray (configFile >> "CfgWorlds" >> worldName >> "centerPosition");
};
// findSafePos failure value: exactly the world center (2D)
if (count GAIA_worldCenter >= 2 && {(_pos distance2D GAIA_worldCenter) < 1}) exitWith {false};

true
