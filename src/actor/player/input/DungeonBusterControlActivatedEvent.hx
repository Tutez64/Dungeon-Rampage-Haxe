package actor.player.input;

import flash.events.Event;

class DungeonBusterControlActivatedEvent extends Event {
	public static inline final TYPE = "DungeonBusterControlActivatedEvent";

	public function new(bubbles:Bool = false, cancelable:Bool = false) {
		super("DungeonBusterControlActivatedEvent", bubbles, cancelable);
	}
}
