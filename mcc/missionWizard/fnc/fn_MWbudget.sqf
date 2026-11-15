/*=================================================== MCC_fnc_MWbudget ===================================================
	Hard cap on the enemy AI the runtime Mission Wizard creates (server). Counts units that really exist (crew and cargo
	included). Two pools: "obj" (reserved for the objectives' minimum: the target and a few guards, spends the reserve
	first, then the general pool) and "gen" (everything else). Only units of the mission's enemy side count, civilians
	and the player side never do. While no budget is active every request is granted.
	State: MCC_MWunitBudget (general units left), MCC_MWunitBudgetReserve, MCC_MWunitBudgetSide, MCC_MWunitBudgetToken.

	Params:
		0: STRING - mode
			"start"   [max, reserve, side] -> NUMBER token
			"release" token (only releases the budget it started) -> nothing
			"left"    [pool, side (optional)] -> NUMBER units still allowed (1e6 when no budget or another side)
			"take"    [side, count, pool] -> NUMBER granted (0..count), spent at once
			"trim"    [units or group, pool] -> ARRAY units kept; extra units of the enemy side are deleted
			          (crew with deleteVehicleCrew, a vehicle left with no crew is deleted too)
		1: ANY - mode arguments
	Example: private _n = ["take", [east, 1, "obj"]] call MCC_fnc_MWbudget;
*/
#define BUDGET_NONE 1e6
#define BUDGET_POOL_OBJ "obj"

params [["_mode", "", [""]], ["_args", []]];

private _active = !isNil "MCC_MWunitBudget";

//Sides may arrive as strings ("EAST", "WEST", "GUER", "CIV")
private _fnc_side = {
	if (_this isEqualType sideUnknown) exitWith {_this};
	switch (toUpperANSI _this) do {
		case "WEST": {west};
		case "EAST": {east};
		case "GUER";
		case "RESISTANCE": {resistance};
		case "CIV";
		case "CIVILIAN": {civilian};
		default {sideUnknown};
	};
};
private _result = nil;

switch (toLowerANSI _mode) do {
	case "start": {
		_args params [["_max", 0, [0]], ["_reserve", 0, [0]], ["_side", east, [east, ""]]];
		_side = _side call _fnc_side;
		_reserve = (round _reserve) max 0 min (round _max);
		isNil {
			MCC_MWunitBudgetToken = (missionNamespace getVariable ["MCC_MWunitBudgetToken", 0]) + 1;
			MCC_MWunitBudgetReserve = _reserve;
			MCC_MWunitBudget = (round _max) - _reserve;
			MCC_MWunitBudgetSide = _side;
		};
		_result = MCC_MWunitBudgetToken;
	};

	case "release": {
		if (_active && {_args isEqualTo (missionNamespace getVariable ["MCC_MWunitBudgetToken", -1])}) then {
			isNil {
				MCC_MWunitBudget = nil;
				MCC_MWunitBudgetReserve = nil;
				MCC_MWunitBudgetSide = nil;
			};
		};
	};

	case "left": {
		_args params [["_pool", "gen", [""]], ["_side", sideUnknown, [sideUnknown, ""]]];
		_side = _side call _fnc_side;
		_result = if (!_active || {!(_side isEqualTo sideUnknown) && {!(_side isEqualTo MCC_MWunitBudgetSide)}}) then {BUDGET_NONE} else {
			MCC_MWunitBudget + ([0, MCC_MWunitBudgetReserve] select (_pool == BUDGET_POOL_OBJ))
		};
	};

	case "take": {
		_args params [["_side", sideUnknown, [sideUnknown, ""]], ["_count", 1, [0]], ["_pool", "gen", [""]]];
		_side = _side call _fnc_side;
		_count = (round _count) max 0;
		if (!_active || {!(_side isEqualTo MCC_MWunitBudgetSide)}) exitWith {_result = _count};
		private _granted = 0;
		isNil {
			private _fromReserve = 0;
			if (_pool == BUDGET_POOL_OBJ) then {
				_fromReserve = _count min MCC_MWunitBudgetReserve;
				MCC_MWunitBudgetReserve = MCC_MWunitBudgetReserve - _fromReserve;
			};
			private _fromGeneral = (_count - _fromReserve) min (MCC_MWunitBudget max 0);
			MCC_MWunitBudget = MCC_MWunitBudget - _fromGeneral;
			_granted = _fromReserve + _fromGeneral;
		};
		_result = _granted;
	};

	case "trim": {
		_args params [["_what", [], [[], grpNull]], ["_pool", "gen", [""]]];
		private _units = if (_what isEqualType grpNull) then {units _what} else {_what};
		_units = _units select {!isNull _x && {alive _x}};
		if (!_active) exitWith {_result = _units};
		private _counted = _units select {(side group _x) isEqualTo MCC_MWunitBudgetSide};
		if (_counted isEqualTo []) exitWith {_result = _units};

		//Leaders and drivers are kept first, cargo goes first
		private _order = [_counted, [], {
			private _veh = objectParent _x;
			switch (true) do {
				case (leader group _x isEqualTo _x): {0};
				case (!isNull _veh && {driver _veh isEqualTo _x}): {1};
				case (!isNull _veh && {(_veh getCargoIndex _x) < 0}): {2};
				default {3};
			}
		}, "ASCEND"] call BIS_fnc_sortBy;

		private _granted = ["take", [MCC_MWunitBudgetSide, count _order, _pool]] call MCC_fnc_MWbudget;
		private _extra = _order select [_granted, count _order];
		private _vehicles = [];
		{
			private _veh = objectParent _x;
			if (isNull _veh) then {
				deleteVehicle _x;
			} else {
				_vehicles pushBackUnique _veh;
				_veh deleteVehicleCrew _x;
			};
		} forEach _extra;
		{
			if (({alive _x} count (crew _x)) == 0) then {deleteVehicle _x};
		} forEach _vehicles;
		if (_extra isNotEqualTo []) then {
			diag_log format ["MCC Mission Wizard: unit cap reached, %1 unit(s) not spawned", count _extra];
		};
		_result = _units - _extra;
	};
};

if (isNil "_result") exitWith {nil};
_result
