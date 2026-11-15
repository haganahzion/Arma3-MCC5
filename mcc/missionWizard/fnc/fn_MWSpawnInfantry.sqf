//======================================================MCC_fnc_MWSpawnInfantry==================================================================================================
// Spawn infantry groups in the zone.
// Example:[_totalEnemyUnits,_zoneNumber] call MCC_fnc_MWSpawnInfantry;
// Return - handler
//===============================================================================================================================================================================
#define INF_FALLBACK_GROUPS 6
#define INF_FALLBACK_MIN_SIZE 4
#define INF_FALLBACK_MAX_SIZE 8

private ["_menArraySpecial","_unitPlaced","_totalEnemyUnits","_script_handler","_spawnbehavior","_group","_unitsArray","_side"];
_totalEnemyUnits	= _this select 0;
_zoneNumber			= _this select 1;
_spawnbehavior		= _this select 2;
_side				= _this select 3;

_menArraySpecial = [];
if ((count MCC_MWGroupArrayMenRecon)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenRecon};
if ((count MCC_MWGroupArrayMenSniper)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenSniper};
if ((count MCC_MWGroupArrayMenSupport)>0) then {_menArraySpecial = _menArraySpecial + MCC_MWGroupArrayMenSupport};

_unitPlaced = 0;
if (isnil "MCC_customGroupsSaveMW") then {MCC_customGroupsSaveMW = []};

_unitsArray = MCC_MWGroupArrayMen + MCC_customGroupsSaveMW;

//The faction has no infantry groups in CfgGroups: build groups from its own soldiers
if (_unitsArray isEqualTo [] && {(missionNamespace getVariable ["MCC_MWunitsArrayMen", []]) isNotEqualTo []}) then {
	private _men = MCC_MWunitsArrayMen apply {_x select 1};
	for "_g" from 1 to INF_FALLBACK_GROUPS do {
		private _size = INF_FALLBACK_MIN_SIZE + floor random (INF_FALLBACK_MAX_SIZE - INF_FALLBACK_MIN_SIZE + 1);
		private _classes = [];
		for "_i" from 1 to _size do {_classes pushBack selectRandom _men};
		_unitsArray pushBack ["Infantry", _size, _classes];
	};
};

if (count _unitsArray > 0) then
{
	//Infantry
	//Units are counted when they really spawn (MCC_fnc_MWbudget trims in mcc_setup), here only the queue is limited
	private _requested = 0;
	while {_unitPlaced < _totalEnemyUnits && {_requested < (["left", ["gen"]] call MCC_fnc_MWbudget)}} do
	{
		//Regular or SF
		if (random 1 < 0.2 && ((count _menArraySpecial)>0)) then
		{
			_group = _menArraySpecial call BIS_fnc_selectRandom;
		}
		else
		{
			_group = _unitsArray call BIS_fnc_selectRandom;
		};

		//count units
		_unitPlaced = _unitPlaced + (_group select 1);
		_requested = _requested + (_group select 1);

		//Spawn them
		[_zoneNumber,"GROUP","LAND",true,_group select 0,_group select 2,_spawnbehavior,_group select 0,_side] call MCC_fnc_MWSpawnInZone;
	};
}
else
{
	diag_log "MCC: Mission Wizard Error: No group available in the selected enemy faction";
};

_unitPlaced;





