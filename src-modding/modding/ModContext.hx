package modding;

import brain.gameObject.GameObject;
import brain.stateMachine.State;
import brain.stateMachine.StateMachine;
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

	/**
	 * This mod's `Resources/` folder, absolute and without a trailing slash, where it reads its own
	 * files; the only ones its release holds besides its code. It may not exist. They never replace the
	 * game's.
	 */
	public var resources(default, null):String;

	/**
	 * This mod's folder to write in, absolute and without a trailing slash: `data/<id>/` in the mods
	 * folder, created on first read. Kept when the mod is updated or uninstalled.
	 */
	public var data(get, never):String;

	var dataPath:String;

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
	function new(id:String, overlay:Sprite, resources:String, data:String) {
		this.id = id;
		this.overlay = overlay;
		this.resources = resources;
		this.dataPath = data;
	}

	function get_data():String {
		if (!sys.FileSystem.exists(dataPath))
			sys.FileSystem.createDirectory(dataPath);
		return dataPath;
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
	 * A game object is ready: a network object (floor, loot, dungeon summary, matchmaker…) once
	 * generated, an actor (hero, monster, NPC) once initialised, and never before its floor. The objects
	 * that were ready before `onReady` are announced right after it, in order.
	 */
	public function onObjectReady(handler:GameObject->Void):ModSubscription {
		return listen(Host.OBJECT_READY, handler);
	}

	/**
	 * A ready object is being destroyed, by the server or by the game: it is still whole while the
	 * handlers run.
	 */
	public function onObjectGone(handler:GameObject->Void):ModSubscription {
		return listen(Host.OBJECT_GONE, handler);
	}

	/** The server set a field or called a method on a ready object, by its network field id. */
	public function onFieldReceived(handler:(GameObject, UInt) -> Void):ModSubscription {
		return listen(Host.FIELD_RECEIVED, handler == null ? null : function(received:Dynamic) handler(received.object, received.field));
	}

	/**
	 * A state machine of the game entered a state, after its `enterState`: the main one (loading,
	 * town, dungeon run…), the town's (inventory, shop, map…) or an actor's. Not before `onReady`.
	 */
	public function onStateEnter(handler:(StateMachine, State) -> Void):ModSubscription {
		return listen(Host.STATE_ENTER, handler == null ? null : function(change:Dynamic) handler(change.machine, change.state));
	}

	/** A state machine leaves a state, before its `exitState`. Not before `onReady`. */
	public function onStateExit(handler:(StateMachine, State) -> Void):ModSubscription {
		return listen(Host.STATE_EXIT, handler == null ? null : function(change:Dynamic) handler(change.machine, change.state));
	}

	/** Tables are in, the account is not parsed against them yet. Fires before `onReady`. */
	public function onTablesLoaded(handler:Void->Void):ModSubscription {
		return listen(Host.TABLES_LOADED, handler == null ? null : function(_:Dynamic) handler());
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
