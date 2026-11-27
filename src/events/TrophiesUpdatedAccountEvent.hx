package events;

import flash.events.Event;

class TrophiesUpdatedAccountEvent extends Event {
	public static inline final EVENT_NAME = "TrophiesUpdatedAccountEvent";

	public var trophyCount:UInt = 0;

	public function new(newTrophyCount:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super("TrophiesUpdatedAccountEvent", bubbles, cancelable);
		trophyCount = newTrophyCount;
	}
}
