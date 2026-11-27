package events;

import flash.events.Event;

class ManagersLoadedEvent extends Event {
	public static inline final EVENT_NAME = "ManagersLoadedEvent";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("ManagersLoadedEvent", bubbles, cancelable);
	}
}
