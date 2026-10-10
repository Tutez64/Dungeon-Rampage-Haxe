package events;

import flash.events.Event;

class LEClientEvent extends Event {
	public static inline final SEND_EVENT = "SEND_EVENT";

	public var eventName:String = "";

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super("SEND_EVENT", bubbles, cancelable);
		eventName = type;
	}
}
