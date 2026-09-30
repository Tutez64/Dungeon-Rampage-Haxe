package modding;

import flash.display.Sprite;

/**
 * What a mod receives in `onInit` and `onReady`.
 *
 * Subscribe from `onInit` for `onTablesLoaded` (it fires before `onReady`) and for
 * anything that can happen as the world appears. Each `on*` returns the subscription
 * to cancel. `replace` is not part of this build.
 */
class ModContext {
	/** This mod's layer of the overlay, above the letterbox and stacked in load order. Removed if the mod fails. */
	public var overlay(default, null):Sprite;

	public var state(default, null):ModState;

	/** Size of the game's view in overlay coordinates. 0 before `onReady`. */
	public var viewWidth(get, never):Float;

	public var viewHeight(get, never):Float;

	var id:String;

	@:allow(modding.Host)
	function new(id:String, overlay:Sprite, state:ModState) {
		this.id = id;
		this.overlay = overlay;
		this.state = state;
	}

	function get_viewWidth():Float {
		return Host.facade == null ? 0 : Host.facade.viewWidth;
	}

	function get_viewHeight():Float {
		return Host.facade == null ? 0 : Host.facade.viewHeight;
	}

	public function log(message:String):Void {
		Host.modLog(id, message);
	}

	/** A hero, local or remote, is on a dungeon floor and initialised. Not town. Always after that floor's `onFloorEnter`. */
	public function onHeroSpawned(handler:ModHero->Void):ModSubscription {
		return listen(Host.HERO_SPAWNED, handler);
	}

	/** A hero leaves the floor. Its wrapper reads empty afterwards. */
	public function onHeroDespawned(handler:ModHero->Void):ModSubscription {
		return listen(Host.HERO_DESPAWNED, handler);
	}

	/** A dungeon floor starts: its grid is built and its map node set. Art may still be loading. */
	public function onFloorEnter(handler:ModFloor->Void):ModSubscription {
		return listen(Host.FLOOR_ENTER, handler);
	}

	public function onFloorExit(handler:ModFloor->Void):ModSubscription {
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
	 * Return true to keep the key: its default action (Tab moving the focus to the chat) does not run.
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
