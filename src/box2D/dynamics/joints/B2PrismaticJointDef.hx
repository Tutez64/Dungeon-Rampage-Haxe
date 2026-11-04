package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

class B2PrismaticJointDef extends B2JointDef {
	public var upperTranslation:Float = Math.NaN;

	public var referenceAngle:Float = Math.NaN;

	public var motorSpeed:Float = Math.NaN;

	public var maxMotorForce:Float = Math.NaN;

	public var lowerTranslation:Float = Math.NaN;

	public var localAxisA:B2Vec2;

	public var localAnchorB:B2Vec2;

	public var localAnchorA:B2Vec2;

	public var enableMotor:Bool = false;

	public var enableLimit:Bool = false;

	public function new() {
		super();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		localAxisA = new B2Vec2();
		type = 2;
		localAxisA.set(1, 0);
		referenceAngle = 0;
		enableLimit = false;
		lowerTranslation = 0;
		upperTranslation = 0;
		enableMotor = false;
		maxMotorForce = 0;
		motorSpeed = 0;
	}

	public function initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2, axis:B2Vec2) {
		Initialize(bA, bB, anchor, axis);
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2, axis:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		localAnchorA = bodyA.getLocalPoint(anchor);
		localAnchorB = bodyB.getLocalPoint(anchor);
		localAxisA = bodyA.getLocalVector(axis);
		referenceAngle = bodyB.getAngle() - bodyA.getAngle();
	}
}
