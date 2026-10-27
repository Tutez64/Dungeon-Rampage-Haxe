package events;

import flash.events.Event;

class FirstRepeaterEvent extends Event {
	public static inline final EVENT_NAME = "FirstRepeater";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("FirstRepeater", bubbles, cancelable);
	}
}
