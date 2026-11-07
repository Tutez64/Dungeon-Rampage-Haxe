package steamInput;

import flash.events.Event;

class OnSteamInputButtonPressedEvent extends Event {
	public static inline final TYPE = "OnSteamInputButtonPressedEvent";

	public var actionName:String;

	public function new(actionName:String) {
		this.actionName = actionName;
		super("OnSteamInputButtonPressedEvent");
	}
}
