# Making a mod

The steps to make, test and publish a mod for DRH. Each one is a DRH Launcher command ([Mod repository](modding.md#mod-repository) says what each does); the rules are in the [modding document](modding.md), linked here instead of repeated.

- What a mod can read, listen to and draw: the [`api` reference](https://github.com/Tutez64/DRH-Mod-API/blob/master/docs/api.md).
- Examples: [Party Board](https://github.com/Tutez64/DRH-Mod-Party-Board) only uses the `api`; [Inspector](https://github.com/Tutez64/DRH-Mod-Inspector) reaches the game's own classes, and shows them as they run.
- Questions, and what the `api` should offer next: the [Discord server](https://discord.gg/VvWbNspZrQ).

## Commands

They run in a terminal, from the launcher's executable (DRH Launcher 0.4 or later). Below, `DRH-Launcher` stands for its path:

| System | Path |
| --- | --- |
| Windows | `"%LOCALAPPDATA%\DRH Launcher\DRH-Launcher"`; in PowerShell, `& "$env:LOCALAPPDATA\DRH Launcher\DRH-Launcher"` |
| Linux | `~/Applications/DRH-Launcher.AppImage` |
| macOS | `"/Applications/DRH Launcher.app/Contents/MacOS/DRH-Launcher"` |

They need git. Publishing needs a GitHub account.

## Create

1. `DRH-Launcher --new-mod <folder>` asks for the mod's `id` ([rules](modding.md#modjson): it is the mod's folder and package), its `name` and your `author` name, then makes the folder from [DRH-Mods-Template](https://github.com/Tutez64/DRH-Mods-Template), with its first commit.
2. It opens GitHub's page to create the repository: keep it public and named `DRH-Mod-<Name>` as it suggests (the index takes no other name), then push with the two lines it prints.
3. Fill `description` in `mod.json`, and `README.md`: its first line is what GitHub visitors read first, replace it with what the repository is; its shown zone is what the launcher shows on the mod's page ([markers](modding.md#mod-repository)). `DRH-Launcher --check-mod <folder>` says what is left.

## Write

The entry is `src/Main.hx`, a `mods.api.Mod`. Each file under `src/` is in `mods.<id>` or the sub-package of its folder ([package rule](modding.md#modjson)). The [`api` reference](https://github.com/Tutez64/DRH-Mod-API/blob/master/docs/api.md) lists what the mod gets: its lifecycle, the game's events and live state, the overlay to draw on, and its folders, `Resources/` to read and `data` to write.

A mod that only uses the `api` keeps working across DRH updates. Reaching the game's own classes, through `context.core`, makes it `extends`: add `"uses": ["extends"]` and `drh`, the DRH tags it was tested on, to `mod.json` ([Mod kinds](modding.md#mod-kinds)). The launcher warns its players that a DRH update may break it. Inspector shows how, and what there is to reach.

## Test

`DRH-Launcher --run-mod <folder>` installs what the mod needs from the index, the `api` included, and starts DRH with it. It prints the game's output, where `context.log` lines read `mod <id>: …`, then, once you quit, each mod's outcome ([Last-run report](modding.md#last-run-report)). The sources are read at each start: edit, quit, run again.

It runs the latest `api` of the major `mod.json` names. `api` is the version the mod is tested with ([rules](modding.md#modjson)): `--new-mod` writes the latest one; raise it when the mod starts using something a later `api` added.

## Publish

1. Raise `version` in `mod.json` ([rules](modding.md#modjson)) and commit. Tag that commit `v<version>` and push the tag (`git tag v0.1.0`, `git push origin v0.1.0`): the release workflow drafts a GitHub release with the mod's zip and its index entry.
2. Test that zip, `DRH-Launcher --run-mod <zip>`, then publish the release on GitHub.
3. `DRH-Launcher --submit-mod <folder>` proposes it to the index. The first time, it opens the index's fork page: fork it, then run it again. It opens the pull request's page: create it. The index CI checks it, and a reviewer reads its diff against your previous version ([Index entry](modding.md#index-entry)).
