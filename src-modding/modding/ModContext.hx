package modding;

import distributedObjects.DistributedDungeonFloor;
import distributedObjects.HeroGameObject;
import flash.display.Sprite;

/**
 * What a mod's entry receives in `onInit` and `onReady`: the core, which the `api` mod is built on.
 * Not a stable surface. A mod other than `api` reaches it through `mods.api.Context.core`, as an
 * `extends` use.
 *
 * Subscribe from `onInit` for `onTablesLoaded` (it fires before `onReady`) and for anything that can
 * happen as the world appears. Each `on*` returns the subscription to cancel. `replace` is not part of
 * this build.
 */
class ModContext {
	/** This mod's layer of the overlay, above the letterbox and stacked in load order. Removed if the mod fails. */
	public var overlay(default, null):Sprite;

	/** Size of the game's view in overlay coordinates. 0 before `onReady`. */
	public var viewWidth(get, never):Float;

	public var viewHeight(get, never):Float;

	/** The game's facade, null before `onReady`. */
	public var facade(get, never):Null<facade.DBFacade>;

	/**
	 * Whether this mod still runs. False once it failed or a dependency did: its own subscriptions are
	 * cancelled then, and another mod holding handlers for it stops calling them.
	 */
	public var alive(get, never):Bool;

	var id:String;

	@:allow(modding.Host)
	function new(id:String, overlay:Sprite) {
		this.id = id;
		this.overlay = overlay;
	}

	function get_viewWidth():Float {
		return Host.facade == null ? 0 : Host.facade.viewWidth;
	}

	function get_viewHeight():Float {
		return Host.facade == null ? 0 : Host.facade.viewHeight;
	}

	function get_facade():Null<facade.DBFacade> {
		return Host.facade;
	}

	function get_alive():Bool {
		return Host.alive(id);
	}

	public function log(message:String):Void {
		Host.modLog(id, message);
	}

	/**
	 * A hero, local (a `HeroGameObjectOwner`) or remote, is on a dungeon floor and initialised. Not
	 * town. Always after that floor's `onFloorEnter`.
	 */
	public function onHeroSpawned(handler:HeroGameObject->Void):ModSubscription {
		return listen(Host.HERO_SPAWNED, handler);
	}

	/** A hero leaves the floor; it is still whole while the handlers run. */
	public function onHeroDespawned(handler:HeroGameObject->Void):ModSubscription {
		return listen(Host.HERO_DESPAWNED, handler);
	}

	/** A dungeon floor starts: its grid is built and its map node set. Art may still be loading. */
	public function onFloorEnter(handler:DistributedDungeonFloor->Void):ModSubscription {
		return listen(Host.FLOOR_ENTER, handler);
	}

	public function onFloorExit(handler:DistributedDungeonFloor->Void):ModSubscription {
		return listen(Host.FLOOR_EXIT, handler);
	}

	/** Tables are in, the account is not parsed against them yet. Fires before `onReady`. */
	public function onTablesLoaded(handler:Void->Void):ModSubscription {
		return listen(Host.TABLES_LOADED, handler == null ? null : function(_:Dynamic) handler());
	}

	/** Town entered, including a return from a dungeon. */
	public function onTownEnter(handler:Void->Void):ModSubscription {
		return listen(Host.TOWN_ENTER, handler == null ? null : function(_:Dynamic) handler());
	}

	public function onTownExit(handler:Void->Void):ModSubscription {
		return listen(Host.TOWN_EXIT, handler == null ? null : function(_:Dynamic) handler());
	}

	/**
	 * A key goes down, with its key code: once per press, not for a held key's repeats, and not while a
	 * text field such as the chat has focus.
	 * Return true to keep the key: the game never sees that press, neither its own shortcuts (Enter
	 * opening the chat) nor OpenFL's (Tab moving the focus), nor its repeats and release.
	 */
	public function onKeyDown(handler:UInt->Bool):ModSubscription {
		return listen(Host.KEY_DOWN, handler);
	}

	function listen(event:String, handler:Dynamic):ModSubscription {
		if (handler == null)
			throw event + ": handler is null";
		return Host.listen(id, event, handler);
	}
}
