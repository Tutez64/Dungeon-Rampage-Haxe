package modding;

import flash.display.DisplayObject;
import flash.display.Sprite;

/**
 * What a mod receives in `onInit` and `onReady`.
 *
 * Event names are the strings below. Subscribe from `onInit` for `tablesLoaded`
 * (it fires before `onReady`) and for anything that can happen as the world appears.
 * `replace` is not part of this build.
 */
class ModContext {
	public static inline final HERO_SPAWNED = "heroSpawned";

	public static inline final HERO_DESPAWNED = "heroDespawned";

	public static inline final FLOOR_ENTER = "floorEnter";

	public static inline final FLOOR_EXIT = "floorExit";

	public static inline final TABLES_LOADED = "tablesLoaded";

	public static inline final TOWN_ENTER = "townEnter";

	public static inline final TOWN_EXIT = "townExit";

	/** Draw root. The host keeps it above the letterbox; mods do not set z-order. */
	public var overlay(default, null):Sprite;

	public var state(default, null):ModState;

	var id:String;

	var tracking:Bool = false;

	var added:Array<Subscription> = [];

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

	/** `handler` is called with the wrapper, or with null when the event has no payload. */
	public function subscribe(event:String, handler:Dynamic):Void {
		if (handler == null || event == null || event == "")
			return;
		Host.listen(id, event, handler);
		if (tracking)
			added.push({event: event, handler: handler});
	}

	public function unsubscribe(event:String, handler:Dynamic):Void {
		Host.unlisten(id, event, handler);
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
		for (sub in added)
			Host.unlisten(id, sub.event, sub.handler);
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

private typedef Subscription = {
	var event:String;
	var handler:Dynamic;
}
