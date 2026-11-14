# Changelog

A short summary of what changed in MCC 5. The full list is in `MCC_changelog.txt` (sections R34 and R35) in the mod.


## v5.0.2

- Fixed GAIA Control Group sending groups to the map corner when a task's destination was an object or missing.
- AI groups that follow tasks now also see the editor Mission Wizard's tasks.
- Groups the editor Mission Wizard puts in zones are registered with GAIA straight away and can be cached.
- The Zeus MCC 5 button makes placed modules editable on the server.
- "Disable Fatigue" now works the right way round; Group Radio Distance goes up to 5000 m.
- Fixed setting labels (View Distance, Grass Detail, IEDs hidden) and the "Ambient Units" module name.
- The cache objective is now spelled "Destroy Weapon Cache".
- The mod's Website button and in-game help link to this wiki.

## v5.0.1

The full MCC 5 overhaul: a new Eden and Zeus interface, a rewritten GAIA AI commander, an in-editor Mission Wizard, ACE3/RHS/CUP support and optional limited logistics.

The release notes say this build has not been tested in game yet. Please report problems with your RPT log and a screenshot. See [Troubleshooting](troubleshooting.md).

Also new: MCC 5 artwork (logo and loading screen).

## R35: the MCC 5 roadmap

### New interface
- The old MCC main menu ("--= MCC =--" action / Ctrl+Del) is gone. MCC users get Zeus automatically (setting "Zeus for MCC Users"). Limit it with the Access Rights module.
- New Zeus modules: Mission Wizard, Artillery, Convoy Spawn / Drive To, Air Drop, CAS Console, Reinforcements, Paradrop, Delete Brush, Jukebox, Hostage, Briefing, Broadcast, Save/Load, Start Location, Mission Start, Arsenal.
- New Zeus module **GAIA: Control Group**: GAIA takes over any AI group, uses vehicles, works through the side's tasks and then patrols.
- New Eden modules: Mission Wizard, Convoy, Fire Mission, Music/Sound.
- New Eden attributes: GAIA control on groups, Zeus editable on objects.
- Eden scenario attributes for logistics, Mission Wizard, campaign, GAIA support and Zeus access, in the **MCC 5** menu.
- The editor Mission Wizard: all the old options, up to 8 objectives of all 12 types, factions from a list, and it builds the whole mission as editor objects in an "MCC Mission Wizard" layer. See [Mission Wizard](mission-wizard.md).

### GAIA / AI
- Performance rewrite: group registry, one scheduler, cached classification, no 91 zone limit, dynamic simulation caching.
- Vehicles: AI borrow empty vehicles for long trips, dismount with the leader at the objective, re-mount after contact, and detect stuck or wrong-way vehicles. Fixed AI driving to the map center.
- AI call artillery, CAS and reinforcements. Coordinated attack, flank, support-by-fire and reserve roles.
- Headless client balancing across all headless clients.
- Works with LAMBS Danger, LAMBS Suppression and HBQ Advanced Driving AI (detected automatically).

See [GAIA AI](gaia.md).

### Missions
- Mission Wizard up to 8 objectives, mission size (Small to Huge), unit cap.
- Campaign with up to 3 AOs at the same time. See [Campaign](campaign.md).

### Mods
- ACE3, RHS and CUP detected automatically. Class lists switch to the loaded mods. See [Mod support](mod-support.md).

### Logistics
- Optional limited logistics (Off / Fuel only / Full): supply trucks and crates run out and refill at bases. See [Limited logistics](logistics.md).
- Side resources are server-authoritative.

## R34: the MCC 5 revamp

### Security
- All `BIS_fnc_MP` calls replaced with `remoteExec`.
- No more code sent over the network (`BIS_fnc_spawn`, `compile format`, remoteExec "call" or "addAction" with code). Named functions instead.
- Rebuilt remoteExec whitelist (functions and engine commands). The mod no longer forces remoteExec mode 2.
- New Eden attribute: Network Security (Normal / Strict).
- `mcc\cfg\strictRemoteExec.txt` explains how to lock down public servers.
- CBA text settings are read as data (`parseSimpleArray`) instead of being run as code.

See [Multiplayer and security](multiplayer-and-security.md).

### Changed
- 154 scripts that ran through `execVM` are now compiled once as functions.
- CBA settings use `CBA_fnc_addSetting`.
- Wiki links point to mccsandbox.fandom.com.

### Fixed
- Hidden characters in config.cpp broke the "Add Valor" Zeus module entry.
- A Mission Wizard error message used an invalid remoteExec target.

## Other fixes in MCC 5

From the release notes:
- Broken Add Valor Zeus module.
- Set Resources swapping ammo and repair.
- East crates ignored.
- Settings registered twice.
- Mission Wizard hanging.
- Settings modules not applying.

## Coming from an older MCC

- The MCC menu is gone. Use Zeus modules and Eden modules and attributes.
- Missions made with older MCC versions are not supported.
- Don't load an older MCC and MCC 5 together.
