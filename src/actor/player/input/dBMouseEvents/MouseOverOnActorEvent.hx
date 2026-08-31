package actor.player.input.dBMouseEvents;

import actor.ActorGameObject;

class MouseOverOnActorEvent extends DBMouseEvent {
	public static inline final TYPE = "MouseOverOnActorEvent";

	public function new(actor:ActorGameObject, bubbles:Bool = false, cancelable:Bool = false) {
		super("MouseOverOnActorEvent", actor, bubbles, cancelable);
	}
}
