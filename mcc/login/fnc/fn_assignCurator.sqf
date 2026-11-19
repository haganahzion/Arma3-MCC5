/*
	MCC_fnc_assignCurator  (server)
	Makes the unit the MCC Zeus (MCC_curator). Over the network the sender must control the unit and be
	allowed to use MCC (MCC_fnc_isAuthorizedOwner).
	Params:
		0: OBJECT - the unit (the unit itself may also be passed instead of an array)
	Example:
		player remoteExec ["MCC_fnc_assignCurator", 2];
*/
private _unit = if (_this isEqualType objNull) then {_this} else {_this param [0, objNull, [objNull]]};

if (!isServer || {isNull _unit} || {isNil "MCC_curator"}) exitWith {};
if (isRemoteExecuted && {!(remoteExecutedOwner in [0, 2, clientOwner])}) then {
	if ((owner _unit) != remoteExecutedOwner || {!([remoteExecutedOwner] call MCC_fnc_isAuthorizedOwner)}) exitWith {
		diag_log format ["MCC network security: refused MCC_fnc_assignCurator from owner %1", remoteExecutedOwner];
		_unit = objNull;
	};
};
if (isNull _unit) exitWith {};

unassignCurator MCC_curator;
_unit assignCurator MCC_curator;
