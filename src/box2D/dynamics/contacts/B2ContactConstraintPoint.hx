package box2D.dynamics.contacts;

import box2D.common.math.B2Vec2;
import flash.Boot;

class B2ContactConstraintPoint {
	public var velocityBias:Float = Math.NaN;

	public var tangentMass:Float = Math.NaN;

	public var tangentImpulse:Float = Math.NaN;

	public var rB:B2Vec2;

	public var rA:B2Vec2;

	public var normalMass:Float = Math.NaN;

	public var normalImpulse:Float = Math.NaN;

	public var localPoint:B2Vec2;

	public var equalizedMass:Float = Math.NaN;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		localPoint = new B2Vec2();
		rA = new B2Vec2();
		rB = new B2Vec2();
	}
}
