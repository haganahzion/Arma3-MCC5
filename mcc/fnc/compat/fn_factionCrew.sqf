/*
	MCC_fnc_factionCrew
	Makes sure every crew member of a vehicle (or static weapon) belongs to the given faction. Crew of another faction
	(the vehicle's config "crew" can point to any faction) is deleted and the same seats are filled with this faction's
	own crewmen (pilots for aircraft), else its soldiers. When the faction has no men at all the crew is left as it is.
	Run where the vehicle's crew is local (server for AI spawned by MCC).
	Params:
		0: OBJECT - vehicle
		1: STRING - faction class (CfgFactionClasses)
	Returns: ARRAY - the crew of the vehicle afterwards
	Example: [_veh, "OPF_F"] call MCC_fnc_factionCrew;
*/
#define FC_CACHE_VAR "MCC_factionCrewCache"
#define FC_SKIP_TOKENS ["_vr_", "diver", "unarmed", "survivor", "story", "_ghillie_"]
#define FC_PILOT_TOKENS ["pilot"]
#define FC_CREW_TOKENS ["crew"]

params [["_veh", objNull, [objNull]], ["_faction", "", [""]]];

if (isNull _veh || {_faction == ""} || {_veh isKindOf "CAManBase"}) exitWith {[]};

private _isForeign = {(toLowerANSI faction _this) != (toLowerANSI _faction)};
private _foreign = (fullCrew [_veh, "", false]) select {(_x select 0) call _isForeign};
if (_foreign isEqualTo []) exitWith {crew _veh};

//Faction men by role, cached per faction: [pilots, crewmen, soldiers]
private _cache = missionNamespace getVariable FC_CACHE_VAR;
if (isNil "_cache") then {
	_cache = createHashMap;
	missionNamespace setVariable [FC_CACHE_VAR, _cache];
};
private _roles = _cache getOrDefault [toLowerANSI _faction, []];
if (_roles isEqualTo []) then {
	private _pilots = [];
	private _crewmen = [];
	private _soldiers = [];
	{
		private _class = configName _x;
		private _lower = toLowerANSI _class;
		if (_class isKindOf "CAManBase" && {(FC_SKIP_TOKENS findIf {_x in _lower}) < 0}) then {
			switch (true) do {
				case ((FC_PILOT_TOKENS findIf {_x in _lower}) > -1): {_pilots pushBack _class};
				case ((FC_CREW_TOKENS findIf {_x in _lower}) > -1): {_crewmen pushBack _class};
				default {_soldiers pushBack _class};
			};
		};
	} forEach (format ["getNumber (_x >> 'scope') == 2 && {getText (_x >> 'faction') == '%1'}", _faction] configClasses (configFile >> "CfgVehicles"));
	_roles = [_pilots, _crewmen, _soldiers];
	_cache set [toLowerANSI _faction, _roles];
};
_roles params ["_pilots", "_crewmen", "_soldiers"];

private _pool = switch (true) do {
	case (_veh isKindOf "Air" && {_pilots isNotEqualTo []}): {_pilots};
	case (_crewmen isNotEqualTo []): {_crewmen};
	case (_soldiers isNotEqualTo []): {_soldiers};
	default {_pilots};
};
if (_pool isEqualTo []) exitWith {
	diag_log format ["MCC: faction %1 has no men, %2 keeps its crew", _faction, typeOf _veh];
	crew _veh
};

private _group = group ((_foreign select 0) select 0);
private _side = side _group;
private _wasLeader = (_foreign findIf {((_x select 0) isEqualTo (leader _group))}) > -1;
{
	_x params ["_unit", "_role", "_cargoIndex", "_turretPath"];
	_veh deleteVehicleCrew _unit;
	if (isNull _group) then {_group = createGroup [_side, true]};
	private _new = _group createUnit [selectRandom _pool, getPosATL _veh, [], 0, "CAN_COLLIDE"];
	switch (toLowerANSI _role) do {
		case "driver": {_new moveInDriver _veh};
		case "cargo": {_new moveInCargo [_veh, _cargoIndex]};
		default {_new moveInTurret [_veh, _turretPath]};
	};
	if (vehicle _new isEqualTo _new) then {_new moveInAny _veh};
	if (vehicle _new isEqualTo _new) then {deleteVehicle _new};
} forEach _foreign;

if (_wasLeader && {!isNull _group}) then {
	private _cmd = effectiveCommander _veh;
	if (!isNull _cmd && {group _cmd isEqualTo _group}) then {_group selectLeader _cmd};
};

crew _veh
