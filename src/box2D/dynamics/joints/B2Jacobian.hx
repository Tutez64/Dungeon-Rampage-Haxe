package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;

class B2Jacobian {
	public var linearB:B2Vec2;

	public var linearA:B2Vec2;

	public var angularB:Float = Math.NaN;

	public var angularA:Float = Math.NaN;

	public function new() {
		linearA = new B2Vec2();
		linearB = new B2Vec2();
	}

	public function setZero() {
		SetZero();
	}

	public function set(x1:B2Vec2, a1:Float, x2:B2Vec2, a2:Float) {
		Set(x1, a1, x2, a2);
	}

	public function compute(x1:B2Vec2, a1:Float, x2:B2Vec2, a2:Float):Float {
		return Compute(x1, a1, x2, a2);
	}

	public function SetZero() {
		linearA.setZero();
		angularA = 0;
		linearB.setZero();
		angularB = 0;
	}

	public function Set(x1:B2Vec2, a1:Float, x2:B2Vec2, a2:Float) {
		linearA.setV(x1);
		angularA = a1;
		linearB.setV(x2);
		angularB = a2;
	}

	public function Compute(x1:B2Vec2, a1:Float, x2:B2Vec2, a2:Float):Float {
		return linearA.x * x1.x + linearA.y * x1.y + angularA * a1 + (linearB.x * x2.x + linearB.y * x2.y) + angularB * a2;
	}
}
