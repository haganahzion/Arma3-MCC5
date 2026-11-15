# Settings

Every MCC setting, grouped as in the game, with what it does and its default.

## Where to change settings

You can change settings in three places, and they all change the same values.

### 1. CBA Addon Options

In the main menu or the pause menu: **Options > Addon Options**. Pick an **MCC** category, for example "MCC GAIA". CBA lets you set values for the server, the mission or the client. These are the "addon settings".

### 2. MCC 5 Mission Settings (Eden)

In the editor: **MCC 5 > MCC 5 Mission Settings...**. This saves settings **into the mission**.

- Almost every value starts at **Use addon setting** (a drop-down) or an **empty box**. That means the CBA addon setting is used.
- Only what you change is saved.
- Number boxes accept the same range as the CBA slider.
- Class list boxes take the same text as the CBA box, for example `["B_officer_F","O_officer_F"]`.
- At mission start the server applies your values through CBA, on every machine. The RPT shows `MCC: Eden attribute <name> -> CBA setting <variable> = <value>`.
- A setting forced by a mission `cba_settings.sqf` or by the server admin with "overwrite mission" priority still wins. The RPT then says the Eden value was not applied.

The categories in this window use the CBA names, for example "MCC GAIA - Support Requests" is CBA category "MCC GAIA", subcategory "Support Requests".

### 3. Settings modules and description.ext

- The Eden settings modules ((Settings) General, GAIA, Mechanics, Radio System, Medical System, HUD, Role Selection, Mission Wizard) and the Zeus settings modules set some of the same values. See [Eden editor](eden-editor.md#settings-modules-general) and [Zeus tools](zeus-tools.md).
- Missions that don't use Eden attributes can put a value in `description.ext`, for example `MCC_logisticsMode = 2;` or `MCC_networkSecurity = 1;`.

## MCC 5 (main category)

These are the first category in MCC 5 Mission Settings. The Eden names are a little different from the CBA names.

| Eden name | CBA setting (category) | What it does | Default |
|---|---|---|---|
| Limited Logistics | Limited Logistics (MCC Logistics) | Off: unlimited supply, as before. Fuel only: fuel trucks, fuel crates and vehicle service fuel are finite. Full: fuel, ammo and repair are finite. Supply trucks refill at their side's base from side resources. See [Limited logistics](logistics.md). | Off |
| Mission Wizard: Max Objectives | Max objectives (MCC Mission Wizard - Mission size) | Objectives per Zeus or runtime Mission Wizard mission, 1 to 8. The dialog sets the first 3, the rest are random types. | 3 |
| Mission Wizard: Mission Size | Mission size (MCC Mission Wizard - Mission size) | Multiplier on the number of enemies: Small 0.5, Normal 1, Large 1.75, Huge 2.5. | Normal |
| Mission Wizard: Max Spawned Units | Max spawned units (MCC Mission Wizard - Mission size) | Hard cap on the units one Mission Wizard mission or campaign AO may spawn. CBA range 30 to 600; Eden offers 50 to 600. | 200 |
| Campaign: Simultaneous AOs | Campaign simultaneous AOs (MCC Mission Wizard - Campaign) | How many campaign areas of operation can be active at once, 1 to 3. | 1 |
| Campaign: AO Size | Campaign AO size (MCC Mission Wizard - Campaign) | Objective radius in meters of every campaign AO. CBA range 150 to 1500. | 300 |
| Campaign: Ambient Groups Cap | Campaign ambient groups cap (MCC Mission Wizard - Campaign) | Max ambient enemy groups kept around players (2 per player up to this). Range 0 to 60. | 18 |
| GAIA: AI Support Requests | AI Support Requests (MCC GAIA - Support Requests) | AI commanders call artillery, CAS and reinforcements on strong contacts. | On |
| GAIA: AI Artillery | Artillery Support (MCC GAIA - Support Requests) | GAIA mortar and artillery groups answer support requests. | On |
| GAIA: AI Close Air Support | CAS Support (MCC GAIA - Support Requests) | GAIA calls an off-map CAS run. | On |
| GAIA: AI Reinforcements | Reinforcements (MCC GAIA - Support Requests) | GAIA calls motorized reinforcements when heavily outnumbered or when nothing else is available. | On |
| GAIA: Coordinated Attacks | Coordinated Attacks (MCC GAIA - Coordination) | Groups on the same contact get roles: main attack, flank, support-by-fire, reserve. Off: every group attacks on its own. | On |
| GAIA: Headless Client Balancing | Headless Client Balancing (MCC GAIA - Headless Clients) | GAIA groups spawned during the mission are moved to connected headless clients, in turn. | On |
| Zeus for MCC Users | Zeus for MCC users (MCC General - Zeus) | Every player allowed to use MCC gets Zeus with all MCC modules. Others get nothing. | On |
| Network Security | (Eden only, no CBA setting) | Normal: MCC accepts network requests from any player. Strict: in multiplayer, MCC ignores requests from players not allowed to use MCC. No effect in single player. See [Multiplayer and security](multiplayer-and-security.md). | Normal |

## CBA settings that are not in the Eden window

| Setting (category) | What it does | Default |
|---|---|---|
| Gain XP automatically (MCC Role Selection - Experience Points) | Players gain XP by killing and doing their role's actions | On |
| Flag west (MCC Role Selection - Flags) | Default flag for the west side | `\a3\Data_f\Flags\flag_nato_co.paa` |
| Flag east (MCC Role Selection - Flags) | Default flag for the east side | `\a3\Data_f\Flags\flag_CSAT_co.paa` |
| Flag resistance (MCC Role Selection - Flags) | Default flag for the resistance side | `\a3\Data_f\Flags\flag_AAF_co.paa` |

## All other settings

The rest of the MCC settings, in the order of the MCC 5 Mission Settings window. The text comes from the setting's own description. "CBA variable" is the name to use in `cba_settings.sqf` or `description.ext`.

Long class list defaults are not repeated here. Hover over the setting in Eden or CBA to see the full default.

### MCC Mission Wizard

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| HVT (man) | Unit that will be used as high value target | `["B_officer_F","O_officer_F","I_officer_F","C_Nikos"]` | `MCC_MWHVT` |
| Radio Tower (Land) | Object that will be used in destroy radio missions | `["Land_TTowerBig_2_F"]` | `MCC_MWRadio` |
| Fuel Tanks (Land) | Object that will be used in destroy fuel tanks missions | `["Land_dp_smallTank_F","Land_ReservoirTank_V1_F","Land_dp_bigTank_F"]` | `MCC_MWFuelTanks` |
| Radar (Land) | Object that will be used in destroy radar missions | `["Land_Radar_Small_F","B_Radar_System_01_F","O_Radar_System_02_F"]` | `MCC_MWradar` |
| Armored Vehicles (Vehicle) | Vehicle that will be used in destroy armored vehicle missions | `["B_MBT_01_cannon_F","O_MBT_02_cannon_F"]` | `MCC_MWTanks` |
| Air Vehicles (Vehicle) | Vehicle that will be used in destroy air vehicle missions | a class list (see the tooltip) | `MCC_MWAir` |
| Anti-Air (Vehicle) | Vehicle that will be used in destroy anti-air missions | `["B_APC_Tracked_01_AA_F","O_APC_Tracked_02_AA_F","I_APC_Wheeled_03_cannon_F"]` | `MCC_MWAA` |
| Artillery (Vehicle) | Vehicle that will be used in destroy artillery missions | `["B_MBT_01_arty_F","B_MBT_01_mlrs_F","O_MBT_02_arty_F","O_Mortar_01_F","I_Mortar_01_F"]` | `MCC_MWArtillery` |
| Ammo cache (Box) | Ammo box that will be used in destroy cache vehicle missions | `["Box_East_AmmoVeh_F","Land_Pallet_MilBoxes_F"]` | `MCC_MWcache` |
| Intel Objects (Small Items) | Object that will be used in find intel missions | a class list (see the tooltip) | `MCC_MWIntelObjects` |
| IED (Small Items) | Object that will be used in disarm IED missions | a class list (see the tooltip) | `MCC_MWIED` |
| Compositions civilians | Will be used as compositions for civilians must be defined in ("CfgGroups" >> "Empty") | a class list (see the tooltip) | `MCC_MWSITES` |
| Compositions military | Will be used as compositions for military must be defined in ("CfgGroups" >> "Empty") | a class list (see the tooltip) | `MCC_MWSITESmilitary` |

### MCC Mission Wizard - Mission size

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Max players | Top of the players slider in the Mission Wizard dialog. Range 10 to 150. | 40 | `MCC_MWmaxPlayersSetting` |

### MCC Role Selection

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Enable Role Selection | Enable role selection menu allows player to gain XP and unlock new weapons and items | Off | `CP_activated` |
| Unlock All Weapons | Unlock All Weapons ignoring the player level | Off | `MCC_rsAllWeapons` |
| Role Change | Players can change roles in HQ | On | `MCC_allowChangingKits` |
| Restrict Weapons | Players using weapons outside of their role (eg rifleman using sniper rifle) will get penalty by increased weapon sway | Off | `MCC_rsEnableRoleWeapons` |
| Restrict Vehicles | Players can't use vehicles outside of their role (eg rifleman driving a tank) except light vehicles | Off | `MCC_rsEnableDriversPilots` |
| Group Callsigns | Default groups callsigns | `["Alpha","Bravo","Charlie","Delta"]` | `CP_defaultGroups` |

### MCC Role Selection - Experience Points

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Gain XP notifications | Players will get notifications when gaining XP | On | `CP_expNotifications` |
| Base Xp | Base Xp needed for each level, Exp will raise by 5% each level. Range 1000 to 10000. | 4000 | `CP_XPperLevel` |

### MCC Classes - IED

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| IEDs small | Array first element is display name, second is the object class | a class list (see the tooltip) | `MCC_ied_small` |
| IEDs medium | Array first element is display name, second is the object class | a class list (see the tooltip) | `MCC_ied_medium` |
| IEDs wrecks | Array first element is display name, second is the object class | a class list (see the tooltip) | `MCC_ied_wrecks` |
| IEDs hidden | Array first element is display name, second is the object class (hidden IED charges) | a class list (see the tooltip) | `MCC_ied_hidden` |

### MCC Classes - Convoy

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| HVT | High value target, array first element is display name, second is the unit class. Left at default: RHS/CUP officers are added when those mods are loaded. Add "auto" to keep them in a custom list. | a class list (see the tooltip) | `MCC_convoyHVT` |
| HVT Vehicle | High value target, array first element is display name, second is the vehicle class. Left at default: RHS/CUP cars are added when those mods are loaded. Add "auto" to keep them in a custom list. | a class list (see the tooltip) | `MCC_convoyHVTcar` |

### MCC Commander Console

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Commander Console Enabled | Player can become a side commander from the MCC respawn screen | On | `MCC_allowConsole` |
| RTS | Enable Real Time Strategy mod from the commander console, build, expand and conquer | On | `MCC_allowRTS` |

### MCC Commander Console - Air support

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Purchase air drop | Commander can trade resources for air Drops - works only on mission restart | On | `MCC_defaultSupplyDropsEnabled` |
| AC-130 uptime | How long in seconds can an AC-130 stay in the air before he is RTB. Range 0 to 1200. | 300 | `MCC_ConsoleACTime` |
| Purchase CAS | Commander can trade resources for close air support - works only on mission restart | On | `MCC_defaultCASEnabled` |

### MCC Commander Console - Tracking

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Show units without GPS | Blueforce tracker show units without GPS on commander console | On | `MCC_ConsoleOnlyShowUnitsWithGPS` |
| Show friendly WP | Show friendly group way points on console | On | `MCC_ConsolePlayersCanSeeWPonMap` |
| Command AI | Commander can issue order to AI groups given to him by mission maker | On | `MCC_ConsoleCanCommandAI` |

### MCC Commander Console - Live Feed

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Restrict live feed | Restrict live feed to vehicles and units wearing one of the specific helmets only | Off | `MCC_ConsoleLiveFeedHelmetsOnly` |
| Live feed helmets | Restrict live feed to vehicles and units wearing one of the specific helmets only | a class list (see the tooltip) | `MCC_ConsoleLiveFeedHelmets` |

### MCC GAIA - AI Skill

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| AI Skill(overall) | General skill of AI units. Range 1 to 10. | 5 | `MCC_AI_Skill_Index` |
| AI Skill(Aim) | Aiming skill of AI units. Range 1 to 10. | 5 | `MCC_AI_AimIndex` |
| AI Skill(Spot) | Spotting skill of AI units. Range 1 to 10. | 5 | `MCC_AI_SpotIndex` |
| AI Skill(Command) | Command skill of AI units. Range 1 to 10. | 5 | `MCC_AI_CommandIndex` |

### MCC GAIA - AI Smoke & Flares

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| AI Use Smoke Grenades & flares | AI use smoke grenades and flares. | Off | `MCC_GAIA_AMBIANT` |
| Smoke/flares Chance | How often AI use smoke and flares. Range 20 to 80. | 50 | `MCC_GAIA_AMBIANT_CHANCE` |

### MCC GAIA

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Cache Distance | How far any player should be from a unit before it cached. Range 1000 to 10000. | 3000 | `GAIA_CACHE_STAGE_1` |
| GAIA Controls All | If set to everyone GAIA will give order to all units available even players | Off | `MCC_GAIA_ATTACKS_FOR_NONGAIA` |
| Target Detection Range | How far around each group leader GAIA looks for enemy targets (nearTargets). Range 300 to 3000. | 1000 | `MCC_GAIA_TARGET_RANGE` |
| GAIA Debug | Write GAIA cycle timings (per phase, groups processed) to the server RPT and enable the GAIA debug markers | Off | `MCC_GAIA_debug` |

### MCC GAIA - Vehicles

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Smart Vehicle Use | AI groups borrow empty friendly vehicles for long trips, get out at the objective (leader included) and get back in after a fight | On | `MCC_GAIA_vehiclesEnabled` |
| Find Ride Distance | Infantry going further than this (meters) look for an empty vehicle. Range 200 to 5000. | 500 | `MCC_GAIA_rideDistance` |
| Dismount Distance | Groups get out of their vehicle this far (meters) from the objective. Range 100 to 1500. | 400 | `MCC_GAIA_dismountDistance` |
| Vehicle Search Radius | How far (meters) from the leader a group looks for an empty vehicle. Range 50 to 1000. | 300 | `MCC_GAIA_rideSearchRadius` |
| Unstick Vehicles | Tanks and armed cars that have not moved for about a minute re-plan their route, back up, then get a new order (off when HBQ Driving AI handles it) | On | `MCC_GAIA_UNSTICK` |

### MCC GAIA - AI Mod Compatibility

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| LAMBS Danger Compatibility | Auto: if LAMBS Danger is loaded GAIA leaves contact tactics to LAMBS and does not override group behaviour in combat | Auto | `MCC_GAIA_compatLAMBS` |
| HBQ Driving AI Compatibility | Auto: if HBQ Advanced Driving AI is loaded GAIA leaves unstuck and route recovery to HBQ | Auto | `MCC_GAIA_compatHBQ` |

### MCC GAIA - Support Requests

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Threat Threshold | Minimum threat points of an enemy contact before support is called (a rifleman is 4 points, 6 inside a GAIA zone; vehicles more). Range 10 to 300. | 40 | `MCC_GAIA_SUPPORT_THRESHOLD` |
| Contact Range | Support is only called when a GAIA group in combat is this close (meters) to the enemy contact. Range 200 to 2000. | 600 | `MCC_GAIA_SUPPORT_CONTACT_RANGE` |
| Contact Cooldown | Seconds before the same enemy contact can get another support response. Range 30 to 1800. | 180 | `MCC_GAIA_SUPPORT_CA_COOLDOWN` |
| Danger Close Distance | No artillery, mortar or CAS when friendly troops are this close (meters) to the target. Range 50 to 600. | 200 | `MCC_GAIA_SUPPORT_DANGERCLOSE` |
| Artillery Cooldown | Seconds between two artillery support calls of one side. Range 0 to 1200. | 60 | `MCC_GAIA_SUPPORT_ARTY_COOLDOWN` |
| Artillery Budget | Artillery support calls per side for the whole mission. Range 0 to 100. | 20 | `MCC_GAIA_SUPPORT_ARTY_BUDGET` |
| NOFOLLOW Artillery Fires Outside Zone | Mortar / artillery groups with a NOFOLLOW zone may fire at targets outside their own zone | Off | `MCC_GAIA_ARTY_OUTSIDE_ZONE` |
| CAS Needs Own Aircraft | CAS is only called when the side has an armed aircraft of its own in the mission | Off | `MCC_GAIA_SUPPORT_CAS_OWNAIR` |
| CAS Cooldown | Seconds between two CAS calls of one side. Range 60 to 3600. | 300 | `MCC_GAIA_SUPPORT_CAS_COOLDOWN` |
| CAS Budget | CAS runs per side for the whole mission. Range 0 to 20. | 2 | `MCC_GAIA_SUPPORT_CAS_BUDGET` |
| CAS Plane BLUFOR | Plane class for BLUFOR CAS runs (empty: vanilla default) | (empty) | `MCC_GAIA_SUPPORT_CAS_PLANE_WEST` |
| CAS Plane OPFOR | Plane class for OPFOR CAS runs (empty: vanilla default) | (empty) | `MCC_GAIA_SUPPORT_CAS_PLANE_EAST` |
| CAS Plane Independent | Plane class for Independent CAS runs (empty: vanilla default) | (empty) | `MCC_GAIA_SUPPORT_CAS_PLANE_INDEP` |
| Reinforcement Cooldown | Seconds between two reinforcement calls of one side. Range 60 to 3600. | 600 | `MCC_GAIA_SUPPORT_REINF_COOLDOWN` |
| Reinforcement Budget | Reinforcement calls per side for the whole mission. Range 0 to 20. | 2 | `MCC_GAIA_SUPPORT_REINF_BUDGET` |
| Reinforcement Size | Number of vehicles: small 2, medium 3, large 4 | Small | `MCC_GAIA_SUPPORT_REINF_SIZE` |

### MCC General

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Teleport to Team | Players can teleport to squad leader | JIP Only | `MCC_t2tIndex` |
| MCC Chat | Will show MCC chat | On | `MCC_MessagesIndex` |
| Sync Jip | Jip players will sync with server | On | `MCC_syncOn` |
| Time Multiplier | Speed of in-game time (set on the server). Range 0.5 to 24. | 1 | `MCC_timeMultiplier_settings` |
| Disable MCC Zeus Edit | Disable the custom MCC interface when editing an object in Zeus | Off | `MCC_CuratorEditDisabled` |
| Logistics System | Allows player to load equipment, vehicles, resources and items into vehicles | On | `MCC_allowlogistics` |
| Armed Civilians Weapons | Armed Civilians default Weapons | a class list (see the tooltip) | `MCC_armedCivilansWeapons` |

### MCC General - Ambient Birds

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Ambient Birds | Random flocks of birds will take flight when units are near | On | `MCC_ambientBirdsSettingIndex` |

### MCC General - Ambient Fire

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Ambient Fire | Explosive may cause sporadic fires that will spread with the wind need a restart to disable | On | `MCC_ambientFireSettingIndex` |
| Vehicle fire chance | Chance a destroyed vehicle will start a fire. Range 0 to 100. | 50 | `MCC_fnc_ambientFireInitVehicleBurnChance` |
| Explosives rounds fire chance | Chance an explosive ammunition start a new fire also effect the chance of non explosive ammunition to start a fire. Range 0 to 100. | 3 | `MCC_fnc_ambientFireInitExplosivesBurnChance` |
| Burning crew escape chance | Chance of each crew member in a destroyed vehicle's to catch on fire running out of the vehicle. Range 0 to 100. | 50 | `MCC_fnc_ambientFireInitCrewBurnChance` |
| Burning crew new fire chance | Chance a burned crew member will start a new fire. Range 0 to 100. | 10 | `MCC_fnc_ambientFireInitCrewNewFireChance` |

### MCC General - Artillery

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Artillery Computer | Enable/disable BI artillery computer | On | `MCC_artilleryComputerIndex` |
| Artillery spread | First element display name second spread in meters | `[["On-target",0], ["Precise",100], ["Tight",200], ["Wide",400]]` | `MCC_artillerySpreadArray` |

### MCC General - Squad Leader PDA

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| SQL PDA Enabled | Any team leader will have access to a PDA that have a Blueforce tracker | On | `MCC_allowsqlPDA` |

### MCC Logistics - Limited Logistics

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Supply Truck Capacity | Resource units an ammo/repair/fuel vehicle carries of each supply type (MCC crates: 200, big crates: 800). Range 100 to 5000. | 1000 | `MCC_logisticsTruckCapacity` |
| Base Refill Rate | Resource units a supply vehicle takes from the side resources every 5 seconds while parked at its base. Range 10 to 1000. | 100 | `MCC_logisticsRefillRate` |
| Base Radius | Distance in meters from the side start location (or an RTS base building) where supply vehicles refill. Range 25 to 500. | 75 | `MCC_logisticsBaseRadius` |
| Supply Cost Factor | Multiplies the resource cost of rearming, repairing and refuelling a vehicle (from supply points and from vehicle service). Range 0.1 to 5. | 1 | `MCC_logisticsCostFactor` |
| Fuel Consumption | Vehicle fuel consumption multiplier while Limited Logistics is on (1 = normal). Range 1 to 10. | 1 | `MCC_logisticsFuelConsumption` |

### MCC Mechanics

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Weapons Binds | Bind weapon to the 1 - 4 keys | Off | `MCC_quickWeaponChange` |
| One Man Tanks | Player can operate a tank by his own driving and shooting | Off | `MCC_arcadeTanks` |
| Disable Fatigue | Turn off the players' fatigue system | Off | `MCC_disableFatigue` |
| 3D Tagging | Squad leader enemy tags and markers will be visible on HUD | On | `MCC_allow3DSpotting` |

### MCC Mechanics - Cover

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Cover System | Players will automatically pop up or side out of cover while aiming down sights | Off | `MCC_cover` |
| Cover System UI | Show icons on HUD when in cover | Off | `MCC_coverUI` |
| Vault System | Allow players to vault over walls and obstacles - see CBA keybinds | Off | `MCC_coverVault` |

### MCC Mechanics - Interaction

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Interaction System | Players can interact with object and themselves - see CBA keybinds | On | `MCC_interaction` |
| Interaction System UI | Show icons on HUD when interaction is available | On | `MCC_ingameUI` |

### MCC Mechanics - Survival

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Survival Mode | Players can loot map objects and need to drink and eat | Disabled | `MCC_surviveModAllowSearch_index` |
| Load Player Position | Load last known player position on mission start | Off | `MCC_surviveModPlayerPos` |
| Load Player Gear | Load last known player gear on mission start | Off | `MCC_surviveModPlayerGear` |
| Load Player Stats | Load last known player stats on mission start | Off | `MCC_surviveModPlayerStats` |

### MCC Mechanics - Ammo Type

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Breaching Ammo | Magazine classes. Shooting this ammo from less than 10 meters will unlock doors. "auto" = every shotgun slug magazine found in the loaded mods | `["auto"]` | `MCC_breacingAmmo` |
| Non Lethal Ammo | Magazine classes. Shooting this ammo at a unit closer than 30 meters stuns it instead of killing it. "auto" = every shotgun slug magazine found in the loaded mods | `["auto"]` | `MCC_nonLeathalAmmo` |

### MCC Medical System

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Enable MCC Medic System | Turns on the MCC medical system. Requires mission restart! | Off | `MCC_medicSystemEnabled` |
| Complex System | Requires mission restart! Complex system replace all the default ArmA items with advanced items such as bandages, epipens exc | Off | `MCC_medicComplex` |
| Medic Only Heal | Only medics can use FAK to heal others can only use bandages to stop bleeding | Off | `MCC_medicOnlyMedicHeals` |
| Medic HUD | Show wounded units as a cross on HUD | Off | `MCC_medicShowWounded` |
| Bleeding | Players and AI will suffer from bleeding effects and will need to stop bleeding or die over time | Off | `MCC_medicBleedingEnabled` |
| Bleeding Time | How long in seconds it will take for unconscious unit to die from bleeding. Range 30 to 1200. | 300 | `MCC_medicBleedingTime` |
| Bulletproof Vests Effectiveness | Players can take more damage than usual. Range 0 to 5. | 2 | `MCC_medicDamageCoef_index` |
| Punish Team Kill | Player who died by friendly fire can forgive or punish the killer | Off | `MCC_medicPunishTK` |

### MCC Radio

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Enable MCC Radio System | Radio system uses default ArmA Voice Over IP | Off | `MCC_VonRadio` |

### MCC Radio - Distance

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Global Radio Distance | Radio range in meters. Range 1000 to 5000. | 2000 | `MCC_vonRadioDistanceGlobal` |
| Side Radio Distance | Radio range in meters. Range 3000 to 7000. | 5000 | `MCC_vonRadioDistanceSide` |
| Commander Radio Distance | Radio range in meters. Range 8000 to 20000. | 12000 | `MCC_vonRadioDistanceCommander` |
| Group Radio Distance | Radio range in meters. Range 300 to 5000. | 2500 | `MCC_vonRadioDistanceGroup` |

### MCC Radio - Anti-Abuse

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Kick Hot Mic | Will kick player with hot mic after some time | Off | `MCC_vonRadioKickIdle` |
| Time Before Kick | Seconds of hot mic before the kick. Range 5 to 60. | 30 | `MCC_vonRadioKickIdleTime` |

### MCC Respawn - Respawn

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Save Gear | Players will respawn with the gear they had when they died | Off | `MCC_saveGearIndex` |
| Delete players bodies | Automatically delete players bodies | Off | `MCC_deletePlayersBody` |
| Respawn Menu | Custom MCC respawn menu | On | `MCC_openRespawnMenu` |
| Respawn Cinematic | Shows a cinematic when a player spawns. | On | `MCC_respawnCinematic` |
| Respawn On Leader | Allow player to select to respawn on team leader from the MCC respawn menu | Off | `MCC_respawnOnGroupLeader` |

### MCC User Interface

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| View Distance | Sets the view distance. Range 200 to 15000. | 5000 | `MCC_Settings_ViewDistance` |
| Grass Detail | Sets the terrain grid (grass) detail. Range 1 to 50. | 10 | `MCC_Settings_grassDetail` |
| Action Menu | Show MCC action in mouse wheel actions | On | `MCC_showActionKey` |
| Allow 3rd Person | Force first person camera | Always | `MCC_Settings_forceCamera` |
| PvP Interface | Shows the opposing sides and the tickets left. | Off | `MCC_UIModuleTickets` |

### MCC User Interface - Compass

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Interactive Compass HUD | Compass on the HUD. Options: Only Compass, Show group's units, Disabled. | Disabled | `MCC_Settings_compassEnabled` |

### MCC User Interface - Map

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Group Markers | Group markers show on map | Off | `MCC_groupMarkers` |
| Unit Markers | Unit markers show on map | Off | `MCC_indevidualMarkers` |

### MCC User Interface - Name Tags

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Name Tags | Show nearby units names | Off | `MCC_nameTags` |
| Name Tags only when pointing | Show nearby units names only when pointing | Off | `MCC_NameTags_direct` |

### MCC User Interface - suppression

| Setting | What it does | Default | CBA variable |
|---|---|---|---|
| Suppression Effects | Client side suppression effects. | Off | `MCC_suppressionOn` |
| Hit direction Effects | Shows the direction of enemy fire. Options: Realistic, Arcade, Off. | Realistic | `MCC_hitRadar` |

## Keybinds

MCC keybinds are CBA keybinds. Change them in **Options > Controls > Configure Addons**, section **MCC**.

| Action | Default key | Notes |
|---|---|---|
| Open Zeus (MCC) | Ctrl+Delete | Only when you have Zeus |
| Commander Console | Ctrl+End | You must be your side's commander |
| Teleport to Team | Alt+T | When **Teleport to Team** allows it |
| Squad Management | P | |
| Squad Leader PDA | Ctrl+Page Down | You must be a team leader |
| Interaction | Left Windows key | With **Interaction System** on |
| Interaction Self | Ctrl+Left Windows key | With **Interaction System** on |
| Climb Over | Alt+V | With **Vault System** on, at an obstacle |
| Switch Weapons 1: Primary/handgun | Shift+1 | With **Weapons Binds** on |
| Switch Weapons 2: Launcher | Shift+2 | With **Weapons Binds** on |
| Switch Weapons 3: Grenades | Shift+3 | With **Weapons Binds** on |
| Switch Weapons 4: Utility | Shift+4 | With **Weapons Binds** on |

Without ACE, MCC shows "Assing MCC Interaction Key !!!" on screen until the Interaction key has a binding.

## Notes

- **Ambient Fire**: the description says it needs a restart to disable.
- **Purchase air drop** and **Purchase CAS**: work only after a mission restart.
- **Enable MCC Medic System** and **Complex System**: need a mission restart. With ACE loaded, the MCC medical settings module is ignored. See [Mod support](mod-support.md).
- **Breaching Ammo** and **Non Lethal Ammo**: the default `["auto"]` means every shotgun slug magazine found in your loaded mods. Add your own classes next to "auto" to keep both.
- **Convoy HVT** lists: left at default, RHS and CUP entries are added when those mods are loaded. Add "auto" to a custom list to keep them.
- To see MCC timings and errors, turn on **GAIA Debug**. See [Troubleshooting](troubleshooting.md).
