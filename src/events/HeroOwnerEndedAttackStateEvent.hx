package events;

import flash.events.Event;

class HeroOwnerEndedAttackStateEvent extends Event {
	public static inline final EVENT_NAME = "PLAYER_ENDED_ATTACK_STATE";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}
}
