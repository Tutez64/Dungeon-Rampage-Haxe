package events;

import flash.events.Event;

class FriendshipEvent extends Event {
	public var id:UInt = 0;

	public function new(type:String, id:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		this.id = id;
	}
}
