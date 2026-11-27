package events;

import flash.events.Event;

class II_FloorCompleteEvent extends Event {
	public static inline final TYPE = "II_FLOOR_COMPLETE";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("II_FLOOR_COMPLETE", bubbles, cancelable);
	}
}
