package steamInput;

import flash.events.Event;

class OnSteamInputButtonReleasedEvent extends Event {
	public static inline final TYPE = "OnSteamInputButtonReleasedEvent";

	public var actionName:String;

	public function new(actionName:String) {
		this.actionName = actionName;
		super("OnSteamInputButtonReleasedEvent");
	}
}
