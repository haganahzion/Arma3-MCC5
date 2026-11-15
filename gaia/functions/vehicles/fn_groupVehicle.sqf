/*
	GAIA_fnc_groupVehicle
	Returns the vehicle a group travels in: the remembered one (GAIA_groupVehicle), else a vehicle assigned to
	or occupied by its AI units that can carry people. Vehicles of player members don't count: a player's own
	ride is not the group's. objNull if none.
	Params:
		0: GROUP
	Returns: OBJECT
*/
params [["_group", grpNull, [grpNull]]];

private _veh = _group getVariable ["GAIA_groupVehicle", objNull];
if (!isNull _veh && {alive _veh}) exitWith {_veh};

_veh = objNull;
{
	private _v = assignedVehicle _x;
	if (isNull _v && {vehicle _x != _x}) then {_v = vehicle _x};
	if (!isNull _v && {alive _v} && {!(_v isKindOf "StaticWeapon")} && {!(_v isKindOf "Air")} && {!(_v isKindOf "Ship")}) exitWith {_veh = _v};
} forEach ((units _group) select {!isPlayer _x});

if (!isNull _veh) then {_group setVariable ["GAIA_groupVehicle", _veh]};
_veh
