package openfl.events;

class StatusEvent extends Event {
	public static inline var STATUS:String = "status";

	public var code:String;
	public var level:String;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, code:String = "", level:String = "") {
		super(type, bubbles, cancelable);
		this.code = code;
		this.level = level;
	}

	override public function clone():Event {
		return new StatusEvent(type, bubbles, cancelable, code, level);
	}
}
