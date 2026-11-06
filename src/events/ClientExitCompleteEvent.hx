package events;

import flash.events.Event;

class ClientExitCompleteEvent extends Event {
	public static inline final EVENT_NAME = "CLIENT_EXIT_COMPLETE";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("CLIENT_EXIT_COMPLETE", bubbles, cancelable);
	}
}
