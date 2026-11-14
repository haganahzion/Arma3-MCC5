# Getting started

This page takes you from an empty map to a playable mission in about 10 minutes. You will use the editor Mission Wizard, place your squad, play, and open Zeus.

If the mod is not installed yet, start with [Installation](installation.md).

## 1. Open the editor

1. Start Arma 3 with **MCC Sandbox 5** and **CBA_A3** loaded.
2. Open **Editor** and pick a map. Altis, Stratis, Tanoa or Malden are fine for a first try.
3. Find **MCC 5** in the top menu bar of the editor.

## 2. Pick the mission area

The Mission Wizard builds the mission around a spot you choose. The easiest way:

1. Move the editor camera so the center of the screen looks at a town or area on land.

Other ways, if you want more control:
- Place a **trigger** (or an area marker), size it, and **select it** before you generate. The mission is built inside that area.
- Or set the wizard to **Whole map** and it picks a random town or location.

The center of the area must be on land, not in the water.

## 3. Set the wizard options

1. Open **MCC 5 > Mission Wizard...**
2. Under **Factions**, set:
   - **Enemy Faction**, for example OPFOR CSAT (`OPF_F`).
   - **Player Faction**, for example BLUFOR NATO (`BLU_F`). It must be on a different side from the enemy.
   - **Civilian Faction**, for example `CIV_F`.
3. Under **Mission area and size**, set **Expected Players** to the number of people who will play.
4. Pick a **Difficulty**. Medium is the default.
5. Leave the rest at the defaults for now. You can read about every option on the [Mission Wizard](mission-wizard.md) page.
6. If you want a spawn point made for you, set **Player Start** to **Respawn marker outside the area**.
7. Close the window with **OK**.

## 4. Generate the mission

1. Click **MCC 5 > Generate Mission**.
2. Wait a moment. A notification shows a summary: the operation name, how many objectives, groups and AI units were placed.
3. The camera moves to the mission area.

Everything the wizard made is now normal editor content in a layer called **MCC Mission Wizard**. Open the layer list on the left to see it. You can move, edit or delete anything in it.

Don't like it? Press **Ctrl+Z** once to undo the whole generation. Or use **MCC 5 > Regenerate Mission (clear + generate)** to throw it away and build a new one.

## 5. Place your squad

The wizard places enemies, not you.

1. Open the asset browser on the right and pick units from your **Player Faction**.
2. Place your squad outside the mission area. If you used **Player Start**, put them near the "MW Start" respawn marker.
3. Make one unit the player (**Player** in the unit attributes) or make units **Playable** for multiplayer.

The tasks and briefing are created for the side of the Player Faction. Your units must be on that side to get them.

## 6. Play

1. Click **Play Scenario** (single player) or save and host it in multiplayer.
2. Read the briefing in the map (Diary). The tasks show which objectives to complete.
3. Go do them. GAIA controls the enemy groups in their zones.

## 7. Open Zeus

MCC users get Zeus automatically. By default that is everyone. A mission maker can limit it with the **Access Rights** module. See [Multiplayer and security](multiplayer-and-security.md).

1. Press **Ctrl+Delete** (the MCC keybind) or **Y** (the normal Zeus key).
2. Click the green **MCC 5** button at the top of the Zeus screen.
3. Double-click a tool in the list. It is placed at the center of the screen and opens its options.

For tools that act on one unit, like **Make Hostage** or **GAIA: Control Group**, drag them from **Modules > MCC** onto the unit instead.

A fun first try: select an AI squad of your side in Zeus, then drop **GAIA: Control Group** on it. GAIA takes over that squad and works through your side's tasks.

All Zeus tools are listed on the [Zeus tools](zeus-tools.md) page.

## Where to go next

- [Mission Wizard](mission-wizard.md) for every option and what Generate builds
- [Eden editor](eden-editor.md) for MCC modules and attributes
- [GAIA AI](gaia.md) to control AI with zones and behaviours
- [Settings](settings.md) to change how MCC behaves
