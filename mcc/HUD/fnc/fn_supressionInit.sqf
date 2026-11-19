/*=================================================================MCC_fnc_supressionInit================================================================================
  Init supression and hit direction effects on this client (runs while MCC_suppressionOn is true or MCC_hitRadar is not Off).
  One CBA class Fired handler for every unit and vehicle (MCC_fnc_supressionFiredEH) collects shots aimed at the player,
  a per-frame handler plays the effects. Stop it with MCC_fnc_supressionStop.
  IN <>
    Nothing
*/
#define MCC_SUPPRESSION_HIT_RADAR_OFF 2
#define MCC_SUPPRESSION_SCALE_MIN 0.5

if (!hasInterface || isDedicated) exitWith {};

waituntil {!(IsNull (findDisplay 46))};

//Init
if (missionNamespace getVariable ["MCC_initSupression",false]) exitWith {};
if (!(missionNamespace getVariable ["MCC_suppressionOn",false]) && {(missionNamespace getVariable ["MCC_hitRadar",0]) == MCC_SUPPRESSION_HIT_RADAR_OFF}) exitWith {};
missionNamespace setVariable ["MCC_initSupression",true];
missionNamespace setVariable ["MCC_supressionHitPos",[]];

//Add onEachFram EH
["MCC_initSupression", "onEachFrame", {
    private ["_pDistance","_array"];

    //in vehicle and not turned out
    if (vehicle player != player && !(isTurnedOut player)) exitWith {};
    _array = (missionNamespace getVariable ["MCC_supressionHitPos",[]]);
    if (_array isEqualTo []) exitWith {};

    {
        _x params ["_projectile","_distance","_unit"];
        if (isNull _projectile) then {
            _array set [_foreachindex,-1];
        } else {
            _pDistance = player distance _projectile;
            if (_pDistance <= _distance) then {
                [(1 -(_pDistance/_distance)) max MCC_SUPPRESSION_SCALE_MIN,[player,_unit] call BIS_fnc_relativeDirTo] spawn MCC_fnc_supressionEffects;
                _array set [_foreachindex,-1];
            };
        };
    } foreach _array;

    _array = _array - [-1];
    missionNamespace setVariable ["MCC_supressionHitPos",_array];
}] call BIS_fnc_addStackedEventHandler;

//One Fired handler for every unit and vehicle, now and later (exits at once while the effects are off)
if !(missionNamespace getVariable ["MCC_supressionClassEH",false]) then {
    missionNamespace setVariable ["MCC_supressionClassEH",true];
    ["AllVehicles", "Fired", {_this call MCC_fnc_supressionFiredEH}] call CBA_fnc_addClassEventHandler;
};
