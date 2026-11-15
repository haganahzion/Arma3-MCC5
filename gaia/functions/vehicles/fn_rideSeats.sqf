/*
	GAIA_fnc_rideSeats
	Free, unlocked seats of a vehicle, read from fullCrew so FFV and turret seats of mod vehicles count too.
	Params:
		0: OBJECT - vehicle
	Returns: ARRAY of [role, turretPath], role in lower case ("driver", "cargo", "turret", "gunner", "commander")
*/
params [["_veh", objNull, [objNull]]];

if (isNull _veh) exitWith {[]};

private _seats = [];
{
	_x params ["_unit", "_role", "_cargoIndex", "_turret"];
	if (isNull _unit) then {
		private _r = toLowerANSI _role;
		private _locked = switch (_r) do {
			case "driver": {lockedDriver _veh};
			case "cargo": {_veh lockedCargo _cargoIndex};
			default {_veh lockedTurret _turret};
		};
		if (!_locked) then {_seats pushBack [_r, _turret]};
	};
} forEach (fullCrew [_veh, "", true]);

_seats
