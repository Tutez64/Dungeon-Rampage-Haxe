package events;

import flash.events.Event;

class GameObjectEvent extends Event {
	public var id:UInt = 0;

	public function new(gameObjectEventType:String, id:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		this.id = id;
		super(uniqueEvent(gameObjectEventType, id), bubbles, cancelable);
	}

	public static function uniqueEvent(inType:String, id:UInt):String {
		return inType + "_" + Std.string(id);
	}
}
