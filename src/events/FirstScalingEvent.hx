package events;

import flash.events.Event;

class FirstScalingEvent extends Event {
	public static inline final EVENT_NAME = "FirstScaling";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("FirstScaling", bubbles, cancelable);
	}
}
