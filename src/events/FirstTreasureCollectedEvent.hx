package events;

import flash.events.Event;

class FirstTreasureCollectedEvent extends Event {
	public static inline final EVENT_NAME = "FirstTreasureCollected";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("FirstTreasureCollected", bubbles, cancelable);
	}
}
