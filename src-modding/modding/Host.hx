package modding;

import facade.DBFacade;
import distributedObjects.DistributedDungeonFloor;
import distributedObjects.HeroGameObject;
import flash.display.Sprite;
import flash.display.Stage;
import haxe.Json;

/**
 * Loads every enabled mod into one hxScript world. No `--mods-dir` means no mods
 * and nothing written. `replace` is intentionally absent until the fork has it.
 *
 * Nothing here is for mods: the game calls the hooks, the `api` mod goes through `ModContext`.
 *
 * Contract: docs/modding.md (lifecycle, passing the list, last-run report).
 */
@:allow(DungeonBustersProject)
@:allow(facade.DBFacade)
@:allow(stateMachine.mainStateMachine.TownState)
@:allow(distributedObjects.HeroGameObject)
@:allow(distributedObjects.HeroGameObjectOwner)
@:allow(distributedObjects.DistributedDungeonFloor)
@:allow(modding.ModContext)
@:allow(modding.ModSubscription)
class Host {
	static inline final HERO_SPAWNED = "heroSpawned";

	static inline final HERO_DESPAWNED = "heroDespawned";

	static inline final FLOOR_ENTER = "floorEnter";

	static inline final FLOOR_EXIT = "floorExit";

	static inline final TABLES_LOADED = "tablesLoaded";

	static inline final TOWN_ENTER = "townEnter";

	static inline final TOWN_EXIT = "townExit";

	static inline final KEY_DOWN = "keyDown";

	/** Above the letterbox (1000), the side backgrounds (1001) and the session id (1002). */
	static inline final OVERLAY_LAYER:Float = 1003;

	/** Above every stage key listener of the game (all at 0), so mods see a key first and can keep it. */
	static inline final KEY_PRIORITY = 1000;

	static inline final MODS_DIR_ARGUMENT = "--mods-dir";

	/** The official mod every other one builds on. Its entry is the only one extending `modding.Mod` directly. */
	static inline final API_ID = "api";

	static inline final API_MOD = "mods.api.Mod";

	static var ID = ~/^[a-z][a-z0-9_]{1,62}[a-z0-9]$/;

	static var ENTRY = ~/^[A-Za-z_][A-Za-z0-9_]*$/;

	static var API_VERSION = ~/^[0-9]+\.[0-9]+(\.[0-9]+)?$/;

	static var booted:Bool = false;

	static var disposed:Bool = false;

	static var flushed:Bool = false;

	static var reportReady:Bool = false;

	static var modsRoot:String = "";

	static var started:String = "";

	static var stage:Stage;

	/** Set at `onReady`, handed to mods as `ModContext.facade`. */
	static var facade:Null<DBFacade>;

	static var keysHooked:Bool = false;

	/** Keys down now, so a held key's repeats do not reach mods; true when a mod kept the key. */
	static var keysDown:Map<Int, Bool> = new Map();

	static var overlay:Sprite;

	static var records:Array<ModRecord> = [];

	static var pending:Array<LogLine> = [];

	static var listeners:Map<String, Array<ModSubscription>> = new Map();

	/** Heroes announced and not yet gone, by object id. */
	static var heroes:Map<UInt, Bool> = new Map();

	/** Floors announced and not yet gone, by object id. */
	static var floors:Map<UInt, Bool> = new Map();

	/** Heroes initialised on a floor that has not been announced yet, released by its `floorEnter`. */
	static var waiting:Array<WaitingHero> = [];

	static var world:hxscript.Environment;

	static var modModules:Map<String, Array<hxscript.Module>> = new Map();

	static var moduleOwner:Map<String, String> = new Map();

	static var parseErrors:Map<String, String> = new Map();

	static function boot(stage:Stage, args:Array<String>):Void {
		if (booted)
			return;
		var directory = modsDirectory(args);
		if (directory == null)
			return;
		booted = true;
		Host.stage = stage;
		started = utcNow();
		modsRoot = directory;
		try {
			hxscript.error.Sink.listen(onDiagnostic);
			hxscript.macro.Expose.apply();
			// A field of a null object throws, as a null dereference in the game does, instead of reading null.
			hxscript.Config.strictNullAccess = true;
			if (sys.FileSystem.exists(directory) && sys.FileSystem.isDirectory(directory)) {
				try modsRoot = sys.FileSystem.absolutePath(directory) catch (_:Dynamic) {}
				loadEnabled();
			} else {
				note("warn", "modding: mods directory not found: " + directory);
			}
		} catch (e:Dynamic) {
			note("warn", "modding: " + errorText(e));
		}
		writeReport();
		for (record in records)
			note("info", summary(record));
	}

	static function flush():Void {
		if (flushed)
			return;
		flushed = true;
		for (line in pending) {
			if (line.level == "warn")
				brain.logger.Logger.warn(line.text);
			else
				brain.logger.Logger.info(line.text);
		}
		pending = [];
	}

	/** Moves the overlay into the facade's layer list, above the letterbox. */
	static function attachOverlay(facade:DBFacade):Void {
		if (overlay == null || facade == null)
			return;
		facade.addRootDisplayObject(overlay, OVERLAY_LAYER);
	}

	static function ready(facade:DBFacade):Void {
		if (!booted || reportReady)
			return;
		Host.facade = facade;
		var wasOk = [for (record in records) record.status == "ok"];
		for (record in records) {
			if (record.status != "ok" || record.instance == null || record.context == null)
				continue;
			try {
				record.instance.onReady(record.context);
			} catch (e:Dynamic) {
				silence(record, errorText(e));
			}
		}
		for (index in 0...records.length)
			if (wasOk[index] && records[index].status == "failed")
				logNow("warn", summary(records[index]));
		reportReady = true;
		writeReport();
	}

	static function dispose():Void {
		if (!booted || disposed)
			return;
		disposed = true;
		var index = records.length - 1;
		while (index >= 0) {
			var record = records[index];
			index--;
			if (record.instance == null)
				continue;
			try {
				record.instance.onDispose();
			} catch (e:Dynamic) {
				logNow("warn", "mod " + record.id + ": onDispose: " + errorText(e));
			}
		}
	}

	static function tablesLoaded():Void {
		emit(TABLES_LOADED, null);
	}

	static function townEnter():Void {
		emit(TOWN_ENTER, null);
	}

	static function townExit():Void {
		emit(TOWN_EXIT, null);
	}

	static function heroSpawned(hero:HeroGameObject, local:Bool):Void {
		if (!booted || hero == null || heroes.exists(hero.id))
			return;
		var floor = hero.distributedDungeonFloor;
		if (floor != null && !floors.exists(floor.id)) {
			for (entry in waiting)
				if (entry.hero == hero)
					return;
			waiting.push({hero: hero, local: local, floor: floor});
			return;
		}
		heroes.set(hero.id, true);
		emit(HERO_SPAWNED, hero);
	}

	/** While the hero is still whole. */
	static function heroDespawned(hero:HeroGameObject):Void {
		if (!booted || hero == null)
			return;
		waiting = waiting.filter(entry -> entry.hero != hero);
		if (!heroes.exists(hero.id))
			return;
		heroes.remove(hero.id);
		emit(HERO_DESPAWNED, hero);
	}

	static function floorEnter(floor:DistributedDungeonFloor):Void {
		if (!booted || floor == null || floors.exists(floor.id))
			return;
		floors.set(floor.id, true);
		emit(FLOOR_ENTER, floor);
		var released = waiting.filter(entry -> entry.floor == floor);
		waiting = waiting.filter(entry -> entry.floor != floor);
		for (entry in released)
			if (!entry.hero.isDestroyed)
				heroSpawned(entry.hero, entry.local);
	}

	static function floorExit(floor:DistributedDungeonFloor):Void {
		if (!booted || floor == null)
			return;
		waiting = waiting.filter(entry -> entry.floor != floor);
		if (!floors.exists(floor.id))
			return;
		floors.remove(floor.id);
		emit(FLOOR_EXIT, floor);
	}

	static function modLog(id:String, message:String):Void {
		note("info", "mod " + id + ": " + message);
	}

	static function listen(id:String, event:String, handler:Dynamic->Void):ModSubscription {
		if (event == KEY_DOWN)
			hookKeys();
		var list = listeners.get(event);
		if (list == null) {
			list = [];
			listeners.set(event, list);
		}
		var subscription = new ModSubscription(id, event, handler);
		list.push(subscription);
		return subscription;
	}

	static function unlisten(subscription:ModSubscription):Void {
		var list = listeners.get(subscription.event);
		if (list != null)
			list.remove(subscription);
	}

	/** Whether a mod is still running: loaded, and not failed or silenced since. */
	static function alive(id:String):Bool {
		var record = recordById(id);
		return record != null && record.status == "ok";
	}

	static function hookKeys():Void {
		if (keysHooked || stage == null)
			return;
		keysHooked = true;
		stage.addEventListener("keyDown", onStageKey, false, KEY_PRIORITY);
		stage.addEventListener("keyUp", onStageKeyUp, false, KEY_PRIORITY);
		// A key released while the window is in the background never sends its keyUp.
		stage.addEventListener("deactivate", function(_) keysDown.clear());
	}

	/**
	 * Keys typed into a text field (chat, search) are not for mods, and neither are a held key's
	 * repeats. A handler that returns true keeps the key: the game never sees that press, neither its
	 * own shortcuts (Enter opening the chat) nor OpenFL's (Tab moving the focus), nor its repeats.
	 */
	static function onStageKey(event:flash.events.KeyboardEvent):Void {
		if (keysDown.exists(event.keyCode)) {
			// A kept key stays kept while held.
			if (keysDown.get(event.keyCode))
				keep(event);
			return;
		}
		keysDown.set(event.keyCode, false);
		var focus = stage.focus;
		if (Std.isOfType(focus, flash.text.TextField) && (cast focus : flash.text.TextField).type == flash.text.TextFieldType.INPUT)
			return;
		var list = listeners.get(KEY_DOWN);
		if (list == null)
			return;
		var kept = false;
		for (subscription in list.copy()) {
			if (!subscription.active)
				continue;
			try {
				var handler:Dynamic = subscription.call;
				if (handler(event.keyCode) == true)
					kept = true;
			} catch (e:Dynamic) {
				logNow("warn", "mod " + subscription.owner + ": " + KEY_DOWN + ": " + errorText(e));
			}
		}
		if (kept) {
			keysDown.set(event.keyCode, true);
			keep(event);
		}
	}

	/** The release of a kept key is hidden too: the game never saw it go down. */
	static function onStageKeyUp(event:flash.events.KeyboardEvent):Void {
		if (keysDown.get(event.keyCode) == true)
			keep(event);
		keysDown.remove(event.keyCode);
	}

	/** Stops the game's stage listeners, which run after the host's, and OpenFL's default action. */
	static function keep(event:flash.events.KeyboardEvent):Void {
		event.stopImmediatePropagation();
		event.preventDefault();
	}

	static function emit(event:String, payload:Dynamic):Void {
		if (!booted)
			return;
		var list = listeners.get(event);
		if (list == null)
			return;
		for (subscription in list.copy()) {
			if (!subscription.active)
				continue;
			try {
				subscription.call(payload);
			} catch (e:Dynamic) {
				logNow("warn", "mod " + subscription.owner + ": " + event + ": " + errorText(e));
			}
		}
	}

	static function onDiagnostic(d:hxscript.error.Diagnostic):Void {
		note(d.fatal ? "warn" : "info", oneLine(d.toString()));
		if (d.phase == hxscript.error.Phase.PParse && d.fatal && d.origin != null)
			parseErrors.set(d.origin, oneLine(d.message));
	}

	static function loadEnabled():Void {
		var path = modsRoot + "/enabled.json";
		if (!sys.FileSystem.exists(path))
			return;
		var text = readText(path);
		if (text == null) {
			note("warn", "modding: could not read enabled.json");
			return;
		}
		var parsed:Dynamic = null;
		try {
			parsed = Json.parse(text);
		} catch (e:Dynamic) {
			note("warn", "modding: enabled.json: " + errorText(e));
			return;
		}
		var mods:Dynamic = parsed == null ? null : Reflect.field(parsed, "mods");
		if (mods == null)
			return;
		if (!Std.isOfType(mods, Array)) {
			note("warn", "modding: enabled.json mods is not a list");
			return;
		}
		var seen = new Map<String, Bool>();
		for (item in (mods : Array<Dynamic>)) {
			var id:Dynamic = item == null ? null : Reflect.field(item, "id");
			if (!Std.isOfType(id, String)) {
				var record = new ModRecord(Std.string(id), "skipped");
				record.error = "invalid enabled entry";
				records.push(record);
				continue;
			}
			var name:String = id;
			if (seen.exists(name)) {
				var duplicate = new ModRecord(name, "failed");
				duplicate.error = "duplicate id";
				records.push(duplicate);
				continue;
			}
			seen.set(name, true);
			records.push(resolve(name));
		}
		dependenciesFirst();
		checkDependencies();
		dropFailedModules();
		startWorld();
		dropFailedModules();
		compileWorld();
		assignModes();
		runInits();
	}

	static function resolve(id:String):ModRecord {
		var record = new ModRecord(id, "skipped");
		if (!validId(id)) {
			record.error = "invalid id";
			return record;
		}
		var directory = findDirectory(id);
		if (directory == null) {
			record.error = folderError(id);
			return record;
		}
		var manifestPath = directory + "/mod.json";
		if (!sys.FileSystem.exists(manifestPath)) {
			record.error = "no mod.json";
			return record;
		}
		var text = readText(manifestPath);
		if (text == null) {
			record.error = "no mod.json";
			return record;
		}
		var manifest:Dynamic = null;
		try {
			manifest = Json.parse(text);
		} catch (e:Dynamic) {
			record.error = "mod.json: " + errorText(e);
			return record;
		}
		var declared:Dynamic = Reflect.field(manifest, "id");
		if (declared != id) {
			record.error = "mod.json id does not match";
			return record;
		}
		record.directory = directory;
		record.status = "ok";
		var version:Dynamic = Reflect.field(manifest, "version");
		if (Std.isOfType(version, String))
			record.version = version;
		if (!readUses(Reflect.field(manifest, "uses"), record))
			return record;
		if (!readApi(Reflect.field(manifest, "api"), record))
			return record;
		var entry:Dynamic = Reflect.field(manifest, "entry");
		if (!Std.isOfType(entry, String) || !ENTRY.match(entry)) {
			record.status = "failed";
			record.error = "entry must be a short class name";
			return record;
		}
		record.entry = entry;
		if (!readDependencies(Reflect.field(manifest, "dependencies"), record))
			return record;
		if (record.uses.length > 0)
			warnDrh(record, Reflect.field(manifest, "drh"));
		if (record.status == "ok")
			loadSources(record);
		return record;
	}

	static function findDirectory(id:String):Null<String> {
		var direct = modsRoot + "/" + id;
		if (sys.FileSystem.exists(direct) && sys.FileSystem.isDirectory(direct) && manifestId(direct) == id)
			return direct;
		if (!sys.FileSystem.exists(modsRoot))
			return null;
		var names = sys.FileSystem.readDirectory(modsRoot);
		names.sort(function(a, b) return a < b ? -1 : a > b ? 1 : 0);
		for (name in names) {
			if (name == "enabled.json" || name == "last-run.json")
				continue;
			var directory = modsRoot + "/" + name;
			if (!sys.FileSystem.isDirectory(directory))
				continue;
			if (manifestId(directory) == id)
				return directory;
		}
		return null;
	}

	/** Why `findDirectory` found nothing, named after the folder that has the id's name. */
	static function folderError(id:String):String {
		var direct = modsRoot + "/" + id;
		if (!sys.FileSystem.exists(direct) || !sys.FileSystem.isDirectory(direct))
			return "no folder";
		if (!sys.FileSystem.exists(direct + "/mod.json"))
			return "no mod.json";
		return "mod.json id does not match";
	}

	static function manifestId(directory:String):Null<String> {
		var path = directory + "/mod.json";
		if (!sys.FileSystem.exists(path))
			return null;
		var text = readText(path);
		if (text == null)
			return null;
		try {
			var manifest:Dynamic = Json.parse(text);
			var id:Dynamic = Reflect.field(manifest, "id");
			return Std.isOfType(id, String) ? id : null;
		} catch (_:Dynamic) {
			return null;
		}
	}

	static function loadSources(record:ModRecord):Void {
		var srcRoot = record.directory + "/src";
		if (!sys.FileSystem.exists(srcRoot) || !sys.FileSystem.isDirectory(srcRoot)) {
			record.status = "failed";
			record.error = "no src directory";
			return;
		}
		if (world == null)
			world = new hxscript.Environment();
		var modules = [];
		modModules.set(record.id, modules);
		var seen = new Map<String, Bool>();
		walk(srcRoot, seen, function(path:String) {
			var name = fileName(path);
			if (name == "import.hx") {
				note("warn", "mod " + record.id + ": import.hx ignored");
				return;
			}
			if (!StringTools.endsWith(name, ".hx"))
				return;
			var stem = name.substr(0, name.length - 3);
			var pack = ["mods", record.id];
			var relative = relativeTo(srcRoot, path);
			var slash = relative.lastIndexOf("/");
			var folder = slash < 0 ? "" : relative.substr(0, slash);
			if (folder != "") {
				for (segment in folder.split("/")) {
					if (segment != "")
						pack.push(segment);
				}
			}
			var modulePath = pack.join(".") + "." + stem;
			if (moduleOwner.exists(modulePath)) {
				fail(record, "duplicate type " + modulePath);
				return;
			}
			var source = readText(path);
			if (source == null) {
				fail(record, "could not read " + relative);
				return;
			}
			var module = new hxscript.Module(source, stem, pack, path);
			if (parseErrors.exists(path)) {
				fail(record, parseErrors.get(path));
				return;
			}
			// hxScript reports these and carries on; for the host they fail the mod.
			module.onProgramError = function(e:haxe.Exception) fail(record, errorText(e));
			module.onTypeError = function(e:haxe.Exception, _) fail(record, errorText(e));
			world.addModule(module);
			modules.push(module);
			moduleOwner.set(module.path, record.id);
		});
		if (record.status == "ok" && modules.length == 0) {
			record.status = "failed";
			record.error = "no scripts";
		}
	}

	/**
	 * A failed mod's files leave the world: after loading, so they do not start, and after the start,
	 * so they do not compile. Its dependents' go with them.
	 */
	static function dropFailedModules():Void {
		if (world == null)
			return;
		for (record in records) {
			if (record.status != "failed")
				continue;
			var modules = modModules.get(record.id);
			if (modules == null)
				continue;
			for (module in modules) {
				world.removeModule(module);
				moduleOwner.remove(module.path);
			}
			modModules.remove(record.id);
		}
	}

	/**
	 * Upstream order: every module is initialised and started before the compile, which resolves
	 * bare names through each module's interpreter. Module-level code therefore runs interpreted
	 * once, compiled modules included.
	 */
	static function startWorld():Void {
		if (world == null)
			return;
		var modules = [for (module in world.modules) module];
		for (module in modules)
			guard(module, function() {
				module.init(world);
			});
		for (module in modules)
			guard(module, function() {
				module.start(world);
			});
		for (module in modules)
			guard(module, function() {
				module.startTypes(world);
			});
		// hxScript catches a static initialiser's throw and keeps it on the class (`staticFailure`).
		for (module in modules)
			for (type in module.types)
				if (type is hxscript.types.ScriptedClass) {
					var scripted:hxscript.types.ScriptedClass = cast type;
					if (scripted.staticFailure != null)
						fail(recordById(moduleOwner.get(module.path)), "static " + scripted.name + "." + scripted.staticFailure);
				}
	}

	/**
	 * hxScript turns the JIT on itself before the first module loads (`Compiler.jit`, on by default).
	 * A throw is the compiler's fault, not a mod's: every module already started interpreted, so what
	 * did not compile keeps running that way and `assignModes` reports it.
	 */
	static function compileWorld():Void {
		if (world == null)
			return;
		try {
			hxscript.compile.Compiler.compile(world);
		} catch (e:Dynamic) {
			note("warn", "modding: compile failed, mods run interpreted: " + errorText(e));
		}
	}

	static function assignModes():Void {
		for (record in records) {
			var modules = modModules.get(record.id);
			if (modules == null)
				continue;
			var compiled = 0;
			var interpreted = 0;
			for (module in modules) {
				var paths = hxscript.cppia.Backend.declaredPaths(module.decls);
				if (paths.length == 0)
					continue;
				if (compiledModule(module))
					compiled++;
				else
					interpreted++;
			}
			if (compiled == 0 && interpreted == 0)
				continue;
			if (interpreted == 0)
				record.mode = "compiled";
			else if (compiled == 0)
				record.mode = "interpreted";
			else
				record.mode = "mixed";
			if (record.status == "ok" && interpreted > 0) {
				var noun = interpreted == 1 ? "module" : "modules";
				record.error = interpreted + " " + noun + " left interpreted";
			}
		}
	}

	static function compiledModule(module:hxscript.Module):Bool {
		if (world == null)
			return false;
		var paths = hxscript.cppia.Backend.declaredPaths(module.decls);
		if (paths.length == 0)
			return false;
		for (path in paths)
			if (!world.compiled.exists(path))
				return false;
		return true;
	}

	static function guard(module:hxscript.Module, call:Void->Void):Void {
		var owner = moduleOwner.get(module.path);
		if (owner == null)
			return;
		try {
			call();
		} catch (e:Dynamic) {
			fail(recordById(owner), errorText(e));
		}
	}

	static function runInits():Void {
		var needsOverlay = false;
		for (record in records) {
			if (record.status == "ok")
				needsOverlay = true;
		}
		if (needsOverlay)
			createOverlay();
		for (record in records) {
			if (record.status != "ok")
				continue;
			var path = "mods." + record.id + "." + record.entry;
			var instance:Null<Mod> = null;
			try {
				instance = createEntry(path);
			} catch (e:Dynamic) {
				fail(record, errorText(e));
				continue;
			}
			if (instance == null) {
				fail(record, "entry " + path + " was not found or does not extend modding.Mod");
				continue;
			}
			if (record.id != API_ID && !extendsPath(path, API_MOD)) {
				fail(record, "entry must extend " + API_MOD);
				continue;
			}
			record.instance = instance;
			record.layer = createLayer(record.id);
			record.context = new ModContext(record.id, record.layer);
			try {
				instance.onInit(record.context);
			} catch (e:Dynamic) {
				silence(record, errorText(e));
			}
		}
	}

	/** One layer per mod inside the shared overlay, stacked in load order. */
	static function createLayer(id:String):Sprite {
		var layer = new Sprite();
		layer.name = "mod:" + id;
		layer.mouseEnabled = false;
		if (overlay != null)
			overlay.addChild(layer);
		return layer;
	}

	/**
	 * A failed mod goes quiet: every subscription it holds is cancelled and its overlay layer
	 * leaves the stage. `onDispose` still runs at exit. Statics, files and threads stay as they are.
	 */
	static function silence(record:ModRecord, message:String):Void {
		record.status = "failed";
		record.error = message;
		for (list in listeners)
			for (subscription in list.copy())
				if (subscription.owner == record.id)
					subscription.cancel();
		if (record.layer != null && record.layer.parent != null)
			record.layer.parent.removeChild(record.layer);
		failDependents(record);
	}

	/** Every mod still running that depends on this one, directly or through another, fails with it. */
	static function failDependents(record:ModRecord):Void {
		for (other in records)
			if (other.status == "ok" && other.dependencies.indexOf(record.id) >= 0)
				silence(other, "dependency " + record.id + " failed");
	}

	/**
	 * Puts every mod after the mods it depends on (`api` included), in `enabled.json` order otherwise,
	 * so a dependency's `onInit` and `onReady` always run first. Inside a cycle the order is not defined.
	 */
	static function dependenciesFirst():Void {
		var ordered:Array<ModRecord> = [];
		var visited = new Map<ModRecord, Bool>();
		function visit(record:ModRecord):Void {
			if (visited.exists(record))
				return;
			visited.set(record, true);
			for (id in record.dependencies) {
				var dependency = recordById(id);
				if (dependency != null)
					visit(dependency);
			}
			ordered.push(record);
		}
		for (record in records)
			visit(record);
		records = ordered;
	}

	/**
	 * Once every enabled mod is resolved, whatever their order: a dependency that is not enabled or was
	 * skipped fails the mod before it loads, and one that already failed takes its dependents with it.
	 */
	static function checkDependencies():Void {
		for (record in records) {
			if (record.status != "ok")
				continue;
			for (id in record.dependencies) {
				var dependency = recordById(id);
				if (dependency == null || dependency.status == "skipped") {
					fail(record, "dependency " + id + " missing");
					break;
				}
			}
		}
		for (record in records)
			if (record.status == "failed")
				failDependents(record);
	}

	/** Whether the class at `path`, compiled or interpreted, is `base` or extends it. */
	static function extendsPath(path:String, base:String):Bool {
		if (world == null)
			return false;
		var current:Dynamic = world.compiled.exists(path) ? world.compiled.get(path) : world.resolve(path);
		var depth = 0;
		while (current != null && depth++ < 64) {
			if (Std.isOfType(current, hxscript.types.ScriptedClass)) {
				var scripted:hxscript.types.ScriptedClass = current;
				if (scripted.path == base)
					return true;
				current = scripted.extending;
			} else {
				if (Type.getClassName(current) == base)
					return true;
				current = Type.getSuperClass(current);
			}
		}
		return false;
	}

	static function createEntry(path:String):Null<Mod> {
		if (world != null && world.compiled.exists(path)) {
			var made:Dynamic = Type.createInstance(world.compiled.get(path), []);
			return Std.downcast(made, Mod);
		}
		var scripted = world == null ? null : world.resolve(path);
		if (scripted is hxscript.types.ScriptedClass) {
			var made:Dynamic = (cast scripted : hxscript.types.ScriptedClass).typeCreateInstance([]);
			return Std.downcast(made, Mod);
		}
		return null;
	}

	static function createOverlay():Void {
		overlay = new Sprite();
		overlay.name = "ModOverlay";
		overlay.mouseEnabled = false;
		if (stage != null && overlay.parent == null)
			stage.addChild(overlay);
	}

	/** First failure wins, so a later interpreted-module note does not replace it. */
	static function fail(record:ModRecord, message:String):Void {
		if (record == null || record.status == "failed")
			return;
		record.status = "failed";
		record.error = message;
		failDependents(record);
	}

	static function recordById(id:String):Null<ModRecord> {
		for (record in records)
			if (record.id == id)
				return record;
		return null;
	}

	static function writeReport():Void {
		if (!booted || modsRoot == "")
			return;
		var body = new StringBuf();
		body.add("{\n");
		body.add('  "drh": ${Json.stringify(Version.TAG)},\n');
		body.add('  "started": ${Json.stringify(started)},\n');
		body.add('  "ready": ${reportReady ? "true" : "false"},\n');
		body.add('  "mods": [\n');
		for (index in 0...records.length) {
			var record = records[index];
			body.add("    {\n");
			body.add('      "id": ${Json.stringify(record.id)}');
			if (record.version != "")
				body.add(',\n      "version": ${Json.stringify(record.version)}');
			body.add(',\n      "status": ${Json.stringify(record.status)}');
			if (record.mode != "")
				body.add(',\n      "mode": ${Json.stringify(record.mode)}');
			if (record.error != null)
				body.add(',\n      "error": ${Json.stringify(record.error)}');
			body.add("\n    }");
			if (index < records.length - 1)
				body.add(",");
			body.add("\n");
		}
		body.add("  ]\n}\n");
		try {
			sys.io.File.saveContent(modsRoot + "/last-run.json", body.toString());
		} catch (e:Dynamic) {
			note("warn", "modding: could not write last-run.json: " + errorText(e));
		}
	}

	static function summary(record:ModRecord):String {
		var parts = ["mod " + record.id];
		if (record.version != "")
			parts.push("version=" + record.version);
		if (record.uses.length > 0)
			parts.push("uses=" + record.uses.join(","));
		if (record.mode != "")
			parts.push("mode=" + record.mode);
		parts.push("status=" + record.status);
		if (record.error != null)
			parts.push(record.error);
		return parts.join(" ");
	}

	/** `extends` and / or `replace`; empty or absent for a mod that only uses the `api` mod. */
	static function readUses(value:Dynamic, record:ModRecord):Bool {
		if (value == null)
			return true;
		if (!Std.isOfType(value, Array)) {
			record.status = "failed";
			record.error = "uses must list extends or replace";
			return false;
		}
		var list:Array<Dynamic> = value;
		for (item in list) {
			if (!Std.isOfType(item, String)) {
				record.status = "failed";
				record.error = "invalid uses value";
				return false;
			}
			var kind:String = item;
			if (kind != "extends" && kind != "replace") {
				record.status = "failed";
				record.error = "invalid uses value: " + kind;
				return false;
			}
			if (record.uses.indexOf(kind) < 0)
				record.uses.push(kind);
		}
		return true;
	}

	/** The `api` mod version a mod needs: a dependency like any other, required everywhere but in `api` itself. */
	static function readApi(value:Dynamic, record:ModRecord):Bool {
		if (record.id == API_ID)
			return true;
		if (!Std.isOfType(value, String) || !API_VERSION.match(value)) {
			record.status = "failed";
			record.error = "api must be a version, such as \"1.0\"";
			return false;
		}
		record.dependencies.push(API_ID);
		return true;
	}

	/** `{ "id": "version" }`. The game only needs the ids; versions are the launcher's. */
	static function readDependencies(value:Dynamic, record:ModRecord):Bool {
		if (value == null)
			return true;
		if (!Reflect.isObject(value) || Std.isOfType(value, String) || Std.isOfType(value, Array)) {
			record.status = "failed";
			record.error = "dependencies must map ids to versions";
			return false;
		}
		for (id in Reflect.fields(value)) {
			if (!Std.isOfType(Reflect.field(value, id), String)) {
				record.status = "failed";
				record.error = "dependencies must map ids to versions";
				return false;
			}
			record.dependencies.push(id);
		}
		return true;
	}

	static function warnDrh(record:ModRecord, spec:Dynamic):Void {
		if (!Std.isOfType(spec, String) || spec == "") {
			note("warn", "mod " + record.id + ": drh is required with extends or replace");
			return;
		}
		var text:String = spec;
		var parsed = parseDrh(text);
		if (parsed == null) {
			note("warn", 'mod ${record.id}: drh "$text" is not a closed tag set');
			return;
		}
		var installed = Std.parseInt(Version.TAG);
		if (installed == null || installed == 0)
			return;
		if (parsed.indexOf(installed) < 0)
			note("warn", 'mod ${record.id}: drh $text does not include this build (${Version.TAG})');
	}

	static function parseDrh(spec:String):Null<Array<Int>> {
		var out = [];
		for (part in spec.split(",")) {
			var token = StringTools.trim(part);
			if (token == "")
				return null;
			var dash = token.indexOf("-");
			if (dash < 0) {
				if (!wholeNumber(token))
					return null;
				out.push(Std.parseInt(token));
			} else if (token.indexOf("-", dash + 1) >= 0) {
				return null;
			} else {
				var left = token.substr(0, dash);
				var right = token.substr(dash + 1);
				if (!wholeNumber(left) || !wholeNumber(right))
					return null;
				var from = Std.parseInt(left);
				var to = Std.parseInt(right);
				if (from > to)
					return null;
				var value = from;
				while (value <= to) {
					out.push(value);
					value++;
				}
			}
		}
		return out.length == 0 ? null : out;
	}

	static function wholeNumber(token:String):Bool {
		var value = Std.parseInt(token);
		return value != null && Std.string(value) == token;
	}

	static function validId(id:String):Bool {
		return id != null && ID.match(id) && !isKeyword(id) && !isReserved(id);
	}

	static function isKeyword(id:String):Bool {
		return switch (id) {
			case "abstract", "break", "case", "cast", "catch", "class", "continue", "default", "dynamic", "else", "enum",
				"extends", "extern", "false", "final", "for", "function", "implements", "import", "inline", "interface",
				"macro", "new", "null", "operator", "overload", "override", "package", "private", "public", "return",
				"static", "switch", "this", "throw", "true", "try", "typedef", "untyped", "using", "var", "while":
				true;
			default:
				false;
		}
	}

	static function isReserved(id:String):Bool {
		if (id == "con" || id == "prn" || id == "aux" || id == "nul")
			return true;
		if (id.length != 4)
			return false;
		var prefix = id.substr(0, 3);
		if (prefix != "com" && prefix != "lpt")
			return false;
		var digit = id.charCodeAt(3);
		return digit >= "1".code && digit <= "9".code;
	}

	static function modsDirectory(args:Array<String>):Null<String> {
		var index = 0;
		while (index < args.length) {
			var arg = args[index];
			if (arg == MODS_DIR_ARGUMENT) {
				if (index + 1 >= args.length || StringTools.startsWith(args[index + 1], "--")) {
					trace("modding: ignoring --mods-dir without a value");
					return null;
				}
				return args[index + 1];
			}
			if (StringTools.startsWith(arg, MODS_DIR_ARGUMENT + "=")) {
				var value = arg.substr(MODS_DIR_ARGUMENT.length + 1);
				if (value == "") {
					trace("modding: ignoring --mods-dir without a value");
					return null;
				}
				return value;
			}
			index++;
		}
		return null;
	}

	static function walk(dir:String, seen:Map<String, Bool>, visit:String->Void):Void {
		var absolute = dir;
		try absolute = sys.FileSystem.absolutePath(dir) catch (_:Dynamic) {}
		if (seen.exists(absolute))
			return;
		seen.set(absolute, true);
		var names = sys.FileSystem.readDirectory(dir);
		names.sort(function(a, b) return a < b ? -1 : a > b ? 1 : 0);
		for (name in names) {
			var path = dir + "/" + name;
			if (sys.FileSystem.isDirectory(path))
				walk(path, seen, visit);
			else
				visit(path);
		}
	}

	static function relativeTo(root:String, path:String):String {
		var normalizedRoot = root.split("\\").join("/");
		var normalizedPath = path.split("\\").join("/");
		if (!StringTools.endsWith(normalizedRoot, "/"))
			normalizedRoot += "/";
		if (StringTools.startsWith(normalizedPath, normalizedRoot))
			return normalizedPath.substr(normalizedRoot.length);
		return fileName(normalizedPath);
	}

	static function fileName(path:String):String {
		var normalized = path.split("\\").join("/");
		var slash = normalized.lastIndexOf("/");
		return slash < 0 ? normalized : normalized.substr(slash + 1);
	}

	static function readText(path:String):Null<String> {
		try {
			var text = sys.io.File.getContent(path);
			if (text.length > 0 && text.charCodeAt(0) == 0xFEFF)
				return text.substr(1);
			return text;
		} catch (_:Dynamic) {
			return null;
		}
	}

	static function note(level:String, text:String):Void {
		if (flushed)
			logNow(level, text);
		else
			pending.push({level: level, text: text});
	}

	static function logNow(level:String, text:String):Void {
		if (level == "warn")
			brain.logger.Logger.warn(text);
		else
			brain.logger.Logger.info(text);
	}

	static function errorText(value:Dynamic):String {
		if (value == null)
			return "unknown error";
		if (Std.isOfType(value, String))
			return oneLine(value);
		var message:Dynamic = null;
		try message = Reflect.field(value, "message") catch (_:Dynamic) {}
		if (message != null)
			return oneLine(Std.string(message));
		return oneLine(Std.string(value));
	}

	static function oneLine(text:String):String {
		if (text == null)
			return "unknown error";
		var flat = ~/[\r\n]+/g.replace(text, " ");
		return StringTools.trim(~/ {2,}/g.replace(flat, " "));
	}

	static function utcNow():String {
		var now = Date.now();
		var utc = Date.fromTime(now.getTime() + now.getTimezoneOffset() * 60 * 1000);
		return pad(utc.getFullYear(), 4) + "-" + pad(utc.getMonth() + 1, 2) + "-" + pad(utc.getDate(), 2) + "T"
			+ pad(utc.getHours(), 2) + ":" + pad(utc.getMinutes(), 2) + ":" + pad(utc.getSeconds(), 2) + "Z";
	}

	static function pad(value:Int, width:Int):String {
		var text = Std.string(value);
		while (text.length < width)
			text = "0" + text;
		return text;
	}
}

private class ModRecord {
	public var id:String;

	public var version:String = "";

	public var uses:Array<String> = [];

	public var dependencies:Array<String> = [];

	public var status:String;

	public var mode:String = "";

	public var error:Null<String>;

	public var entry:String = "";

	public var directory:String = "";

	public var instance:Null<Mod>;

	public var context:Null<ModContext>;

	public var layer:Null<Sprite>;

	public function new(id:String, status:String) {
		this.id = id;
		this.status = status;
	}
}

private typedef WaitingHero = {
	var hero:HeroGameObject;
	var local:Bool;
	var floor:DistributedDungeonFloor;
}

private typedef LogLine = {
	var level:String;
	var text:String;
}
