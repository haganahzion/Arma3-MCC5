private ["_hostage","_init"];

_hostage = _this;

removeallweapons _hostage;
dostop _hostage;
if (MCC_isACE) then {
	 [_hostage, true] call ACE_captives_fnc_setHandcuffed;
} else {
	_hostage allowFleeing 0;
	_hostage disableAI "MOVE";
	_hostage setVariable ["MCC_disarmed",true,true];
	removeallweapons _hostage;
	_hostage setcaptive true;
	_init = "_this switchmove 'Acts_ExecutionVictim_Loop';";
	[[[netID _hostage,_hostage], _init, false], 0, true] remoteExec ["MCC_fnc_requestVehicleInit", 2];
	/*[_hostage, "Hold %1 to interact"] remoteExec ["MCC_fnc_createHelper",2];*/
};

// The untie action is added on every machine by the server. This script can run on several machines,
// so only the server, or the machine where the hostage is local, asks for it.
if (isServer || {local _hostage}) then {
	[_hostage, "hostageUntie", []] remoteExec ["MCC_fnc_rxAddHoldAction", 2];
};



