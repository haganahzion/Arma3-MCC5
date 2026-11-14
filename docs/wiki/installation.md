# Installation

## What you need

- Arma 3, current version.
- **CBA_A3**. MCC needs it. Subscribe to it on the Steam Workshop.
- Optional: ACE3, RHS, CUP, LAMBS Danger.fsm, LAMBS Suppression, HBQ Advanced Driving AI. MCC finds them by itself.

## Get the right file

Download **ARMA3-MCC5.zip** from the latest GitHub release. Use the release file. GitHub's "Code > Download ZIP" button gives you the source code, not the mod.

When you unzip it you get this folder:

```
@mcc_sandbox_a3\
    addons\mcc_sandbox_mod.pbo
    mod.cpp
    INSTALL.md
```

## Install with the Arma 3 Launcher

1. Copy the whole `@mcc_sandbox_a3` folder into your Arma 3 folder. For example:
   `C:\Program Files (x86)\Steam\steamapps\common\Arma 3\@mcc_sandbox_a3`
   Any folder works. The Arma 3 folder is just the simplest.
2. Open the **Arma 3 Launcher** and go to **Mods**.
3. Use **Add watched folder**, or **Local mod** in the "..." menu, and pick the `@mcc_sandbox_a3` folder.
4. Tick **MCC Sandbox 5** and **CBA_A3**. Tick any optional mods you want.
5. Untick or remove any older **MCC Sandbox** version. Two MCC versions loaded together will conflict.
6. Press **Play**.

## Dedicated server

1. Copy `@mcc_sandbox_a3` into the server folder.
2. Add it to the server start line together with CBA:
   ```
   -mod=@CBA_A3;@mcc_sandbox_a3
   ```
3. This build is **not signed**. If the server uses `verifySignatures=2`, turn signature checks off or sign the PBO with your own key.

See [Multiplayer and security](multiplayer-and-security.md) for access rights and network security on public servers.

## Headless clients

Give every headless client the same `-mod` line as the server:

```
-mod=@CBA_A3;@mcc_sandbox_a3
```

GAIA spreads new AI groups across all connected headless clients by itself. This is the **Headless Client Balancing** setting, on by default. See [GAIA AI](gaia.md#headless-clients).

## Updating

1. Close Arma 3 (and stop the server).
2. Replace the old `@mcc_sandbox_a3` folder with the new one from the new zip.
3. Keep the same folder location, so the launcher and your `-mod` line still point to it.
4. Do the same on the server and on every headless client. All machines should run the same version.

## Removing MCC or old versions

- To stop using MCC, untick it in the launcher, or remove it from the `-mod` line.
- To remove it fully, delete the `@mcc_sandbox_a3` folder.
- Remove or untick any older **MCC Sandbox** version. Don't run two MCC versions together.
- Missions made with older MCC versions are not supported in MCC 5.
- Missions that use MCC modules need the mod loaded to work.

## Check that it works

1. Start the game with MCC and CBA ticked.
2. Open the **Eden editor** on any map.
3. Look for **MCC 5** in the top menu bar. It works with or without 3den Enhanced.

If the menu is there, the mod is loaded. Next step: [Getting started](getting-started.md).

## Install problems

**No MCC 5 menu in Eden.**
- Check that both **MCC Sandbox 5** and **CBA_A3** are ticked in the launcher.
- Check the folder. The launcher must point to `@mcc_sandbox_a3`, the folder that contains `addons\mcc_sandbox_mod.pbo`. Pointing at a parent folder or at the zip does not work.
- Make sure you used the release zip, not the source code download.

**Errors or strange behaviour right after install.**
- Make sure no older MCC version is loaded at the same time.

**Server kicks players or refuses the mod.**
- The PBO is not signed. With `verifySignatures=2` the server refuses it. Turn the check off or sign the PBO yourself.

**Server runs but MCC does nothing there.**
- Check the server `-mod` line includes both `@CBA_A3` and `@mcc_sandbox_a3`.
- Headless clients need the same `-mod` line.

For anything else, look at the RPT log. See [Troubleshooting](troubleshooting.md).
