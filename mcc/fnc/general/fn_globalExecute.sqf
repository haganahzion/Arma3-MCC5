//==================================================================MCC_fnc_globalExecute======================================================================================
// Runs code on selected machines. Used by the mission maker command line ("Global").
// Over the network the code is only accepted from the server. Clients send it to the server with
// MCC_fnc_requestGlobalExecute, which checks the sender first.
// Example: [mode,code] remoteExec ["MCC_fnc_requestGlobalExecute", 2];
// Params:
//	mode: number, 0:clients only, 1: server only 2: all clients and server
//	code: code, code to be executed
//==============================================================================================================================================================================
params [["_type", 2, [0]], ["_code", {}, [{}]]];

// remoteExecutedOwner is 0 in single player and for calls from a headless client.
if (isRemoteExecuted && {!(remoteExecutedOwner in [0, 2])}) exitWith {
	diag_log format ["MCC network security: refused MCC_fnc_globalExecute from owner %1", remoteExecutedOwner];
};

switch (_type) do {
	case 0:	//clients
	{
		if (!isServer) then {call _code};
	};

	case 1:	//Server
	{
		if (isServer) then {call _code};
	};

	case 2:	//all
	{
		call _code;
	};
};
