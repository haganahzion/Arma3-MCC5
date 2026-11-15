/*
	MCC_fnc_operationIntro  (clients, sent by MCC_fnc_operationIntroStart)
	Operation intro screen: letterbox, camera sweep over the operation area (or the player's own view), the operation
	name, place, time and weather, the enemy and the objectives, and a "weapons hold" countdown that ends with
	"weapons free". The player can't fire while it plays. When it ends the client sets MCC_opIntroDone on the player
	so the server can let every AI group fire again.
	Params:
		0: ARRAY - [prefix, name, location, enemy, objectives, center, music, cinematic]
			prefix     STRING  e.g. "OPERATION" or "BLACK OPS"
			name       STRING  operation name, e.g. "Silver Arrow"
			location   STRING  nearest place name ("" for none)
			enemy      STRING  enemy faction name
			objectives ARRAY of STRING
			center     ARRAY   position of the operation area ([] = the player's position)
			music      STRING  CfgMusic class, "" for none
			cinematic  BOOL    true: camera over the area, false: title card over the player's view
		1: SIDE   - only players of this side see it (sideUnknown = everyone)
		2: NUMBER - intro id from the server
	Returns: nothing
*/
#define LATE_JOIN_TIME 300
#define WATCHDOG_TIME 60
#define LAYER_NAME "MCC_opIntro"
#define FONT_MONO "EtelkaMonospacePro"
#define FONT_BOLD "PuristaBold"
#define FONT_MEDIUM "PuristaMedium"
#define FONT_LIGHT "PuristaLight"
#define COLOR_ACCENT [0.95, 0.62, 0.15, 1]
#define HEX_ACCENT "#F29E26"
#define HEX_TEXT "#ECEFE8"
#define HEX_DIM "#9AA39A"
#define COLOR_HOLD [0.75, 0.15, 0.1, 0.9]
#define COLOR_FREE [0.2, 0.6, 0.2, 0.9]
#define TYPE_DELAY 0.025
#define CAM_DIST_START 420
#define CAM_DIST_END 260
#define CAM_HEIGHT_START 170
#define CAM_HEIGHT_END 90
#define CAM_ORBIT_DEG 50
#define MAX_OBJECTIVE_LINES 5
#define COUNTDOWN_FROM 5

if (!hasInterface) exitWith {};
if (!canSuspend) exitWith {_this spawn MCC_fnc_operationIntro};

params [["_data", [], [[]]], ["_side", sideUnknown, [sideUnknown]], ["_id", 0, [0]]];
_data params [
	["_prefix", "OPERATION", [""]],
	["_name", "", [""]],
	["_location", "", [""]],
	["_enemy", "", [""]],
	["_objectives", [], [[]]],
	["_center", [], [[]]],
	["_music", "", [""]],
	["_cinematic", true, [true]]
];

waitUntil {sleep 0.2; !isNull player && {!isNull (findDisplay 46)} && {time > 1}};
if ((missionNamespace getVariable ["MCC_opIntroShown", 0]) == _id) exitWith {};
MCC_opIntroShown = _id;

private _fnc_done = {player setVariable ["MCC_opIntroDone", _id, true]};
if (_side != sideUnknown && {side group player != _side}) exitWith {call _fnc_done};
if (time > LATE_JOIN_TIME) exitWith {call _fnc_done};

if (_center isEqualTo []) then {_center = getPosATL player};
_center = [_center select 0, _center select 1, 0];

//------------------------------------------------------------ Cleanup (also run by the watchdog) ------------------------------------------------------------
MCC_opIntroState = createHashMapFromArray [["id", _id], ["finished", false], ["hud", shownHUD], ["music", musicVolume]];

MCC_fnc_operationIntroCleanup = {
	private _state = missionNamespace getVariable ["MCC_opIntroState", createHashMap];
	if (_state getOrDefault ["finished", true]) exitWith {};
	_state set ["finished", true];

	private _eh = _state getOrDefault ["firedEH", -1];
	private _unit = _state getOrDefault ["firedUnit", objNull];
	if (_eh > -1 && {!isNull _unit}) then {_unit removeEventHandler ["FiredMan", _eh]};

	private _cam = _state getOrDefault ["cam", objNull];
	if (!isNull _cam) then {
		_cam cameraEffect ["terminate", "back"];
		camDestroy _cam;
	};
	{ppEffectDestroy _x} forEach (_state getOrDefault ["pp", []]);
	(LAYER_NAME call BIS_fnc_rscLayer) cutText ["", "PLAIN"];
	showHUD (_state getOrDefault ["hud", true]);
	player setVariable ["MCC_opIntroDone", _state getOrDefault ["id", 0], true];
};

[] spawn {
	sleep WATCHDOG_TIME;
	call MCC_fnc_operationIntroCleanup;
};

//------------------------------------------------------------ Hold fire for the player ------------------------------------------------------------
MCC_opIntroState set ["firedUnit", player];
MCC_opIntroState set ["firedEH", player addEventHandler ["FiredMan", {
	params ["", "", "", "", "", "", "_projectile"];
	deleteVehicle _projectile;
}]];

//------------------------------------------------------------ Text ------------------------------------------------------------
private _fnc_esc = {
	params ["_s"];
	_s = (_s splitString "&") joinString "&amp;";
	_s = (_s splitString "<") joinString "&lt;";
	(_s splitString ">") joinString "&gt;"
};
private _fnc_spaced = {
	params ["_s"];
	(toUpperANSI _s splitString "") joinString " "
};

date params ["_year", "_month", "_day"];
private _months = ["JAN", "FEB", "MAR", "APR", "MAY", "JUN", "JUL", "AUG", "SEP", "OCT", "NOV", "DEC"];
private _dateText = format ["%1 %2 %3", _day, _months select ((_month - 1) max 0 min 11), _year];
private _timeText = [daytime, "HH:MM"] call BIS_fnc_timeToString;
private _weather = switch (true) do {
	case (rain > 0.3): {"Rain"};
	case (overcast > 0.7): {"Overcast"};
	case (overcast > 0.35): {"Cloudy"};
	default {"Clear"};
};
if (fog > 0.3) then {_weather = _weather + ", fog"};
private _grid = mapGridPosition _center;
private _place = [_location, getText (configFile >> "CfgWorlds" >> worldName >> "description")] select (_location == "");
if (_place == "") then {_place = worldName};

private _lines = [];
if (_enemy != "") then {_lines pushBack ["ENEMY", _enemy]};
_lines pushBack ["TIME", format ["%1  %2", _timeText, _weather]];
_lines pushBack ["GRID", _grid];
{
	if (_forEachIndex < MAX_OBJECTIVE_LINES) then {
		_lines pushBack [["OBJECTIVES", ""] select (_forEachIndex > 0), format ["%1%2  %3", ["0", ""] select (_forEachIndex >= 9), _forEachIndex + 1, _x]];
	};
} forEach _objectives;

//------------------------------------------------------------ Screen ------------------------------------------------------------
private _layer = LAYER_NAME call BIS_fnc_rscLayer;
_layer cutRsc ["MCC_RscOperationIntro", "PLAIN", 0, false];
private _waitUntil = diag_tickTime + 5;
waitUntil {!isNull (uiNamespace getVariable ["MCC_RscOperationIntro", displayNull]) || {diag_tickTime > _waitUntil}};
private _d = uiNamespace getVariable ["MCC_RscOperationIntro", displayNull];
if (isNull _d) exitWith {call MCC_fnc_operationIntroCleanup};

private _sx = safezoneX;
private _sy = safezoneY;
private _sw = safezoneW;
private _sh = safezoneH;
private _barH = 0.12 * _sh;

private _fnc_ctrl = {
	params ["_class", "_pos", ["_fade", 1]];
	private _c = _d ctrlCreate [_class, -1];
	_c ctrlSetPosition _pos;
	_c ctrlSetFade _fade;
	_c ctrlCommit 0;
	_c
};
private _fnc_type = {
	params ["_ctrl", "_fmt", "_text"];
	private _n = count _text;
	for "_i" from 1 to _n do {
		_ctrl ctrlSetStructuredText parseText format [_fmt, [_text select [0, _i]] call _fnc_esc, ["_", ""] select (_i == _n)];
		sleep TYPE_DELAY;
	};
};

// Look
private _pp = [];
private _cc = -1;
private _prio = 1501;
while {_cc = ppEffectCreate ["ColorCorrections", _prio]; _cc < 0} do {_prio = _prio + 1};
_cc ppEffectEnable true;
_cc ppEffectAdjust [1, 1.08, -0.01, [0.1, 0.12, 0.1, 0.08], [1, 0.95, 0.85, 0.75], [0.299, 0.587, 0.114, 0]];
_cc ppEffectCommit 0;
_pp pushBack _cc;
private _grain = -1;
_prio = 2001;
while {_grain = ppEffectCreate ["FilmGrain", _prio]; _grain < 0} do {_prio = _prio + 1};
_grain ppEffectEnable true;
_grain ppEffectAdjust [0.06, 1, 1, 0.1, 1, false];
_grain ppEffectCommit 0;
_pp pushBack _grain;
MCC_opIntroState set ["pp", _pp];

showHUD false;
cutText ["", "BLACK FADED", 999];

if (_cinematic) then {
	private _dir = random 360;
	private _p1 = _center getPos [CAM_DIST_START, _dir];
	_p1 set [2, CAM_HEIGHT_START];
	private _p2 = _center getPos [CAM_DIST_END, _dir + CAM_ORBIT_DEG];
	_p2 set [2, CAM_HEIGHT_END];
	private _cam = "camera" camCreate _p1;
	MCC_opIntroState set ["cam", _cam];
	_cam cameraEffect ["internal", "back"];
	showCinemaBorder false;
	cameraEffectEnableHUD false;
	camUseNVG (sunOrMoon < 0.3);
	_cam camSetTarget _center;
	_cam camSetFov 0.75;
	_cam camCommit 0;
	_cam camSetPos _p2;
	_cam camSetFov 0.5;
	_cam camCommit 26;
};

if (_music != "") then {playMusic _music};
cutText ["", "BLACK IN", 2.5];

// Letterbox
private _top = ["RscText", [_sx, _sy - _barH, _sw, _barH], 0] call _fnc_ctrl;
_top ctrlSetBackgroundColor [0, 0, 0, 1];
private _bottom = ["RscText", [_sx, _sy + _sh, _sw, _barH], 0] call _fnc_ctrl;
_bottom ctrlSetBackgroundColor [0, 0, 0, 1];
_top ctrlSetPosition [_sx, _sy, _sw, _barH];
_bottom ctrlSetPosition [_sx, _sy + _sh - _barH, _sw, _barH];
_top ctrlCommit 1.2;
_bottom ctrlCommit 1.2;
sleep 1.2;

// Header line in the top bar
private _header = ["RscStructuredText", [_sx + 0.04 * _sw, _sy + 0.045 * _sh, 0.5 * _sw, 0.05 * _sh], 0] call _fnc_ctrl;
private _headerR = ["RscStructuredText", [_sx + 0.46 * _sw, _sy + 0.045 * _sh, 0.5 * _sw, 0.05 * _sh], 1] call _fnc_ctrl;
_headerR ctrlSetStructuredText parseText format ["<t align='right' font='%1' size='0.8' color='%2'>%3   /   %4   /   GRID %5</t>", FONT_MONO, HEX_DIM, _dateText, _timeText, _grid];
_headerR ctrlSetFade 0;
_headerR ctrlCommit 1.5;
[_header, format ["<t font='%1' size='0.8' color='%2'>%3</t>", FONT_MONO, HEX_DIM, "%1%2"], "MCC 5   /   OPERATION ORDER"] call _fnc_type;

// Title block
private _bx = _sx + 0.09 * _sw;
private _by = _sy + 0.33 * _sh;
private _stripe = ["RscText", [_bx - 0.012 * _sw, _by, 0.0025 * _sw, 0], 0] call _fnc_ctrl;
_stripe ctrlSetBackgroundColor COLOR_ACCENT;
_stripe ctrlSetPosition [_bx - 0.012 * _sw, _by, 0.0025 * _sw, 0.235 * _sh];
_stripe ctrlCommit 0.8;

private _label = ["RscStructuredText", [_bx, _by, 0.7 * _sw, 0.05 * _sh]] call _fnc_ctrl;
_label ctrlSetStructuredText parseText format ["<t font='%1' size='1.1' color='%2'>%3</t>", FONT_MEDIUM, HEX_ACCENT, [_prefix] call _fnc_spaced];
_label ctrlSetFade 0;
_label ctrlCommit 0.8;
sleep 0.6;

private _title = ["RscStructuredText", [_bx + 0.04 * _sw, _by + 0.035 * _sh, 0.85 * _sw, 0.13 * _sh]] call _fnc_ctrl;
_title ctrlSetStructuredText parseText format ["<t font='%1' size='3.4' color='%2' shadow='2'>%3</t>", FONT_BOLD, HEX_TEXT, [toUpperANSI _name] call _fnc_esc];
_title ctrlSetPosition [_bx, _by + 0.035 * _sh, 0.85 * _sw, 0.13 * _sh];
_title ctrlSetFade 0;
_title ctrlCommit 1.4;
sleep 1.2;

private _rule = ["RscText", [_bx, _by + 0.165 * _sh, 0, 0.004 * _sh], 0] call _fnc_ctrl;
_rule ctrlSetBackgroundColor COLOR_ACCENT;
_rule ctrlSetPosition [_bx, _by + 0.165 * _sh, 0.34 * _sw, 0.004 * _sh];
_rule ctrlCommit 1;

private _sub = ["RscStructuredText", [_bx, _by + 0.178 * _sh, 0.7 * _sw, 0.05 * _sh]] call _fnc_ctrl;
_sub ctrlSetStructuredText parseText format ["<t font='%1' size='1.25' color='%2'>%3</t>", FONT_LIGHT, HEX_DIM, [format ["%1   /   %2", toUpperANSI _place, toUpperANSI worldName]] call _fnc_esc];
_sub ctrlSetFade 0;
_sub ctrlCommit 1.2;
sleep 1.5;

// Order panel
private _rowH = 0.032 * _sh;
private _panelH = _rowH * (count _lines) + 0.03 * _sh;
private _px = _bx;
private _py = _sy + _sh - _barH - _panelH - 0.04 * _sh;
private _panel = ["RscText", [_px - 0.012 * _sw, _py, 0.4 * _sw, _panelH]] call _fnc_ctrl;
_panel ctrlSetBackgroundColor [0, 0, 0, 0.55];
_panel ctrlSetFade 0;
_panel ctrlCommit 0.6;
sleep 0.6;
{
	_x params ["_key", "_value"];
	private _row = ["RscStructuredText", [_px, _py + 0.015 * _sh + _rowH * _forEachIndex, 0.38 * _sw, _rowH], 0] call _fnc_ctrl;
	private _keyText = format ["<t font='%1' size='0.85' color='%2'>%3</t>", FONT_MONO, HEX_ACCENT, (_key + "            ") select [0, 12]];
	[_row, _keyText + format ["<t font='%1' size='0.85' color='%2'>%3</t>", FONT_MONO, HEX_TEXT, "%1%2"], _value] call _fnc_type;
	sleep 0.15;
} forEach _lines;

// Weapons hold, then weapons free
private _pillW = 0.2 * _sw;
private _pill = ["RscStructuredText", [_sx + _sw - _pillW - 0.04 * _sw, _sy + _sh - 0.08 * _sh, _pillW, 0.045 * _sh]] call _fnc_ctrl;
_pill ctrlSetBackgroundColor COLOR_HOLD;
_pill ctrlSetFade 0;
_pill ctrlCommit 0.4;
private _hint = ["RscStructuredText", [_sx + 0.04 * _sw, _sy + _sh - 0.075 * _sh, 0.5 * _sw, 0.04 * _sh]] call _fnc_ctrl;
_hint ctrlSetStructuredText parseText format ["<t font='%1' size='0.8' color='%2'>ALL UNITS HOLD FIRE UNTIL THE ORDER ENDS</t>", FONT_MONO, HEX_DIM];
_hint ctrlSetFade 0;
_hint ctrlCommit 0.6;
sleep 1.5;

for "_i" from COUNTDOWN_FROM to 1 step -1 do {
	_pill ctrlSetStructuredText parseText format ["<t align='center' font='%1' size='1' color='%2'>WEAPONS HOLD   %3</t>", FONT_BOLD, HEX_TEXT, _i];
	playSound "FD_Timer_F";
	sleep 1;
};
_pill ctrlSetBackgroundColor COLOR_FREE;
_pill ctrlSetStructuredText parseText format ["<t align='center' font='%1' size='1' color='%2'>WEAPONS FREE</t>", FONT_BOLD, HEX_TEXT];
_hint ctrlSetStructuredText parseText format ["<t font='%1' size='0.8' color='%2'>GOOD LUCK</t>", FONT_MONO, HEX_DIM];
playSound "FD_Start_F";
if (_music != "") then {6 fadeMusic 0};
sleep 1.5;

// Out
if (_cinematic) then {
	cutText ["", "BLACK OUT", 1];
	sleep 1;
};
{
	_x ctrlSetFade 1;
	_x ctrlCommit 0.8;
} forEach ((allControls _d) - [_top, _bottom]);
_top ctrlSetPosition [_sx, _sy - _barH, _sw, _barH];
_bottom ctrlSetPosition [_sx, _sy + _sh, _sw, _barH];
_top ctrlCommit 1;
_bottom ctrlCommit 1;
sleep 1;

call MCC_fnc_operationIntroCleanup;
if (_cinematic) then {cutText ["", "BLACK IN", 1.5]};

if (_music != "") then {
	[MCC_opIntroState getOrDefault ["music", 0.5]] spawn {
		params ["_volume"];
		sleep 5;
		playMusic "";
		0 fadeMusic _volume;
	};
};
