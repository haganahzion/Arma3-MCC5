/*=================================================== MCC_fnc_edenWizardSpawnGroup ===================================================
	Editor-time Mission Wizard: places one AI group as Eden entities in the wizard layer and (optionally) puts it under
	GAIA control in a wizard zone. The source is a CfgGroups group (create3DENComposition), a list of unit classes, or a
	single vehicle class (created with its crew). Hard unit cap: never places more AI than MCC5MW_ctx "maxUnits" minus
	"units" (AI already placed) minus "reserve" (kept for objectives still to come). An infantry group is cut down to the
	units that still fit; a group with vehicles that does not fit is skipped. Crew of another faction than the enemy
	faction (vehicle config "crew") is swapped for the faction's own men at mission start (MCC_fnc_factionCrew).

	Params:
		0: CONFIG, ARRAY or STRING - CfgGroups group config / array of unit classes / vehicle class
		1: ARRAY   - position (ATL)
		2: HASHMAP - (optional) zone (MCC_fnc_edenWizardZone), empty = no GAIA
		3: STRING  - (optional) GAIA behaviour "MOVE", "NOFOLLOW", "FORTIFY" (default "MOVE")
		4: NUMBER  - (optional) direction (default random)
		5: STRING  - (optional) extra init code for the leader (default "")
	Returns: ARRAY - [GROUP, ARRAY of all created objects (units and vehicles)], [grpNull, []] when nothing was placed
	Example: private _res = [_cfg, _pos, _zone, "NOFOLLOW"] call MCC_fnc_edenWizardSpawnGroup;
*/
params [
	["_source", [], [configNull, [], ""]],
	["_pos", [0, 0, 0], [[]]],
	["_zone", createHashMap, [createHashMap]],
	["_intend", "MOVE", [""]],
	["_dir", -1, [0]],
	["_leaderInit", "", [""]]
];

#define SG_DEFAULT_MAX_UNITS 200
#define SG_CREW_FIX_INIT "if (isServer) then {[this, '%1'] spawn MCC_fnc_factionCrew};"

private _ctx = missionNamespace getVariable ["MCC5MW_ctx", createHashMap];
private _maxUnits = _ctx getOrDefault ["maxUnits", SG_DEFAULT_MAX_UNITS];
private _faction = (_ctx getOrDefault ["enemy", createHashMap]) getOrDefault ["faction", ""];
if (_dir < 0) then {_dir = random 360};

private _unitsBefore = _ctx getOrDefault ["units", 0];
private _left = _maxUnits - _unitsBefore - (_ctx getOrDefault ["reserve", 0]);
if (_left < 1) exitWith {
	_ctx set ["capped", true];
	[grpNull, []]
};

//Men a class brings: 1 for a soldier, the crew seats (no cargo) for a vehicle
private _fnc_size = {
	params ["_class"];
	if (_class isKindOf "CAManBase") exitWith {1};
	[_class, false] call BIS_fnc_crewCount
};

switch (true) do {
	case (_source isEqualType configNull): {
		private _classes = ("isClass _x" configClasses _source) apply {getText (_x >> "vehicle")};
		private _size = 0;
		{_size = _size + ([_x] call _fnc_size)} forEach _classes;
		if (_size > _left) then {
			//Infantry only: the same men, cut down to what fits
			_source = if ((_classes findIf {!(_x isKindOf "CAManBase")}) < 0) then {_classes select [0, _left]} else {""};
			_ctx set ["capped", true];
		};
	};
	case (_source isEqualType []): {
		if (count _source > _left) then {
			_source = _source select [0, _left];
			_ctx set ["capped", true];
		};
	};
	default {
		if (([_source] call _fnc_size) > _left) then {
			_source = "";
			_ctx set ["capped", true];
		};
	};
};
if (_source isEqualTo "" || {_source isEqualTo []}) exitWith {[grpNull, []]};

private _objects = [];
private _layer = _ctx getOrDefault ["curLayer", -1];

switch (true) do {
	//CfgGroups group: the editor places it like the asset browser does
	case (_source isEqualType configNull): {
		if (!isClass _source) exitWith {};
		private _entities = create3DENComposition [_source, _pos];
		if (isNil "_entities") then {_entities = []};
		_objects = _entities select {_x isEqualType objNull && {!isNull _x}};
		private _crew = [];
		{_crew append (crew _x)} forEach (_objects select {!(_x isKindOf "CAManBase")});
		{_objects pushBackUnique _x} forEach _crew;
		{
			if (_layer >= 0) then {_x set3DENLayer _layer};
			(_ctx getOrDefault ["entities", []]) pushBack _x;
		} forEach _objects;
	};

	//Unit classes: first unit makes the group, the others join it
	case (_source isEqualType []): {
		private _group = grpNull;
		{
			private _p = if (_forEachIndex == 0) then {_pos} else {_pos getPos [2 + (2 * _forEachIndex), _dir + 180 + (([-30, 30] select (_forEachIndex mod 2 == 0)))]};
			private _unit = ["Object", _x, _p, [], false, _group] call MCC_fnc_edenWizardCreate;
			if (!isNull _unit) then {
				_objects pushBack _unit;
				if (isNull _group) then {_group = group _unit};
			};
		} forEach _source;
	};

	//One vehicle with its crew
	default {
		private _veh = ["Object", _source, _pos, [["rotation", [0, 0, _dir]]]] call MCC_fnc_edenWizardCreate;
		if (!isNull _veh) then {
			_objects pushBack _veh;
			{_objects pushBackUnique _x} forEach (crew _veh);
		};
	};
};

//Remove what was placed (cap exceeded or nothing usable), keep the counters right
private _fnc_remove = {
	params ["_list"];
	if (_list isEqualTo []) exitWith {};
	_ctx set ["entities", (_ctx getOrDefault ["entities", []]) - _list];
	_objects = _objects - _list;
	delete3DENEntities _list;
};

//Count every man really placed; more than the estimate (config crew differs from the seats) is cut back
private _men = _objects select {_x isKindOf "CAManBase"};
if (count _men > _left) then {
	private _onFoot = _men select {isNull objectParent _x};
	reverse _onFoot;
	[_onFoot select [0, (count _men - _left) min (count _onFoot)]] call _fnc_remove;
	_men = _objects select {_x isKindOf "CAManBase"};
	if (count _men > _left) then {[+_objects] call _fnc_remove};
	_men = _objects select {_x isKindOf "CAManBase"};
	_ctx set ["capped", true];
};
_ctx set ["units", _unitsBefore + count _men];

if (_men isEqualTo []) exitWith {
	[+_objects] call _fnc_remove;
	[grpNull, []]
};

//Crew of another faction: the faction's own men take the seats at mission start
if (_faction != "") then {
	{
		private _veh = _x;
		if (((crew _veh) findIf {!(getText (configOf _x >> "faction") == _faction)}) > -1) then {
			private _init = (_veh get3DENAttribute "Init") param [0, ""];
			if !(_init isEqualType "") then {_init = ""};
			_veh set3DENAttribute ["Init", _init + format [SG_CREW_FIX_INIT, _faction]];
		};
	} forEach (_objects select {!(_x isKindOf "CAManBase")});
};

private _group = group (_men select 0);
if (_layer >= 0) then {_group set3DENLayer _layer};
_ctx set ["groups", (_ctx getOrDefault ["groups", 0]) + 1];

//Stealth: the enemy starts relaxed (GAIA switches them to combat on contact)
if (_ctx getOrDefault ["stealthInit", false]) then {
	_leaderInit = _leaderInit + "if (local this) then {(group this) setBehaviour 'SAFE'; (group this) setSpeedMode 'LIMITED'};";
};
if (_leaderInit != "") then {
	private _leader = leader _group;
	if (isNull _leader) then {_leader = _men select 0};
	_leader set3DENAttribute ["Init", _leaderInit];
};

if (count _zone > 0) then {
	[_group, _zone, _intend] call MCC_fnc_edenWizardAssign;
};

[_group, _objects]
