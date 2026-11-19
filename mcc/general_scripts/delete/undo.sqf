 /*
 if !mcc_isloading then 
			{
			mcc_safe = mcc_safe + FORMAT ["script_handler = [1] execVM '%1mcc\general_scripts\delete\undo.sqf';
								waitUntil {scriptDone script_handler};
								"
								, MCC_path
								];									
			};
*/
// Clients ask the server, which checks the sender and passes it on to everyone.
[] remoteExec ["MCC_fnc_rxUndoLastSpawn", [2, 0] select isServer];
	
 
 

