package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;

class B2Jacobian {
	public var linearA:B2Vec2 = new B2Vec2();

	public var angularA:Float = Math.NaN;

	public var linearB:B2Vec2 = new B2Vec2();

	public var angularB:Float = Math.NaN;

	public function new() {}

	public function SetZero() {
		this.linearA.SetZero();
		this.angularA = 0;
		this.linearB.SetZero();
		this.angularB = 0;
	}

	public function Set(x1:B2Vec2, a1:Float, x2:B2Vec2, a2:Float) {
		this.linearA.SetV(x1);
		this.angularA = a1;
		this.linearB.SetV(x2);
		this.angularB = a2;
	}

	public function Compute(x1:B2Vec2, a1:Float, x2:B2Vec2, a2:Float):Float {
		return this.linearA.x * x1.x
			+ this.linearA.y * x1.y
			+ this.angularA * a1
			+ (this.linearB.x * x2.x + this.linearB.y * x2.y)
			+ this.angularB * a2;
	}
}
