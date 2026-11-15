# Developer notes

Notes for anyone working on this repo. Read this first.

## What this is
MCC Sandbox 5: an Arma 3 mod (SQF + config) built on MCC Sandbox by Shay_gman & Spirit. Owner: haganahzion
(Discord @z1on_8200). Licensed GPL-3.0 like the original MCC Sandbox (see `LICENSE.md`); keep the Shay_gman & Spirit credit. Discord: https://discord.gg/bxwX5EkMEf.
Current version: see `VERSION` (5.0.x scheme; do not jump to 6). Requires CBA_A3.

There is no Arma 3 in the dev container, and no SQF linter can be installed. Nothing can be run here. Every change
must be checked by reading the code and by the bracket/quote balance check below, and the owner tests in game.
Say clearly in replies that changes are untested in game.

## Owner preferences
- Wants things done fast and completely; uses agents for big work. Short, plain replies.
- Commit and push every finished piece of work. Don't leave uncommitted changes at the end of a turn
  (a stop hook enforces it); work an agent is still editing may stay uncommitted until it reports.
- No AI-sounding comments or prose in code/docs: no plan labels ("Phase B"), no history notes in code comments
  ("replaces the old menu", "used to"), no em dashes. History goes in `MCC_changelog.txt`.
- No MCC 4 branding anywhere. The mod is "MCC 5" / "MCC Sandbox 5".
- Verify facts (Arma commands, mod class names, CBA APIs) on the BI wiki / CBA source before relying on them.

## Branch, build, release
- Work branch: `mcc5` (this is where all MCC 5 work lives; `master` still has the old code
  until the owner merges). Push with `git push -u origin mcc5`.
- Build locally: `python3 tools/build_pbo.py <outdir>` makes `<outdir>/@mcc_sandbox_a3/addons/mcc_sandbox_mod.pbo`
  (+ mod.cpp, INSTALL.md, LICENSE.md). Unbinarized, unsigned. PBO prefix `mcc_sandbox_mod` (also `$PBOPREFIX$`);
  the packer generates `BIS_AddonInfo.hpp`.
- Release: bump `VERSION`, then push a commit whose message contains `[release]`. `.github/workflows/build-release.yml`
  builds, zips `@mcc_sandbox_a3` as `ARMA3-MCC5.zip`, and publishes release `ARMA3-MCC5-v<VERSION>` with
  `docs/RELEASE_NOTES.md` as the body (marked latest). Tags can't be pushed from the session; the workflow creates them.
  Keep `config.cpp` CfgPatches `version` and `definesMod.hpp` `MCCVersion` in step with `VERSION`.
- Steam Workshop: item id `3840123393` (https://steamcommunity.com/sharedfiles/filedetails/?id=3840123393), CBA_A3 set
  as required item. Update: build into `Documents\MCC5-workshop\@mcc_sandbox_a3`, sign the PBO with
  `Documents\MCC5-keys\mcc5.biprivatekey` (Arma 3 Tools `DSSignFile`, key `keys\mcc5.bikey` stays in the mod folder), then
  `"<Arma 3 Tools>\Publisher\PublisherCmd.exe" update /id:3840123393 /changeNoteFile:<notes.txt> /path:<mod folder>`.
  Launch Publisher tools through the Windows shell (not a sandboxed shell) or Steam init fails. Never commit the private key.
- Images: `python3 tools/img2paa.py in.png out.paa` (DXT1 + mipmaps, power-of-two sizes). Banner/logo sources in `docs/`.
- Settings window: after changing any CBA setting in `mcc/settings/*.sqf`, run `python3 tools/gen_eden_settings.py`
  to regenerate `mcc/cfg/eden/settingsAttributes.hpp` and `mcc/fnc/eden/edenSettingsMap.sqf`.

## Balance check (run on every changed file before committing)
Strip `//` and `/* */` comments and `"strings"` (with `""` escapes), then count `[]`, `{}`, `()`. Compare with the
same count on `git show HEAD:<file>` (some original files are already "unbalanced" because of strings in single quotes).

## Layout
- `config.cpp`: CfgPatches (units[] lists for Eden and Zeus modules, requiredAddons incl. `3DEN`), CfgMods,
  Extended_PostInit (settings registration), Cfg3DEN (scenario section `MCC5` = "MCC 5 Mission Settings",
  section `MCC5_MW` = editor Mission Wizard, attribute controls), `#include definesMod.hpp`.
- `definesMod.hpp` (mod) / `defines.hpp` (mission version): dialogs, CfgFunctions includes, CfgRemoteExec.
- `XEH_preInit.sqf`: includes `mcc/settings/*.sqf` (CBA settings, registered in PostInit on purpose: callbacks touch
  player/UI).
- `init.sqf`: big legacy init (globals, defaults guarded with isNil where settings set them).
- `gaia/`: GAIA AI commander. `functions/core` (registry `GAIA_fnc_registerGroup/getGroups`, one strategic loop
  `GAIA_fnc_sideCycle`, CBA per-frame `GAIA_fnc_perFrame` -> `GAIA_fnc_groupTick`), `functions/vehicles`
  (rides, dismount with leader, re-mount, stuck; `GAIA_fnc_vehicleTick`; AI mod detection `GAIA_fnc_detectAIMods`,
  `GAIA_fnc_compat`), `functions/support` (artillery/CAS/reinforcement requests, roles, HC balance),
  `functions/control` (analyze/issue orders), `functions/cache`.
  A group is GAIA-controlled when it has `GAIA_ZONE_INTEND = [zoneStr, "MOVE"|"NOFOLLOW"|"FORTIFY"]` and is registered.
- `mcc/cfg/curator/`: Zeus modules (`MCC_Module_*Curator`, function `MCC_fnc_curator*`, options via
  `MCC_fnc_initDynamicDialog`), Zeus right-click menu for AI groups (`fn_curatorContextMenu`, ZEN menu when ZEN is loaded, -> `fn_curatorGroupControl`), auto Zeus for MCC users
  (`fn_curatorAutoAssign`), GAIA Control Group (`fn_curatorGaiaControl` -> `fn_gaiaControlGroups` -> `fn_gaiaTaskTick`).
- `mcc/cfg/modules/`: Eden modules (Mission Wizard runtime, Convoy, Fire Mission, Music, Create Zones, settings...).
- `mcc/cfg/eden/`: Eden menu (`display3DEN.hpp`, menu "MCC 5"), wizard section, attribute controls, generated settings.
- `mcc/fnc/intro/`: operation intro screen (`fn_operationIntroStart` server: hold fire for every AI group, `fn_operationIntro`
  client screen on the `MCC_RscOperationIntro` title layer).
- `mcc/fnc/edenWizard/`: editor-time Mission Wizard (builds Eden entities in layer "MCC Mission Wizard",
  inside `collect3DENHistory`, so no sleeps).
- `mcc/fnc/security/` (Network Security Normal/Strict, `MCC_fnc_remoteAllowed` guard), `mcc/fnc/remote/` (small
  `MCC_fnc_rx*` functions that replaced code sent over the network), `mcc/fnc/supply/` (limited logistics,
  server-side resources `MCC_fnc_resChange`), `mcc/fnc/compat/` (ACE/RHS/CUP detection and class presets),
  `mcc/fnc/eden/` (applies Eden attributes over CBA settings via `CBA_settings_fnc_set`).
- `mcc/cfg/cfgFunctionsScripts.hpp`: legacy scripts registered as `MCC_fnc_s_*` (replaced execVM).
- Old MCC main menu dialogs (`mcc_groupGen`, login) still exist but are unreachable; some files there are still used
  by Zeus modules (dynamic dialog, save/load screen, convoy/hostage scripts). Don't delete without checking.

## Rules for new code
- Network: never send code. Use `remoteExec` to a named function or engine command, add it to
  `mcc/cfg/CfgRemoteExec.hpp` (functions) or `mcc/cfg/CfgRemoteExecCommands.hpp` (commands). Guard powerful
  remote-callable functions with `if !(["MCC_fnc_x"] call MCC_fnc_remoteAllowed) exitWith {};`.
- Side resources only through `MCC_fnc_resChange` (server-authoritative).
- New functions: `fn_<name>.sqf` with a short header (what, params, returns), `params [...]`, registered in the
  folder's cfgFunctions file (tag MCC or GAIA, `#ifdef MCCMODE` file path pattern).
- New mission-maker options: CBA setting in `mcc/settings/*.sqf`, then regenerate the Eden settings window.
- Respect other AI mods: don't force behaviour/stance on GAIA groups in contact when LAMBS is loaded
  (`["LAMBS"] call GAIA_fnc_compat`); GAIA's unstick stands down when `["HBQ"] call GAIA_fnc_compat`.
- Groups led by a player are never taken over by GAIA.

## Known open points (check in game)
- Everything since the revamp is untested in game: Eden menu, editor wizard (faction drop-down, marker colours,
  tasks), Zeus right-click menu, operation intro screen, GAIA performance and vehicle logic, logistics, PAA artwork.
- Wiki: `docs/wiki/*.md` is the source. `python3 tools/build_wiki_html.py site/index.html` builds the one-page
  site into `site/` (built-in Markdown converter, no CDN). Hosted on Cloudflare Pages (project `mcc5-wiki`,
  https://mcc5-wiki.pages.dev/, direct upload, no Git integration): after a wiki change commit the rebuilt
  `site/index.html` and deploy it with `npx wrangler pages deploy site --project-name mcc5-wiki --branch main`. The mod's Website button, in-game help and login screen link there.
