package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

/*use*/ /*namespace*/ /*b2internal*/ class B2WeldJointDef extends B2JointDef {
	public var localAnchorA:B2Vec2 = new B2Vec2();

	public var localAnchorB:B2Vec2 = new B2Vec2();

	public var referenceAngle:Float = Math.NaN;

	public function new() {
		super();
		type = B2Joint.e_weldJoint;
		this.referenceAngle = 0;
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchor:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		this.localAnchorA.SetV(bodyA.GetLocalPoint(anchor));
		this.localAnchorB.SetV(bodyB.GetLocalPoint(anchor));
		this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
	}
}
