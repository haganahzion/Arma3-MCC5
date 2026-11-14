# AI mod compatibility

GAIA is a commander. It decides where groups go, which vehicle they use and when to call support. It works next to these AI mods instead of fighting them:

- **LAMBS Danger.fsm**
- **LAMBS Suppression**
- **HBQ Advanced Driving AI**

MCC detects them when the game starts. You don't need to set anything.

## What is detected

At start the RPT log shows one line like this:

```
GAIA: AI mods detected - LAMBS Danger: true, LAMBS Suppression: false, HBQ Advanced Driving AI: false
```

How MCC finds them:
- LAMBS Danger: the addon `lambs_danger` is loaded.
- LAMBS Suppression: the addon `lambs_suppression` is loaded.
- HBQ Advanced Driving AI: any loaded addon whose name contains both "hbq" and "driv".

## LAMBS Danger

With LAMBS Danger active:
- GAIA leaves contact tactics to LAMBS. It does not force group behaviour every cycle while a group is in contact. It only sets it again when it gives a new order.
- When GAIA vehicle groups meet the enemy, dismounting in contact is LAMBS's call. GAIA only puts the group back into its vehicle after the fight.

Groups running a **LAMBS task waypoint** (a scripted waypoint from LAMBS) are left alone by GAIA. GAIA treats them like fortify groups and does not give them new orders.

## LAMBS Suppression

MCC detects LAMBS Suppression and writes it in the RPT. The code has no further special handling for it, so both simply run side by side.

MCC also has its own **Suppression Effects** setting (MCC User Interface, off by default). It is a separate, client side effect.

## HBQ Advanced Driving AI

With HBQ active, GAIA leaves stuck vehicles and route recovery to HBQ:
- GAIA's own "not getting closer, plan a new route, then go on foot" check for vehicle groups is turned off.
- **Unstick Vehicles** (flip, re-route, back up, drop the order) is skipped.

GAIA still picks rides, dismounts and remounts.

## Auto, On, Off

Two CBA settings in **MCC GAIA > AI Mod Compatibility** let you override detection. They are also in MCC 5 Mission Settings.

| Setting | Auto (default) | On | Off |
|---|---|---|---|
| **LAMBS Danger Compatibility** | Cooperate if LAMBS Danger is loaded | Always act as if LAMBS Danger is loaded | Never, GAIA behaves as without LAMBS |
| **HBQ Driving AI Compatibility** | Cooperate if HBQ is loaded | Always act as if HBQ is loaded | Never, GAIA uses its own unstick logic |

When to change them:
- Set **Off** if you have the mod loaded but want GAIA to keep full control.
- Set **On** if your version of the mod is not detected. For HBQ the addon name is not documented, so MCC guesses it from the name.

There is no override setting for LAMBS Suppression.

See also [GAIA AI](gaia.md) and [Settings](settings.md#mcc-gaia---ai-mod-compatibility).
