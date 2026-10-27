package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

/*use*/ /*namespace*/ /*b2internal*/ class B2PrismaticJointDef extends B2JointDef {
	public var localAnchorA:B2Vec2 = new B2Vec2();

	public var localAnchorB:B2Vec2 = new B2Vec2();

	public var localAxisA:B2Vec2 = new B2Vec2();

	public var referenceAngle:Float = Math.NaN;

	public var enableLimit:Bool = false;

	public var lowerTranslation:Float = Math.NaN;

	public var upperTranslation:Float = Math.NaN;

	public var enableMotor:Bool = false;

	public var maxMotorForce:Float = Math.NaN;

	public var motorSpeed:Float = Math.NaN;

	public function new() {
		super();
		type = B2Joint.e_prismaticJoint;
		this.localAxisA.Set(1, 0);
		this.referenceAngle = 0;
		this.enableLimit = false;
		this.lowerTranslation = 0;
		this.upperTranslation = 0;
		this.enableMotor = false;
		this.maxMotorForce = 0;
		this.motorSpeed = 0;
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2, axis:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		this.localAnchorA = bodyA.GetLocalPoint(anchor);
		this.localAnchorB = bodyB.GetLocalPoint(anchor);
		this.localAxisA = bodyA.GetLocalVector(axis);
		this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
	}
}
