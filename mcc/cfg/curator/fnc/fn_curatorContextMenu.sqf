/*
	MCC_fnc_curatorContextMenu  (postInit, clients)
	Zeus right-click menu for AI units and groups: GAIA: Control Group, GAIA: Attack Area, GAIA: Defend Area and
	Player Control Group (GAIA lets go of the group).
	With ZEN loaded the entries go into the ZEN context menu (under "MCC 5"). Without ZEN, a right-click (click, not
	drag) on an AI unit opens a small MCC menu. It opens when nothing is selected, or when the clicked unit's group is
	part of the selection; right-clicking another unit with a group selected still places waypoints as usual.
	Params: none
	Returns: nothing
*/
if (!hasInterface) exitWith {};

#define IDD_CURATOR 312
#define IDC_CURATOR_MAINMAP 50
#define IDC_CURATOR_MOUSEAREA 53
#define IDC_MCC_CTX_GROUP 31260
#define CLICK_MAX_TIME 0.35
#define CLICK_MAX_MOVE 0.01

MCC_curatorCtxEntries = [
	["GAIA: Control Group", "GAIA takes the group and works through your side's tasks, then patrols", 0],
	["GAIA: Attack Area", "GAIA attacks and patrols the nearest zone with the group", 1],
	["GAIA: Defend Area", "GAIA holds the nearest zone with the group", 2],
	["Player Control Group", "GAIA lets go of the group, so you or the players control it again", 3]
];

// AI groups from a hovered entity plus the selection. Returns ARRAY of GROUP.
MCC_fnc_curatorCtxGroups = {
	params [["_hovered", objNull], ["_objects", []], ["_groups", []]];
	private _out = [];
	if (_hovered isEqualType grpNull && {!isNull _hovered}) then {_out pushBack _hovered};
	if (_hovered isEqualType objNull && {!isNull _hovered} && {!isNull group _hovered} && {side group _hovered != sideLogic}) then {
		_out pushBack (group _hovered);
	};
	{
		if (_x isEqualType grpNull && {!isNull _x}) then {_out pushBackUnique _x};
	} forEach _groups;
	{
		if (_x isEqualType objNull && {!isNull group _x} && {side group _x != sideLogic} && {_x isKindOf "CAManBase" || {crew _x isNotEqualTo []}}) then {
			_out pushBackUnique (group _x);
		};
	} forEach _objects;
	_out select {!isPlayer leader _x && {side _x != sideLogic} && {({alive _x} count units _x) > 0}}
};

//------------------------------------------------------------ ZEN ------------------------------------------------------------
if (isClass (configFile >> "CfgPatches" >> "zen_context_menu")) exitWith {
	private _parent = [
		"MCC5_GroupControl", "MCC 5", "\A3\ui_f\data\igui\cfg\simpleTasks\types\attack_ca.paa", {},
		{([_hoveredEntity, _objects, _groups] call MCC_fnc_curatorCtxGroups) isNotEqualTo []}
	] call zen_context_menu_fnc_createAction;
	[_parent, [], 0] call zen_context_menu_fnc_addAction;

	{
		_x params ["_name", "", "_mode"];
		private _action = [
			format ["MCC5_GroupControl_%1", _mode], _name, "",
			{[[_hoveredEntity, _objects, _groups] call MCC_fnc_curatorCtxGroups, _args] call MCC_fnc_curatorGroupControl},
			{true}, _mode
		] call zen_context_menu_fnc_createAction;
		[_action, ["MCC5_GroupControl"], 10 - _mode] call zen_context_menu_fnc_addAction;
	} forEach MCC_curatorCtxEntries;
};

//------------------------------------------------------------ Without ZEN ------------------------------------------------------------
MCC_fnc_curatorCtxClose = {
	private _display = findDisplay IDD_CURATOR;
	if (isNull _display) exitWith {};
	private _ctrl = _display displayCtrl IDC_MCC_CTX_GROUP;
	if (!isNull _ctrl) then {ctrlDelete _ctrl};
};

MCC_fnc_curatorCtxOpen = {
	params ["_display", "_groups", "_mousePos"];
	[] call MCC_fnc_curatorCtxClose;
	uiNamespace setVariable ["MCC_curatorCtxGroups", _groups];

	private _w = 0.13 * safezoneW;
	private _rowH = 0.028 * safezoneH;
	private _rows = count MCC_curatorCtxEntries;
	private _h = _rowH * (_rows + 1) + 0.004 * safezoneH;
	_mousePos params ["_mx", "_my"];
	private _x0 = (_mx + 0.005) min (safezoneX + safezoneW - _w);
	private _y0 = _my min (safezoneY + safezoneH - _h);

	private _grp = _display ctrlCreate ["RscControlsGroupNoScrollbars", IDC_MCC_CTX_GROUP];
	_grp ctrlSetPosition [_x0, _y0, _w, _h];
	_grp ctrlCommit 0;

	private _bg = _display ctrlCreate ["RscText", -1, _grp];
	_bg ctrlSetPosition [0, 0, _w, _h];
	_bg ctrlSetBackgroundColor [0.05, 0.05, 0.05, 0.92];
	_bg ctrlCommit 0;

	private _first = _groups select 0;
	private _gaia = !isNil {_first getVariable "GAIA_ZONE_INTEND"} || {_first getVariable ["GAIA_followTasks", false]};
	private _title = if (count _groups > 1) then {format ["%1 groups", count _groups]} else {groupId _first};
	private _header = _display ctrlCreate ["RscText", -1, _grp];
	_header ctrlSetPosition [0, 0, _w, _rowH];
	_header ctrlSetBackgroundColor [0.85, 0.55, 0.1, 0.95];
	_header ctrlSetTextColor [0.05, 0.05, 0.05, 1];
	_header ctrlSetText format ["%1  |  %2", _title, ["Player control", "GAIA control"] select _gaia];
	_header ctrlCommit 0;

	{
		_x params ["_name", "_tip", "_mode"];
		private _btn = _display ctrlCreate ["RscButton", -1, _grp];
		_btn ctrlSetPosition [0.002 * safezoneW, _rowH * (_forEachIndex + 1) + 0.002 * safezoneH, _w - 0.004 * safezoneW, _rowH - 0.002 * safezoneH];
		_btn ctrlSetText _name;
		_btn ctrlSetTooltip _tip;
		_btn ctrlSetBackgroundColor [0.15, 0.15, 0.15, 0.95];
		_btn setVariable ["MCC_mode", _mode];
		_btn ctrlAddEventHandler ["ButtonClick", {
			params ["_btn"];
			private _mode = _btn getVariable ["MCC_mode", 0];
			private _groups = uiNamespace getVariable ["MCC_curatorCtxGroups", []];
			[] spawn MCC_fnc_curatorCtxClose;
			[_groups, _mode] call MCC_fnc_curatorGroupControl;
		}];
		_btn ctrlCommit 0;
	} forEach MCC_curatorCtxEntries;
};

MCC_fnc_curatorCtxInit = {
	params ["_display"];
	{
		private _ctrl = _display displayCtrl _x;
		if (!isNull _ctrl) then {
			_ctrl ctrlAddEventHandler ["MouseButtonDown", {
				params ["", "_button", "_mx", "_my"];
				if (_button == 1) then {
					uiNamespace setVariable ["MCC_curatorCtxDown", [diag_tickTime, [_mx, _my], curatorMouseOver]];
				} else {
					[] call MCC_fnc_curatorCtxClose;
				};
			}];
			_ctrl ctrlAddEventHandler ["MouseButtonUp", {
				params ["_ctrl", "_button", "_mx", "_my"];
				if (_button != 1) exitWith {};
				(uiNamespace getVariable ["MCC_curatorCtxDown", [0, [0, 0], []]]) params ["_t", "_pos", "_over"];
				uiNamespace setVariable ["MCC_curatorCtxDown", nil];
				[] call MCC_fnc_curatorCtxClose;
				if ((diag_tickTime - _t) > CLICK_MAX_TIME || {(abs ((_pos select 0) - _mx)) > CLICK_MAX_MOVE} || {(abs ((_pos select 1) - _my)) > CLICK_MAX_MOVE}) exitWith {};
				if (count _over < 2) exitWith {};

				private _hovered = _over select 1;
				private _hoverGroups = [_hovered] call MCC_fnc_curatorCtxGroups;
				if (_hoverGroups isEqualTo []) exitWith {};

				curatorSelected params [["_selObjects", []], ["_selGroups", []], ["_selWaypoints", []], ["_selMarkers", []]];
				private _selection = [objNull, _selObjects, _selGroups] call MCC_fnc_curatorCtxGroups;
				private _nothingSelected = _selection isEqualTo [] && {_selWaypoints isEqualTo []};
				if (!_nothingSelected && {!((_hoverGroups select 0) in _selection)}) exitWith {};

				// Stop Zeus from giving the selected group a waypoint on itself, then restore the selection
				if (!_nothingSelected) then {
					private _restore = _selObjects + _selGroups + _selWaypoints + _selMarkers;
					setCuratorSelected [];
					[{setCuratorSelected _this}, _restore] call CBA_fnc_execNextFrame;
				};

				private _groups = _hoverGroups;
				{_groups pushBackUnique _x} forEach _selection;
				[ctrlParent _ctrl, _groups, [_mx, _my]] call MCC_fnc_curatorCtxOpen;
			}];
		};
	} forEach [IDC_CURATOR_MAINMAP, IDC_CURATOR_MOUSEAREA];

	_display displayAddEventHandler ["KeyDown", {
		params ["_display", "_key"];
		if (_key == 1 && {!isNull (_display displayCtrl IDC_MCC_CTX_GROUP)}) exitWith {
			[] call MCC_fnc_curatorCtxClose;
			true
		};
		false
	}];
};

[] spawn {
	while {true} do {
		waitUntil {sleep 0.5; !isNull (findDisplay IDD_CURATOR)};
		private _display = findDisplay IDD_CURATOR;
		if (isNil {_display getVariable "MCC_curatorCtxInit"}) then {
			_display setVariable ["MCC_curatorCtxInit", true];
			[_display] call MCC_fnc_curatorCtxInit;
		};
		waitUntil {sleep 0.5; isNull (findDisplay IDD_CURATOR)};
	};
};
