/*=================================================================MCC_fnc_supressionStop================================================================================
  Stops the supression and hit direction effects on this client when both are off
  (MCC_suppressionOn false and MCC_hitRadar Off), else makes sure they run.
  The class Fired handler stays but exits at once while MCC_initSupression is false.
  IN <>
    0: BOOL   - (optional) suppression setting, default MCC_suppressionOn
    1: NUMBER - (optional) hit direction setting, default MCC_hitRadar
*/
#define MCC_SUPPRESSION_HIT_RADAR_OFF 2

params [
    ["_suppression", missionNamespace getVariable ["MCC_suppressionOn",false], [false]],
    ["_hitRadar", missionNamespace getVariable ["MCC_hitRadar",0], [0]]
];

if (_suppression || {_hitRadar != MCC_SUPPRESSION_HIT_RADAR_OFF}) exitWith {
    if !(missionNamespace getVariable ["MCC_initSupression",false]) then {[] spawn MCC_fnc_supressionInit};
};

missionNamespace setVariable ["MCC_initSupression",false];
missionNamespace setVariable ["MCC_supressionHitPos",[]];
["MCC_initSupression", "onEachFrame"] call BIS_fnc_removeStackedEventHandler;
