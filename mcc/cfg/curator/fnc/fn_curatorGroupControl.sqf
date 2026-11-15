/*
	MCC_fnc_curatorGroupControl  (client, Zeus)
	Gives AI groups to GAIA or hands them back to Zeus / the players. Used by the Zeus right-click menu.
	Params:
		0: ARRAY of GROUP
		1: NUMBER - 0 GAIA follows the tasks, 1 GAIA attacks/patrols the nearest zone, 2 GAIA defends the nearest zone,
		            3 player control (GAIA lets go of the group)
	Returns: nothing
*/
params [["_groups", [], [[]]], ["_mode", 0, [0]]];

_groups = _groups select {
	_x isEqualType grpNull && {!isNull _x} && {!isPlayer leader _x} && {({alive _x} count units _x) > 0}
};
if (_groups isEqualTo []) exitWith {
	[objNull, "No AI group here. Groups led by a player can't be given to GAIA."] call BIS_fnc_showCuratorFeedbackMessage;
};

[_groups, _mode, true] remoteExec ["MCC_fnc_gaiaControlGroups", 2];

private _text = [
	"GAIA now controls %1 group(s): they work through the tasks, then patrol",
	"GAIA now controls %1 group(s): attack and patrol the nearest zone",
	"GAIA now controls %1 group(s): defend the nearest zone",
	"%1 group(s) back under player control"
] select (_mode max 0 min 3);
[objNull, format [_text, count _groups]] call BIS_fnc_showCuratorFeedbackMessage;
