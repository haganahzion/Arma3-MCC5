# Limited logistics

By default Arma supply is endless: an ammo truck never runs dry and a fuel crate never empties. In MCC 5, with **limited logistics** on, supply trucks, crates and vehicle service run out, and they refill at your base from your side's resources.

It is optional and off by default.

## Turn it on

Pick a mode in one of these places:
- Eden: **MCC 5 > MCC 5 Mission Settings... > MCC 5 > Limited Logistics**
- CBA Addon Options: **MCC Logistics > Limited Logistics**
- `description.ext`: `MCC_logisticsMode = 2;` (0 Off, 1 Fuel only, 2 Full)

| Mode | What runs out |
|---|---|
| **Off** | Nothing. Unlimited supply, as before. |
| **Fuel only** | Fuel trucks, fuel crates and fuel from vehicle service. |
| **Full (fuel, ammo, repair)** | Fuel, ammo and repair. |

The mode can be changed while the mission runs. When you switch it to Off, MCC gives the supply objects their normal cargo back.

## Supply points

A supply point is any vehicle or crate that can rearm, repair or refuel. That means:
- classes with engine ammo, repair or fuel cargo (ammo trucks, fuel trucks, repair trucks, supply crates),
- MCC supply crates,
- with ACE, classes that ACE rearm or ACE refuel treat as a source.

The server looks for new supply objects every 30 seconds and checks each one every 5 seconds.

Each supply point gets a stock for each type it can supply. The stock is in **resource units**, the same units as side resources.

| Supply object | Stock per type |
|---|---|
| Vehicles (trucks) | **Supply Truck Capacity**, default 1000 |
| MCC crates | 200 |
| MCC big crates | 800 |
| Anything else | 200 |

## What things cost

When a vehicle near a supply point gains ammo, health or fuel, MCC takes the price from that point's stock. A full service (0 to 100%) costs:

| Vehicle kind | Ammo | Repair | Fuel |
|---|---|---|---|
| Plane | 150 | 150 | 100 |
| Helicopter | 100 | 100 | 60 |
| Tank | 120 | 120 | 60 |
| Wheeled APC | 80 | 80 | 40 |
| Ship | 40 | 40 | 30 |
| Static weapon | 20 | 20 | 0 |
| Anything else | 30 | 30 | 20 |

A partial service costs part of that. All prices are multiplied by **Supply Cost Factor** (default 1).

When a stock is empty, that supply type is switched off on the object. It works again when it is refilled.

## Refilling at base

A supply vehicle refills when it is parked at its side's base:

- "At base" means within **Base Radius** (default 75 m) of the side's **start location**, or of a built **RTS base building** of that side.
- While parked there, it takes **Base Refill Rate** (default 100) resource units from the side resources every 5 seconds, until it is full.

Without side resources the trucks stay empty.

## Side resources

Each side has resources: ammo, repair (materials), fuel, food and meds. In MCC 5 they are **server-authoritative**. All changes are made on the server and sent to everyone, so they can't get out of sync.

Ways to change them:
- **Set Resources** module (Eden or Zeus).
- **Capture Point** modules that yield resources over time.
- MCC campaign and RTS gameplay.

## Vehicle service

MCC's own vehicle service (the rearm, repair and refuel of the pylon dialog, for example at a **Rearm Area**) also costs side resources when limited logistics is on:
- **Fuel only** mode: refuelling costs fuel. Repair and rearm stay free.
- **Full** mode: repair, rearm and refuel all cost.
- If the side can't pay, the service is refused with "Not enough ... resources (N needed)".

With logistics Off, vehicle service is free, as before.

## Fuel consumption

**Fuel Consumption** (default 1, range 1 to 10) multiplies how fast vehicles burn fuel while limited logistics is on. It uses the Arma 3 2.16+ fuel consumption command. It is applied by whichever machine owns the vehicle, and set back to normal when you turn logistics off.

## Returning crates

When a crate is returned at base, its remaining stock counts toward what you get back.

## ACE

With ACE rearm or ACE refuel loaded:
- MCC pushes its stock into ACE's own counters (ammo as ACE supply points, fuel as liters).
- Each check, MCC reads how much ACE used and takes it from the stock.
- MCC crates without ACE rearm config are made ACE rearm sources first, because ACE ignores normal ammo cargo.

## The Logistics System setting

**Logistics System** (MCC General, default On) is a different feature. It lets players load equipment, vehicles, resources and items into vehicles. It does not limit anything.

## Settings summary

| Setting | Default | Range |
|---|---|---|
| Limited Logistics | Off | Off, Fuel only, Full |
| Supply Truck Capacity | 1000 | 100 to 5000 |
| Base Refill Rate | 100 | 10 to 1000 |
| Base Radius | 75 m | 25 to 500 |
| Supply Cost Factor | 1 | 0.1 to 5 |
| Fuel Consumption | 1 | 1 to 10 |

All are in CBA **MCC Logistics > Limited Logistics**, and in MCC 5 Mission Settings. See [Settings](settings.md#mcc-logistics---limited-logistics).
