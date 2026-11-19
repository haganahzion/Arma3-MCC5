// Network security helpers, plus small named functions so clients never send raw code over the network.
class security
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\security";
	#else
	file = "mcc\fnc\security";
	#endif

	class networkSecurity {description = "Returns the mission's MCC network security level (0 Normal, 1 Strict)";};
	class isAuthorizedOwner {description = "Server only: may this owner id use MCC";};
	class remoteAllowed {description = "Guard for remote-executed functions in Strict mode";};
	class isTrustedSender {description = "May this owner send init code or object names (server, admin, MCC user who is Zeus)";};
	class remoteTrusted {description = "Guard: remote calls only from the server, admins or MCC users who are Zeus";};
	class remoteOwnsUnit {description = "Guard: remote calls only from the machine that controls the unit, or a trusted sender";};
	class remoteSenderUnit {description = "Server: the player unit of the machine that sent the current remoteExec call";};
	class sideFromString {description = "Side name text to side, without compile";};
	class configFromString {description = "configFile path text to config, without compile";};
	class requestGlobalExecute {description = "Server: check the sender, then run mission maker command line code on every machine";};
	class arrayFromString {description = "Data array text to array, without compile";};
	class requestVehicleInit {description = "Server: check the sender, then run an object init on the targets";};
	class requestVehicleName {description = "Server: check the sender and name, then name an object everywhere";};
	class setAllowedPlayers {description = "Server: set who may use MCC (server copy plus shared list)";};
	class setAuthorizedOwners {description = "Clients: store authorized owners sent by the server";};
	class securityInit {postInit = 1; description = "Server: publish owners allowed to use MCC";};
};

class remote
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\fnc\remote";
	#else
	file = "mcc\fnc\remote";
	#endif

	class rxAddCatapultAction {};
	class rxAddHoldAction {description = "Server checks the sender, then every machine adds a fixed MCC hold action";};
	class rxApplyFatigue {};
	class rxAddIntel {};
	class rxAddShipControlAction {};
	class rxCuratorAddEditable {};
	class rxEjectUnconscious {};
	class rxEndMission {};
	class rxRespawnTickets {};
	class rxHaltStop {};
	class rxPlaceSatchel {};
	class rxSideRating {};
	class rxUndoLastSpawn {};
	class rxServerCommand {description = "Server: a few fixed server commands for clients, after a sender check";};
	class rxVote {description = "Server: count a vote or share the count (MCC vote variables only)";};
};

// Server and headless client functions for the MCC spawn menu, convoys, boxes and high command.
class pvHandling
{
	#ifdef MCCMODE
	file = "\mcc_sandbox_mod\mcc\pv_handling\fnc";
	#else
	file = "mcc\pv_handling\fnc";
	#endif

	class spawnHandler {description = "Server or HC: spawn an MCC spawn request (called after the sender check)";};
	class setupSpawn {description = "Server or HC: check the sender, then spawn an MCC spawn request";};
	class simpleSpawn {description = "Server or HC: check the sender, then spawn from the 3D placer";};
	class FPS {description = "Server or HC: start the FPS benchmark";};
	class highCommand {description = "Server: check the sender, then set up high command";};
	class boxGenerator {description = "Server: check the sender, then create a filled box";};
	class placeConvoy {description = "Server: check the sender, then place a convoy";};
	class startConvoy {description = "Server: check the sender, then start a convoy";};
};
