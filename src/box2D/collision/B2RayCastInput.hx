package box2D.collision;

import box2D.common.math.B2Vec2;

class B2RayCastInput {
	public var p1:B2Vec2 = new B2Vec2();

	public var p2:B2Vec2 = new B2Vec2();

	public var maxFraction:Float = Math.NaN;

	public function new(p1:B2Vec2 = null, p2:B2Vec2 = null, maxFraction:Float = 1) {
		if (p1 != null) {
			this.p1.SetV(p1);
		}
		if (p2 != null) {
			this.p2.SetV(p2);
		}
		this.maxFraction = maxFraction;
	}
}
