# Making a mod

The steps to make and test a mod for DRH. The rules are in the [modding document](modding.md); this page links to them instead of repeating them. The DRH Launcher commands planned for these steps ([Mod repository](modding.md#mod-repository)) do not exist yet: the steps below are the manual ones.

## Create

1. On [DRH-Mod-Template](https://github.com/Tutez64/DRH-Mod-Template), *Use this template* creates your repository. Its name is free (`DRH-Mod-<Name>` is the suggestion); add the topic `drh-mod`.
2. Pick an `id` ([rules](modding.md#modjson)): it is the mod's folder and package. Replace `my_mod` with it in `mod.json` and in the `package` line of `src/Main.hx`, then fill `name`, `description` and `author`. `api` is the version of the `api` you test with (the `version` of its `mod.json`, as `major.minor`); keep it in step when you update that clone.
3. Write `README.md`: its shown zone is what the launcher will show on the mod's page ([markers](modding.md#mod-repository)); the line after it is for you, remove it.

## Write

The entry is `src/Main.hx`, a `mods.api.Mod` ([Lifecycle](modding.md#lifecycle)). Each file under `src/` is in `mods.<id>` or the sub-package of its folder ([package rule](modding.md#modjson)). What the `api` offers is in [The `api` mod](modding.md#the-api-mod) and its sources ([DRH-Mod-API](https://github.com/Tutez64/DRH-Mod-API)). Reaching the game's own classes is an `extends` mod ([Mod kinds](modding.md#mod-kinds)).

## Test

1. Make a mods folder and clone into it your repository under its `id`, and DRH-Mod-API as `api`. Work in that clone: a mod's repository is its folder.

   ```sh
   git clone <your repository> "$HOME/drh-mods/<id>"
   git clone https://github.com/Tutez64/DRH-Mod-API "$HOME/drh-mods/api"
   ```

2. List both in `enabled.json`, in that folder ([Passing the list](modding.md#passing-the-list)):

   ```json
   { "mods": [{ "id": "api" }, { "id": "<id>" }] }
   ```

3. In [DRH Launcher](https://github.com/Tutez64/DRH-Launcher), add the folder's absolute path to *Options*, *Extra arguments*: `--mods-dir "/home/me/drh-mods"`. Then *Play*. From a terminal, the same flag works in the game's folder ([Disk layout](modding.md#disk-layout)): `./"Dungeon Rampage Haxe" --mods-dir "$HOME/drh-mods"`.

4. Mods compile when the game starts. `last-run.json`, written in the mods folder, gives each mod's outcome ([Last-run report](modding.md#last-run-report)). The game's session log, in the launcher, shows what a mod logs (`context.log`) as `mod <id>: …`, and why a module failed.

The sources are read at each start: edit, quit, run again.

## Publish

Not open yet: the release workflow, `--pack-mod`, `--submit-mod` and the index come later ([Mod repository](modding.md#mod-repository)). Until then, a mod is shared as its repository, cloned as above.
