// GAIA constants for vehicles and contact recovery. Mission makers tune the CBA settings in
// mcc/settings/gaiaSettings.sqf (MCC_GAIA_rideDistance, MCC_GAIA_dismountDistance, MCC_GAIA_rideSearchRadius);
// the *_DEFAULT values here are the fallbacks when a setting is missing and must match the setting defaults.
// Include from a function folder with: #include "..\gaiaDefines.hpp"

//------------------------------ Vehicles ------------------------------
// Seconds between two vehicle ticks of the same group
#define GAIA_VEH_TICK_INTERVAL		5

// Setting fallbacks (meters)
#define GAIA_RIDE_DIST_DEFAULT		500
#define GAIA_DISMOUNT_DIST_DEFAULT	400
#define GAIA_RIDE_SEARCH_DEFAULT	300

// A ride is only taken when it saves at least this much walking past the dismount point (meters)
#define GAIA_RIDE_MIN_DRIVE			200
// Share of the group's AI a vehicle must carry; the AI that don't fit walk on as their own GAIA group
#define GAIA_RIDE_MIN_FILL			0.6
// Kinds searched for a ride; static weapons are filtered out
#define GAIA_RIDE_KINDS				["LandVehicle"]
// locked value that keeps the AI out (0 unlocked, 1 default, 2 locked, 3 locked for players only)
#define GAIA_RIDE_LOCKED			2
#define GAIA_RIDE_MIN_FUEL			0.1
#define GAIA_REMOUNT_MIN_FUEL		0.05
// Seconds the AI wait for everyone to get in; then stragglers are left behind (players) or walk as their own group (AI)
#define GAIA_RIDE_BOARD_TIMEOUT		90
// Seat roles in the order passengers fill them (the driver is picked first)
#define GAIA_RIDE_SEAT_ORDER		["cargo", "turret", "gunner", "commander"]

// Vehicle ticks without contact before a group gets back in after a fight
#define GAIA_CALM_TICKS				3
// Re-mount only when the objective is further than max(dismount distance x 2, this) (meters)
#define GAIA_REMOUNT_MIN_DIST		800

// Stuck vehicle: must get this much closer (meters) within this time (seconds), at most this many re-paths
#define GAIA_STUCK_PROGRESS			100
#define GAIA_STUCK_TIME				90
#define GAIA_STUCK_TRIES			3
// After giving up on a stuck vehicle, no new ride for this long (seconds)
#define GAIA_NO_RIDE_COOLDOWN		300

// Group variables copied to the walking group when a group splits
#define GAIA_SPLIT_VARS				["GAIA_ZONE_INTEND", "GAIA_followTasks", "GAIA_followTask", "GAIA_taskMarch", "GAIA_noVehicles", "mcc_gaia_cache"]

//------------------------------ Contact ------------------------------
// Contact: an enemy known within this radius (meters) with information younger than this (seconds)
#define GAIA_CONTACT_RADIUS			500
#define GAIA_CONTACT_MAX_AGE		60
// Seconds between two contact checks of the same group
#define GAIA_CONTACT_TICK_INTERVAL	5
// Seconds without contact before a group counts as out of the fight and goes back to its own job
#define GAIA_CONTACT_CLEAR_TIME		30
// Seconds after GAIA calmed a group down in which COMBAT behaviour alone is not counted as contact
#define GAIA_CONTACT_CALM_COOLDOWN	90
// Behaviour a group gets back after the fight when it is still in COMBAT
#define GAIA_CONTACT_CALM_BEHAVIOUR	"AWARE"
// Orders that come from contact (attack, flank, support by fire and hold all use "DoAttack")
#define GAIA_CONTACT_ORDERS			["DoAttack", "DoClear"]
// Task-following groups only take on fights this close to them (meters) unless the fight is in their task zone
#define GAIA_CHASE_LIMIT			250

//------------------------------ Task march ------------------------------
// A task-following group "marches" until it reaches its task. While marching GAIA gives it no other orders
// (no attacks on other fights, no clear spots, no transport, no order timeouts) and it keeps its formation.
// Arrived: leader this close to the task (meters) or inside the task zone
#define GAIA_TASK_ARRIVE_RADIUS		150
// An arrived group that ends up this far from the task (meters) and outside the task zone marches back
#define GAIA_TASK_LEAVE_RADIUS		400
// Task zone size made around a task when no zone covers it (meters)
#define GAIA_TASK_ZONE_SIZE			[200, 200]
// An existing zone within this distance of the task is used for it (meters)
#define GAIA_TASK_ZONE_SEARCH		400
// The march waypoint must end this close to the task, else it is set again (meters)
#define GAIA_MARCH_WP_TOLERANCE		100
#define GAIA_MARCH_WP_RADIUS		30
// Marching: return fire, keep formation (RED would let every soldier run off after targets)
#define GAIA_MARCH_COMBAT_MODE		"YELLOW"
#define GAIA_MARCH_SPEED			"NORMAL"
#define GAIA_MARCH_BEHAVIOUR		"AWARE"
// Enemies known this close (meters) make a marching group fight properly (engine combat mode on)
#define GAIA_MARCH_ENGAGE_RADIUS	150
// Seconds without close enemies before a marching group goes back to marching mode
#define GAIA_MARCH_CALM_TIME		20
// Not this much closer (meters) in this time (seconds) on foot: set the march again (new path)
#define GAIA_MARCH_PROGRESS			50
#define GAIA_MARCH_STUCK_TIME		120

//------------------------------ Targets ------------------------------
// Machine id of the server (remoteExecutedOwner / setVariable target)
#define GAIA_SERVER_OWNER			2
// Only targets known with a position accuracy below this count
#define GAIA_TARGET_MAX_ACCURACY	18
// A side counts as enemy below this friendship value
#define GAIA_ENEMY_FRIENDSHIP		0.6
// Headless client: seconds between two target reports of the same group to the server
#define GAIA_HC_TARGET_INTERVAL		15
// Group variable that holds the last target report of a headless client group
#define GAIA_HC_TARGETS_VAR			"GAIA_HC_TARGETS"
// Per side object variable with the target info [time, position, accuracy] (+ GAIA_fnc_sideSuffix)
#define GAIA_TARGET_INFO_VAR		"GAIA_TargetInfo_"
// Per side object flag and missionNamespace list of objects that hold target info (+ GAIA_fnc_sideSuffix)
#define GAIA_KNOWN_TARGET_FLAG		"GAIA_isKnownTarget_"
#define GAIA_KNOWN_TARGETS_VAR		"GAIA_KNOWN_TARGETS_"

//------------------------------ Fight priority (GAIA_fnc_prioritizeCAs) ------------------------------
// Threat weight per CA class; a class not listed counts 1
#define GAIA_THREAT_WEIGHTS			[["Tank",3],["MechanizedInfantry",2.5],["AA",2.2],["Artillery",2],["Helicopter",1.8],["Static",1.6],["MotorizedInfantry",1.5],["Car",1.5],["MotorizedRecon",1.4],["Ship",1.3],["ReconInfantry",1.2]]
// Classes that count as heavy: one more ground group and a second aircraft may respond
#define GAIA_HEAVY_CLASSES			["Tank","MechanizedInfantry","AA"]
// Our groups already fighting there: base bonus, plus enemy / own points up to this cap
#define GAIA_PRIORITY_CONTACT_BONUS	1.5
#define GAIA_PRIORITY_OUTNUMBER_CAP	4
// A fight this many meters from our closest zone scores half (the distance is capped)
#define GAIA_PRIORITY_DISTANCE_SCALE	1000
#define GAIA_PRIORITY_DISTANCE_CAP	5000
// Enemy points above this many times ours in contact means badly outnumbered (enemy points carry the x2/x3 zone multiplier)
#define GAIA_PRIORITY_OUTNUMBERED	4
// Most ground groups GAIA sends to one fight
#define GAIA_PRIORITY_MAX_RESPONSE	4

//------------------------------ Air support (GAIA_fnc_airSupport) ------------------------------
// Aircraft below this fuel are left to the normal orders
#define GAIA_AIR_MIN_FUEL			0.15
// Planes reach this many times the helicopter range
#define GAIA_AIR_PLANE_RANGE_FACTOR	2.5
// Aircraft score: fight score / (1 + distance / this)
#define GAIA_AIR_DISTANCE_SCALE		2000
// Keep the current fight unless another one scores this many times higher
#define GAIA_AIR_STICKY				1.5
// Aircraft per fight: normal and heavy (see GAIA_HEAVY_CLASSES / outnumbered)
#define GAIA_AIR_PER_FIGHT			1
#define GAIA_AIR_PER_HEAVY_FIGHT	2
// reveal knowledge given to the crew, and how many known enemies are revealed per fight
#define GAIA_AIR_REVEAL_LEVEL		4
#define GAIA_AIR_REVEAL_MAX			12
#define GAIA_AIR_ORDER				"DoAirSupport"
