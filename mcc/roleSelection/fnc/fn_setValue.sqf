//==================================================================MCC_fnc_setValue======================================================================================
// Stores a value the server read from the player database (reply to MCC_fnc_getVariable).
// Accepted only from the server. Only role selection and player save names are allowed:
// "MCCplayerRank", "<role>Level", "<world>_<mission>_playerPos", "..._playerGear", "..._playerStats".
// Input:
//	_varName: 	String - variable Name
//	_value:		Anything - Value
//	_id  		String - player ID where to set the value
//
//Outout: <NOTHING>
//
// Example: [_varName, _value, _id] remoteExec ["MCC_fnc_setValue", _player];
//==============================================================================================================================================================================
#define MCC_SETVALUE_PATTERN "(MCCplayerRank|[A-Za-z0-9_]{1,64}Level|[A-Za-z0-9_.\-]{1,128}_player(Pos|Gear|Stats))"

params [["_varName", "", [""]], "_value", ["_id", "", [""]]];

// remoteExecutedOwner is 0 in single player and for calls from a headless client.
if (isRemoteExecuted && {!(remoteExecutedOwner in [0, 2, clientOwner])}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_setValue from owner %1", remoteExecutedOwner];
};
if (getPlayerUID player != _id) exitWith {};
if !(_varName regexMatch MCC_SETVALUE_PATTERN) exitWith {
	diag_log format ["MCC: refused value name %1", str _varName];
};
private _old = missionNamespace getVariable _varName;
if (!isNil "_old" && {_old isEqualType {}}) exitWith {};

missionNamespace setVariable [_varName, _value];
