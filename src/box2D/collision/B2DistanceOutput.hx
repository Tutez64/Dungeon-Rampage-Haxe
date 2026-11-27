package box2D.collision;

import box2D.common.math.B2Vec2;

class B2DistanceOutput {
	public var pointB:B2Vec2;

	public var pointA:B2Vec2;

	public var iterations:Int = 0;

	public var distance:Float = Math.NaN;

	public function new() {
		pointA = new B2Vec2();
		pointB = new B2Vec2();
	}
}
