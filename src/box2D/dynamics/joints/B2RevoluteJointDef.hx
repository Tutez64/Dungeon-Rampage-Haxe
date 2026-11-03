package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;
import flash.Boot;

class B2RevoluteJointDef extends B2JointDef {
	public var upperAngle:Float = Math.NaN;

	public var referenceAngle:Float = Math.NaN;

	public var motorSpeed:Float = Math.NaN;

	public var maxMotorTorque:Float = Math.NaN;

	public var lowerAngle:Float = Math.NaN;

	public var localAnchorB:B2Vec2;

	public var localAnchorA:B2Vec2;

	public var enableMotor:Bool = false;

	public var enableLimit:Bool = false;

	public function new() {
		if (!Boot.skip_constructor) {
			super();
			localAnchorA = new B2Vec2();
			localAnchorB = new B2Vec2();
			type = 1;
			localAnchorA.set(0, 0);
			localAnchorB.set(0, 0);
			referenceAngle = 0;
			lowerAngle = 0;
			upperAngle = 0;
			maxMotorTorque = 0;
			motorSpeed = 0;
			enableLimit = false;
			enableMotor = false;
		}
	}

	public function initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) {
		Initialize(bA, bB, anchor);
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.getLocalPoint(anchor);
		localAnchorB = bodyB.getLocalPoint(anchor);
		referenceAngle = bodyB.getAngle() - bodyA.getAngle();
	}
}
