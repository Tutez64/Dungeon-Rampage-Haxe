package starling.events;

class KeyboardEvent extends Event {
	public static inline final KEY_UP = "keyUp";

	public static inline final KEY_DOWN = "keyDown";

	var _charCode:UInt = 0;

	var _keyCode:UInt = 0;

	var _keyLocation:UInt = 0;

	var _altKey:Bool = false;

	var _ctrlKey:Bool = false;

	var _shiftKey:Bool = false;

	var _isDefaultPrevented:Bool = false;

	public function new(type:String, charCode:UInt = (0 : UInt), keyCode:UInt = (0 : UInt), keyLocation:UInt = (0 : UInt), ctrlKey:Bool = false,
			altKey:Bool = false, shiftKey:Bool = false) {
		super(type, false, keyCode);
		_charCode = charCode;
		_keyCode = keyCode;
		_keyLocation = keyLocation;
		_ctrlKey = ctrlKey;
		_altKey = altKey;
		_shiftKey = shiftKey;
	}

	public function preventDefault() {
		_isDefaultPrevented = true;
	}

	public function isDefaultPrevented():Bool {
		return _isDefaultPrevented;
	}

	@:isVar public var charCode(get, never):UInt;

	public function get_charCode():UInt {
		return _charCode;
	}

	@:isVar public var keyCode(get, never):UInt;

	public function get_keyCode():UInt {
		return _keyCode;
	}

	@:isVar public var keyLocation(get, never):UInt;

	public function get_keyLocation():UInt {
		return _keyLocation;
	}

	@:isVar public var altKey(get, never):Bool;

	public function get_altKey():Bool {
		return _altKey;
	}

	@:isVar public var ctrlKey(get, never):Bool;

	public function get_ctrlKey():Bool {
		return _ctrlKey;
	}

	@:isVar public var shiftKey(get, never):Bool;

	public function get_shiftKey():Bool {
		return _shiftKey;
	}
}
