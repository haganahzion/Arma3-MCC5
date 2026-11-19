/*=================================================================MCC_fnc_supressionFiredEH================================================================================
  CBA class Fired handler (see MCC_fnc_supressionInit): stores shots aimed at the player for the effects.
  IN <>
    Fired event handler arguments
*/
#define MCC_SUPPRESSION_MAX_SHOOTER_DIST 600
#define MCC_SUPPRESSION_MAX_SHOTS 40
#define MCC_SUPPRESSION_MIN_RADIUS 8
#define MCC_SUPPRESSION_AIM_LEFT 310
#define MCC_SUPPRESSION_AIM_RIGHT 50

if !(missionNamespace getVariable ["MCC_initSupression",false]) exitWith {};

params [
        "_unit",
        "_weapon",
        "_muzzle",
        "_mode",
        "_ammo",
        "_magazine",
        "_projectile"
    ];
private ["_cfg","_hit","_distance","_projectiles","_dirTo"];

if (_unit == vehicle player || {_unit == player}) exitWith {};
if ((_unit distance player) > MCC_SUPPRESSION_MAX_SHOOTER_DIST) exitWith {};
if (_weapon in ["throw","put"]) exitWith {};

_projectiles = missionNamespace getVariable ["MCC_supressionHitPos",[]];
if (count _projectiles >= MCC_SUPPRESSION_MAX_SHOTS) exitWith {};

if (isNull _projectile) then {
     _projectile = nearestObject [_unit, _ammo];
};

if (isNull _projectile) exitWith {};

_cfg = configFile >> "CfgAmmo" >> _ammo;
_hit  = getNumber (_cfg >> "hit");

//No damage
if (_hit <= 0) exitWith {};

_distance = (getNumber (_cfg >> "suppressionRadiusHit")) max MCC_SUPPRESSION_MIN_RADIUS;
_dirTo = [_projectile,player] call BIS_fnc_relativeDirTo;

//Manage only bulltes that are aimed on the player
if (_dirTo > MCC_SUPPRESSION_AIM_LEFT || _dirTo < MCC_SUPPRESSION_AIM_RIGHT) then {
    _projectiles pushBack [_projectile, _distance, _unit];
    missionNamespace setVariable ["MCC_supressionHitPos",_projectiles];
};
