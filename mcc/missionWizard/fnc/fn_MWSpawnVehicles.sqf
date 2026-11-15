//======================================================MCC_fnc_MWSpawnVehicles==================================================================================================
// Spawn infantry groups in the zone.
// Example:[_totalEnemyUnits,_zoneNumber,_arrayGroup,_arrayUnits,_priceGroup,_priceUnit] call MCC_fnc_MWSpawnVehicles;
// Return - handler
//=====================================================================================================================================================================
#define VEH_EST_CREW_PER_UNIT 3

private ["_menArraySpecial","_simType","_unitPlaced","_totalEnemyUnits","_script_handler","_spawnbehavior","_arrayGroup","_arrayUnits","_group","_priceGroup","_priceUnit","_price","_side"];
_totalEnemyUnits	= _this select 0;
_zoneNumber			= _this select 1;
_arrayGroup			= _this select 2;
_arrayUnits			= _this select 3;
_priceGroup			= _this select 4;
_priceUnit			= _this select 5;
_simType			= _this select 6;
_side				= _this select 7;

_unitPlaced = 0;
if (count _arrayUnits > 0) then
{
	//Units are counted when they really spawn (MCC_fnc_MWbudget trims in mcc_setup), here only the queue is limited
	private _requested = 0;
	while {_unitPlaced < (_totalEnemyUnits) && {_requested < (["left", ["gen"]] call MCC_fnc_MWbudget)}} do
	{
		//Behavior
		_spawnbehavior	= ["MOVE","NOFOLLOW"] call BIS_fnc_selectRandom;

		//Group or units
		if (random 1 < 0.5 && ((count _arrayGroup)>0)) then
			{
				//Group
				_group = _arrayGroup call BIS_fnc_selectRandom;
				_price = (_priceUnit * (_group select 1));

				//Spawn a group only if it isn't too much
				if !(_price > _totalEnemyUnits) then
				{
					_unitPlaced = (_unitPlaced + (_group select 1))*_priceGroup;
					_requested = _requested + ((_group select 1) * VEH_EST_CREW_PER_UNIT);

					//Spawn them
					[_zoneNumber,"GROUP",_simType,true,_group select 0,_group select 2,_spawnbehavior,_group select 0,_side] call MCC_fnc_MWSpawnInZone;
				};
			}
			else
			{
				if (count _arrayUnits > 0) then
				{
					//Units
					_group = _arrayUnits call BIS_fnc_selectRandom;
					_unitPlaced = _unitPlaced + _priceUnit;
					_requested = _requested + VEH_EST_CREW_PER_UNIT;

					//Spawn them
					[_zoneNumber,"VEHICLE",_simType,true,_group select 1,_group select 2,_spawnbehavior,_group select 3,_side] call MCC_fnc_MWSpawnInZone;
				}
				else
				{
					diag_log "MCC: Mission Wizard Error: No vehicles available in the selected enemy faction";
				};
			};
	};
}
else
{
	diag_log "MCC: Mission Wizard Error: No vehicles available in the selected enemy faction";
};
_unitPlaced;





