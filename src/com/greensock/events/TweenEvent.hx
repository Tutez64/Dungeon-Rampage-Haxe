package com.greensock.events;

import flash.events.Event;

class TweenEvent extends Event {
	public static inline final VERSION:Float = 1.1;

	public static inline final START = "start";

	public static inline final UPDATE = "change";

	public static inline final COMPLETE = "complete";

	public static inline final REVERSE_COMPLETE = "reverseComplete";

	public static inline final REPEAT = "repeat";

	public static inline final INIT = "init";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}

	override public function clone():Event {
		return new TweenEvent(this.type, this.bubbles, this.cancelable);
	}
}
