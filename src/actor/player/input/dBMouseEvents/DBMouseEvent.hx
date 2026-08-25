package actor.player.input.dBMouseEvents;

import actor.ActorGameObject;
import flash.events.Event;

class DBMouseEvent extends Event {
	var mActor:ActorGameObject;

	public function new(type:String, actor:ActorGameObject, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		mActor = actor;
	}

	@:isVar public var actor(get, never):ActorGameObject;

	public function get_actor():ActorGameObject {
		return mActor;
	}
}
