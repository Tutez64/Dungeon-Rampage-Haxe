package box2D.collision;

import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;

class B2OBB {
	public var extents:B2Vec2;

	public var center:B2Vec2;

	public var R:B2Mat22;

	public function new() {
		R = new B2Mat22();
		center = new B2Vec2();
		extents = new B2Vec2();
	}
}
