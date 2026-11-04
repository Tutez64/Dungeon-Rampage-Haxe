package starling.events;

class EnterFrameEvent extends Event {
	public static inline final ENTER_FRAME = "enterFrame";

	public function new(type:String, passedTime:Float, bubbles:Bool = false) {
		super(type, bubbles, passedTime);
	}

	@:isVar public var passedTime(get, never):Float;

	public function get_passedTime():Float {
		return ASCompat.asNumber(data);
	}
}
