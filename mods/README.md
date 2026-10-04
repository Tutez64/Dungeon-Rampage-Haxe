# Example mods

Run DRH with `--mods-dir <absolute path to this folder>`. `enabled.json` loads all of them; the game writes `last-run.json` here.

| Id | Role | Expected in `last-run.json` |
| --- | --- | --- |
| `api_tour` | Uses every `modding.*` member and checks the contract. Each check logs `ok` or `FAIL`; the panel top-left shows the totals. | `ok` |
| `broken_init` | Subscribes, draws a red square, then throws in `onInit`. Nothing of it may show or fire afterwards. | `failed` |
| `null_ready` | Calls a method on `null` in `onReady`. The game keeps running; the mod goes quiet. | `failed`, `Null Object Reference` |
| `null_field` | Reads `state.floor.number` in `onInit`, before any floor exists. | `failed`, `Null access to field number` |
| `not_installed` | Listed in `enabled.json`, no folder. | `skipped` |
| `dep_ready` | Depends on `null_ready` but loads before it. Goes quiet when `null_ready` fails in `onReady`. | `failed`, `dependency null_ready failed` |
| `dep_missing` | Depends on `not_installed`. Never loads. | `failed`, `dependency not_installed missing` |
| `dep_failed` | Depends on `broken_init`. Never reaches `onInit`. | `failed`, `dependency broken_init failed` |
| `dep_chain` | Depends on `dep_failed` only. | `failed`, `dependency dep_failed failed` |
