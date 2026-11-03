package box2D.collision;

import box2D.common.math.B2Vec2;
import flash.Boot;

class B2RayCastOutput {
	public var normal:B2Vec2;

	public var fraction:Float = Math.NaN;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		normal = new B2Vec2();
	}
}
