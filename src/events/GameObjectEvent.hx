package events;

import flash.events.Event;

class GameObjectEvent extends Event {
	public var id:UInt = 0;

	public function new(type:String, id:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		this.id = id;
		super(uniqueEvent(type, id), bubbles, cancelable);
	}

	public static function uniqueEvent(type:String, id:UInt):String {
		return type + "_" + Std.string(id);
	}
}
