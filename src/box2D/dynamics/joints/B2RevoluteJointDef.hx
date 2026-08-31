package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

/*use*/ /*namespace*/ /*b2internal*/ class B2RevoluteJointDef extends B2JointDef {
	public var localAnchorA:B2Vec2 = new B2Vec2();

	public var localAnchorB:B2Vec2 = new B2Vec2();

	public var referenceAngle:Float = Math.NaN;

	public var enableLimit:Bool = false;

	public var lowerAngle:Float = Math.NaN;

	public var upperAngle:Float = Math.NaN;

	public var enableMotor:Bool = false;

	public var motorSpeed:Float = Math.NaN;

	public var maxMotorTorque:Float = Math.NaN;

	public function new() {
		super();
		type = B2Joint.e_revoluteJoint;
		this.localAnchorA.Set(0, 0);
		this.localAnchorB.Set(0, 0);
		this.referenceAngle = 0;
		this.lowerAngle = 0;
		this.upperAngle = 0;
		this.maxMotorTorque = 0;
		this.motorSpeed = 0;
		this.enableLimit = false;
		this.enableMotor = false;
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		this.localAnchorA = bodyA.GetLocalPoint(anchor);
		this.localAnchorB = bodyB.GetLocalPoint(anchor);
		this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
	}
}
