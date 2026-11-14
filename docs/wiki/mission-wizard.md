# Mission Wizard

The Mission Wizard builds a complete mission for you: zones, objectives with tasks, enemy patrols and garrisons, vehicles, roadblocks, IEDs, civilians, a briefing and the weather.

There are three ways to use it:

| | Editor wizard | Zeus Mission Wizard | Mission Wizard Eden module |
|---|---|---|---|
| Where | Eden menu **MCC 5 > Generate Mission** | Zeus module **Mission Wizard** | Eden module **Mission Wizard**, placed in the editor |
| When it builds | In the editor, right away | In game, when you place it | In game, at mission start |
| Result | Normal editor objects you can see and edit before playing | Spawned live on the server | Spawned live on the server |
| Objectives | Up to 8, each slot chosen | 3 chosen, more from the Max Objectives setting | 3 chosen, up to 8 with the Objectives option |
| Factions | Picked from a list | Picked from a list | Typed as class names |
| Undo | Ctrl+Z, Clear, Regenerate | No | No |
| Different every time you play | No, it is fixed once generated | Yes | Yes |

The editor wizard is new in MCC 5. It is the main way to build a Mission Wizard mission.

## Editor wizard: step by step

1. Choose the area (see [Mission area](#mission-area)).
2. Open **MCC 5 > Mission Wizard...** and set the options. Click **OK**.
3. Click **MCC 5 > Generate Mission**.
4. Read the notification. It shows the operation name, the number of objectives, groups, AI units and entities, and anything that was skipped.
5. Look through the **MCC Mission Wizard** layer and change what you like.
6. Place your own playable units. The wizard does not place players.

All "Random" choices are rolled when you press Generate. The result is fixed after that. Generate again to get a different roll.

## Editor wizard options

### Mission area and size

| Option | What it does | Default |
|---|---|---|
| Mission Area | Where the mission is built. **Selected trigger/marker, else camera view**: the area of the one selected trigger or area marker; with nothing selected, the point the camera looks at. **Camera view (center of screen)**: always the screen center. **Whole map (random location)**: a random town or location on the map. | Selected trigger/marker, else camera view |
| Area Radius (m) | Radius of the area. 0 = automatic, worked out from players, objectives and mission size. Ignored when a selected trigger or marker gives the area. | 0 |
| Expected Players | Number of players the mission is built for. | 10 |
| Difficulty | Enemies per player: Easy (2), Medium (4), Hard (6). | Medium |
| Mission Size | Multiplier on enemy numbers and area size: Small (0.5), Normal (1), Large (1.75), Huge (2.5). | Normal |
| Max AI Units | Hard cap on the AI the wizard places (enemies, civilians, crews). | 200 |

How many enemies: Expected Players x Difficulty. If that is 10 or less, 20 is used. The result is multiplied by Mission Size. If the estimate would go over Max AI Units, the number is lowered to fit.

### Factions

| Option | What it does | Default |
|---|---|---|
| Enemy Faction | The faction players fight. The enemy side comes from the faction. Groups come from CfgGroups, single units and vehicles from CfgVehicles. | OPFOR `OPF_F` |
| Player Faction | The players' faction. It decides who gets the tasks and briefing, the hostage faction and who sets off IEDs. Must be on a different side from the enemy. | BLUFOR `BLU_F` |
| Civilian Faction | Civilians for CQB, hostages, suicide bombers and armed civilians. | `CIV_F` |

The faction lists show every faction that has at least one playable-scope soldier, as "SIDE - Name (class)". This includes factions from mods you have loaded. The list is built once per game session. If you load a new mod, restart the game to see its factions. A faction saved in the mission whose mod is no longer loaded shows as "(not loaded)".

### Objectives

| Option | What it does | Default |
|---|---|---|
| Number of Objectives | How many of the 8 objective slots are used. Slots set to None are skipped. | 3 |
| Objective 1 to Objective 8 | The type of each objective. **Random** picks a type not used yet in this mission. | Random |

Objective types:

| Type | What players do | Done when | Failed when |
|---|---|---|---|
| Secure HVT (hostage rescue) | Find a tied up hostage (a soldier of your faction or a civilian), untie him and take him home | He is alive, freed and more than 300 m from where he was held | He dies |
| Kill HVT | Kill or capture an enemy officer with 1 to 4 bodyguards. In the open he may walk a patrol. | He is dead, captive, handcuffed (ACE) or disarmed | - |
| Destroy Vehicle | Destroy a locked prototype tank or aircraft, in a sandbag nest or a hangar | It is destroyed | - |
| Destroy AA | Destroy a crewed anti-air vehicle | It is destroyed | - |
| Destroy Artillery | Destroy a crewed artillery piece | It is destroyed | - |
| Destroy Weapon Cache | Destroy an ammo cache | It is destroyed | - |
| Destroy Fuel Depot | Destroy a fuel tank | It is destroyed | - |
| Destroy Radar/Radio | Destroy a radar or a radio tower | It is destroyed | - |
| Acquire Intel | Pick up an intel item (files, photos, laptop, phone or suitcase) from a small table | The item is picked up | The item is destroyed |
| Download Intel | Hack a data terminal and download the data | The download is done | The terminal is destroyed |
| Capture Area | Clear an enemy camp, or a building in CQB | No enemy left within 100 m (50 m in CQB), checked after 30 s | - |
| Disarm IED | Find and disarm a large IED device (60 s disarm time) | Disarmed and not set off | The device is destroyed |

In open terrain, most objectives come with a camp or outpost composition. In CQB the objective goes in or next to a building.

The classes used for HVTs, tanks, aircraft, AA, artillery, caches, fuel tanks, radars, radio towers, intel items and compositions come from the **MCC Mission Wizard** settings. The wizard reads them in this order: the value in **MCC 5 Mission Settings** for this mission, then the CBA setting, then the preset for your loaded mods (RHS, CUP), then the built-in default. Only classes that exist in your game are used. Where possible, the enemy side's own vehicles are picked first. See [Settings](settings.md#mcc-mission-wizard).

### Enemy forces and threats

| Option | What it does | Default |
|---|---|---|
| CQB | Urban mission. Enemies garrison buildings and objectives go in buildings. **With civilians** also puts civilians in buildings. Choices: No, Yes - without civilians, Yes - with civilians, Random. | Random |
| Enemy Vehicles | Light and motorized enemy vehicles patrolling. No, Yes, Random. | Random |
| Enemy Armor | Armored and mechanized enemy groups. | Random |
| Stealth | Black ops. Enemies start relaxed (SAFE, slow). If Weather / Time changes the time, the mission is at night. | Random |
| IEDs | MCC IEDs on the roads in the area. | Random |
| Suicide Bombers | Civilian suicide bombers. | Random |
| Armed Civilians | Civilians that draw weapons on the players. | Random |
| Roadblocks | Manned checkpoints on roads leading into the area. | Random |
| Animals | Ambient animals (vanilla goat, poultry and sheep modules). | Random |
| Reinforcements | No, Aerial, Motorized, Random. Any choice other than No turns on GAIA AI reinforcement requests for this mission. Motorized also places a motorized QRF group outside the area. | Random |
| Enemy Artillery | No, Mortars, Self propelled artillery, Random. Places artillery in the area and turns on GAIA AI artillery requests. | Random |

### Weather, briefing and markers

| Option | What it does | Default |
|---|---|---|
| Weather / Time | **Don't change**, **Random**, **Sandstorm**, **Blizzard**, **Snow**. Changes the scenario date, time and weather in Attributes > Environment. Sandstorm, Blizzard and Snow also add the MCC weather effect at mission start. | Don't change |
| Intro | **Cinematic (music + title)**, **Pop-up title**, **None**. | Cinematic |
| Precise Objective Markers | On: the task points at the exact objective. Off: the task points somewhere within 300 m. | On |
| General Markers | Also place map markers for the objective zones, roadblocks and enemy positions. Players see them. | Off |
| Briefing | Add the generated briefing to the players' map (Diary). | On |
| Player Start | **None (place your own)** or **Respawn marker outside the area**. | None |
| End Mission When Done | When every objective is done, the scenario ends (END1). | Off |

## Mission area

With **Mission Area** set to the first option:

- **One trigger selected**: its area is used, including its rotation and shape. If the trigger is smaller than 20 m on a side, the radius is used instead.
- **One area marker selected** (rectangle or ellipse, at least 20 m): its area is used. Other markers only give the center.
- **Nothing selected**: the point at the center of the screen, with the radius.

**Whole map** picks a random named place that is not in the water. With CQB it only picks cities and villages. Without CQB it can also pick local names and hills.

The center of the area must be on land. Otherwise you get "the center of the mission area is in the water".

## What Generate builds

Everything goes into a root layer called **MCC Mission Wizard**. If one already exists, the new one is called "MCC Mission Wizard 2", and so on. It has five sub-layers:

| Layer | What's inside |
|---|---|
| Area and zones | The operation marker (red border, named "Operation NAME" or "Black Ops: NAME"), the main zone |
| Objectives | Objective objects and units, compositions, guards, objective zones |
| Enemy forces | Patrols, garrisons, vehicles, armor, artillery, static weapons, roadblocks, the QRF |
| Civilians, IEDs and animals | Civilians, IED objects and modules, suicide bombers, armed civilians, animal modules |
| Tasks, triggers and briefing | Task logics, task triggers, briefing, intro, weather effect, end trigger |

### Zones and GAIA

Each zone is built the way you would do it by hand: a **trigger** (the zone area) synced to a **Create Zone** module. There is one main zone for the whole area and one zone per objective.

Each enemy group is synced to an **Assign AI to zone** module of its zone. There is one such module per behaviour (aggressive, defensive, fortify). At mission start, GAIA takes the groups over in their zones.

The groups' own "MCC: GAIA Control" attributes are not used here, because the zone numbers only exist once the mission runs. To change a group's behaviour, sync its leader to another Assign AI to zone module of the same zone.

### Objectives

For each objective:
- The objective object or unit.
- Guards in nearby buildings (fortify). If there are no buildings, a defending group next to it.
- Infantry patrols in the objective zone, about 20% of the enemy force per objective.
- In CQB, more garrison units. With civilians, civilians in nearby buildings.
- With General Markers on, a marker on the objective zone.
- A task.

### Main area forces

- Infantry patrols (about 20% of the force, 10% in CQB).
- CQB garrisons in buildings.
- Light vehicles (up to 6) and armor (up to 4), on roads where possible.
- Artillery: 1 to 2 mortars, or 1 self propelled gun.
- Static weapons, in about 70% of missions (1 to 3).
- Roadblocks: up to 3, on roads entering the area. Each has barriers, a bunker, lights, 3 guards and a static weapon when the faction has one.
- IEDs: 2 to 8 on roadsides, hidden in junk or a parked civilian car, each with an MCC IED module.
- Suicide bombers and armed civilians: civilians with the matching MCC module synced.
- Animals.
- The motorized QRF, outside the area, when Reinforcements is Motorized.

With Stealth on, every group's leader gets an init line that sets the group to SAFE and slow speed.

### Tasks

Each task is made from editor objects you can read and change:
- A **Game Logic** whose init creates the task on the server for the player side.
- A **server-only trigger** that sets the task to Succeeded when its condition is true.
- For some objectives, a second trigger that sets it to Failed.

With more than one objective there is also a parent "operation" task. An end trigger waits until every task is done. Then it marks the operation done and plays the "mission accomplished" sound. With **End Mission When Done** on, it also ends the scenario.

### Briefing, intro, weather and support

- **Briefing**: a logic adds a diary entry for the player side, with the enemy, threats and the objective list with grid references.
- **Intro**: a logic shows the operation title (and plays music for Cinematic).
- **Weather / Time**: sets the scenario date, time, overcast, fog and rain. Sandstorm, Blizzard and Snow add a logic for the effect.
- **Reinforcements** or **Enemy Artillery** other than No set **GAIA: AI Support Requests** to On in MCC 5 Mission Settings, plus **AI Reinforcements** and/or **AI Artillery**.
- **Player Start**: a respawn marker for the player side called "MW Start", on flat land outside the area.

All entity names start with `mcc5mw_` plus a random number per generation, so a second generated mission never clashes with the first.

## Clear, Regenerate and Undo

- **Ctrl+Z** right after Generate undoes the whole generation in one step.
- **MCC 5 > Clear Generated Mission** deletes every entity in all layers whose name starts with "MCC Mission Wizard", and the layers. This is also one undo step.
- **MCC 5 > Regenerate Mission (clear + generate)** clears, then generates again.

Anything you put into an "MCC Mission Wizard" layer yourself is deleted by Clear too. Move things you want to keep to another layer first.

## Tips

- Start small. Use Normal size and 2 or 3 objectives, then grow.
- Watch **Max AI Units**. If the notification says "Unit cap reached", some groups were not placed. Raise the cap or lower players, difficulty or size.
- A trigger gives you the most control over the area shape.
- Generate several times until you like the layout. Then edit by hand.
- Check the task triggers in the **Tasks, triggers and briefing** layer if you want to change win or fail rules.
- The editor wizard settings are only used in the editor. The generated objects carry everything the mission needs.

### Error messages

| Message | What to do |
|---|---|
| every objective slot is None | Set at least one objective in MCC 5 > Mission Wizard... |
| enemy faction X has no soldiers | Pick another enemy faction |
| the enemy faction and the player faction are on the same side | Pick factions on different sides |
| the center of the mission area is in the water | Move the camera or select a trigger on land |
| no mission area found | Select a trigger or marker, or use Camera view |
| generation failed - see the RPT log | Check the RPT for lines starting with "MCC Mission Wizard" |

Parts that fail on their own (for example "roadblocks" or "objective 2 (Kill HVT): no position") are listed as **Skipped** in the notification. The rest is still built.

## The Zeus Mission Wizard

In game, a Zeus player can place the **Mission Wizard** Zeus module. It opens a dialog and then generates a mission live on the server.

Dialog options:

- **Area**: Around this position, or Anywhere on the map
- **Search radius (m)**: 500, 1000, 2000, 3000, 5000
- **Enemy faction**, **Players' faction** (default: your own faction), **Civilians faction**
- **Players**: 5 to 80
- **Difficulty**: Easy, Medium, Hard
- **Objective 1**, **Objective 2**, **Objective 3**
- **Terrain**: Open terrain, CQB, CQB with civilians, Random
- **Stealth**, **IEDs**, **Suicide bombers**, **Armed civilians**, **Roadblocks**, **Vehicles**, **Armor**, **Animals**: Random, Yes, No
- **Reinforcements**: No, Aerial, Motorized, Random
- **Artillery**: No, Mortars, Self propelled, Random
- **Weather**: Don't change, Random, Sandstorm, Blizzard, Snow
- **Intro**: Cinematic, Intro only, None
- **Precise objective markers**, **Debug markers**

Objectives beyond 3, the mission size and the unit cap come from the CBA settings **Max objectives**, **Mission size** and **Max spawned units** (or the matching MCC 5 Mission Settings).

Only one mission is generated at a time. If you try while one is generating you get "MCC is generating a mission, try again later". If you place it right at mission start you may see "MCC factions are not ready yet". Wait a moment and try again.

## The Mission Wizard Eden module (runtime)

The **Mission Wizard** Eden module (**MCC 5 > Place MCC Module > Mission Wizard (generated at mission start)**) generates a new random mission on the server each time the mission starts. Nothing is visible in the editor.

| Option | What it does | Default |
|---|---|---|
| Mission Area | **Area (synced trigger or module area)**: a random spot inside a synced trigger, or the module's own area (750 m by default). **Exact (around the module)**: objectives around the module. **Whole map**. | Area |
| Start Delay (s) | Seconds after mission start before generating | 5 |
| Mission ID | Optional. While the mission runs, `MCC_MWMissionRuning_<ID>` is true. Empty: edenMW_1, edenMW_2... | empty |
| Expected Players | Players the mission is built for | 10 |
| Difficulty | Easy, Medium, Hard | Medium |
| Objectives | Use MCC setting, or 1 to 8. Objectives above 3 are random. | Use MCC setting |
| Objective 1 / 2 / 3 | Objective types | Random, Random, None |
| Enemy Faction | CfgFactionClasses class name | `OPF_F` |
| Player Faction | CfgFactionClasses class name | `BLU_F` |
| Civilian Faction | CfgFactionClasses class name | `CIV_F` |
| CQB | No, Yes - without civilians, Yes - with civilians, Random | Random |
| Enemy Vehicles, Enemy Armor, Stealth, IEDs, Suicide Bombers, Armed Civilians, Roadblocks, Animals | No, Yes, Random | Random |
| Reinforcements | No, Aerial, Motorized, Random | Random |
| Enemy Artillery | No, Mortars, Self propelled artillery, Random | Random |
| Weather / Time | Don't change, Random, Sandstorm, Blizzard, Snow | Don't change |
| Intro | Cinematic, Pop-up, None | Cinematic |
| Precise Objective Markers | Exact spot or an area marker | On |
| General Markers | Show the general enemy area markers | Off |

Notes:
- No MCC zones are needed. The wizard makes its own.
- Several modules queue. Only one mission is generated at a time.
- The module stores `MCC_MWstate`: waiting, generating, running or failed. Use it, or `MCC_MWMissionRuning_<Mission ID>`, in triggers.
- Mission size and the unit cap come from the MCC Mission Wizard settings.
- If the enemy faction class does not exist, or has no infantry, nothing is generated and the RPT says why.

For a campaign of many missions in a row, see [Campaign](campaign.md).
