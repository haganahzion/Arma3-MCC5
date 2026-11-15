/*
	GAIA_fnc_marchAI
	Turns march mode on or off for a group, on the machine where its AI are local (server or headless client;
	call it with remoteExecCall to groupOwner from anywhere else).
	On:  AI don't switch to COMBAT by themselves (AUTOCOMBAT off), so they keep moving and return fire instead of
	     going prone and hunting every contact. Combat mode GAIA_MARCH_COMBAT_MODE keeps them in formation.
	     LAMBS Danger group behaviour (hunting, flanking, building clearing) is paused.
	Off: AUTOCOMBAT and LAMBS group behaviour come back. GAIA's next orders set the combat mode again.
	Sets GAIA_marchAI (BOOL, local).
	Params:
		0: GROUP
		1: BOOL - true march mode on, false off
	Returns: nothing
*/
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]], ["_on", false, [false]]];
if (isNull _group) exitWith {};

{
	if (local _x && {!isPlayer _x}) then {
		if (_on) then {_x disableAI "AUTOCOMBAT"} else {_x enableAI "AUTOCOMBAT"};
	};
} forEach (units _group);

if (local _group) then {
	if (_on) then {
		_group setCombatMode GAIA_MARCH_COMBAT_MODE;
		if (behaviour (leader _group) == "COMBAT") then {_group setBehaviour GAIA_MARCH_BEHAVIOUR};
	};
	if (_on) then {
		_group setVariable ["lambs_danger_disableGroupAI", true, true];
	} else {
		_group setVariable ["lambs_danger_disableGroupAI", nil, true];
	};
};

_group setVariable ["GAIA_marchAI", _on];
