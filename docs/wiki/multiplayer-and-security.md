# Multiplayer and security

For server owners and mission makers who run MCC in multiplayer.

## Dedicated server setup

1. Copy `@mcc_sandbox_a3` to the server.
2. Start the server with `-mod=@CBA_A3;@mcc_sandbox_a3`.
3. Give headless clients the same `-mod` line.
4. The PBO is not signed. With `verifySignatures=2`, turn the check off or sign the PBO with your own key.

More in [Installation](installation.md#dedicated-server).

GAIA, the Mission Wizard, limited logistics and side resources run on the server. Headless clients take GAIA groups when **Headless Client Balancing** is on. See [GAIA AI](gaia.md#headless-clients).

## Who may use MCC

"Allowed to use MCC" decides who gets Zeus, and, in Strict network security, whose MCC requests the server accepts.

| Mission has | Who is allowed |
|---|---|
| No Access Rights module | **Everyone** (the default `MCC_allowedPlayers = ["all"]`) |
| An **Access Rights** module | Players whose UID is in the module, players whose unit is synced to it, and logged-in admins if **Admin Access** is ticked |

The server and the host are always allowed.

### The Access Rights module

1. In Eden, use **MCC 5 > Place MCC Module > Access Rights**. Or find **Access Rights** under **(MCC) General** in the module browser.
2. In **MCC Operators**, enter player UIDs as an array, for example:
   ```
   ["76561190000000001","76561190000000002"]
   ```
3. And/or sync the module to the playable units (roles) that should have MCC.
4. Tick **Admin Access** to also allow logged-in admins and the host.

The server keeps its own copy of this list where clients can't change it. A unit variable that a client could set (`MCC_allowed`) is not trusted.

### Zeus for MCC users

With **Zeus for MCC Users** on (the default), allowed players get Zeus automatically. Players who are not allowed get nothing. Set it in **MCC 5 Mission Settings** or in CBA **MCC General > Zeus**. See [Zeus tools](zeus-tools.md#who-gets-zeus).

If you use the vanilla **Game Master** module for some players, MCC leaves those players' Zeus alone.

## Network security

MCC 5 rebuilt its network code:
- No code is sent over the network any more. Remote calls go to named functions.
- There is a full remoteExec whitelist for MCC's functions and commands.
- The mod no longer forces remoteExec mode 2.
- CBA text settings are read as data, not run as code.

On top of that you can pick a **Network Security** level for each mission.

### Normal and Strict

Set it in Eden: **MCC 5 > MCC 5 Mission Settings... > MCC 5 > Network Security**.

| Level | What it does |
|---|---|
| **Normal** (default) | MCC accepts network requests from any player. This is the old behaviour. |
| **Strict (recommended for public servers)** | In multiplayer, MCC refuses requests that came over the network from players who are not allowed to use MCC. Requests from the server or the same machine are always fine. |

- Strict has no effect in single player.
- Without an Access Rights module, everyone is allowed, so Strict changes little. Use Strict together with the Access Rights module.
- Each refused call is written to the RPT as `MCC network security: refused <function> from owner <id>`.
- The server tells clients every 10 seconds (and when players join or leave) which players are allowed, so clients can check requests too.

For a mission without Eden attributes, put this in `description.ext`:

```
MCC_networkSecurity = 1;
```

### Engine whitelist (strongest)

For the strongest lock-down, add an engine remoteExec whitelist to your mission's `description.ext`. It blocks every function and command that is not listed, and keeps MCC working:

```cpp
class CfgRemoteExec
{
	class Functions
	{
		mode = 1;
		jip = 1;
		#include "\mcc_sandbox_mod\mcc\cfg\CfgRemoteExec.hpp"
		#include "\mcc_sandbox_mod\mcc\radio\CfgRemoteExec.hpp"
		#include "\mcc_sandbox_mod\mcc\aas\CfgRemoteExec.hpp"
	};
	class Commands
	{
		mode = 1;
		#include "\mcc_sandbox_mod\mcc\cfg\CfgRemoteExecCommands.hpp"
	};
};
```

- If your mission or other mods use their own remoteExec calls, add those classes too.
- Test the mission in multiplayer after turning this on.
- Blocked calls show in the server RPT as `remoteExec ... blocked`.

You can use the Network Security level, the engine whitelist, or both.

## Public server checklist

1. Place an **Access Rights** module with your admins' UIDs (and tick Admin Access if you want).
2. Set **Network Security** to **Strict**.
3. Optional: add the engine whitelist above.
4. Decide if everyone allowed should get Zeus (**Zeus for MCC Users**).
5. Test with a second, non-admin player.

## Other multiplayer settings

- **Sync Jip** (MCC General, On): players who join in progress sync with the server.
- **Teleport to Team** (MCC General, JIP Only): when players can teleport to their squad leader.
- **Kick Hot Mic** (MCC Radio): kicks a player with an open mic after a time. Only with the MCC radio system.

See [Settings](settings.md).

## Usage rules for servers

MCC 5 may not be used on servers that charge players, sell perks or ranks, or otherwise monetize gameplay, without written permission. See [License and usage rules](license.md).
