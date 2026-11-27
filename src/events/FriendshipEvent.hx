package events;

import flash.events.Event;

class FriendshipEvent extends Event {
	public var id:UInt = 0;

	public function new(friendshipEventType:String, id:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super(friendshipEventType, bubbles, cancelable);
		this.id = id;
	}
}
