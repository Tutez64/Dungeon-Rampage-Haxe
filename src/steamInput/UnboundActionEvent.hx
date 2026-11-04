package steamInput;

import flash.events.Event;

class UnboundActionEvent extends Event {
	public static inline final PRESSED = "UnboundActionEvent.PRESSED";

	public static inline final RELEASED = "UnboundActionEvent.RELEASED";

	public var actionName:String;

	public function new(type:String, actionName:String) {
		super(type);
		this.actionName = actionName;
	}

	public static function isAction(event:Event, actionName:String):Bool {
		var _loc3_ = ASCompat.reinterpretAs(event, UnboundActionEvent);
		return _loc3_ != null && _loc3_.actionName == actionName;
	}

	override public function clone():Event {
		return new UnboundActionEvent(type, actionName);
	}
}
