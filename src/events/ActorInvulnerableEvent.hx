package events;

class ActorInvulnerableEvent extends GameObjectEvent {
	public var mIsInvulnerable:Bool = false;

	public function new(actorInvulnerableType:String, id:UInt, isInvulnerable:Bool, bubbles:Bool = false, cancelable:Bool = false) {
		super(actorInvulnerableType, id, bubbles, cancelable);
		mIsInvulnerable = isInvulnerable;
	}
}
