package actor.player.input.dBMouseEvents;

import actor.ActorGameObject;

class MouseDownOnActorEvent extends DBMouseEvent {
	public static inline final TYPE = "MouseDownOnActorEvent";

	public function new(actor:ActorGameObject, bubbles:Bool = false, cancelable:Bool = false) {
		super("MouseDownOnActorEvent", actor, bubbles, cancelable);
	}
}
