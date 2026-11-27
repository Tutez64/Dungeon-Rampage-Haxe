package events;

import flash.events.Event;

class FirstCooldownEvent extends Event {
	public static inline final EVENT_NAME = "FirstCooldown";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("FirstCooldown", bubbles, cancelable);
	}
}
