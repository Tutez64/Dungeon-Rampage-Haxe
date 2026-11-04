package steamInput;

import input.keyBindings.KeyBindings;

class KeyboardEventsSpoofMap {
	var mKeyBindings:KeyBindings;

	var mActionNames:Vector<String> = new Vector();

	public function new(keyBindings:KeyBindings) {
		mKeyBindings = keyBindings;
		mActionNames.push("revive_ally");
		mActionNames.push("toggle_menu");
	}

	@:isVar public var actionNames(get, never):Vector<String>;

	public function get_actionNames():Vector<String> {
		return mActionNames;
	}

	public function getKeyCode(action:String):Int {
		var _loc2_ = 0;
		switch (action) {
			case "revive_ally":
				_loc2_ = mKeyBindings.getPrimary("reviveAlly");
				return _loc2_ != 0 ? _loc2_ : mKeyBindings.getAlternate("reviveAlly");
			case "toggle_menu":
				return 27;
			default:
				return 0;
		}
		return 0;
	}
}
