package actor.player.input.dBMouseEvents;

import actor.ActorGameObject;

class MouseUpOnActorEvent extends DBMouseEvent {
	public static inline final TYPE = "MouseUpOnActorEvent";

	public function new(actor:ActorGameObject, bubbles:Bool = false, cancelable:Bool = false) {
		super("MouseUpOnActorEvent", actor, bubbles, cancelable);
	}
}
