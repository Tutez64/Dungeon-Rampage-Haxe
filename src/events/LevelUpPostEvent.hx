package events;

import flash.events.Event;

class LevelUpPostEvent extends Event {
	public static inline final NAME = "LevelUpPostEvent";

	var mLevel:UInt = 0;

	public function new(levelUpPostType:String, level:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super(levelUpPostType, bubbles, cancelable);
		mLevel = level;
	}

	@:isVar public var level(get, never):UInt;

	public function get_level():UInt {
		return mLevel;
	}
}
