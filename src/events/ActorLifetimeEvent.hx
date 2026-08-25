package events;

import flash.events.Event;

class ActorLifetimeEvent extends Event {
	public static inline final ACTOR_CREATE_EVENT = "ACTOR_CREATED";

	public static inline final ACTOR_DESTROY_EVENT = "ACTOR_DESTROYED";

	var mActorId:UInt = 0;

	public function new(type:String, actorId:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		mActorId = actorId;
	}

	@:isVar public var actorId(get, never):UInt;

	public function get_actorId():UInt {
		return mActorId;
	}
}
