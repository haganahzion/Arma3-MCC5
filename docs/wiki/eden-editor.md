# Eden editor

In MCC 5 everything for the mission maker lives in the Eden editor: one top menu, one settings window, MCC modules and two MCC attributes on objects and groups.

## The MCC 5 menu

**MCC 5** sits in the top menu bar of the editor. It works with or without 3den Enhanced.

| Menu item | What it does |
|---|---|
| **MCC 5 Mission Settings...** | Opens the MCC 5 window with every MCC setting for this mission. See [Mission Settings window](#mission-settings-window). |
| **Mission Wizard...** | Opens the editor Mission Wizard options. See [Mission Wizard](mission-wizard.md). |
| **Generate Mission** | Builds the whole Mission Wizard mission as editor objects. |
| **Regenerate Mission (clear + generate)** | Deletes the last generated mission, then generates a new one. |
| **Clear Generated Mission** | Deletes everything in the "MCC Mission Wizard" layers. |
| **Place MCC Module** | Submenu. Places an MCC module at the center of the screen and opens its attributes. |
| **Place Settings Module** | Submenu. Same for the MCC settings modules. |
| **In-game: Zeus (Ctrl+Delete / Y) > Modules > MCC** | A reminder. It only shows a notification about how Zeus works in game. |
| **About MCC 5** | Shows a short notification about where things are. |

### Place MCC Module

Each entry creates the module at the screen center, selects it and opens its attributes.

- Mission Wizard (generated at mission start)
- Convoy
- Fire Mission
- Music / Sound
- Create Zone
- Campaign Init
- Capture Point
- IED / Suicide Bomber
- Evac Vehicle
- Intel
- Vehicle Respawn
- Start Location
- Access Rights

### Place Settings Module

- General
- GAIA
- Mission Wizard
- Mechanics
- Medical System

All these modules are also in the normal Eden module browser (**Systems > Modules**, under the **(MCC) ...** categories). The menu is a shortcut.

## Mission Settings window

**MCC 5 > MCC 5 Mission Settings...** opens one window called **MCC 5 Mission Settings**. It has:

- A first category, **MCC 5**, with the main MCC 5 options:
  - Limited Logistics
  - Mission Wizard: Max Objectives, Mission Size, Max Spawned Units
  - Campaign: Simultaneous AOs, AO Size, Ambient Groups Cap
  - GAIA: AI Support Requests, AI Artillery, AI Close Air Support, AI Reinforcements, Coordinated Attacks, Headless Client Balancing
  - Zeus for MCC Users
  - Network Security
- One more category for each group of MCC CBA settings (General, GAIA, Mission Wizard, Logistics, Mechanics, Medical, Radio, Respawn, User Interface, Role Selection, Classes, Commander Console). These start collapsed.

Almost every value starts at **Use addon setting** (or an empty box). That means: keep whatever the CBA addon setting says. Only values you change are saved into the mission.

When the mission starts, the server copies the values you changed over the matching CBA settings, for every machine. Each change is written to the RPT as `MCC: Eden attribute ...`. If a mission `cba_settings.sqf` or a server admin forces a setting with "overwrite mission" priority, that forced value still wins, and the RPT says so.

**Network Security** is the one exception. It has no "Use addon setting" state. It is Normal by default. See [Multiplayer and security](multiplayer-and-security.md).

The full list of settings, with defaults, is on the [Settings](settings.md) page.

Missions that don't use these Eden attributes can set the same names in `description.ext` instead, for example `MCC_logisticsMode = 2;` or `MCC_networkSecurity = 1;`.

## MCC attributes on objects and groups

### Objects: MCC: Zeus Editable

Open the attributes of a unit, vehicle or simulated object. In the **MCC** category tick **MCC: Zeus Editable**.

At mission start the object, and its crew, is added to every Zeus. Use it for things your Zeus players must be able to move or edit. Default: off.

### Groups: MCC: GAIA Control

Open the attributes of a group (not a single unit). The **MCC: GAIA Control** category has:

| Attribute | What it does | Default |
|---|---|---|
| **GAIA Zone** | The MCC zone number this group belongs to. 0 means GAIA does not control the group. | 0 |
| **GAIA Behavior** | How GAIA uses the group in its zone. See below. | Aggressive |
| **GAIA Cache** | Let GAIA cache (freeze or remove) the group while no player is near. | Off |

GAIA Behavior choices:

- **Aggressive**: patrol, and pursue enemies outside the zone (`MOVE`).
- **Defensive**: patrol, stay in the zone (`NOFOLLOW`).
- **Fortify**: occupy buildings and static weapons (`FORTIFY`).
- **BIS Defence** and **BIS Patrol** are also listed. The GAIA code only gives special orders for the first three behaviours, so pick one of those if you want GAIA to command the group.

The zone number must exist when the mission runs. Zones get numbers in the order they are created, starting at 1. Each **Create Zone** module makes one zone at mission start. With several Create Zone modules (or a generated Mission Wizard mission) you can't be sure which zone gets which number, so syncing the group to an **Assign AI to zone** module is the safer way. See [GAIA AI](gaia.md).

## Eden modules

MCC modules sit in the Eden module browser under these categories:

- **(MCC) General**
- **(MCC) AI**
- **(MCC) Ordnance**
- **(MCC) Utility**
- **(MCC) Ships Static**
- **(MCC) RTS**
- **(MCC) Environment**
- **(MCC) PvP**

Most modules work by **syncing** (right-click the module > Connect > Sync to) to triggers, units or objects. The module's own description in Eden tells you what to sync.

### New in MCC 5

**Mission Wizard** (General). Generates a random Mission Wizard mission on the server when the mission starts. It uses the module's own options. See [Mission Wizard](mission-wizard.md#the-mission-wizard-eden-module-runtime).

**Convoy** (AI). Turns synced crewed land vehicles into one convoy that drives to a destination.
1. Place crewed vehicles and sync them (or their crew) to the module.
2. Set a destination: a **Destination Marker** name, or sync an empty object such as a Game Logic or invisible helipad. Without both, the convoy follows the Eden waypoints of the lead vehicle's group.
3. Optional: sync a trigger. The convoy starts when the trigger activates. Without a trigger it starts at mission start.

Options:

| Option | What it does | Default |
|---|---|---|
| Destination Marker | Marker name of the destination | empty |
| Start Delay (s) | Wait after the trigger (or mission start) before moving | 0 |
| Lead Speed (km/h) | Speed of the lead vehicle, 0 = no limit | 40 |
| Separation (m) | Distance between vehicles | 30 |
| HVT Class | Optional unit class. The HVT rides captive and disarmed in the middle vehicle (handcuffed with ACE) | empty |
| Escort Infantry | Fill free cargo seats with infantry of each vehicle's faction | off |
| On Arrival | Stop and hold, Dismount passengers, or Delete the convoy | Stop and hold |

The vehicle closest to the destination leads. The module stores `MCC_convoyState` (waiting, moving, arrived, destroyed), `MCC_convoyVehicles` and `MCC_convoyHVT`, so you can check them in triggers.

**Fire Mission** (Ordnance). Fires artillery at the module position, or at a synced object or unit (its position when the salvo fires).
- Sync a trigger to fire when it activates. A repeatable trigger fires it again on every activation. Without a trigger it fires at mission start.
- Sync crewed artillery (mortars, howitzers, MLRS) to use real guns. They fire their first magazine that is in range. Without guns, or when none is in range, MCC simulated shells are used.

| Option | What it does | Default |
|---|---|---|
| Shell (simulated) | Shell used when no synced gun can fire: DPICM, HE 120mm, HE 155mm, Cluster AP, Mines 120mm, HE Laser-guided (as plain bomb), HE 82mm, Incendiary 82mm, Smoke White 120mm, Smoke White 82mm, Smoke Green 40mm, Smoke Red 40mm, Flare White, Flare Green, Flare Red | HE 120mm |
| Spread | On target, Precise (100 m), Tight (200 m), Wide (400 m) | Precise (100 m) |
| Rounds per Salvo | Shells per salvo (per gun with synced guns) | 4 |
| Salvos | Number of salvos | 1 |
| Time Between Salvos (s) | Seconds between salvos | 30 |
| Time Between Shells (s) | Simulated shells only | 1 |
| Delay (s) | Seconds from trigger (or mission start) to the first salvo | 0 |

**Music / Sound** (Environment). Plays music or a sound for every player.
- **Track / Sound**: a CfgMusic class (for example `LeadTrack01_F`) or a CfgSounds class (for example `AlarmSfx`). Mission classes work too. Default `LeadTrack01_F`.
- **Type**: Music, Sound or Stop music.
- Sync a trigger to play it when the trigger activates (again on each activation of a repeatable trigger). Without a trigger it plays at mission start.

### Zones and AI

**Create Zone** (AI). Makes an MCC zone for GAIA.
1. Place a trigger and size it. The trigger area is the zone area.
2. Sync the trigger to the Create Zone module.
3. To put groups in this zone, also sync one or more **Assign AI to zone** modules to it.

At mission start the zone gets the next free zone number.

**Assign AI to zone** (AI). Sync groups or units to it, and sync it to one Create Zone module. Those groups are put under GAIA in that zone. **Behavior**: aggressive (default), defensive or fortify.

**Respawn Group** (AI). Sync to any unit or group. The group respawns when all its units are dead. **Respawns**: how many times.

**Ambient Units** (AI). Ambient civilians and cars around players. Options: Ambient Patrols, Ambient Cars, Parked Cars, Parked Cars Locked, Faction, Car's Faction, Civilians attitude, Civs Always Friendly.

**Ambient units(Restrict)** (AI). Server side: stops ambient AI spawning within its **Radius**.

**Set Unconscious** (AI). Sync to an AI man to force the unconscious state. Needs the MCC medical system on. Options: Disable Bleeding, Force Unconscious.

**Undercover Agents** (AI). Sync to player roles. Those players can move near enemy AI as long as they keep weapons hidden and don't act suspicious. **Remove Weapons** removes their weapons at game start.

**Convoy** is described above.

### General

**Access Rights**. Who may use MCC (and so who gets Zeus). Enter player UIDs in **MCC Operators** as an array, for example `["76561190000000000"]`, and/or sync player roles to the module. **Admin Access** also allows admins and the host. See [Multiplayer and security](multiplayer-and-security.md).

**Start Location**. Defines a side's start location. Options: Side, Type (F.O.B or Main; you need at least one Main), Insertion (open the respawn menu at mission start and how to insert: don't open/don't teleport, Teleport, Paradrop, H.A.L.O), Distractable (can be destroyed), Construct Buildings (a real building or just a flag pole).

**Evac Vehicle**. Sync to a vehicle to make it an AI evac vehicle that players can command. Options: Evac Side, Add Gunners, Campaign Evac (respawns each in-game day during an MCC campaign).

**IED/Suicide Bomber**. Sync to a vehicle or object to make an IED, or to an AI to make a suicide bomber. Options: Activate Side, Explosion Size (Small, Medium, Large), Explosion Effect (Deadly, Disabling, Fake, None), Disarm Time (10 to 240 seconds), Jammable, Activation Type (Proximity, Radio/Spotter, Mission Maker Only, Mini-Game (Proximity), Mini-Game (Manual)), Activation Distance (5 to 50 m).

**Armed Civilian**. Sync to an AI unit. It will randomly draw a weapon on units of its rival side. Options: Attack Side, Random Patrol.

**Intel**. Sync to an object or unit. Players can interact with it and get the intel. Options: Shared With (All, Group, Side), Intel's Tittle, Intel's Text, Marker Name, Delete Object After.

**Vehicle Respawn**. Sync to vehicles to respawn them. Options: Abandon Distance, Wait Time, Respawns (empty = infinite), Explosion Effect, Disabled Vehicles, Code (runs on the respawned vehicle as `_this`).

**Restricted zones**. Sync to triggers to make restricted areas. Options: Restricted Sides, Time Before Punishment, Air Vehicles, Create markers.

**Special Forces**. Sync to player roles to give them the helmet camera. **User custom key** picks which "Use Action" key (1 to 20) opens it.

**Campaign init**. Starts an MCC campaign. See [Campaign](campaign.md).

**Mission Wizard** is described above.

**Survival: Spawn loot in buildings**. Spawns loot crates in buildings around the module, or in synced triggers. Options: Radius, Density (1 to 10), Markers.

### Settings modules (General)

These set MCC settings for the mission from a module, the older way. The MCC 5 Mission Settings window does the same and more.

- **(Settings) General**
- **(Settings) GAIA**
- **(Settings) Mechanics**
- **(Settings) Radio System**
- **(Settings) Medical System** (ignored when ACE is loaded)
- **(Settings) HUD**
- **(Settings) Role Selection**
- **(Settings) Mission Wizard**: define the classes the Mission Wizard uses for one list (HVT, radio tower, fuel tanks, armored vehicles, air vehicles, ammo cache, radar, intel objects, IED, anti-air, artillery), from synced vehicles or a class array.

### Ordnance

**Fire Mission** is described above.

### Utility

**Rearm Area**. Sync to objects. Those objects become sources where aircraft can change their pylon loadout. The pylon dialog also has rearm, refuel and repair buttons.

**Load to Cargo**. Loads objects into a vehicle's or container's cargo at mission start, using ACE cargo when it is loaded, else MCC logistics.
1. Sync the module to the vehicle (or container).
2. Place a Game Logic (the module description calls it the "unlock logic") and sync it to the module as well.
3. Sync the objects you want loaded to that Game Logic.

### Ships Static

**Spawn Ship**. Spawns a static ship that acts as a base. Options: Side, Respawn Position, Vehicles Purchasing (buy vehicles on the main deck), Rearm and Refuel (rearm, refuel and repair on the main deck), Ship type (the LHD needs CUP), Ship Name.

### RTS

**Vehicle Shop**. A kiosk where players buy vehicles. Sync one Notice Board object and one Invisible Helipad. Options: Vehicles Type (Vehicles, Armored, Helicopters, Fixed Wings, Ships, Units), Side Purchase.

**Weapon Shop**. Sync one ammo box and one other object or unit. The box contents become the items for sale. Options: Action Text, Prices, Persistent, Unique name.

**Create Building**. Builds an RTS building instantly. Options: Building, Side.

**Set Resources**. Sets a side's resources: Materials, Ammo, Fuel, Food, Meds.

**Add Credits To Players**. Sync to player units to give them credits at mission start. Option: Credits.

### Environment

**Ambient Birds**. Flocks of birds fly up when units get close to trees.

**Ambient Fire**. Fires start from explosives and fire fights and spread with the wind.

**Atmosphere**. Preset or custom atmosphere. Custom options include dust, snow, newspapers, mist, fog, leaves, wind sounds, color filter and grain filter.

**(ILS) Instrument Landing System**. Place one on the start of each runway, facing the runway direction. Options: Runway Name, Runway Length (100, 200 or 300 m), Allowed Sides, Arcade Mode (circles that guide the landing path).

**Music / Sound** is described above.

### PvP

**Capture Point**. A capture zone that gives resources over time. Sync a trigger for the capture area, and optionally a flagpole. Options: Type (Ammo, Supply, Fuel, Tickets), Score Reward, Flag, Respawn (owner side can respawn there), HUD, Designation.

**Advance And Secure init**. An Advance and Secure mission where objectives must be captured in order. Sync it to MCC capture zones or dummy sector modules in the order they should be captured. Options: side1, side2, Tickets Bleed (tickets lost every 5 seconds by the losing side).

**AAS Spawn AI**. Spawns AI that try to take enemy sectors in AAS. Options: Spawn Faction, Enemy Side, auto balance, Minimum number of AI per side, Spawn at Sectors, Search Vehicles Radius, Use MCC roles gear, Spawn Vehicles.

## Sample missions

MCC ships ready-made multiplayer missions. They show up in the multiplayer scenario list with names like **(MCC) Template**, **(MCC) Campaign** (and RHS, BAF, USMC, RU, GU, TK variants) and **(MCC) PvP**, on maps such as Altis, Tanoa, Malden, Stratis and others. Some need the map or the mods in their name to be loaded.
