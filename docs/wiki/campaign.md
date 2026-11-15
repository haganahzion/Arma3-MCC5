# Campaign

The MCC campaign is a long game mode. MCC generates one Mission Wizard mission (an "AO", area of operations) after another across the map. Players earn resources, push the front line out from their base, and the campaign ends after a set number of missions or when the enemy runs out of places.

In MCC 5 a campaign can run **up to 3 AOs at the same time**.

## Quick start: sample missions

The quickest way to try it is with the campaign missions that ship with the mod. In the multiplayer scenario list, look for names like:

- **(MCC) Campaign** and **(MCC) Campaign CSAT** (Altis, Tanoa)
- **(MCC) Campaign BAF**, **USMC**, **USA**, **RU**, **GU**, **TK** on other maps
- **(MCC RHS) Campaign USA vs RU**, **CHDKZ vs USA**, **RU vs USA** (need RHS)

Some need the map or mods in their name.

## Set up your own campaign

1. Place a **Start Location** module for the players' side with **Type: Main**. The campaign needs at least one HQ start location.
2. Place a **Campaign init** module (**MCC 5 > Place MCC Module > Campaign Init**, or under (MCC) General).
3. Set its options (below).
4. Optional: turn on Role Selection and time acceleration. The module description recommends them.
5. Optional: place empty markers with **"ao"** in their name where you want AOs. If you place any, MCC uses only those. Without them, MCC picks towns, military places and nature locations from the map that are at least 700 m from the start locations.

You can also start a campaign in game with the Zeus module **Campaign init**. It asks the same questions. Only one campaign can run at a time ("Campaign already running").

## Campaign init options

| Option | What it does | Default |
|---|---|---|
| **Players Faction** | Faction class name of the players | `BLU_F` |
| **Rival Players Side** | A second player side. Rival players gain resources from killing the main faction's players. None, West, East, Independent, Civilian | None |
| **Enemy Faction** | Faction class name of the enemy | `OPF_F` |
| **Civilian Faction** | Faction class name of the civilians | `CIV_F` |
| **Number of Missions** | Missions until the campaign ends: 5, 10, 15 or unlimited | 10 |
| **Difficulty** | Easy, Medium, Hard | Medium |
| **Intro** | Cinematic, Pop-Up (the operation screen with or without the camera), None | Pop-Up |
| **Starting Tickets** | Respawn tickets for each player side | 100 |
| **Missions Rotation** | After each set of missions MCC picks a new location | 3 |
| **Tile Size** | MCC divides the map into tiles of this size (meters) | 400 |
| **Load from DB** | Load saved campaign data from the database | Off |

## Campaign settings

These are in **MCC 5 Mission Settings > MCC 5** and in CBA **MCC Mission Wizard > Campaign**:

| Setting | What it does | Default |
|---|---|---|
| **Campaign: Simultaneous AOs** | How many AOs can be active at once, 1 to 3 | 1 |
| **Campaign: AO Size** | Objective radius of every AO, in meters | 300 |
| **Campaign: Ambient Groups Cap** | Max ambient enemy groups kept around players (2 per player, up to this) | 18 |
| **Mission Wizard: Max Objectives** | Objectives per AO. Above 3, each extra one has a difficulty based chance | 3 |
| **Mission Wizard: Max Spawned Units** | Cap on the units one AO may spawn | 200 |

The ambient cap is read every cycle, so you can change it during the campaign.

## What happens during a campaign

At the start:
- The time multiplier is raised to at least 12.
- Each player side gets its starting tickets.
- The map is split into tiles and shown with markers. The players' base area is painted in their colour.
- Ambient enemy patrols start around players.
- The campaign data is saved to the database every 20 minutes.

Each AO:
- Is its own Mission Wizard mission with its own zones and objectives.
- About 1 in 5 is a **recon** mission, picked at a random spot.
- The first missions are easier: no enemy vehicles or artillery in the first 3, no armor in the first 4. After that the chance grows with difficulty.
- A radio tower objective may be added, more often on higher difficulty.

When an AO is done:
- Rewards are worked out from the objectives done and failed and the tickets lost.
- The AO's objectives are removed. The area is cleaned up once no player is near.
- For normal (non recon) AOs, the borders move: tiles turn to the players' colour.
- A new AO starts.

The campaign ends when the number of missions is reached, or when no enemy locations are left (a win for everyone).

Each in-game day the campaign also updates tickets, weather and the enemy's behaviour. A **Campaign Evac** vehicle (Evac Vehicle module) respawns each in-game day.

## Tips

- Don't run more AOs than your server can take. Start with 1.
- Use **Max Spawned Units** to keep each AO light.
- Headless clients help a lot in long campaigns. See [GAIA AI](gaia.md#headless-clients).
- For a one-off mission, use the [Mission Wizard](mission-wizard.md) instead.

The campaign code has more details (resource rewards, day cycle, database) than are covered here. As a mission maker you only set the options above.
