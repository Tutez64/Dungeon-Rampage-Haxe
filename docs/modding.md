# DRH modding

Living design document. Not a user guide or an implementation commitment. `decided` rows below are frozen.

The game owns the runtime. The launcher owns the folder, enablement, and launch. Launcher-side catalog and install: [DRH Launcher architecture](https://github.com/Tutez64/DRH-Launcher/blob/master/docs/architecture.md) (Mods). This document is the source of truth for how mods load and talk to DRH.

## Open decisions

`open` = not decided. `recommended` = working direction. `decided` = frozen here. Notes stay short; the linked section has the rule.

| Topic | Status | Notes |
| --- | --- | --- |
| Fairness / `layers` | decided | No fairness police. `layers` dropped; taxonomy is `uses`. [Policy](#policy) |
| First-run disclosure | decided | Once in DRHL; `--play` gated like updates. [First-run disclosure](#first-run-disclosure) |
| API surface | decided | Host core `modding.*` + `api` mod + host `extends` / `replace`. [API surface](#api-surface) |
| hxScript fork | decided | Lasting fork: classpath-entry scan + `replace`. [API surface](#api-surface), [Compilation](#compilation) |
| Mod kinds | decided | Every mod builds on `api`. `uses`: `extends` / `replace`, empty for stable only (recommended). [Mod kinds](#mod-kinds) |
| Dependencies | decided | Versioned. The launcher installs them; a failure fails the dependents. [`mod.json`](#modjson) |
| Enabled list | decided | `mods/enabled.json` + `--mods-dir`. No flag → no mods. [Passing the list](#passing-the-list) |
| Debug scan | decided | Same `--mods-dir`. Later optional: `--mods-all`, `--mod <id>`. No implicit scan next to the exe. |
| Lifecycle | decided | `onInit` before `new DBFacade()`, `onReady` before the loop, `onDispose` on `exiting`. [Lifecycle](#lifecycle) |
| hxScript `Environment` | decided | One shared world, one compile batch, package `mods.<id>`. [Compilation](#compilation) |
| Checksummed JSON overlay | decided | No extra warn/block. [Policy](#policy) |
| Game → launcher status | decided | `mods/last-run.json` + one log line per mod. [Last-run report](#last-run-report) |
| `mod.json` schema | decided | [`mod.json`](#modjson) |
| cppia bytecode cache | open | Future optimization, not v1. |
| Private / offline scripted gameplay | open | Out of scope while DRH only talks to official servers. |
| Distribution | decided | Pointer index we control; not a monorepo; not Thunderstore/Nexus as identity. [Distribution](#distribution) |
| Trust for updates | decided | Trust artifacts (`id` + version + SHA-256), not author repos. |
| v1 discovery UI | decided | Minimal catalog in DRHL, same index a later site can reuse. |
| Index schema / repo URL | open | Draft shape in [Distribution](#distribution). |
| Mod page in the launcher | open | What it shows is undecided. The long description (`README.md` and its markers) is a draft: [Mod repository](#mod-repository). |
| Mod repository and publishing | decided | Repo = mod folder from `DRH-Mod-Template`, DRH Launcher commands for every step (checks implemented once, also run by the index CI), `vX.Y.Z` tags, flat zip, PR to the index with git. [Mod repository](#mod-repository) |
| Thunderstore / Nexus / itch as mirrors | open | Optional later; must not replace `mod.json` or the index. |
| Resource overlay rules | open | `Resources/` is composited at runtime; precedence, SWF vs JSON, and `Locale/` merge are unspecified. No separate `locale/` tree. |
| Type blacklist | decided | None. Interpreted and compiled see the same types. [Compilation](#compilation) |
| Host build (cppia) | decided | `-dce no`, force-include std, patch hxcpp, JIT on, verbose log, `HXCPP_CHECK_POINTER`. [Compilation](#compilation) |
| Mod `id` and zip extract | decided | `id` = folder = package `mods.<id>`. Regex + keyword/reserved-name lists. No zip-slip, no size cap. [`mod.json`](#modjson) |
| `dependencies` cycles | decided | Not an error. Order inside a cycle is not defined. [Passing the list](#passing-the-list) |
| `import.hx` in a mod | decided | Skipped with a warning. [`mod.json`](#modjson) |
| `drh` in `mod.json` | decided | Required with `extends` / `replace`, omitted for `api` only. Closed tag string. Warns, does not block. [`mod.json`](#modjson) |

## Context

Dungeon Rampage Haxe (DRH) is a Haxe/OpenFL port, compiled natively with **hxcpp**. Official Dungeon Rampage is still moving (art overhaul, Starling for 1.0), so DRH internals will keep changing.

The script runtime is a **fork** of [hxScript](https://github.com/MeguminBOT/hxscript), pinned as [`submodules/hxscript`](https://github.com/Tutez64/hxscript): mods in ordinary Haxe, compiled **in-process** to cppia, no Haxe toolchain on the player's machine. Same model as the other submodules: rebase on upstream, stack our commits, PR immediately, do not wait for acceptance. Stock hxScript bridges whole packages (`-D hxscript_bridge_packages`). The fork adds the classpath-entry scan, the exclude list, and `replace`.

Constraints:

- hxcpp only (`project.xml`).
- Fully multiplayer on official servers. The client `sCode` fold is not a catalog special case ([Policy](#policy)).
- Updates replace `Dungeon Rampage Haxe/current/`. Mods live **outside** that directory.

## Architecture

```mermaid
flowchart LR
  subgraph publish [Publish]
    author["author zip + hash"]
    index["index repo"]
  end
  subgraph launcher [DRH-Launcher]
    catalog["v1 catalog"]
    modsDir["install-dir/mods/"]
    enabled["enable + load order"]
  end
  subgraph game [DRH hxcpp]
    host["modding host"]
    hxscript["one shared Environment"]
    cppia["compile cppia or interp"]
    core["modding core"]
    gameCore["GameMaster timelines UI"]
  end
  author -->|"PR per version"| index
  index --> catalog
  catalog -->|"verify SHA-256"| modsDir
  modsDir --> enabled
  enabled -->|"--mods-dir + enabled.json"| host
  host --> hxscript
  hxscript --> cppia
  cppia -->|"api mod"| core
  cppia -->|"extends / replace"| gameCore
  core --> gameCore
```

The launcher does not compile. It discovers mods, keeps the enabled set and load order, and passes `--mods-dir`. The game loads every enabled mod into **one** hxScript `Environment` (`mods.<id>`), compiles that world in one batch, and interprets what the emitter skips. Every mod builds on the official `api` mod. `extends` / `replace` are explicit, costlier kinds on top.

"Compiled" means `Compiler.compile(env)` inside the game process at load — not a rebuild of the DRH binary, and not a Haxe compile in the launcher.

| Role | Owns |
| --- | --- |
| Launcher | folder, index/catalog, enablement, `--mods-dir`, first-run disclosure. No Haxe toolchain. |
| Game | parse the flag, load, compile, lifecycle, `last-run.json`. |
| Author | zip + `mod.json`. Publish = PR to the index. Playing does not need the Haxe SDK. |

## Policy

DR is PvE, not a ladder. The official client is already leaky; DRH itself is a modified client. v1 does **not** reject mods for in-game advantage (exact HP, FOV, stacked-chest UI, chat macros, damage meters, client bugfixes).

How you hook is `uses` (`extends` / `replace`, or nothing). A `layers` field (client / data / gameplay) was dropped: FOV is “client” and a large advantage; a mana-check patch sits in a weapon controller; it reopened the fairness debate.

**Official tables and `sCode`.** `Resources/Levels/DB_GameMaster.json`, `Resources/Combat/AttackTimeline.json`, and `Resources/Levels/library_server.json` feed `mSecurityGM` / `mSecurityTL` / `mSecuritySL`. The fold only counts runtime `"int"` fields; AttackTimeline is **shallow** (top-level keys of each attack: name, flags, `totalFrames`, the `frames` array object — not nested actions). `{ "type": "helloMod" }` does not change `mSecurityTL`. Timeline/library values are then `% 1097`. `blockCheater()` is only `Hero.BaseMove > 250` in the loaded GameMaster. `sCode` is sent on `ClientRequestEntry`; server use is **unknown**. A mismatch would at most fail dungeon entry (`ResponceCode != 0`). It is not an automatic ban in the client.

v1 does **not** warn or block those three paths in the index, the launcher, or the host. An indexed mod was reviewed and plays; sideload is already labeled unreviewed. Index review still refuses or yanks malware and combat bots / protocol spoof.

## First-run disclosure

DRHL shows this **once** (launcher config) the first time the user would actually use mods: first enable, or first Play with a non-empty `enabled.json`. Do not nag every launch. **`--play`** with a non-empty `enabled.json` and no confirmation yet opens the **full UI**, like an available update. Browsing the catalog does not require it. Not an EULA lecture: one line that DRH is already a modified client is enough.

1. **Code in-process.** Haxe/cppia inside the game, not a skin pack. Index review is human, not a proof. Sideload is weaker.
2. **Official servers.** Same as vanilla DRH. No promise about bans either way.
3. **Updates.** Mods follow the `api` mod's major version. `extends` / `replace` can also break on any DRH update. A modded session is not supported like vanilla.
4. **Several mods.** `replace` on the same rewritten surface can clash. Load order is in the launcher.
5. **Back to vanilla.** Disable all mods / Play with an empty list. Nothing is written into `current/`.
6. **EULA / blessing.** Like DRH, this is not the official Steam client; rights holders do not endorse it.

## API surface

hxScript is ordinary Haxe in-process, not a JS-style "patch any function" runtime. `private` / `inline` / `final` methods, and a comparison buried inside a compiled function, stay out of reach.

**Core + `api` mod + host types.** Every mod builds on the `api` mod. `extends` / `replace` exist so a mod can still reach what it does not cover. The `submodules/hxscript` fork commit is the pin, rebased on upstream, PR'd once it works for DRH. hxScript's compiler is BETA; `replace` touches bridge generation and the emitter, so rebases will conflict more than on lime/openfl. Accepted: the goal is a clean `replace`, not the smallest diff.

- **Core (`modding.*`, in the host).** What must exist before any mod or touches `src/`: loading, compile, [Lifecycle](#lifecycle), isolation, overlay layers, key routing, and the [game events](#game-events) that hand game objects. Small, and changes only with a release. The foundation of `api`, not meant for mods: a host type like any other, so using it directly is `extends`.
- **`api` mod (`mods.api.*`).** The official mod that turns game objects into stable wrappers (players, heroes, weapons, floor, account, art) and re-emits [its own events](#the-api-mod). Not raw `HeroGameObject`. A fix or an addition is a new `api` version, not a game release. What its version promises is in [Versioning](#versioning).
- **Host types.** Two features:

### Bridges

A scriptable base is any eligible class that ships as **game or engine code**: DRH's own source roots and the vendored engine. Not bridged: the **toolchain** (hxcpp, hxScript, Haxe std) and haxelibs the engine uses internally (`format`). A curated allow-list puts the burden of proof on the wrong side.

| Root | Package(s) | In / out |
| --- | --- | --- |
| `src/` | 35 packages incl. vendored `box2D`, `org`, `com`, `generatedCode` | in — the game |
| `src-steam/` | `com.amanitadesign.steam` (FRESteamWorks shim, `if="cpp"`) | in — DRH code; `replace(FRESteamWorks, …)` intercepts Steam calls |
| `compat/` | `compat.*` plus 15 **root-level** files (`ASCompat`, `ASDictionary`, `ASProxyBase`, …) | in — DRH code. Abstracts (`ASAny` / `ASObject` / `ASFunction`) and macros drop out via `eligible()` / `*.macro.hx` |
| `submodules/openfl` | `openfl` | in — display list (`Sprite`, `MovieClip`, `Bitmap`, `TextField`, …) |
| `submodules/lime` | `lime` | in — windows / input / timing |
| `submodules/swf` | `swf` | in — Animate symbols and timelines |
| `submodules/SteamWrap` | `steamwrap` | in — binding under `src-steam`; mostly `@:cffi` / statics, near-zero cost |
| `submodules/hxcpp` | — | out — C++ runtime / build tool. `cpp.*` lives in the Haxe std |
| hxScript (`-lib hxscript`) | `hxscript` | out — the loader, not game content. `replace(Environment, …)` would rewrite the loader that loaded the mod; `compile.*` / `cppia.*` bridges break on every rebase |
| Haxe std, `cpp.*` | — | out of the *bridge* scan — presets handle the std; `cpp.*` is almost all `extern` / `abstract` / `@:coreType` |
| haxelib `format` | `format` | out — used from Lime / OpenFL / swf internals, never from `src/`. Add it the day someone has a use |

"Not bridged" means **no `extends`**, not "unreachable": a mod can call any host static (`cpp.vm.Gc.run`, …). The GC *algorithm* is C++ / compile-time defines, out of reach by nature. What keeps unreferenced std members in the binary is DCE / include, not bridging ([Compilation](#compilation)).

One default exclusion: **`DungeonBustersProject`**. Lime's `ApplicationMain` constructs it **before** the host exists (the host runs inside its constructor), so `replace` is impossible and `extends` would be a second application. Its bridge would be the whole `Sprite` surface through `GameEntry` for a use that cannot exist. The other two `src/` root classes (`Loading_screen_swf`, `Db_UI_skip_button_swf`) stay in: they go through `ASCompat.createInstance`, which consults the `replace` table.

Whole submodule trees are bridged (`openfl._internal`, Lime backends included). Stock hxScript's thin OpenFL preset (`Sprite` only) is a size default, not a limit. **Measure first:** the first cppia build records binary size and build time; the lever if it is too fat is `hxscript_bridge_exclude`, not `final` on DRH types one by one.

The fork keeps upstream `Bridges.eligible`. Four rules are Haxe; two are scan filters:

| Kind | Source | Why skipped |
| --- | --- | --- |
| `final class` | language | Haxe forbids the subclass. Un-`final` a type we own if it must be extendable (kills hxcpp de-virtualisation on that type). In `src/` only vendored helpers (`com.greensock`, `com.adobe`, `com.wildtangent`), `AssetCache` and `RootFacade` are `final`. |
| `extern class` | language | No Haxe body. Scripts can still *call* it. |
| `interface` | language | Not a class base. Scripts **`implements`** a native interface already. |
| `private class` | language | Invisible from a mod package. Make it `public` in DRH if a mod needs it. |
| generic class (`Foo<T>`) | `eligible()` | Haxe allows `extends Foo<Int>`; the generated bridge cannot substitute the erased parameter. DRH has no generic class; v1 does not lift this. |
| class without its own constructor | `eligible()` | Conservative: generator already handles inherited `super`. In DRH the only such class is `RootFacade`, already `final`. Lever = the filter, not an explicit `new` added to DRH. |

`-D hxscript_bridge_types` also goes through `eligible()`; only the presets' curated bases skip it. `-D hxscript_verbose` names every skipped module and why.

`final` / `inline` **methods** on an otherwise scriptable class still cannot be overridden.

Do not hand out internal instances as the stable API. A HUD that peeks `actor.HeroGameObject` is an `extends` mod, even if it only reads fields.

### `replace`

Explicit `replace(HostClass, Sub)` so host `new HostClass(...)` constructs the subclass. **`extend` is not `replace`.** `class HudIcon extends Sprite` is a widget; it does not steal OpenFL's `new Sprite()`. Only `replace(Sprite, …)` would. Same rule for every type, including OpenFL/Lime: no special blacklist.

Disjoint-method merge lives in hxScript; DRH calls `replace` and gets one class or a conflict. A `new` rewrite does not see dynamic instantiation. DRH's own goes through **`ASCompat.createInstance`** (`compat/ASCompat.hx`): `AssetRepository`, the loading clip, the skip button, every `var X:Dynamic = SomeClass` pattern. The host makes `createInstance` consult the same `replace` table. That function is `inline`, so the lookup goes **into its body**; a runtime wrap would miss every already-inlined call site. Outside: Lime's `Type.createInstance` (e.g. `AnimateLibrary` from the asset manifest) — `extends` works, `replace` does not.

- Off by default: a type is replaceable because a mod registered it, not because it is scriptable or because a script `extend`s it.
- Any number of mods may `extend` without `replace`. Several `replace` on the same base are OK if rewritten methods/fields/`new` do not overlap. Overlap → error or explicit priority. Residual risk: `A.update` can call `this.onWeaponDown()` and hit `B`'s override on the same instance. A wrap/`callNext` chain is how you *intentionally* stack one method. Out of scope to prove disjoint `this` use statically.

### Versioning

- The **stable** API is `mods.api.*`, nothing else. The core (`modding.*`), `facade.DBFacade`, `actor.*`, `combat.*`, `uI.*` are host types: usable via `extends` / `replace`, not covered.
- The `api` mod's version is semver over its written contract: when an event fires, what a wrapper represents, the empty-until-event rules. A fix is a patch, an addition a minor, a change to that text a major. A core change is absorbed by `api` where it can be; its major moves only when its own contract does. Game content behind a stable reading, and OpenFL/Lime used to draw on the overlay, are outside it.
- The `api` mod is `extends`: its `drh` lists the tags it was verified on. It lives in its own repository, published and indexed like any mod; DRH pins it as the `mods/api` submodule, the version its examples and test mods run against. `api` and its index entry are published **before** the DRH release, so a release is never without one: a DRH tag only drafts its release; that draft's archive is tested by hand with `api` (a dungeon run with `api_tour`; everything past `onReady` needs an account, and social actions are never exercised), then a version whose `drh` adds the tag is published and indexed (a patch when the code did not change), then the DRH release. The launcher installs the highest `api` version that satisfies every enabled mod, one whose `drh` contains the installed tag first ([`mod.json`](#modjson)). The game does not check versions.
- Official examples for all three kinds live in [`mods/`](../mods/) (stable only so far) and load with the pinned `api` on every tag. A signature break fails that load. Whether a call site still matches the written when/what is review.

## Mod kinds

Every mod depends on `api` (`mod.json` `api` field). `uses` says what it touches beyond it. Recommend stable only; the other two exist because the `api` mod will not cover everything.

| Kind | What it means | DRH versions | Other mods |
| --- | --- | --- | --- |
| stable only (`uses` empty) | Uses only `mods.api.*`. OpenFL/Lime for drawing on the overlay is OK; the core, `actor.*` / `combat.*` / `facade.*` are not. | Tied to the `api` major. [Versioning](#versioning). | Best. No `replace` occupancy. |
| `extends` | Subclasses or calls **host** types but does **not** `replace` vanilla `new`. Helpers, `new MyRepeater()`, reading public internals. | Tied to those class/method names. Starling / conversions can break it even if `api` is unchanged. | Usually fine with others. Still shares live objects with a `replace` on the same type (`is RepeaterWeaponController` remains true). |
| `replace` | Explicit `replace(HostClass, Sub)` at `onInit`. Host `new HostClass(...)` becomes the subclass (merge if rewritten methods/fields/`new` are disjoint). | Same host-type fragility as `extends`, plus construction. | Conflicts when rewritten surfaces overlap. One occupancy per method/field/`new`. |

A mod may list both (`uses: ["extends", "replace"]`). Catalog / index show the **strongest** present: `replace` > `extends` > stable only (labelled `api`). Index review checks the declare matches the code (honor + grep). Sideload can lie; label it. The `api` mod is shown as official, without that label or its warning; its `extends` and `drh` still drive which version is installed.

Players see a short warning on `extends` / `replace` (may break on game updates; `replace` may clash), not a fairness lecture.

## Lifecycle

Core. `mods.api.Mod` mirrors them as `init(context)`, `ready(context)` and `dispose()`, with its own `Context`, at the same moments, and its major covers that. They are **boot** hooks; names are frozen. Two anchors: `onInit` = nothing of the game exists yet; `onReady` = every singleton exists (tables, account, inventory, clock, network) and the loop is about to start. Neither means "a hero is on screen": live moments are **events**.

`mod.json` `entry` extends `mods.api.Mod` (only the `api` mod's own extends `modding.Mod`); otherwise the host fails the mod (`entry must extend mods.api.Mod`). All three methods are optional (empty defaults).

| Method | When | Typical use |
| --- | --- | --- |
| `onInit(ctx:ModContext)` | `DungeonBustersProject` constructor, after `--mods-dir` parse + compile, **before `new DBFacade()`**. Process and `stage` are up; **nothing of the game is constructed** (no facade, no `Logger`, no clocks, no camera, no state machine, no `FRESteamWorks`; `FeatureFlags` does not exist yet and its values come later anyway). | `replace(...)`, subscribe, draw on the overlay layer `ctx` hands out. State wrappers empty. Read feature flags in `onReady`. |
| `onReady(ctx:ModContext)` | `LoadingFinishedEvent`, inside `DBFacade.architectureLoaded`, after `mDBAccountInfo` is set and `gameClock.initTime()`, **before `run()` and `mainStateMachine.start()`**. Tables, account (inventory, active avatar, friends), feature flags (CLI + config), matchmaker, server time, clock are up; the loop has not ticked. No town, hero, or floor. **Once** per process. | Read tables and account-level wrappers. Closest to Unity `Start`. Hero / floor wrappers stay empty until the matching event. |
| `onDispose()` | `NativeApplication` **`exiting`**, registered at the **top** of the constructor (before compile, ahead of the game's listener, so it runs **before `mSteamworks.dispose()`**). Once, reverse load order. Every graceful exit (window close, `WM_CLOSE`, `SIGTERM`, Cmd+Q, Quit, socket error). The launcher's Stop force-kills after **3 s**. Not called on a crash, a force-kill, or if the loop never pumps the quit (compile stuck, hung frame). | Timers, listeners, flush a local file. No network, no waiting. Must not block exiting. |

`onInit` is before `new DBFacade()` because that is the only placement where **`replace` covers every host `new`**. HUD, sound, Steam Input and `MainStateMachine` are built later (`stagetwo_init`, `buildEngines`, `createHUD`); an `onInit` at the end of `onInvoke` would already see them. What it would miss is field initialisers and `Facade.init`: **`FRESteamWorks`** (`mSteamworks = new FRESteamWorks()` runs inside `new DBFacade()`, before `init()`), both `GameClock`s, `EventManager`, `Camera`, work managers, letterbox, loading clip. A second early hook would be a second "what exists here" list, and that list moves with Starling. Steam identity and the auth ticket are readable from `onReady`; feature flags are only complete after `LoadingState.configReady`. `AssetRepository`, the loading clip and the skip button go through `ASCompat.createInstance` (same `replace` table).

`onReady` is `LoadingFinishedEvent`, not `ManagersLoadedEvent`, because the `api` mod promises an **inventory** wrapper and inventory is account data. At `ManagersLoaded` the tables are in and the account / matchmaker / `initTime()` are not. Mutating GameMaster before the account is parsed against it is the additive `tablesLoaded` event, not a fourth method.

**Order:** `onInit` → (`tablesLoaded`) → `onReady` → any gameplay event. Town / tutorial dungeon is entered by the `mainStateMachine.start()` that follows `onReady`, so no `heroSpawned` / `floorEnter` can precede it. In a dungeon, a hero's `heroSpawned` follows its floor's `floorEnter` (the host holds the hero back until then).

**Boot that never reaches `onReady`:** `SocketErrorState` (service discovery failed) and `blockCheater()` — `ManagersLoadedEvent` never fires. Mods must tolerate a missing `onReady`; `last-run.json` records `ready: false`. An account with **no active avatar** is *not* that case: `MainStateMachine.start()` logs and returns, but it runs **after** `onReady`, so `ready: true` and no town. Wait for `heroSpawned`, do not infer a hero from `onReady`.

**Return to town (`ReloadTownState`) is not a second `onReady`.** That is additive `townEnter`.

Host obligations:

- **Overlay root stays on top.** Root z-order is `Facade.addRootDisplayObject(child, layer)` (letterbox at 1000, loading clip at 0), not `stage.addChild`. A child added during `onInit` is unknown to `mChildLayer` and counts as layer 0, so the letterbox lands above it. After `DBFacade.init` the host re-registers the overlay above the letterbox. Inside it, each mod has its own layer (`ctx.overlay`), in load order. Authors do not manage z-order against vanilla.
- **No `Logger` during `onInit`.** `Logger.init` runs inside `Facade.init`. The host buffers compile / `onInit` logs and flushes them, or uses `trace`.
- **Throw isolation.** Move the game's `uncaughtError` listener to the **top** of the constructor (null-guard `mDBFacade`) so compile, `onInit` and `new DBFacade()` are inside it. That listener catches event-dispatch errors, not a synchronous throw in the constructor chain: the host still wraps each mod's compile and `onInit` in try/catch. Isolation is the `modding.*` contour (`onInit` / `onReady` / event handlers). The build sets `HXCPP_CHECK_POINTER`, so a null dereference in mod or game code throws `Null Object Reference` and follows these rules rather than killing the process. A throw in `onDispose` is logged and ignored. A throw from a **replaced host method** is a host throw. A `replace` subclass whose **constructor throws while `new DBFacade()` or `init()` constructs it** kills the boot. Accepted. `last-run.json` is written right after `onInit` (`ready: false`); the launcher's "process exited + `ready: false`" reading covers it.
- **A failed mod goes quiet.** A throw in `onInit` or `onReady` cancels all its subscriptions (those to [`api` events](#the-api-mod) included) and removes its overlay layer; `last-run` is `failed`. After a failed `onInit`: no `onReady`, a `replace` from that call is dropped, later mods still start, its types stay. A failed `onReady` does not undo a `replace`. `onDispose` still runs at exit. Files, threads, and statics are not rolled back. A throw in an event handler is only logged.
- **A failed dependency fails its dependents.** When a mod fails (load, `onInit`, `onReady`), every enabled mod that depends on it (`api` or `dependencies`), directly or through another, fails too (`dependency <id> failed`) and goes quiet the same way, whatever the load order. A dependency that is skipped or not enabled fails the mod before it loads (`dependency <id> missing`). Versions are the launcher's check, not the game's.
- **Startup cost.** Parse + compile of every enabled mod happens before the first frame (hxScript: ≈10 ms per module). Measure with real mods. If it becomes a visible black window, the fix is a splash **before `new DBFacade()`** (OpenFL preloader, or a Lime-level clip), not a split of `init()`: `new DBFacade()` already constructs `FRESteamWorks`. A bytecode cache is the later lever.

### Game events

Subscribe from `onInit` or `onReady` with `ModContext.on<Event>(handler)` (`onHeroSpawned(f:HeroGameObject->Void)`, `onTownEnter(f:Void->Void)`, …), which returns a `ModSubscription` (`cancel()`). Host-emitted; not existing game `Event` class names. They are what the `api` mod is built on; an event is added in a release when it needs a hook it cannot reach otherwise.

| Event | Hands | When |
| --- | --- | --- |
| `heroSpawned` / `heroDespawned` | `HeroGameObject` | A hero (local **or** other players) is initialised on a dungeon floor / is destroyed. Dungeon only. |
| `floorEnter` / `floorExit` | `DistributedDungeonFloor` | A dungeon floor starts (grid built, map node set) / is destroyed. |
| `tablesLoaded` | — | `ManagersLoadedEvent`: tables in, account not yet parsed against them. Window to mutate tables (`extends` use). |
| `townEnter` / `townExit` | — | `TownState` entered / left, including `ReloadTownState`. |
| `keyDown` | key code | A key goes down: once per press, not while a text field (chat) has focus. A handler returning `true` keeps the key: the game never sees that press (its shortcuts, OpenFL's Tab focus, repeats, release). |

`ModContext`: overlay layer and view size, log, `replace`, these subscriptions, `facade` (from `onReady`, a host type), and `alive`, false once the mod failed, so another mod holding handlers for it stops calling them.

### The `api` mod

`mods.api.*`, loaded before every other mod. `mods.api.Mod` hands its own context: overlay layer, view size, log, `tablesLoaded`, `townEnter` / `townExit`, `keyDown`, the hero and floor events with wrappers, and the raw core `ModContext` (`core`, an `extends` use). Its subscriptions hold the subscriber's `ModContext`: a handler of a failed mod is no longer called (`alive`), and a handler's throw is logged under that mod.

Its types sit by what they read: `mods.api` (`Mod`, `Context`, `State`, `Subscription`), `mods.api.dungeon` (`Floor`, `Hero`, `Player`), `mods.api.account` (`Account`, `Inventory`, `OwnedHero`, `Pet`, `Stack`, `Weapon`). `mods.api._internal` is the `api` mod's own plumbing: not API, not covered by its version.

Pattern: subscribe in `init`, read tables and account in `ready`, react to spawn/floor for anything with a hero in it. Do not assume a hero exists in `ready`. Wrappers that need a hero or floor stay empty until the matching event. Town has no heroes: the selected avatar is the account (read live); friends' avatars will be an account-level wrapper.

`context.state` holds the live window, shared by every mod: the account (read live, from `ready`: currencies, trophies, `inventory`), the floor in progress, the heroes on it (a copy), and the players met in the dungeon in progress (a copy). A hero and its player are two wrappers. `Hero` is what a player plays on one floor (class, level, `weapons` as `Weapon` copies); each floor gives a new one, and its fields go empty after the `heroDespawned` handlers. `Player` is the account behind it (`hero.player`): one instance from its first hero to the return to town, listed in `state.players` with those who left, with `hero` null while it has none. It holds the screen name, `isFriend`, and the end screen's `addFriend`, `block` and `report` (the game's own popups for the last two). `inventory` lists, as copies, the weapons, pets and consumables in storage and the account's heroes: an `OwnedHero` is a hero of the account, with the weapons, pets and consumables it has equipped, not a `Hero` on a floor. Coin and XP boosters, chests and keys are not covered yet. Game art comes as plain sprites that load themselves and are released when removed from their parent: `Player.createPortrait` (the skin icon, as on the end screen) and `Weapon.createIcon` (icon on its rarity background, with the game's tooltip on hover, drawn above the overlay).

Load order is `enabled.json`'s, dependencies first ([Passing the list](#passing-the-list)). Outcomes land in [last-run.json](#last-run-report). `modding.Host` is not API: its hooks are private, `@:allow`ed to their game callers.

## Disk layout

Mods live outside `Dungeon Rampage Haxe/current/`, so they survive updates and rollbacks.

```text
<install-dir>/
  data/
  Dungeon Rampage Haxe/
    current/          # game, replaced on every update
    previous/         # launcher rollback
  mods/
    enabled.json      # launcher-owned: enabled ids, the user's load order
    last-run.json     # game-owned: last session outcome per mod
    some_mod/         # folder name = id
      mod.json
      src/            # .hx sources; package mods.some_mod (+ subfolders); no import.hx
        Main.hx       #   package mods.some_mod;
        ui/Panel.hx   #   package mods.some_mod.ui;
      Resources/      # non-destructive overlay (including Locale/)
      README.md       # long description
```

`<install-dir>` is the launcher managed content root (not the launcher executable). Linux default looks like `~/.local/share/DRH Launcher`.

**No destructive overlay** in `current/Resources/`. The game composites mod resources over vanilla at runtime. The launcher does not copy, patch, or verify files inside the game install. Merge rules are still [open](#open-decisions).

## Passing the list

The game cwd is `Dungeon Rampage Haxe/current/`. Enablement must not live in `current/` (wiped on update) or inside each `mod.json` (author artifact).

The launcher writes `<install-dir>/mods/enabled.json`:

```json
{
  "mods": [
    { "id": "example_hud" },
    { "id": "chat_macros" }
  ]
}
```

Array order is the user's load order. The host starts every mod **after** its dependencies (`api` included), whatever their place in the file, and keeps that order otherwise; `last-run.json` lists mods in the order they started. Disabled mods are omitted. Enabling a mod installs and enables its missing dependencies ([`mod.json`](#modjson)). If one cannot be (absent from the index, disabled by the user), the launcher warns and still writes the file; the game fails the mod (`dependency <id> missing`).

**Cycles** are not an error, and enabling is never refused. In one shared batch, mutual imports compile; the only undefined thing is which `onInit` of the cycle runs first.

If an id in `enabled.json` has no folder / no `mod.json`, the game **skips** it, logs, and records `skipped` in `last-run.json`. It does not abort boot. On the Mods page scan (not during `--play`), the launcher drops those ids and rewrites the file.

On Play the launcher passes **`--mods-dir <absolute path to mods/>`** (quote paths with spaces). The game parses it from `Sys.args()` in the constructor, like `--fps`. Then it reads `enabled.json` and resolves each `id` to a directory (scan `mod.json` if the folder name differs). Missing or empty `enabled.json` → load nothing (same as an empty list). Prod CLI does **not** list ids (Windows command-line length, quoting). Session logs already capture the flag.

No `--mods-dir` → **no mods**. Intentional vanilla.

Debug: the same flag. Later optional `--mods-all` (ignore `enabled.json`) and `--mod <id>`. No environment variables (the launcher sanitizes env; wrappers like `prime-run` make that channel unreliable).

## Last-run report

When `--mods-dir` is set, the game writes `<install-dir>/mods/last-run.json`. Without the flag, it writes nothing. The session log is not a Mods-page UI.

Draft, not frozen:

```json
{
  "drh": "20",
  "started": "2026-09-15T13:20:00Z",
  "ready": true,
  "mods": [
    {
      "id": "example_hud",
      "version": "0.1.0",
      "status": "ok",
      "mode": "compiled"
    },
    {
      "id": "broken_replace",
      "version": "1.0.0",
      "status": "failed",
      "mode": "interpreted",
      "error": "replace overlap on RepeaterWeaponController.onWeaponDown"
    }
  ]
}
```

| Field | Role |
| --- | --- |
| `drh` / `started` | Tag-number string of the game that wrote the file (`"20"`, no `V` — same space as `mod.json`) and UTC start time, for display. |
| `ready` | `false` until `onReady` has run; stays `false` when boot never gets there (`SocketErrorState`, `blockCheater()`). A mod `ok` with `ready: false` only got `onInit`. While the game is still loading the file also says `false`; the launcher disambiguates with process state (alive → loading, exited → boot stopped before `LoadingFinished`). No active avatar still reports `true`. |
| `status` | `ok` / `failed` (its own error or a dependency's) / `skipped` (id in `enabled.json` but folder, `mod.json`, or valid `id` missing) |
| `mode` | `compiled` if every module of the mod compiled, `interpreted` if none did, `mixed` otherwise. |
| `error` | Present on `failed`, `mixed`, an interpreted skip, or a `replace` overlap. One line (`2 modules left interpreted`). Per-module reasons stay in the session log. |

Write after compile + `onInit` (`ready: false`). Rewrite after `onReady` (`ready: true`, plus any `onReady` failure). Update the same file if a later `replace` conflict happens. Not live IPC.

The launcher deletes the file before each Play with `--mods-dir`, so a file present is this session's. Missing: still booting while the process is alive, a crash before the first write once it has exited. A file that does not parse (read during a write, or cut by a crash) is read again once shortly after, then counts as missing.

The launcher reads it when the Mods page is shown. That is where replace overlap becomes visible for **that** mod.

At load, one `Logger.info` per enabled mod (`id`, `version`, `uses`, `mode`, skip/fail reason). The session log already captures stdout.

Out of v1: in-session toasts, a pipe back to a running launcher.

## `mod.json`

Shared launcher/game contract.

```json
{
  "id": "some_mod",
  "name": "Some Mod",
  "description": "Short summary for the catalog.",
  "version": "0.1.0",
  "author": "example",
  "api": "1.2",
  "entry": "Main",
  "uses": [],
  "dependencies": { "cool_lib": "0.3" }
}
```

| Field | Role |
| --- | --- |
| `id` | Stable identifier, install folder, and the mod's **package**: every source file is in `mods.<id>` or a sub-package. Must match `^[a-z][a-z0-9_]{1,62}[a-z0-9]$` (3–64, snake_case, letter start, no trailing underscore) and must **not** be a Haxe keyword or a Windows reserved device name. Index CI, launcher install, and host skip all apply the same regex + lists. Display name stays in `name`. |
| `name` | Display name, at most 64 characters. |
| `description` | One line for the catalog, at most 120 characters. |
| `version` | `MAJOR.MINOR.PATCH`, digits only. Semver over what other mods may rely on. |
| `author` | Display name of the author or team, at most 32 characters. Free text, not an account. |
| `api` | Version of the [`api` mod](#versioning) this one needs. **Required**, except in the `api` mod itself. Same syntax as a dependency. |
| `drh` | Tags this artifact was built for (no `V`, no `>=`). `"20"`, `"20,21"`, or `"20-22"` (closed, inclusive). **Required** if `uses` contains `extends` or `replace`; omit otherwise. Never blocks: the launcher warns when the installed tag is not in the set. Untagged local builds (`"0"`) skip it. |
| `entry` | Short class name, resolved as `mods.<id>.<entry>` (e.g. `Main` → `mods.some_mod.Main`, extends `mods.api.Mod`). Cannot name anything outside the mod's package. |
| `uses` | `extends` and/or `replace`. Empty: stable only. |
| `dependencies` | Other mods whose types this one imports, as `{ "id": "version" }`. Not `api`, which has its own field. May be empty or absent. A cycle is not an error ([Passing the list](#passing-the-list)). |

Lengths count characters. `--check-mod` and the index CI refuse a longer value.

**Versions.** `api` and each dependency take `"x.y"` or `"x.y.z"`: the same major, and not older (`"1.2"` accepts `1.2.0` up to anything below `2.0.0`). With major `0`, the minor is the major (`"0.3"` accepts `0.3.x` only). The launcher installs and enables, from the index, the highest version that satisfies every enabled mod naming it. For `extends` / `replace` (`api` included), one whose `drh` contains the installed tag comes first; when none does, the highest satisfying version is installed anyway, with the `drh` warning. One version per id; when no version satisfies everyone, it keeps the installed one and warns. No backtracking across dependencies' own constraints. The game only checks that dependencies loaded ([Lifecycle](#lifecycle)).

Haxe keywords (the regex alone lets `package mods.new;` through): `abstract`, `break`, `case`, `cast`, `catch`, `class`, `continue`, `default`, `dynamic`, `else`, `enum`, `extends`, `extern`, `false`, `final`, `for`, `function`, `implements`, `import`, `inline`, `interface`, `macro`, `new`, `null`, `operator`, `overload`, `override`, `package`, `private`, `public`, `return`, `static`, `switch`, `this`, `throw`, `true`, `try`, `typedef`, `untyped`, `using`, `var`, `while`.

Windows reserved device names (the folder cannot be created): `con`, `prn`, `aux`, `nul`, `com1`–`com9`, `lpt1`–`lpt9`.

**Package rule.** hxScript requires the package the host passes to match the file. The host derives it from the path under `src/`: `mods/<id>/src/ui/Panel.hx` is `mods.<id>.ui`, `src/Main.hx` is `mods.<id>`. A file that declares anything else is hxScript's parse error; the module declares nothing; the mod is `failed`. Ids are unique (index) and the host refuses a second mod with the same `id` (sideload), so two mods can never declare the same type — otherwise the interpreter silently replaces the earlier module (`Environment.modules`) and hxcpp's cppia class table overwrites (last wins). `mods.` also keeps a mod from shadowing a host or engine root (`combat`, `com`, `openfl`, …).

**`import.hx` is not supported (v1).** The host skips it with a warning attributed to the mod (`import.hx ignored`); other files still load. hxScript's prelude (`ImportModule`) is host-wired and interpreter-only; the cppia emitter reads a module's own `import`s only, so honouring it would silently interpret every file of that mod. Fed as a normal module it would fail the package rule (no `package` line). Each file lists its imports. Lifting this later is additive if hxScript teaches the emitter about preludes.

**Using another mod's types** holds as long as its author follows semver on `version`. Nothing checks that but review.

The launcher refuses to install (index or local zip) if `id` fails the regex / lists, and extracts to `mods/<id>/` with the same path rules as game releases (`enclosed_name` / `safe_relative_path`: no `..`, no absolute paths, files and directories only). No uncompressed size cap: index artifacts already have size + SHA-256; sideload is a file the user picked. A hand-copied folder whose directory name differs from `id` can still be scanned via `mod.json`; a bad `id` is skipped (game) or not a mod (launcher).

A directory without `mod.json` is not a mod.

## Distribution

Three roles, kept separate so a nicer front can land later without moving mods:

| Role | v1 | Later |
| --- | --- | --- |
| Discussion | Discord | still Discord |
| Listing (source of truth) | Index repo we control | same index |
| Files | Author-hosted zip (e.g. GitHub Release) | same, plus optional mirrors |
| Human catalog | **Minimal list in DRHL** | polish in DRHL and/or a website reading the same index |

The index **points**. It does not contain community mods. Official example mods may live in the DRH tree; third-party mods do not, nor does `api`, which has its own repository ([Versioning](#versioning)).

A listing is an **artifact**, not a repo: `id + version + sha256 + download URL` plus its `mod.json` fields. Trusting `github.com/alice/cool-hud` forever would auto-approve the next Release. Reviewing "the repo" once does not review v1.2. A new version is not visible until it is a new index entry (PR). CI can check that the zip opens, `mod.json` matches, and the hash is correct; a human still diffs against the last indexed version. **Auto-ingest of GitHub Releases without the index is out.**

Sideload (Open mods folder / install from zip / a GitHub repository link) stays, labeled unreviewed. A repository link installs the zip of its latest published release, never a branch.

Thunderstore, Nexus, itch.io are **not** the identity of a DRH mod. They may become mirrors of the same zip with a generated extra manifest. Nexus is the weakest legal fit for a fan port. Steam Workshop is out of scope (DRH is not a Steam app).

The Mods page (fetch, install, enable, order, `last-run` display) is specified in the launcher architecture. This document owns the shared files and `--mods-dir`.

### Mod repository

A mod's repository **is** its folder: `mod.json`, `src/`, `Resources/` (when the mod has any) at the root, plus `README.md`, `LICENSE` and `.github/`. Cloning it into a mods folder runs it as is, and DRH can pin one as a submodule (`mods/api`). Its name is free; `DRH-Mod-<Name>` is the suggestion. The GitHub topic `drh-mod` is required, so mods can be found.

`README.md` is also the long description, shown on the mod's page in the launcher. HTML comments, invisible on GitHub, pick what the launcher shows: `<!-- drh:show -->` … `<!-- /drh:show -->` keeps only those zones (several allowed, joined in order), and `<!-- drh:hide -->` … `<!-- /drh:hide -->` drops one, inside a shown zone too. Without a shown zone, the whole file is shown, minus its hidden zones. Zones do not nest, except a hidden one inside a shown one; an unclosed or misplaced marker fails `--check-mod`. What is shown is Markdown, at most 4000 characters. It need not say it is a DRH mod: the catalog says so, and GitHub shows the repository's name and topic.

A mod runs combined with DRH and `api` (GPLv3), so its license must be GPL-compatible (GPL, LGPL, MIT, BSD, Apache 2.0, MPL 2.0, …). A reviewer checks it at an `id`'s first entry and whenever `LICENSE` changes.

`DRH-Mod-Template` is the skeleton: `mod.json`, `src/Main.hx` (`class Main extends mods.api.Mod`), `README.md` (a placeholder: a shown zone to fill, and a pointer to the modder documentation online; `--check-mod` refuses it unchanged), `LICENSE` (GPLv3, as DRH and `api`), and `.github/workflows/release.yml`, which only calls the reusable workflow of `Tutez64/DRH-Mod-Workflows`, pinned to its moving major tag (`@v1`, moved along its `v1.x.y` releases): fixes reach every mod, only a breaking change needs a new major. Nothing else is copied into a mod, so nothing there needs updating. It runs as is, as `my_mod` (its `Main` logs `loaded`): the `id` is only in `mod.json` and in the `package` line of `src/Main.hx`. It is a GitHub template repository: until `--new-mod` exists, *Use this template* gives the fresh history, and the author changes both by hand.

Every step is a DRH Launcher command. The checks exist once, in the launcher; the release workflow and the index CI run its latest Linux release (the AppImage, with `APPIMAGE_EXTRACT_AND_RUN=1`: runners have no FUSE), and a modder editing them gains nothing.

| Command | Does |
| --- | --- |
| `--new-mod <dir>` | Copies the template with git into a fresh history, asks for `id`, `name` and `author` and writes them (the `id` into the `package` line of `src/Main.hx` too), then opens `github.com/new` pre-filled. The repository is created there, with the topic `drh-mod`; the first push is plain git. |
| `--check-mod <dir>` | Checks what needs no game: the `mod.json` schema (`id` rules, `version`, `api` and dependency syntax, `drh` present exactly when `uses` names `extends` or `replace`), values left from the template (`id` `my_mod`, `name`, `description`, an empty `author`, `README.md`), the lengths (what `README.md` shows included) and its markers, the package rule for every file under `src/`, no `import.hx`, a non-empty `LICENSE`. |
| `--run-mod <dir>` | Installs the mod's dependencies (`api` included) from the index into a cache, composes a temporary mods folder with them and `<dir>`, and launches DRH on it. Loading and behaviour are the author's own run. |
| `--pack-mod <dir>` | Checks, then builds the zip from a fixed list (`mod.json`, `src/`, `Resources/` when present, `LICENSE`, `README.md`, flat at its root, extracted as is into `mods/<id>/`) and its index entry. |
| `--submit-mod <dir>` | Adds the index entry of the published release on a branch of the author's fork of the index (forked once, in the browser), pushes it with git, and opens the pre-filled compare page: one click opens the PR. |

Publishing:

1. Tag `vX.Y.Z`, equal to `mod.json` `version`, or nothing is built.
2. The release workflow packs and drafts a GitHub release with the zip and its index entry.
3. The author tests that zip, then publishes the release.
4. `--submit-mod`. Git and a GitHub account are required; nothing else is installed and no token is handed out.

### Index entry (draft)

Not frozen. One file per version (`mods/<id>/<version>.json`), so concurrent PRs do not conflict; the index CI checks each one and generates the static file the launcher reads (served as a file, not through the GitHub API, whose unauthenticated rate limit would throttle the catalog):

```json
{
  "id": "some_mod",
  "name": "Some Mod",
  "version": "0.1.0",
  "author": "example",
  "description": "Short summary for the catalog.",
  "longDescription": "What the mod's README.md shows.",
  "api": "1.2",
  "uses": [],
  "dependencies": { "cool_lib": "0.3" },
  "url": "https://github.com/example/some-mod/releases/download/v0.1.0/some_mod-0.1.0.zip",
  "sha256": "...",
  "source": "https://github.com/example/some-mod"
}
```

`longDescription` is what `README.md` shows ([Mod repository](#mod-repository)), so the catalog shows it before install. `source` is documentation (issues, code), not a download pipe. `--pack-mod` fills it from the repository the release workflow runs in. An `id` belongs to the `source` of its first entry: the index CI refuses a version from another one, unless a reviewer accepts a takeover. Yanking a version is an index change (tombstone or removal).

Out of v1, same index: ratings, galleries, collections, dependency solving beyond [one version per id](#modjson), a publishing UI in the launcher (its [commands](#mod-repository) cover it), a separate website.

## Compilation

hxScript parses `.hx` at runtime. On hxcpp a module can become [cppia](https://haxe.org/manual/target-cppia.html) loaded as a real class. The interpreter is the default and the safety net: anything the emitter cannot express is skipped with a reason and stays interpreted.

Intended game build flags (`hxscript` = **our fork**):

```text
-lib hxscript
-D hxscript_cppia
-D scriptable
-D hxscript_verbose                                         # the CI log is where a skipped module is explained
-D hxscript_host=modding
-D hxscript_bridge_classpath=src,src-steam,compat,src-modding   # classpath entries walked with an empty package
-D hxscript_bridge_exclude=DungeonBustersProject,...        # value in project.xml, explained below
-D hxscript_bridge_packages=openfl,lime,swf,steamwrap       # stock; whole trees until measured
-D hxscript_bridge_eager                                     # type each bridge before the next: hundreds of bases overflow the compiler otherwise
-dce no                                                     # hxScript's own cppia setting
--macro include('haxe', true, ['haxe.macro', 'haxe.atomic.AtomicObject'])   # force-type the std; AtomicObject is #error on hxcpp
--macro include('sys', true, ['sys.db'])                    # sys.db is @:cffi over hxcpp sqlite/mysql
-D hxscript_keep=cpp.vm.Gc,cpp.vm.Profiler                  # cpp.* by name (package has objc / link)
```

**Bridge scan (fork).** Submodules each have one root package, so stock `-D hxscript_bridge_packages=openfl,lime,swf,steamwrap` covers them (recursive; presets' ignore lists do not apply). DRH's own roots need a **classpath-entry scan** — walking the empty root would include the std — so the pinned fork has `-D hxscript_bridge_classpath=src,src-steam,compat,src-modding` and `-D hxscript_bridge_exclude`. `src-modding` is the cpp-only host (`modding.Mod`). Necessity is `compat/` (root-level types no package scan can reach); for `src/` alone a 35-package list would do. The define names **classpath entries** walked with an **empty package**, not a package called `src` (`modulesUnder("src")` would look for `src/src/` and emit `src.actor.Hero`). The walk skips `*.macro.hx`. `-D hxscript_host=modding` stays upstream's meaning: packages scanned for `@:scriptAmbient` / `@:scriptStatic`. `-D scriptable` is hxcpp's cppia flag; it does not generate extend bridges.

What the first cppia build does not compile:

- `DungeonBustersProject` is the entry point, not a base a mod extends.
- `openfl.fl` imports `openfl._internal.formats.xfl`, absent here. `openfl.data` is `#if windows` with no else. `WebSocket` and `ServerWebSocket` have no `openfl.utils.io.ByteArray`. `openfl.xml`: `XML` has no `Namespace`, and `XMLList`'s inlined methods do not type in C++ under `-D scriptable`.
- `openfl.display._internal.native`, `NativeLocalConnection` and `NativeVideoBackend` `@:include` a file that pulls `Windows.h`.
- Lime's cpp backend is `native`. The exclude drops `html5`, `air`, `flash`, `emscripten`, and `lime.tools` (the CLI).
- The swf exporters and `SWFLiteLoader` import `hxp`. `ActionNextFrame`, `ActionGotoFrame`, `ActionGetURL` and `ActionGotoLabel` have a `package` line with no semicolon. `AS3GraphicsDataShapeExporter` and `FrameScriptParser` do not type on cpp.
- `b2internal` and `as3commons_collections` are leftover AS3 `namespace` files.

If the binary is too fat, cut `openfl._internal` and Lime backends first, then narrow to display roots (`openfl.display`, `openfl.text`, `openfl.geom`, `openfl.events`).

**DCE.** DRH and Lime's cpp templates pass no `-dce`, so the build is Haxe's default **`-dce std`**: unused *standard library* members are stripped; game / OpenFL / Lime / swf / SteamWrap never were. The host switches to **`-dce no`**. That is hxScript's cppia position (`-D scriptable` resolves host classes by name at load; DCE removes whatever no compiled call site references). Its probe: 42 of 83 commonly-scripted std members unreachable under `-dce std`, 3 under `-dce no`. `hxscript_keep` as the *primary* mechanism is the same curated list we rejected for bridges.

`-dce no` keeps what is **typed**; it does not type what nothing references. A mod calling `haxe.crypto.Sha256` when nothing in the host names it gets `Type not found`. Libraries are already covered (Autowire + the bridge scan). The std is the gap. DRH goes **further than hxScript** and force-includes it: `--macro include('haxe', true, ['haxe.macro'])` and `include('sys', true, ['sys.db'])`. `sys` is 34 modules and Lime already types most of them; the net addition is `Http`, `FileStat`, thread pools, `EventLoop`, `Condition`, `Semaphore`, `ssl.Digest`. `sys.db` is excluded up front (`Sqlite` / `Mysql` need linking). `haxe.atomic.AtomicObject` is `#error` on hxcpp, so it is on the ignore list; anything else that fails to type joins it. `cpp.*` is **not** included wholesale (`cpp.objc`, `cpp.link`); name what a mod may want via `-D hxscript_keep`. Cost is mostly **build time** (one `.cpp` per class). If it hurts, grow the ignore list; never return to `-dce std`.

**hxcpp.** Patched with `submodules/hxscript/patches/apply-hxcpp.py` on `submodules/hxcpp`.

**JIT.** On before any module loads: `Compiler.compile` does it (`Compiler.jit`) and retries a refused batch once without it.

**Start, then compile** (upstream's order: the emitter resolves bare names through each module's interpreter). Static initialisers therefore run once interpreted, compiled modules included. A module-level, type-init or static-initialiser throw fails its mod. A mod that failed before the compile (load, start, or a dependency's) has its files removed first. A throw inside the compiler fails no mod: the emitter skips the module it was writing, and if `Compiler.compile` throws anyway, everything stays interpreted.

**Size / time.** Real binary cost: `-D scriptable`, OpenFL/Lime/swf bridges (`DisplayObject` has a large method surface; swf ~240 modules; SteamWrap / `src-steam` / `compat` are negligible), and the `src/` classpath bridges. `-dce no` plus the std include is mostly build time. Measure a first cppia build against current DRH before treating compiled mods as free.

**No type blacklist.** Do not set `-D hxscript_sandbox`. Interpreted and compiled resolve the same types.

The compiled path is not automatic: the host must call `Compiler.compile(env)` and wire `Compiler.ambient` / `Compiler.statics` (hxScript trap: interpreter ambients are not the compiler's).

**One world, one batch (v1).** All enabled mods go into a single `Environment` and a single `Compiler.compile(env)`. That is what lets a mod import another's types *and* stay compiled: cppia resolves a class either inside the module being loaded or as a host class; a scripted class in another batch is neither. Inside one batch, every module is declared before any is emitted. Price:

- **Skips cascade.** If `mods.cool_lib.Api` is refused, every module naming it is skipped too. A parse error in `cool_lib` means it declares nothing and dependents fail at import. `dependencies` makes that visible; it does not remove the coupling.
- **Blast radius of `Module.boot()`.** A loader reject splits the batch (`narrowOnFailure`, default on) until the bad module is left interpreted. The rest still compile. Per-mod worlds would confine that and forbid compiled inter-mod use.
- **No selective unload.** Dropping the world drops all mods. v1 does not unload.

Name collisions are excluded by the [package rule](#modjson), not by isolation.

Bytecode cache (cppia bytes on disk, invalidated when the game version, `mod.json`, or sources change) is a future optimization, not what makes mods "compiled".

## Starling / 1.0

Vanilla code will follow DR.

- **`api` mods** follow [Versioning](#versioning). Internals can move behind wrappers.
- **`extends` / `replace`** depend on host types. They can break on Starling without an `api` bump. `drh` is how the launcher warns (not a hard refuse).
- The game still tries to load; failures go to `last-run.json`.

## Technical prerequisites

Needed before a real host; not a restatement of the rules above.

1. **Done**. Patch hxScript. Except `replace` which is still missing.
2. **Done.** hxcpp cppia patch.
3. **Done.** The flags above are in `project.xml`.
4. **Done**, except `replace`. `src-modding/` loads `--mods-dir` into one world, runs the lifecycle, re-registers the overlay, and bakes the release tag (no `V`) into the host. `uncaughtError` and the mod `exiting` listener sit at the top of the constructor. Still later: `ASCompat.createInstance` consulting the `replace` table, once the fork has `replace`.
5. Launcher: index fetch, catalog install, `enabled.json`, `--mods-dir`, `last-run.json` display — no destructive overlay.
6. Index repository (separate from DRH / DRHL), PR + CI for new versions.
7. **Done**, except the `api` repository and its submodule in DRH ([Versioning](#versioning)). The wrappers live in the `api` mod, core events hand game objects, dependency failures propagate.

## Out of scope for this document

- User guide, polished store UX, or Steam Workshop.
- Final JSON schema for the index.
- Host code or hxcpp patch.
- Private servers, offline solo, or bypassing official checksums.
- Making Thunderstore, Nexus, or Discord the source of truth.
