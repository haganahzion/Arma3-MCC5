/*
	MCC_fnc_rxServerCommand  (server)
	Runs one of a few fixed server commands for a client, after checking the sender.
	Operations:
		"hideObject"          [object, hide]: the sender must control the object, or be trusted
		"removeEditable"      [curator, objects]: Zeus edit list, trusted senders only
		"timeMultiplier"      [number 0.1 to 120]: trusted senders only
		"resistanceHostility" [mode]: 1 hostile to east, 2 hostile to west, else hostile to west; trusted senders only
	Trusted = MCC_fnc_isTrustedSender (server, admin, Zeus) or a player allowed to use MCC.
	Params:
		0: STRING - operation
		1: ARRAY - its arguments
	Example:
		["hideObject", [_object, true]] remoteExec ["MCC_fnc_rxServerCommand", 2];
*/
params [["_op", "", [""]], ["_args", [], [[]]]];

if (!isServer) exitWith {};
private _trusted = !isRemoteExecuted || {[remoteExecutedOwner] call MCC_fnc_isTrustedSender} || {[remoteExecutedOwner] call MCC_fnc_isAuthorizedOwner};
private _refuse = {diag_log format ["MCC network security: refused MCC_fnc_rxServerCommand %1 from owner %2", _op, remoteExecutedOwner]};

switch (_op) do {
	case "hideObject": {
		_args params [["_object", objNull, [objNull]], ["_hide", true, [true]]];
		if (isNull _object) exitWith {};
		if (!_trusted && {(owner _object) != remoteExecutedOwner}) exitWith _refuse;
		_object hideObjectGlobal _hide;
	};
	case "removeEditable": {
		_args params [["_curator", objNull, [objNull]], ["_objects", [], [[]]]];
		if (!_trusted) exitWith _refuse;
		if (isNull _curator) exitWith {};
		_curator removeCuratorEditableObjects [_objects select {_x isEqualType objNull}, true];
	};
	case "timeMultiplier": {
		_args params [["_value", 1, [0]]];
		if (!_trusted) exitWith _refuse;
		setTimeMultiplier ((_value max 0.1) min 120);
	};
	case "resistanceHostility": {
		_args params [["_mode", 0, [0]]];
		if (!_trusted) exitWith _refuse;
		private _hostile = if (_mode == 1) then {east} else {west};
		private _friendly = if (_mode == 1) then {west} else {east};
		resistance setFriend [_hostile, 0];
		resistance setFriend [_friendly, 0.8];
		_hostile setFriend [resistance, 0];
		_friendly setFriend [resistance, 0.8];
	};
};
