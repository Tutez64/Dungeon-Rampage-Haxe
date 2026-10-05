# Example mods

Run DRH with `--mods-dir <absolute path to this folder>`. `enabled.json` loads all of them; the game writes `last-run.json` here. Every one builds on the `api` mod, which has its own repository (not published yet): without it, each fails with `dependency api missing`.

| Id | Role | Expected in `last-run.json` |
| --- | --- | --- |
| `api_tour` | Uses every `mods.api` member and checks the contract. Each check logs `ok` or `FAIL`; the panel top-left shows the totals. | `ok` |
| `broken_init` | Subscribes, draws a red square, then throws in `init`. Nothing of it may show or fire afterwards. | `failed` |
| `null_ready` | Calls a method on `null` in `ready`. The game keeps running; the mod goes quiet. | `failed`, `Null Object Reference` |
| `null_field` | Reads `state.floor.number` in `init`, before any floor exists. | `failed`, `Null access to field number` |
| `not_installed` | Listed in `enabled.json`, no folder. | `skipped` |
| `dep_ready` | Depends on `null_ready` but loads before it. Goes quiet when `null_ready` fails in `ready`. | `failed`, `dependency null_ready failed` |
| `dep_missing` | Depends on `not_installed`. Never loads. | `failed`, `dependency not_installed missing` |
| `dep_failed` | Depends on `broken_init`. Never reaches `init`. | `failed`, `dependency broken_init failed` |
| `dep_chain` | Depends on `dep_failed` only. | `failed`, `dependency dep_failed failed` |
| `wrong_base` | Its entry extends `modding.Mod`, not `mods.api.Mod`. | `failed`, `entry must extend mods.api.Mod` |
