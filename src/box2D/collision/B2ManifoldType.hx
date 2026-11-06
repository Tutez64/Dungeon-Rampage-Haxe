package box2D.collision;

final class B2ManifoldType {
	public static inline final __isenum = true;

	public static var CIRCLES:B2ManifoldType = new B2ManifoldType("CIRCLES", 0, null);

	public static var FACE_A:B2ManifoldType = new B2ManifoldType("FACE_A", 1, null);

	public static var FACE_B:B2ManifoldType = new B2ManifoldType("FACE_B", 2, null);

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
		return ASCompat.haxeEnumToString(this);
	}

	static function __init__() {
		__constructs__ = ["CIRCLES", "FACE_A", "FACE_B"];
	}
}
