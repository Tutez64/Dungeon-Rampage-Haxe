package box2D.collision;

import box2D.common.math.B2Vec2;

class B2SimplexVertex {
	public var wB:B2Vec2;

	public var wA:B2Vec2;

	public var w:B2Vec2;

	public var indexB:Int = 0;

	public var indexA:Int = 0;

	public var a:Float = Math.NaN;

	public function new() {
		indexB = 0;
		indexA = 0;
		a = 0;
	}

	public function set(other:B2SimplexVertex) {
		Set(other);
	}

	public function Set(other:B2SimplexVertex) {
		wA.setV(other.wA);
		wB.setV(other.wB);
		w.setV(other.w);
		a = other.a;
		indexA = other.indexA;
		indexB = other.indexB;
	}
}
