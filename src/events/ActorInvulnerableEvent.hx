package events;

class ActorInvulnerableEvent extends GameObjectEvent {
	public var mIsInvulnerable:Bool = false;

	public function new(type:String, id:UInt, isInvulnerable:Bool, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, id, bubbles, cancelable);
		mIsInvulnerable = isInvulnerable;
	}
}
