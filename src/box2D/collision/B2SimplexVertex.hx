package box2D.collision;

import box2D.common.math.B2Vec2;

/*internal*/
class B2SimplexVertex {
	public var wA:B2Vec2;

	public var wB:B2Vec2;

	public var w:B2Vec2;

	public var a:Float = Math.NaN;

	public var indexA:Int = 0;

	public var indexB:Int = 0;

	public function new() {}

	public function Set(other:B2SimplexVertex) {
		this.wA.SetV(other.wA);
		this.wB.SetV(other.wB);
		this.w.SetV(other.w);
		this.a = other.a;
		this.indexA = other.indexA;
		this.indexB = other.indexB;
	}
}
