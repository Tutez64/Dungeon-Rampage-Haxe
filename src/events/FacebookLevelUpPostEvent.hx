package events;

import flash.events.Event;

class FacebookLevelUpPostEvent extends Event {
	public static inline final NAME = "FacebookLevelUpPostEvent";

	var mLevel:UInt = 0;

	public function new(type:String, level:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		mLevel = level;
	}

	@:isVar public var level(get, never):UInt;

	public function get_level():UInt {
		return mLevel;
	}
}
