package actor.player.input.dBMouseEvents;

import actor.ActorGameObject;

class MouseOutOnActorEvent extends DBMouseEvent {
	public static inline final TYPE = "MouseOutOnActorEvent";

	public function new(actor:ActorGameObject, bubbles:Bool = false, cancelable:Bool = false) {
		super("MouseOutOnActorEvent", actor, bubbles, cancelable);
	}
}
