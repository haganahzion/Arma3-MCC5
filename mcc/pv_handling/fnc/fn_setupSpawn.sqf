/*
	MCC_fnc_setupSpawn
	Server or headless client: checks the sender, then runs an MCC spawn request (MCC_fnc_spawnHandler).
	Accepted from the server, a headless client, an admin, or an MCC user who is Zeus right now.
	A player's request with the HC flag set (index 20 = 1) is checked on the server and passed on to the headless client.
	Params: the MCC spawn array built in mcc\general_scripts\mcc_Spawnstuff.sqf
	Example:
		_ar remoteExec ["MCC_fnc_setupSpawn", 2];
*/
if (!isServer && {!(missionNamespace getVariable ["MCC_isLocalHC", false])}) exitWith {};
if !(["MCC_fnc_setupSpawn"] call MCC_fnc_remoteTrusted) exitWith {};
if !(_this isEqualType []) exitWith {};

if (isServer && {isRemoteExecuted} && {remoteExecutedOwner != 0}
	&& {(_this param [20, 0]) isEqualTo 1}
	&& {missionNamespace getVariable ["MCC_isHC", false]}) exitWith {
	private _hc = missionNamespace getVariable ["MCC_ownerHC", objNull];
	if (_hc isEqualType objNull && {!isNull _hc}) then {
		_this remoteExec ["MCC_fnc_setupSpawn", _hc];
	} else {
		_this call MCC_fnc_spawnHandler;
	};
};

_this call MCC_fnc_spawnHandler;
