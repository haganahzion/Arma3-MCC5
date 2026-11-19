#define QRF_ROAD_TRIES 200
#define QRF_PLAYER_DIST 1000
//======================================================MCC_fnc_MWreinforcement=========================================================================================================
// Create a reinforcment type
// Example:[_reinforcement,_side, _missionCenterTriggerPos,_missionCenterTriggerArea,_cond] call MCC_fnc_MWreinforcement;
//
//	<IN>
//	_reinforcement: 			Integer, 1 - Aerial, 2 - Motorized, 3 - Mixed
// 	_side: 					side, reinforcment's side
// 	_missionCenterTriggerPos: 	Array, Center Position
//	_missionCenterTriggerArea	Trigger Area as in  [H, W, angle, rectangle (boolead)].
// 	_cond: 					Array of conditions when the number of units at the start are less in precentage then the number in condition a reinforcment will occur.
//
// 	<OUT>
//			Nothing
//========================================================================================================================================================================================
#define QRF_MIN_FREE_UNITS 4
#define QRF_TRIM_DELAY 8

private ["_reinforcement","_side","_missionCenterTriggerPos","_missionCenterTriggerArea","_cond","_trigger","_tlist","_zoneNumber","_script_handler","_found",
         "_faction","_warning","_ar","_totalEnemyUnits","_size","_strDir","_command","_para","_check"];

_reinforcement 				= _this select 0;
_side 						= _this select 1;
_missionCenterTriggerPos 	= _this select 2;
_missionCenterTriggerArea 	= _this select 3;
_cond					 	= _this select 4;
_zoneNumber					= _this select 5;
_faction					= _this select 6;
_warning					= param [7,true];
_totalEnemyUnits			= _this select 8;


if !(isServer || isDedicated) exitWith {};

if (isnil "mcc_mwunitsarraycar") then
{
	//Build the faction's unitsArrays and send it to the server.
	_check = [_faction, _side] call MCC_fnc_MWCreateUnitsArray;
	waituntil {_check};
};

if (typeName _side == "STRING") then
{
	_side = switch (_side) do
			{
				case "WEST":{west};
				case "EAST":{east};
				case "GUER":{resistance};
				case "CIV":{civilian};
				default {east};
			};
};

//Size: 0 - small, 1 - medium, 2 - large
_size = 0;
if (_totalEnemyUnits > 40) then {_size = 1};
if (_totalEnemyUnits > 60) then {_size = 2};

_trigger = createTrigger ["emptydetector",_missionCenterTriggerPos];
_trigger settriggerarea _missionCenterTriggerArea;
_trigger setTriggerActivation [str _side, "PRESENT", true];
sleep 5;

//Wait untill player is nearby to work with cache and delayed spawn
if (!isNil "GAIA_fnc_isNearPlayer") then {
	while {!([getposAtl _trigger,((missionNamespace getVariable ["GAIA_CACHE_STAGE_1",1000])/2)] call GAIA_fnc_isNearPlayer)} do {sleep 10};
};

_tlist = (_side countSide (list _trigger)) max 1;

private ["_dir","_distance","_newPos","_script_handler","_rfc"];

for "_i" from 0 to ((count _cond) - 1) step 1 do
{
	//Create Zone
	_found = false;

	_rfc = if (_reinforcement == 3) then {[1,2] call BIS_fnc_selectRandom} else {_reinforcement};
	if (_rfc == 2 && (count MCC_MWunitsArrayCar) <= 0) then {_rfc = 1};

	//A road away from the players; limited tries, then any dry spot away from the players
	private _tries = 0;
	private _players = allPlayers - (entities "HeadlessClient_F");
	while {!_found && {_tries < QRF_ROAD_TRIES}} do
	{
		_tries = _tries + 1;
		_dir = floor random 360;
		_distance = (floor (random 1000)) + (if (_rfc == 0) then {2000} else {1000});
		_newPos = [_missionCenterTriggerPos, _distance, _dir] call BIS_fnc_relPos;
		private _roads = _newPos nearRoads 200;
		if (_roads isNotEqualTo []) then
		{
			_newPos = getPosATL (_roads select 0);
			_found = (_players findIf {(_x distance _newPos) < QRF_PLAYER_DIST}) < 0;
		};
		if (_tries % 20 == 0) then {sleep 0.1};
	};
	if (!_found) then {
		_newPos = [_missionCenterTriggerPos, 1000, 2500, 5, 0, 0.5, 0] call BIS_fnc_findSafePos;
		if (count _newPos == 2) then {_newPos pushBack 0};
	};

	while {(1-(_side countSide (list _trigger))/_tlist) < (_cond select _i)} do {sleep 10};

	switch (_rfc) do
	{
		case 1: 	//Aerial
		{
			//Size
			switch (_size) do
			{
				case 0:
				{
					_para = [0,0,1,3,3,4,6,6,7] call BIS_fnc_selectRandom;
				};

				case 1:
				{
					_para = [1,1,2,4,4,5,7,7,8] call BIS_fnc_selectRandom;
				};

				case 2:
				{
					_para = [1,2,2,4,5,5,7,8,8] call BIS_fnc_selectRandom;
				};
			};

			if (_warning) then
			{
				//Lets give the player some hint about movment
				_dir 	= [_missionCenterTriggerPos, _newPos] call BIS_fnc_dirTo;
				_strDir = "<t size='1' t font = 'puristaLight' color='#FFFFFF'> HQ: Enemy aerial QRF is moving in from the " + ([_dir] call MCC_fnc_dirToString) + "</t>";
				[_strDir,0,0.2,5,1,0.0] remoteExec ["bis_fnc_dynamictext", 0];
			};
		};

		case 2: 	//Motorized
		{
			_para = _size + 9;
			if (_warning) then
			{
				//Lets give the player some hint about movment
				_dir 	= [_missionCenterTriggerPos, _newPos] call BIS_fnc_dirTo;
				_strDir = "<t size='1' t font = 'puristaLight' color='#FFFFFF'> HQ: Enemy motorized QRF is moving in from the " + ([_dir] call MCC_fnc_dirToString) + "</t>";
				[_strDir,0,0.2,5,1,0.0] remoteExec ["bis_fnc_dynamictext", 0];
			};

		};
	};

	//spawn
	_ar =	[ "Reinforcement"
				, _para
				, false
				, true
				, _para
				, _faction
				, _zoneNumber
				, "NOTHING"
				, str _zoneNumber
				, "MOVE"
				, _missionCenterTriggerPos
				, [_missionCenterTriggerArea select 0,_missionCenterTriggerArea select 1]
				, _missionCenterTriggerArea select 0
				, str _side
				, MCC_server
				, 0
				, false
				, false
				, mcc_missionmaker
				, "default"
				, 0
				, _newPos
				, 0 //(mcc_zonetype select 0 ) select 1
				, 0 //(mcc_zonetypenr select 0 ) select 1
				, 0
				, _newPos
				, false
				, false
				];

	//Max AI Units: no QRF when the side is at the cap, and units over the cap are removed after the spawn
	private _cap = missionNamespace getVariable ["MCC_MW_maxEnemyAI", 0];
	private _before = units _side select {alive _x};
	if (_cap > 0 && {(_cap - count _before) < QRF_MIN_FREE_UNITS}) exitWith {};
	_ar remoteExec ["MCC_fnc_setupSpawn", 2];
	if (_cap > 0) then {
		sleep QRF_TRIM_DELAY;
		private _new = (units _side select {alive _x}) - _before;
		private _excess = (count _before) + (count _new) - _cap;
		if (_excess > 0) then {
			_new = (_new select {isNull objectParent _x}) + (_new select {!isNull objectParent _x && {_x != driver objectParent _x}}) + (_new select {!isNull objectParent _x && {_x == driver objectParent _x}});
			{
				if (_forEachIndex < _excess) then {
					if (!isNull objectParent _x) then {moveOut _x};
					deleteVehicle _x;
				};
			} forEach _new;
		};
	};
};

//Clean up
deleteVehicle _trigger;
