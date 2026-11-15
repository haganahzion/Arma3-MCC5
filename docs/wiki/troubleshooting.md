# Troubleshooting

## The RPT log

Most answers are in the Arma 3 log file (RPT).

- **Your PC**: `%LOCALAPPDATA%\Arma 3\` (paste it into the Windows Explorer address bar). Open the newest `.rpt` file.
- **Dedicated server**: the server's own RPT, in the server's profile or log folder.

GAIA and most MCC logic run on the server. For AI problems in multiplayer, read the **server** RPT.

### Lines to look for

| Line starts with | What it tells you |
|---|---|
| `MCC compat:` | Which of CBA, ACE, RHS and CUP MCC found |
| `GAIA: AI mods detected` | Whether LAMBS Danger, LAMBS Suppression and HBQ were found |
| `MCC: Eden attribute` | Each MCC 5 Mission Settings value applied at mission start, or why it was not applied |
| `MCC Zeus: assigned` / `MCC Zeus: removed` | Zeus given to or taken from a player |
| `MCC Mission Wizard:` | Editor and runtime Mission Wizard messages and errors |
| `MCC campaign:` | Campaign AOs starting |
| `GAIA` cycle timings | AI performance (needs GAIA Debug on) |
| `GAIA tasks:` | Groups following tasks (needs GAIA Debug on) |
| `MCC network security: refused` | A blocked network call (only in Strict mode) |
| `remoteExec ... blocked` | A call blocked by the engine remoteExec whitelist |

## Debug settings

- **GAIA Debug** (CBA **MCC GAIA**, or MCC 5 Mission Settings): GAIA timings per phase in the server RPT, GAIA debug markers, support request logs.
- **Debug markers** in the Zeus Mission Wizard dialog.
- **General Markers** in the editor Mission Wizard: shows objective zones, roadblocks and enemy positions on the map.

## Common problems

### The mod does not load / no MCC 5 menu in Eden

- Tick both **MCC Sandbox 5** and **CBA_A3** in the launcher.
- The launcher must point at the `@mcc_sandbox_a3` folder (the one with `addons\mcc_sandbox_mod.pbo` inside).
- Use the release zip **ARMA3-MCC5.zip**, not GitHub's source code download.
- Don't load an older MCC version at the same time.
- On a server, check the `-mod` line, and `verifySignatures` (the PBO is not signed).

See [Installation](installation.md#install-problems).

### I don't get Zeus

Check these in order:

1. **Zeus for MCC Users** must be On (MCC 5 Mission Settings or CBA MCC General > Zeus). It is On by default.
2. You must be allowed to use MCC. With an **Access Rights** module in the mission, only listed UIDs, synced units and (if ticked) admins are allowed. Without the module, everyone is.
3. Wait a few seconds after spawning. The server hands out Zeus every 10 seconds, once your client is ready.
4. If you already have a Zeus from another module (for example Game Master), MCC leaves it alone. Use that one.
5. Press **Ctrl+Delete** (the MCC keybind) or **Y**. If you get "MCC: you have no Zeus access", MCC has not given you a Zeus. Look for `MCC Zeus: assigned` in the server RPT.
6. The key may be taken by another mod. Change "Open Zeus (MCC)" in CBA keybinds (MCC).

### The right-click menu doesn't open in Zeus

- Click the right button, don't hold it. Holding moves the camera.
- Right-click the soldier himself, not empty ground.
- With a group selected, right-clicking a unit of another group gives a waypoint instead. Click empty ground to clear the selection, or select the group you right-click.
- With ZEN loaded, the options are in the ZEN menu under **MCC 5**, and ZEN only opens it when no AI is selected.
- Groups led by a player don't get the menu.

### The Mission Wizard faction list is empty or a faction is missing

- The list shows factions that have at least one soldier with public scope. Factions without soldiers are not listed.
- Civilian factions are only in the **Civilian Faction** list. Military factions are only in the Enemy and Player lists.
- The list is built once per game session. If you loaded a new mod, **restart the game**.
- A faction saved in the mission whose mod is not loaded now shows as "(not loaded)". Load the mod or pick another faction.

### Generate Mission does nothing or shows an error

Read the notification. The common ones are in [Mission Wizard: error messages](mission-wizard.md#error-messages). The full reason is in the RPT under `MCC Mission Wizard:`.

- "the enemy faction ... and the player faction ... are on the same side": pick factions on different sides.
- "the center of the mission area is in the water": move the camera, or select a trigger on land.
- "Unit cap reached": raise **Max AI Units**, or lower players, difficulty or size.

### The Zeus Mission Wizard says "MCC factions are not ready yet"

MCC is still starting. Wait a little and place the module again. "MCC is generating a mission, try again later" means another mission is being built right now.

### AI does not move

- **Is the group under GAIA?** GAIA only commands groups with a zone and behaviour. Use **GAIA: Control Group** or **Assign AI to zone** in Zeus, or the Eden group attribute or **Assign AI to zone** module. See [GAIA AI](gaia.md#putting-groups-under-gaia).
- **Does the zone exist?** The Eden group attribute needs a zone number that exists when the mission runs. 0 means no GAIA.
- **Behaviour**: **Fortify** groups stay in buildings on purpose. **Defensive** groups don't leave their zone. Default, BIS Defence and BIS Patrol don't get GAIA's own orders.
- **Is the leader a player?** GAIA won't take a group led by a player.
- **LAMBS task waypoint?** GAIA leaves groups on LAMBS task waypoints alone.
- **Caching**: a cached group far from players is frozen (dynamic simulation) or removed until a player comes close. This is normal.
- **Mod clash**: try setting **LAMBS Danger Compatibility** or **HBQ Driving AI Compatibility** to Off to test. See [AI mod compatibility](ai-mod-compatibility.md).
- Turn on **GAIA Debug** and check the server RPT.

### AI vehicles get stuck

- Keep **Unstick Vehicles** on.
- With HBQ Advanced Driving AI loaded, GAIA leaves unsticking to HBQ.
- Groups on foot that borrowed a vehicle re-plan after 90 seconds without progress, and walk after 3 tries.

### AI never calls artillery, CAS or reinforcements

- **AI Support Requests** must be On, and the kind you want (Artillery, CAS, Reinforcements).
- Artillery needs a GAIA mortar or artillery group in range.
- No artillery or CAS when friendlies are within **Danger Close Distance** (200 m).
- The contact must reach the **Threat Threshold** and a GAIA group in combat must be within **Contact Range**.
- Each kind has a cooldown and a budget per mission. CAS has only 2 per side by default.
- With **CAS Needs Own Aircraft** on, the side needs an armed aircraft.

### My Eden MCC settings don't apply

- Check the RPT for `MCC: Eden attribute ... not applied`. A setting forced in `cba_settings.sqf`, or by the server admin with "overwrite mission" priority, wins over the mission value.
- Values left at "Use addon setting" use the CBA value, by design.

### Supply trucks are empty

With **Limited Logistics** on, supply runs out. Park the truck within **Base Radius** of your side's start location or an RTS base building, and make sure your side has resources. See [Limited logistics](logistics.md).

### Network calls are refused

`MCC network security: refused` means Strict mode blocked a player who is not allowed to use MCC. Add the player to the **Access Rights** module or set Network Security to Normal. See [Multiplayer and security](multiplayer-and-security.md).

## Reporting a problem

Please send:
- the RPT log (and the server RPT for multiplayer),
- which mods were loaded,
- what you did,
- what happened, and a screenshot if you can.

Missions made with older MCC versions aren't supported.
