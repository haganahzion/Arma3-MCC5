//==================================================================MCC_fnc_setVehicleInit======================================================================================
// Sets vehicle init and runs it on this machine.
// Over the network it only runs when the server sent it. Send requests through the server:
// Example: [[[netID _unit,_unit], _init], 0, true] remoteExec ["MCC_fnc_requestVehicleInit", 2];
// Params:
//	_unit: [netId, object], vehicle we want to set its init.
//	_init: string, the new init command (use _this instead of this)
//    _save: Boolean, should the init be saved as a variable - default true
//==============================================================================================================================================================================
if (isRemoteExecuted && {!(remoteExecutedOwner in [2, clientOwner])}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_setVehicleInit from owner %1", remoteExecutedOwner];
};
params [["_ref", [], [[]]], ["_unitinit", "", [""]], ["_save", true, [true]]];
private _unit = if ((_ref param [0, ""]) isEqualTo "") then {_ref param [1, objNull]} else {objectFromNetID (_ref select 0)};
if (isNull _unit || {_unitinit isEqualTo ""}) exitWith {};

if (_save) then {_unit setVariable ["vehicleinit",_unitinit]};
_unit call compile _unitinit;
