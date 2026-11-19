// Server and headless client setup for MCC spawn requests.
// The handlers are final, so another machine cannot replace them with publicVariable.

my_pv = [];

if (isServer || {MCC_isLocalHC}) then {
	if (isnil "MCC_Chat") then {MCC_Chat = true};
};

if (isServer) then {
	// Same as MCC_fnc_setupSpawn on the server; GAIA delayed spawns send to this name.
	mcc_setup = compileFinal {if (["mcc_setup"] call MCC_fnc_remoteTrusted) then {_this call MCC_fnc_spawnHandler}};
	diag_log format ["Added 'mcc_setup' EventHandler for Server"];
};

my_pv_handler = compileFinal {_this call MCC_fnc_spawnHandler};
