# Example mods

Run DRH with `--mods-dir <absolute path to this folder>`. `enabled.json` loads all three; the game writes `last-run.json` here.

| Id | Role | Expected in `last-run.json` |
| --- | --- | --- |
| `api_tour` | Uses every `modding.*` member and checks the contract. Each check logs `ok` or `FAIL`; the panel top-left shows the totals. | `ok` |
| `broken_init` | Subscribes, draws a red square, then throws in `onInit`. Nothing of it may show or fire afterwards. | `failed` |
| `not_installed` | Listed in `enabled.json`, no folder. | `skipped` |
