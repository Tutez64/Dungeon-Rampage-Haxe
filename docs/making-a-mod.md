# Making a mod

The steps to make, test and publish a mod for DRH. Each one is a DRH Launcher command ([Mod repository](modding.md#mod-repository) says what each does); the rules are in the [modding document](modding.md), linked here instead of repeated.

## Commands

They run in a terminal, from the launcher's executable (DRH Launcher 0.4 or later). Below, `DRH-Launcher` stands for its path:

| System | Path |
| --- | --- |
| Windows | `"%LOCALAPPDATA%\DRH Launcher\DRH-Launcher"`; in PowerShell, `& "$env:LOCALAPPDATA\DRH Launcher\DRH-Launcher"` |
| Linux | `~/Applications/DRH-Launcher.AppImage` |
| macOS | `"/Applications/DRH Launcher.app/Contents/MacOS/DRH-Launcher"` |

They need git. Publishing needs a GitHub account.

## Create

1. `DRH-Launcher --new-mod <folder>` asks for the mod's `id` ([rules](modding.md#modjson): it is the mod's folder and package), its `name` and your `author` name, then makes the folder from [DRH-Mod-Template](https://github.com/Tutez64/DRH-Mod-Template), with its first commit.
2. It opens GitHub's page to create the repository: keep it public, add the topic `drh-mod`, then push with the two lines it prints.
3. Fill `description` in `mod.json`, and `README.md`: its shown zone is what the launcher shows on the mod's page ([markers](modding.md#mod-repository)); the line after it is for you, remove it. `DRH-Launcher --check-mod <folder>` says what is left.

## Write

The entry is `src/Main.hx`, a `mods.api.Mod` ([Lifecycle](modding.md#lifecycle)). Each file under `src/` is in `mods.<id>` or the sub-package of its folder ([package rule](modding.md#modjson)). What the `api` offers is in [The `api` mod](modding.md#the-api-mod) and its sources ([DRH-Mod-API](https://github.com/Tutez64/DRH-Mod-API)). Reaching the game's own classes is an `extends` mod ([Mod kinds](modding.md#mod-kinds)).

## Test

`DRH-Launcher --run-mod <folder>` installs what the mod needs from the index, the `api` included, and starts DRH with it. It prints the game's output, where `context.log` lines read `mod <id>: …`, then, once you quit, each mod's outcome ([Last-run report](modding.md#last-run-report)). The sources are read at each start: edit, quit, run again.

It runs the latest `api` of the major `mod.json` names. `api` is the version the mod is tested with ([rules](modding.md#modjson)): `--new-mod` writes the latest one; raise it when the mod starts using something a later `api` added.

## Publish

1. Raise `version` in `mod.json` ([rules](modding.md#modjson)) and commit. Tag that commit `v<version>` and push the tag (`git tag v0.1.0`, `git push origin v0.1.0`): the release workflow drafts a GitHub release with the mod's zip and its index entry.
2. Test that zip, `DRH-Launcher --run-mod <zip>`, then publish the release on GitHub.
3. `DRH-Launcher --submit-mod <folder>` proposes it to the index. The first time, it opens the index's fork page: fork it, then run it again. It opens the pull request's page: create it. The index CI checks it, and a reviewer reads its diff against your previous version ([Index entry](modding.md#index-entry)).
