//==================================================================MCC_fnc_setVehicleName======================================================================================
// Sets vehicle name. Over the network it only runs when the server sent it; send requests through the server:
// Example: [[netid _unit,_unit], _name] remoteExec ["MCC_fnc_requestVehicleName", 2];
// Params:
//	_unit: [netId, object], vehicle we want to name.
//	_name: string, the new name (checked by MCC_fnc_requestVehicleName)
//==============================================================================================================================================================================
if (isRemoteExecuted && {!(remoteExecutedOwner in [2, clientOwner])}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_setVehicleName from owner %1", remoteExecutedOwner];
};
params [["_ref", [], [[]]], ["_unitname", "", [""]]];
private _unit = if ((_ref param [0, ""]) isEqualTo "") then {_ref param [1, objNull]} else {objectFromNetID (_ref select 0)};
if (isNull _unit || {_unitname isEqualTo ""}) exitWith {};

_unit setVehicleVarName _unitname;
missionNamespace setVariable [_unitname, _unit];
if (isServer) then {_unit setVariable ["text",_unitname,true]};
