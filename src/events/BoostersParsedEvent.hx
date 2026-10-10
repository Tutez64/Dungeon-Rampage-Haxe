package events;

import flash.events.Event;

class BoostersParsedEvent extends Event {
	public static inline final BOOSTERS_PARSED_UPDATE = "BoostersParsedEvent_BOOSTERS_PARSED_UPDATE";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}
}
