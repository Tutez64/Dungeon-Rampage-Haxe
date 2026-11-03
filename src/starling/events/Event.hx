package starling.events;

import starling.utils.StringUtil;

/*use*/ /*namespace*/ /*starling_internal*/ class Event {
	public static inline final ADDED = "added";

	public static inline final ADDED_TO_STAGE = "addedToStage";

	public static inline final ENTER_FRAME = "enterFrame";

	public static inline final REMOVED = "removed";

	public static inline final REMOVED_FROM_STAGE = "removedFromStage";

	public static inline final TRIGGERED = "triggered";

	public static inline final RESIZE = "resize";

	public static inline final COMPLETE = "complete";

	public static inline final CONTEXT3D_CREATE = "context3DCreate";

	public static inline final RENDER = "render";

	public static inline final RENDER_COMPLETE = "renderComplete";

	public static inline final SKIP_FRAME = "skipFrame";

	public static inline final ROOT_CREATED = "rootCreated";

	public static inline final REMOVE_FROM_JUGGLER = "removeFromJuggler";

	public static inline final REMOVED_FROM_JUGGLER = "removedFromJuggler";

	public static inline final TEXTURES_RESTORED = "texturesRestored";

	public static inline final IO_ERROR = "ioError";

	public static inline final SECURITY_ERROR = "securityError";

	public static inline final PARSE_ERROR = "parseError";

	public static inline final FATAL_ERROR = "fatalError";

	public static inline final CHANGE = "change";

	public static inline final CANCEL = "cancel";

	public static inline final SCROLL = "scroll";

	public static inline final OPEN = "open";

	public static inline final CLOSE = "close";

	public static inline final SELECT = "select";

	public static inline final READY = "ready";

	public static inline final UPDATE = "update";

	static var sEventPool:Vector<Event> = new Vector((0 : UInt));

	var _target:EventDispatcher;

	var _currentTarget:EventDispatcher;

	var _type:String;

	var _bubbles:Bool = false;

	var _stopsPropagation:Bool = false;

	var _stopsImmediatePropagation:Bool = false;

	var _data:ASObject;

	public function new(type:String, bubbles:Bool = false, data:ASObject = null) {
		_type = type;
		_bubbles = bubbles;
		_data = data;
	}

	/*starling_internal*/
	public static function fromPool(type:String, bubbles:Bool = false, data:ASObject = null):Event {
		if (sEventPool.length != 0) {
			return sEventPool.pop() /*starling_internal::*/ .reset(type, bubbles, data);
		}
		return new Event(type, bubbles, data);
	}

	/*starling_internal*/
	public static function toPool(event:Event) {
		event._data = event._target = event._currentTarget = null;
		sEventPool[sEventPool.length] = event;
	}

	public function stopPropagation() {
		_stopsPropagation = true;
	}

	public function stopImmediatePropagation() {
		_stopsPropagation = _stopsImmediatePropagation = true;
	}

	public function toString():String {
		return StringUtil.format("[{0} type=\"{1}\" bubbles={2}]", ASCompat.getQualifiedClassName(this).split("::").pop(), _type, _bubbles);
	}

	@:isVar public var bubbles(get, never):Bool;

	public function get_bubbles():Bool {
		return _bubbles;
	}

	@:isVar public var target(get, never):EventDispatcher;

	public function get_target():EventDispatcher {
		return _target;
	}

	@:isVar public var currentTarget(get, never):EventDispatcher;

	public function get_currentTarget():EventDispatcher {
		return _currentTarget;
	}

	@:isVar public var type(get, never):String;

	public function get_type():String {
		return _type;
	}

	@:isVar public var data(get, never):ASObject;

	public function get_data():ASObject {
		return _data;
	}

	@:allow(starling.events) function setTarget(value:EventDispatcher) {
		_target = value;
	}

	@:allow(starling.events) function setCurrentTarget(value:EventDispatcher) {
		_currentTarget = value;
	}

	@:allow(starling.events) function setData(value:ASObject) {
		_data = value;
	}

	@:allow(starling.events) @:isVar var stopsPropagation(get, never):Bool;

	function get_stopsPropagation():Bool {
		return _stopsPropagation;
	}

	@:allow(starling.events) @:isVar var stopsImmediatePropagation(get, never):Bool;

	function get_stopsImmediatePropagation():Bool {
		return _stopsImmediatePropagation;
	}

	/*starling_internal*/
	public function reset(type:String, bubbles:Bool = false, data:ASObject = null):Event {
		_type = type;
		_bubbles = bubbles;
		_data = data;
		_target = _currentTarget = null;
		_stopsPropagation = _stopsImmediatePropagation = false;
		return this;
	}
}
