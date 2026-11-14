# Zeus tools

In MCC 5, Zeus is how you use MCC in game. The old MCC main menu ("--= MCC =--" action) is gone. Its features are now Zeus modules.

## Who gets Zeus

With the setting **Zeus for MCC users** on (the default), every player who is allowed to use MCC gets Zeus with all MCC modules.

A player is allowed to use MCC when:
- there is no **Access Rights** module in the mission. Then everyone is allowed by default.
- or the mission has an **Access Rights** module, and the player's UID is listed in it, or his unit is synced to it, or he is a logged-in admin and the module allows admins.
- The host and the server are always allowed.

Details:
- The server checks every 10 seconds and gives Zeus to allowed players. This happens once the player's client is ready, so it can take a few seconds after you spawn.
- The first player gets MCC's own Zeus (so MCC save/load keeps working). Every other player gets his own Zeus with all addons.
- You keep your Zeus across respawn and reconnect.
- Players who already have a Zeus (for example from an Eden **Game Master** module) are left alone.
- If a player stops being allowed, or the setting is turned off, MCC takes back only the Zeus it gave.
- Every 20 seconds, objects that one MCC Zeus can edit are shared with all MCC Zeus players.

Turn it off with **Zeus for MCC Users** in MCC 5 Mission Settings, or the CBA setting **Zeus for MCC users**. See [Multiplayer and security](multiplayer-and-security.md).

## Opening Zeus

- **Ctrl+Delete**: the MCC keybind "Open Zeus (MCC)". You can change it in CBA keybinds (MCC section). If you have no Zeus, you get "MCC: you have no Zeus access" in chat.
- **Y**: the normal Arma Zeus key.

## The MCC 5 button

At the top of the Zeus screen there is a green **MCC 5** button.

1. Click **MCC 5**. A list opens with every MCC Zeus module, as "Category: Name".
2. Double-click a module.
3. It is placed at the center of the screen and opens its options, as if you had dragged it from the module tree.

Some modules act on one unit, group or object. For those, drag the module from **Modules > MCC** in the Zeus module tree and drop it **onto** the unit. The tables below say which ones.

Most modules open a dialog, do their job and then delete themselves.

## (MCC) General

| Module | How to use it |
|---|---|
| **Mission Wizard** | Generates a whole mission live. Place it where you want the mission, or pick "Anywhere on the map". See [Mission Wizard](mission-wizard.md#the-zeus-mission-wizard). |
| **Artillery Fire Mission** | Pick Shell type, Spread, Rounds and Delay. **Action**: "Fire now at this position", or "Add shells to a side's artillery console" (then pick the Console side: West, East or Resistance). |
| **Convoy - Spawn** | Spawns an MCC convoy of up to 5 vehicles at the module, facing the Heading you pick. Page 1: Faction and Heading. Page 2: the vehicles, an optional HVT and HVT vehicle. The HVT rides in the middle vehicle. |
| **Convoy - Drive To** | Place it where the convoy should go and confirm. The last spawned convoy fills its cargo seats and drives there in column. Add more Zeus waypoints to its group afterwards if you like. |
| **Air Drop (Crates/Vehicles)** | **Delivery**: Parachute from helicopter, Slingload (one object), or Parachute (no aircraft). **Cargo**: Supply crates or Vehicles. Pick Faction, Amount (1 to 6), Approach from, then the object. **Action**: Drop now, or add it to the faction side's commander console. Heavy vehicles may be too heavy to slingload. |
| **Reinforcements (Air/Motorized)** | Calls AI reinforcements to the module. **Type**: Paradrop, Drop-off or Fast-rope (small Spec-Ops, medium QRF, large Airborne), or Motorized (small, medium, large). Pick Faction, Coming from, Start distance (1000 to 3000 m) and Behavior after landing (Patrol around, Defend, Seek & destroy, or GAIA aggressive / defensive / fortify in a zone). Type an **MCC zone number** for the GAIA choices and for motorized. Motorized needs a road near the start point. |
| **Paradrop Units/Players** | **Who**: the group the module was placed on, All players, or all West, East or Independent players. **Method**: Parachute, Drop pods or H.A.L.O. **Coming from**: a heading. Drop it on a unit to drop his group. |
| **Delete / Area Brush** | Runs an action in a radius (10 to 2000 m) around the module. Actions: Delete All, Delete All Units, Delete Man, Delete Vehicles, Delete Tanks, Delete Air, Delete Ammoboxes, Delete Markers, Lights (Off), Lights (On), Lock Doors (All), Unlock Doors (All), Lock Doors (Random), Atmosphere (Warzone, Sandstorm, Blizzard, Snow, Heatwave, Clear), Remove N/V from units, Add Flashlights to all units, Delete Bodies. **Skip players** applies to N/V and flashlights. Players and their vehicles are never deleted. |
| **Jukebox** | **Type**: Music or Sound. **Action**: Play to everyone now, Stop music for everyone, or Play when an area trigger activates (set the trigger radius, activated by and condition). Then pick the track. |
| **Make Hostage** | Place a unit first, then drop this on it. The unit becomes a tied up hostage that players can untie, like the Mission Wizard HVT. |
| **Briefing** | Adds a diary entry under Briefing. Pick the Section (Situation, Enemy Forces, Friendly Forces, Mission, Special Tasks, Fire Support), For (Everyone, West, East, Independent, Civilian) and type the Text. Players who join later get it too. |
| **Broadcast Message** | Shows a text to every player. **Style**: Small (bottom) or Big (center). |
| **Save / Load Mission** | Opens the MCC save/load screen: save to profile slots or the clipboard, load, export to SQM or a composition, turn the persistent database on or clear it. |
| **Start Location / FOB** | Builds a start location at the module. Pick Side, Type (HQ start location or FOB respawn point), At mission start (Teleport, None, Paradrop, HALO), FOB can be destroyed, Show HQ icon (3D). |
| **Respawn / Mission Start** | **Action**: Teleport players to their start location now, Start mission (disable respawn), or Enable/Disable role selection. Only a logged-in admin or the host can change role selection. |
| **Arsenal (Zeus Player)** | Closes Zeus and opens the full Virtual Arsenal for your own unit. |
| **CAS for Commander Console** | Gives a side's commander console a CAS, AC-130 or UAV call. Pick Side, Aircraft and CAS type. AC-130 needs an armed VTOL or gunship; UAV needs a drone. To fire CAS right now, use **CAS - MCC** instead. |
| **GAIA: Control Group** | Drop it on an AI group, or select AI groups first and then place it. GAIA takes those groups over. See [GAIA: Control Group](#gaia-control-group). |
| **(Settings) MCC**, **(Settings) GAIA**, **(Settings) UI**, **(Settings) Mechanics**, **(Settings) Medic**, **(Settings) Role Selection** | Open a dialog to change those MCC settings during the mission. |
| **Survival: Spawn loot in buildings** | Spawns loot crates in buildings around the module. Options: Radius, Density (1 to 10), Markers. |

## (MCC) AI

| Module | How to use it |
|---|---|
| **Assign AI to zone** | Drop it on a unit or group. Pick the **Zone** from the list of existing MCC zones and the **Behavior**: aggressive, Defensive, Fortify, Default, BIS Defence, BIS Patrol. The group is put under GAIA in that zone. For real GAIA control pick one of the first three. |
| **Create Zone** | Makes a new MCC zone at the module, or moves an existing one. Pick the Zone ("New" or a number), size X, size Y (default 2000) and Angle. |
| **Respawn Group** | Drop it on a group or unit and set **Respawns** (default 10). The group respawns when all its units are dead. |
| **Ambient Units** | Ambient civilians around players. Options: Ambient Civilians, Ambient Driving Cars, Ambient Parked Cars, Parked cars always locked, Spawn distance around the players, Max units spawned around the player, Faction, Car's Faction, Civilians Reaction to players, Civilians Always Friendly. It runs on the server for each player and uses CPU. |
| **Ambient units(Restrict)** | Stops ambient AI spawning within a **Radius** of the module. |
| **Make Evac Vehicle** | Drop it on a vehicle. It becomes an MCC AI evac vehicle that players can command. Options: Side, Add gunners, Campaign Evac. |
| **Garrison** | Fills buildings around the module with units. Options: Faction, Radius, Population Intensity, Parked Cars, Cars Always Locked, One Group Per House. |
| **Set Unconscious** | Drop it on an AI man. Options: Disable Bleeding, Force Unconscious. Needs the MCC medical system. |
| **Undercover Agents** | Drop it on a player's unit. AI won't be hostile to him unless he gets too close, shows a weapon, or runs or crouches in their sight. He can hide handguns and small weapons. **Remove Weapons** takes his weapons away at the start. |

## (MCC) Ordnance

| Module | How to use it |
|---|---|
| **CAS - MCC** | Calls an MCC close air support run at the module. Pick the Plane and the CAS type. |
| **IED/Suicide Bomber** | Drop it on an object to make an IED: Explosion Size, Explosion Effect, Disarm Time, Can be jammed using ECM vehicle, Activation Type, Activation Distance, Activation Side. Drop it on a unit to make a suicide bomber: Explosion Size, Explosion Effect, Activation Side. |
| **Armed Civilian** | Drop it on a unit. Pick the Attack Side and Patrol. The unit will draw a weapon on that side. |

## (MCC) Utility

| Module | How to use it |
|---|---|
| **Add To Zeus** | Adds (or removes) all units and objects in a **Radius** (default 100 m) around the module to every Zeus. |
| **Rearm Area** | Drop it on an object (or place it on its own). That object becomes a place where aircraft can change their pylons, rearm, refuel and repair. |
| **Load to Cargo** | Drop it on an object, then click near the vehicle (within 15 m) to load the object into its cargo. Uses ACE cargo when ACE cargo is loaded, else MCC logistics. |
| **Intel** | Drop it on an object or unit. Options: Shared With, Title, Text, Marker Name, Delete Object After. Players can pick up the intel. |
| **Damage Part** | Drop it on a vehicle and pick which part to hit. |
| **Doors Lock/Unlock** | Locks or unlocks doors in a **Radius** around the module. |

## (MCC) Ships Static

| Module | How to use it |
|---|---|
| **Spawn Ship** | Spawns a static ship that acts as a base. Options: Ship Side, Respawn Position, Ship Type, Ship Name, Vehicles Purchasing, Rearm and Refuel. The LHD needs CUP. |
| **Open Menu** | Opens the ship spawn menu. |

## (MCC) RTS

| Module | How to use it |
|---|---|
| **Campaign init** | Starts an MCC campaign. Needs an MCC Start Location. See [Campaign](campaign.md). |
| **Set Resources** | Sets a side's Materials, Ammo, Fuel, Food and Meds. |
| **Add Credits/Valor Points** | Drop it on a player to give him **Credits** (default 5000). Place it on empty ground instead to give credits to every player of the **Player Side** you pick. |
| **Add Credits To Players** | The Eden version of the credits module, also usable from Zeus. |
| **Create Building** | Builds an RTS building right away. Pick Building and Side. |
| **Vehicle Shop** | Makes a vehicle kiosk. **Type**: Vehicles, Armored, Helicopters, Fixed Wing, Ships, Units. **Side Purchase**: buy from the whole side or only the faction. |
| **Weapon Shop** | Drop it on an ammo box. The box contents become the items for sale. Option: Prices. |

## (MCC) Environment

| Module | How to use it |
|---|---|
| **Ambient Birds** | Turns on random bird flocks near trees. |
| **Ambient Fire** | Turns on fires from explosives and fire fights that spread with the wind. |
| **Atmosphere** | Preset or custom atmosphere. Options include Random Weather, Dust, Snow, Papers, Mist, Fog, Leaves, Wind Sounds, Color, Film Grain, Overcast, Wind, Waves, Rain, Lightnings. |
| **Night Effects** | In a **Radius**: Lights Off, Remove Night Vision, Add Flashlights, Ignore Player's Units. |
| **War Zone Atmosphere** | Adds war zone effects in a **Radius** (default 1000 m). |

## (MCC) PvP

| Module | How to use it |
|---|---|
| **Capture Point** | Creates a capture point. Options: Type (Ammo, Supply, Fuel, Tickets), Radius (default 300), Score Reward (default 50), Flag, UI, Owner. |
| **AAS Spawn AI** | Spawns AI that fight for Advance and Secure sectors. Set the AAS mission up in Eden with **Advance And Secure init**. |

## GAIA: Control Group

This module gives any AI group to GAIA. It works for any side, also your own friendly AI.

1. Drop the module on an AI group. Or select one or more AI groups (or units) in Zeus, then place the module.
2. GAIA takes over at once. You get "GAIA now controls N group(s)".

What the group does:
- It picks the **nearest open task of its side** that has a position on the map.
- MCC makes sure an MCC zone covers that task (it creates a 200 m zone if none is within 400 m) and sends the group there as aggressive.
- When the task is done, the group moves on to the next nearest open task.
- With no tasks left, it patrols its last zone, or the nearest zone. If there is no zone at all, a 300 m zone is made around it.
- It uses vehicles like any GAIA group. See [GAIA AI](gaia.md#vehicles).

Limits:
- Groups led by a player can't be given to GAIA. A player can be a member, but not the leader. You get "groups led by a player can't be given to GAIA".
- Tasks are checked every 15 seconds.

## Editing objects in Zeus

When you double-click an object in Zeus, MCC shows its own edit window. Turn it off with the setting **Disable MCC Zeus Edit**. See [Settings](settings.md#mcc-general).
