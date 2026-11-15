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
#define GAIA_SPLIT_VARS				["GAIA_ZONE_INTEND", "GAIA_followTasks", "GAIA_followTask", "GAIA_noVehicles", "mcc_gaia_cache"]

//------------------------------ Contact ------------------------------
// Contact: an enemy known within this radius (meters) with information younger than this (seconds)
#define GAIA_CONTACT_RADIUS			500
#define GAIA_CONTACT_MAX_AGE		60
// Seconds between two contact checks of the same group
#define GAIA_CONTACT_TICK_INTERVAL	5
// Seconds without contact before a group counts as out of the fight and goes back to its own job
#define GAIA_CONTACT_CLEAR_TIME		30
// Behaviour a group gets back after the fight when it is still in COMBAT
#define GAIA_CONTACT_CALM_BEHAVIOUR	"AWARE"
// Orders that come from contact (attack, flank, support by fire and hold all use "DoAttack")
#define GAIA_CONTACT_ORDERS			["DoAttack", "DoClear"]
// Task-following groups only take on fights this close to them (meters) unless the fight is in their task zone
#define GAIA_CHASE_LIMIT			400
