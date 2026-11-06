package box2D.collision.shapes;

import box2D.common.math.B2Vec2;

class B2MassData {
	public var mass:Float = Math.NaN;

	public var center:B2Vec2;

	public var I:Float = Math.NaN;

	public function new() {
		mass = 0;
		center = new B2Vec2(0, 0);
		I = 0;
	}
}
