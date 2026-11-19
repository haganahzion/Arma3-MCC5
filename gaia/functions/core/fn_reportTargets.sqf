/* ----------------------------------------------------------------------------
Function: GAIA_fnc_reportTargets

Description:
	Headless client: AI target knowledge only exists where the AI are local, so
	the server can not read nearTargets of a headless client group. Every
	GAIA_HC_TARGET_INTERVAL seconds this sends the enemy targets the leader
	knows well (nearTargets entries) to the server as the group variable
	GAIA_HC_TARGETS_VAR. GAIA_fnc_analyzeTargets reads and clears it.
	Called by GAIA_fnc_perFrame for local GAIA groups on a headless client.

Parameters:
	0: GROUP

Returns:
	nothing
---------------------------------------------------------------------------- */
#include "..\gaiaDefines.hpp"
params [["_group", grpNull, [grpNull]]];

if (isServer || {isNull _group} || {!local _group}) exitWith {};
private _leader = leader _group;
if (!alive _leader) exitWith {};
if (time < (_group getVariable ["GAIA_HC_TARGETS_NEXT", 0])) exitWith {};
_group setVariable ["GAIA_HC_TARGETS_NEXT", time + GAIA_HC_TARGET_INTERVAL];

private _side = side _group;
private _range = missionNamespace getVariable ["MCC_GAIA_TARGET_RANGE", 1000];
private _report = (_leader nearTargets _range) select {
	((_x select 5) < GAIA_TARGET_MAX_ACCURACY) && {((_x select 2) getFriend _side) < GAIA_ENEMY_FRIENDSHIP}
};

//Nothing new to say
if (_report isEqualTo [] && {!(_group getVariable ["GAIA_HC_TARGETS_SENT", false])}) exitWith {};
_group setVariable ["GAIA_HC_TARGETS_SENT", _report isNotEqualTo []];
_group setVariable [GAIA_HC_TARGETS_VAR, _report, GAIA_SERVER_OWNER];
