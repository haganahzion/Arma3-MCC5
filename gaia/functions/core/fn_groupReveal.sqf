/* ----------------------------------------------------------------------------
Function: GAIA_fnc_groupReveal

Description:
	Reveals targets to a group. reveal only works where the group is local, so on
	the server a headless client group gets it sent to its owner.
	Only the server may remote execute it.

Parameters:
	0: GROUP
	1: ARRAY of OBJECT - targets

Returns:
	nothing

Example:
	[_group, [_tank, _soldier]] call GAIA_fnc_groupReveal;
---------------------------------------------------------------------------- */
#include "..\gaiaDefines.hpp"

params [["_group", grpNull, [grpNull]], ["_targets", [], [[]]]];

if (isRemoteExecuted && {remoteExecutedOwner != GAIA_SERVER_OWNER}) exitWith {};
if (isNull _group || {_targets isEqualTo []}) exitWith {};

if (!local _group) exitWith {
	if (isServer && {!isRemoteExecuted}) then {
		[_group, _targets] remoteExecCall ["GAIA_fnc_groupReveal", groupOwner _group];
	};
};

{
	if (_x isEqualType objNull && {!isNull _x}) then {_group reveal [_x, GAIA_AIR_REVEAL_LEVEL]};
} forEach _targets;
