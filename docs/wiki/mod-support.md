# Mod support: ACE3, RHS, CUP

MCC 5 detects ACE3, RHS and CUP by itself when the game starts. You don't need to set anything. MCC works with or without them.

For LAMBS and HBQ, see [AI mod compatibility](ai-mod-compatibility.md).

## How detection works

MCC checks which addons are loaded:

| Mod | Checked addon |
|---|---|
| CBA | `cba_main` |
| ACE3 | `ace_common` |
| ACE medical, cargo, rearm, refuel | `ace_medical`, `ace_cargo`, `ace_rearm`, `ace_refuel` |
| RHS AFRF, USAF, GREF, SAF | `rhs_main`, `rhsusf_main`, `rhsgref_main`, `rhssaf_main` |
| CUP Units | `CUP_Creatures_People_Core` or `CUP_Creatures_People_Civil_Russia` |
| CUP Vehicles | `CUP_Vehicles_Core` or `CUP_AirVehicles_Core` |
| CUP Weapons | `CUP_Weapons_WeaponsCore` |

The result is written to the RPT in one line starting with `MCC compat:`, for example:

```
MCC compat: CBA true | ACE false (medical false, cargo false, rearm false, refuel false) | RHS true (AFRF true, USAF true, GREF false, SAF false) | CUP false (units false, vehicles false, weapons false)
```

## RHS and CUP: class lists

Several MCC settings are lists of classes. When such a list is still at its vanilla default, MCC swaps in a list for your loaded mods.

| Setting | With RHS / CUP |
|---|---|
| Mission Wizard HVT (man) | RHS / CUP officers |
| Mission Wizard Armored Vehicles | RHS / CUP tanks |
| Mission Wizard Anti-Air | RHS / CUP AA vehicles |
| Mission Wizard Artillery | RHS / CUP artillery |
| Convoy HVT and HVT Vehicle | RHS / CUP officers and cars are added to the list |
| Breaching Ammo, Non Lethal Ammo | every shotgun slug magazine found in your mods |

Rules:
- Only classes that exist in your loaded mod version are used. Missing ones are dropped.
- For the Mission Wizard lists, mod entries come first. Vanilla entries are only kept for sides the mods don't cover.
- For the convoy lists, the mod entries are added after the vanilla ones.
- If you **changed** a list, MCC leaves it alone.
- Put the word `"auto"` in a list to get the detected entries plus your own. Example: `["auto","my_magazine_class"]`.
- If you change one of these settings during the mission, the mod presets are applied again.

MCC's RTS and spawn groups also have RHS and CUP variants. They are used when that mod is loaded and every class in the variant exists.

## Mission Wizard factions

The editor Mission Wizard lists every faction from every loaded mod that has soldiers. So RHS and CUP factions show up in the Enemy, Player and Civilian faction lists. See [Mission Wizard](mission-wizard.md#factions).

The sample missions include RHS campaign versions, for example "(MCC RHS) Campaign USA vs RU". They need RHS loaded.

The **Spawn Ship** LHD type needs CUP.

## ACE3

When ACE is loaded, MCC hands several jobs to ACE:

- **Medical**: the MCC medical settings module is ignored. Use ACE medical.
- **Interaction**: MCC does not ask you to bind its own interaction key. The MCC interaction key then only halts AI and opens doors, and the MCC self-interaction menu is off. Use ACE interaction for the rest. For MCC ammo boxes you get the hint "Use ACE keys to resupply".
- **Captives**: the convoy and Mission Wizard HVTs and hostages use ACE handcuffs. A Kill HVT objective also counts as done when the HVT is handcuffed with ACE.
- **Cargo**: **Load to Cargo** uses ACE cargo when it is loaded.
- **Rearm and refuel**: with limited logistics on, MCC syncs its stock with ACE rearm and ACE refuel. See [Limited logistics](logistics.md#ace).
- Some MCC actions, like resupply, use ACE items (for example field dressings instead of First Aid Kits).

If something MCC normally does seems missing with ACE loaded, it is usually because ACE does that job.
