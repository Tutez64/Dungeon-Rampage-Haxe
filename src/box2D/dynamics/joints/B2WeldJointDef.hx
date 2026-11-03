package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import flash.Boot;

class B2WeldJointDef extends B2JointDef {
	public var referenceAngle:Float = Math.NaN;

	public var localAnchorB:B2Vec2;

	public var localAnchorA:B2Vec2;

	public function new() {
		if (!Boot.skip_constructor) {
			super();
			localAnchorA = new B2Vec2();
			localAnchorB = new B2Vec2();
			type = 8;
			referenceAngle = 0;
		}
	}

	public function initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) {
		Initialize(bA, bB, anchor);
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		localAnchorA.setV(bodyA.getLocalPoint(anchor));
		localAnchorB.setV(bodyB.getLocalPoint(anchor));
		referenceAngle = bodyB.getAngle() - bodyA.getAngle();
	}
}
