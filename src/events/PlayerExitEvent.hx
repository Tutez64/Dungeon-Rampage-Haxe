package events;

import flash.events.Event;

class PlayerExitEvent extends Event {
	public static inline final EVENT_STRING = "PlayerExitEvent_str";

	public var id:UInt = 0;

	public function new(in_id:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		id = in_id;
		super("PlayerExitEvent_str", bubbles, cancelable);
	}
}
