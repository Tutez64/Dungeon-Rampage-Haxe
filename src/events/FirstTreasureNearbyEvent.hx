package events;

import flash.events.Event;

class FirstTreasureNearbyEvent extends Event {
	public static inline final EVENT_NAME = "FirstTreasureNearby";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("FirstTreasureNearby", bubbles, cancelable);
	}
}
