package modding;

import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * What a mod receives in `onInit` and `onReady`.
 *
 * Subscribe from `onInit` for `onTablesLoaded` (it fires before `onReady`) and for
 * anything that can happen as the world appears. Each `on*` returns the subscription
 * to cancel. `replace` is not part of this build.
 */
class ModContext {
	/** Draw root. The host keeps it above the letterbox; mods do not set z-order. */
	public var overlay(default, null):Sprite;

	public var state(default, null):ModState;

	var id:String;

	var tracking:Bool = false;

	var added:Array<ModSubscription> = [];

	var children:Array<DisplayObject> = [];

	@:allow(modding.Host)
	function new(id:String, overlay:Sprite, state:ModState) {
		this.id = id;
		this.overlay = overlay;
		this.state = state;
	}

	public function log(message:String):Void {
		Host.modLog(id, message);
	}

	/** A hero, local or remote, is on a dungeon floor and initialised. Not town. */
	public function onHeroSpawned(handler:ModHero->Void):ModSubscription {
		return listen(Host.HERO_SPAWNED, handler);
	}

	/** A hero leaves the floor. Its wrapper reads empty afterwards. */
	public function onHeroDespawned(handler:ModHero->Void):ModSubscription {
		return listen(Host.HERO_DESPAWNED, handler);
	}

	/** A dungeon floor starts. Its tiles may still be building. */
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

	function listen(event:String, handler:Dynamic):ModSubscription {
		if (handler == null)
			throw event + ": handler is null";
		var subscription = Host.listen(id, event, handler);
		if (tracking)
			added.push(subscription);
		return subscription;
	}

	@:allow(modding.Host)
	function beginCall():Void {
		tracking = true;
		added = [];
		children = snapshot();
	}

	@:allow(modding.Host)
	function commitCall():Void {
		tracking = false;
		added = [];
		children = [];
	}

	/** Drops subscriptions and overlay children added during the call that just failed. */
	@:allow(modding.Host)
	function rollbackCall():Void {
		for (subscription in added)
			subscription.cancel();
		added = [];
		tracking = false;
		if (overlay == null)
			return;
		var keep = new Map<DisplayObject, Bool>();
		for (child in children)
			keep.set(child, true);
		var index = overlay.numChildren - 1;
		while (index >= 0) {
			var child = overlay.getChildAt(index);
			if (!keep.exists(child))
				overlay.removeChildAt(index);
			index--;
		}
		children = [];
	}

	function snapshot():Array<DisplayObject> {
		var out = [];
		if (overlay == null)
			return out;
		for (index in 0...overlay.numChildren)
			out.push(overlay.getChildAt(index));
		return out;
	}
}
