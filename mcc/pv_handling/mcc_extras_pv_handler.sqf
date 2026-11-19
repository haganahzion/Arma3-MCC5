// MCC 3D placer, on every machine. Final, so another machine cannot replace it with publicVariable.
// The server functions MCC_fnc_simpleSpawn, FPS, highCommand, boxGenerator, placeConvoy and startConvoy are in mcc\pv_handling\fnc.
MCC_3D_PLACER = compileFinal preProcessFileLineNumbers format["%1mcc\pop_menu\3rd_placer.sqf",MCC_path];

if ( (isServer) || (MCC_isLocalHC) ) then {
	mcc_fps_running = false;
};
