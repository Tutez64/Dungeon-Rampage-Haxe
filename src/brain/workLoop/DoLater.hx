package brain.workLoop;

class DoLater extends Task implements IPrioritizable {
	public var delay:Float = 0;

	public var dueTime:UInt = (0 : UInt);

	var mRepeat:Bool = true;

	public function new(repeating:Bool = true) {
		super();
		mRepeat = repeating;
	}

	@:isVar public var repeat(get, never):Bool;

	public function get_repeat():Bool {
		return mRepeat;
	}

	@:isVar public var priority(get, set):Int;

	public function get_priority():Int {
		return (-dueTime : Int);
	}

	function set_priority(value:Int):Int {
		throw new Error("Not implemented, set dueTime and requeue");
		return value;
	}
}
