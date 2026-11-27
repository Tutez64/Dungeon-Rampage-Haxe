package actor.player.input.dBMouseEvents;

import actor.ActorGameObject;
import flash.events.Event;

class DBMouseEvent extends Event {
	var mActor:ActorGameObject;

	public function new(mouseEventType:String, actor:ActorGameObject, bubbles:Bool = false, cancelable:Bool = false) {
		super(mouseEventType, bubbles, cancelable);
		mActor = actor;
	}

	@:isVar public var actor(get, never):ActorGameObject;

	public function get_actor():ActorGameObject {
		return mActor;
	}
}
