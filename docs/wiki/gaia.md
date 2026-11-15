# GAIA AI

GAIA is the MCC AI commander. You give AI groups a **zone** and a **behaviour**. GAIA then decides where each group goes: patrols, attacks on enemy contacts, building defence, vehicle use and calls for support.

GAIA gives orders to groups and leaves the soldiers' own combat AI alone. With LAMBS Danger or HBQ Advanced Driving AI loaded, GAIA leaves unit combat or driving to those mods. See [AI mod compatibility](ai-mod-compatibility.md).

GAIA runs on the server. Groups can be moved to headless clients.

## Zones

A zone is an area on the map with a number (1, 2, 3...). Every GAIA group belongs to one zone. There is no limit on the number of zones in MCC 5.

Ways to make a zone:
- **Eden**: place a trigger, size it, and sync it to a **Create Zone** module. At mission start it gets the next free number.
- **Zeus**: place the **Create Zone** module, pick "New" (or an existing number to move it), set the size and angle.
- **Mission Wizard**: makes its own zones, one for the area and one per objective.
- **GAIA: Control Group** and the task follower make a zone when there is none nearby.

## Behaviours (intends)

| Behaviour | Code name | What GAIA does with the group |
|---|---|---|
| Aggressive | `MOVE` | Patrols the zone. Attacks enemy contacts, also outside the zone, as long as they are in range. Mortar and artillery groups may fire anywhere. |
| Defensive | `NOFOLLOW` | Patrols the zone. Only attacks contacts inside its own zone. Mortar and artillery groups fire only inside the zone, unless **NOFOLLOW Artillery Fires Outside Zone** is on. |
| Fortify | `FORTIFY` | Occupies buildings and static weapons near its position and stays there. |

How far an aggressive group reacts depends on how fast it is. In the code, slow groups react up to about 600 m, medium groups up to about 4.5 km, and fast groups much further. Any contact inside the group's own zone always counts.

Some menus also offer **Default**, **BIS Defence** and **BIS Patrol**. GAIA only gives its own orders for the three behaviours above. Use those for real GAIA control.

## Putting groups under GAIA

### In Zeus: right-click menu

Right-click an AI soldier and pick **GAIA: Control Group**, **GAIA: Attack Area** or **GAIA: Defend Area**. **Player Control Group** gives the group back to you. See [Zeus tools](zeus-tools.md#right-click-menu-on-ai-units).

### In Zeus: GAIA: Control Group module

Or drop the **GAIA: Control Group** module on an AI group, or select groups and place it. GAIA takes over and works through the side's tasks, then patrols. This works for any side, including friendly AI. The leader can't be a player. See [Zeus tools](zeus-tools.md#gaia-control-group).

### In Zeus: Assign AI to zone

Drop **Assign AI to zone** on a unit or group. Pick a zone from the list and a behaviour.

### In Eden: the group attribute

1. Select the group and open its attributes.
2. In **MCC: GAIA Control**, set **GAIA Zone** to the zone number and pick the **GAIA Behavior**.
3. Optional: tick **GAIA Cache**.

0 means "not GAIA controlled". The zone number must exist when the mission runs.

### In Eden: Assign AI to zone module

1. Place a trigger and a **Create Zone** module, and sync them.
2. Place an **Assign AI to zone** module, pick the **Behavior**, and sync it to the Create Zone module.
3. Sync your groups (or their units) to the Assign AI to zone module.

This is the safest Eden method, because you don't need to know the zone number. The Mission Wizard does it this way too.

### Other ways

- The Zeus **Reinforcements** module can hand its troops to GAIA (aggressive, defensive or fortify) in a zone number you type.
- AI reinforcements called by GAIA itself are given to GAIA in the zone of the group that asked.

## Following tasks

Groups given to GAIA with **GAIA: Control Group** follow the side's tasks:

1. The group takes the nearest unfinished task of its side that has a map position.
2. If no MCC zone is within 400 m of the task, a 200 m zone is made there.
3. The group goes there as aggressive.
4. When that task is done, it takes the next nearest one. Tasks are checked every 15 seconds.
5. With no tasks left, it patrols its last zone, or the nearest one. With no zone at all, a 300 m zone is made around the group.

Use it to let friendly AI squads play a Mission Wizard mission next to you.

## Vehicles

With **Smart Vehicle Use** on (default), GAIA groups use vehicles like this:

- Long trips: infantry going further than **Find Ride Distance** (500 m) look for an empty land vehicle within **Vehicle Search Radius** (300 m) of the leader. Any side's empty vehicle counts, as long as it isn't locked, can move and has fuel. An AI drives (never a player, and not the leader when another AI can). If the vehicle fits at least 60% of the AI, they get in; the rest walk on as their own GAIA group with the same order. Players in the group are ordered in too, but the vehicle leaves without them after about 90 seconds.
- After a fight: a group goes back to normal and to its job about 30 seconds after the last known enemy within 500 m. Groups that follow tasks only join fights within 400 m of their route or inside their task's zone.
- At the objective: at **Dismount Distance** (400 m) from the objective, the whole group gets out, leader included.
  - A borrowed vehicle is left parked. The group remembers it.
  - A group's own vehicle (motorized or mechanized): passengers and leader get out, the crew stays in to give fire support.
- After a fight: if the objective is still far, the group gets back into the same vehicle instead of walking.
- Stuck or wrong way: if the vehicle is not 100 m closer to the objective after 90 seconds, the route is planned again. After 3 tries the group continues on foot. This is off when HBQ Advanced Driving AI is active.
- Vehicle lost: the group forgets it and may find another ride later.

**Unstick Vehicles** (default on) is for tanks and armed cars without passengers. If they have not moved for about a minute while they still have somewhere to go:
1. If flipped, and no player is within 300 m, they are put back on their wheels.
2. The driver plans a new route.
3. They back up 40 m.
4. They drop the order, and GAIA gives a new one.

This is skipped when HBQ Advanced Driving AI handles it, and for air, ships, statics and groups in combat.

MCC 5 also fixed AI driving to the middle of the map.

## Coordinated attacks

With **Coordinated Attacks** on (default), groups sent to the same enemy contact get roles:

- **Attack**: the main effort, straight at the contact. Groups already fighting close by, aircraft and ships always attack.
- **Support by fire** (one per contact): a vehicle group with guns, or an infantry group when there are 3 or more ground groups. It moves to an overwatch spot with line of sight and fires from there.
- **Flank** (up to 2): comes from another direction, about 75 degrees off the main attack.
- **Reserve** (one, with 4 or more ground groups): waits in cover about 450 m away and joins in when no attacking group is left.

A single group, or the setting off, means a plain attack.

## Support requests

With **AI Support Requests** on (default), GAIA can call support when its groups fight a strong enemy contact. One response per contact.

GAIA only calls support when:
- the contact is worth at least **Threat Threshold** points (default 40; a rifleman is 4 points, 6 inside a GAIA zone, vehicles more),
- and a GAIA group in combat is within **Contact Range** (600 m) of it,
- and the same contact did not get support within **Contact Cooldown** (180 s).

The three kinds:

| Support | What happens | Limits |
|---|---|---|
| Artillery | An idle GAIA mortar or artillery group in range fires on the contact. | Not when friendlies are within **Danger Close Distance** (200 m). **Artillery Cooldown** 60 s, **Artillery Budget** 20 per side per mission. Needs a GAIA artillery group. |
| CAS | An off-map close air support run with the side's CAS plane (or the vanilla default). | Not danger close. **CAS Cooldown** 300 s, **CAS Budget** 2 per mission. With **CAS Needs Own Aircraft** on, only when the side has an armed aircraft of its own. |
| Reinforcements | Motorized reinforcements spawn about 2 km behind the friendly group, unload near it, then join GAIA in that group's zone. **Reinforcement Size**: small 2, medium 3, large 4 vehicles. | **Reinforcement Cooldown** 600 s, **Reinforcement Budget** 2 per mission. |

Which one GAIA tries first:
- Heavily outnumbered: reinforcements, then artillery, then CAS.
- Armoured contact: CAS, then artillery, then reinforcements.
- Otherwise: artillery, then CAS, then reinforcements.

Each kind can be turned off on its own. At most one new support response per side per GAIA cycle. Air contacts are ignored. All settings are on the [Settings](settings.md#mcc-gaia---support-requests) page and in MCC 5 Mission Settings.

The Mission Wizard turns on reinforcement and artillery requests when you choose reinforcements or artillery.

## Headless clients

With **Headless Client Balancing** on (default), GAIA moves new groups to headless clients:

- Groups that join GAIA for the first time after 30 seconds of mission time are queued.
- After 5 seconds each is handed to the next headless client in turn.
- The list of headless clients is refreshed every 10 seconds, so clients can join or leave.

Not moved:
- groups with players,
- groups already on a headless client,
- garrisoned and fortify groups,
- groups flagged `GAIA_noHC`, `MCC_noHC` or `acex_headless_blacklist`.

Groups placed in Eden and present at the very start are not moved by this. Headless clients run the vehicle logic for their own groups, and mortar fire is passed to the machine that owns the group.

Every headless client needs the same `-mod` line as the server. See [Installation](installation.md#headless-clients).

## Caching

Caching saves performance for groups far from players. It only applies to groups flagged for caching, for example with the Eden group attribute **GAIA Cache**.

- **Stage 1**: when no player is within **Cache Distance** (default 3000 m), the group is put under the engine's dynamic simulation and freezes. Not for groups in combat, mortar and artillery groups, or groups on a moving order (attack, clear, transport, support).
- **Stage 2**: when no player is within twice the Cache Distance, the group is saved and removed. It comes back when a player gets that close again.

## Performance

The MCC 5 GAIA was rewritten for speed:
- One scheduler for all sides, on the server.
- Per-group work is spread over frames: 5 groups per frame, each group at most once per second.
- Group data is cached. Groups are kept in a registry that is cleaned every 10 seconds.
- No zone limit (the old limit was 91 zones).
- Far groups can be frozen with dynamic simulation (see Caching).

Tips:
- Keep the number of AI reasonable. The Mission Wizard has **Max AI Units** and **Max spawned units** caps.
- Use **GAIA Cache** on groups far from the action.
- Use headless clients on busy servers.

## Other GAIA settings

- **Target Detection Range** (1000 m): how far around each group leader GAIA looks for enemy targets.
- **GAIA Controls All** (Off): GAIA may also give orders to groups it does not control, even players.
- **AI Skill** (overall, aim, spot, command; 1 to 10, default 5).
- **AI Use Smoke Grenades & flares** (Off) and **Smoke/flares Chance** (50).

## Debug

Turn on **GAIA Debug** in CBA Addon Options (MCC GAIA), or in MCC 5 Mission Settings. Then:
- GAIA writes its cycle timings per phase, with the number of groups processed, to the **server** RPT.
- GAIA debug markers are shown.
- Support requests are logged.
- Groups following tasks log lines starting with `GAIA tasks:`.

At start the RPT also shows `GAIA: AI mods detected` with the AI mods found. See [Troubleshooting](troubleshooting.md).
