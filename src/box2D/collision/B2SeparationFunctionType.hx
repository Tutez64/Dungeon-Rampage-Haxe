package box2D.collision;

import flash.Boot;

final class B2SeparationFunctionType {
	public static inline final __isenum = true;

	public static var FACE_A:B2SeparationFunctionType = new B2SeparationFunctionType("FACE_A", 1, null);

	public static var FACE_B:B2SeparationFunctionType = new B2SeparationFunctionType("FACE_B", 2, null);

	public static var POINTS:B2SeparationFunctionType = new B2SeparationFunctionType("POINTS", 0, null);

	public static var __constructs__:Array<ASAny>;

	public var tag:String;

	public var index:Int = 0;

	public var params:Array<ASAny>;

	public static inline final __enum__ = true;

	public function new(tag:String, index:Int, params:Array<ASAny>) {
		this.tag = tag;
		this.index = index;
		this.params = params;
	}

	final public function toString():String {
		return Boot.enum_to_string(this);
	}

	static function __init__() {
		__constructs__ = ["POINTS", "FACE_A", "FACE_B"];
	}
}
