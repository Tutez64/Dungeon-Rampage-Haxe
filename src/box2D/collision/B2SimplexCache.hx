package box2D.collision;

class B2SimplexCache {
	public var metric:Float = Math.NaN;

	public var indexB:Array<ASAny>;

	public var indexA:Array<ASAny>;

	public var count:Int = 0;

	public function new() {
		count = 0;
		metric = 0;
		indexA = [];
		indexB = [];
	}
}
