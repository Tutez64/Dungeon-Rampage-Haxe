package box2D.collision;

import box2D.collision.shapes.B2Shape;
import box2D.common.math.B2Vec2;

class B2ContactPoint {
	public var velocity:B2Vec2;

	public var shape2:B2Shape;

	public var shape1:B2Shape;

	public var separation:Float = Math.NaN;

	public var restitution:Float = Math.NaN;

	public var position:B2Vec2;

	public var normal:B2Vec2;

	public var id:B2ContactID;

	public var friction:Float = Math.NaN;

	public function new() {
		position = new B2Vec2();
		velocity = new B2Vec2();
		normal = new B2Vec2();
		id = new B2ContactID();
	}
}
