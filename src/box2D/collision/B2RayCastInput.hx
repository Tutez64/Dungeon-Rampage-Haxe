package box2D.collision;

import box2D.common.math.B2Vec2;

class B2RayCastInput {
	public var p2:B2Vec2;

	public var p1:B2Vec2;

	public var maxFraction:Float = Math.NaN;

	public function new(p1:B2Vec2 = /*undefined*/ null, p2:B2Vec2 = /*undefined*/ null, maxFraction:Float = 1) {
		this.p1 = new B2Vec2();
		this.p2 = new B2Vec2();
		if (p1 != null) {
			this.p1.setV(p1);
		}
		if (p2 != null) {
			this.p2.setV(p2);
		}
		this.maxFraction = maxFraction;
	}
}
