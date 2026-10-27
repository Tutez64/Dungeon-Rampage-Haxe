package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

/*use*/ /*namespace*/ /*b2internal*/ class B2DistanceJointDef extends B2JointDef {
	public var localAnchorA:B2Vec2 = new B2Vec2();

	public var localAnchorB:B2Vec2 = new B2Vec2();

	public var length:Float = Math.NaN;

	public var frequencyHz:Float = Math.NaN;

	public var dampingRatio:Float = Math.NaN;

	public function new() {
		super();
		type = B2Joint.e_distanceJoint;
		this.length = 1;
		this.frequencyHz = 0;
		this.dampingRatio = 0;
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchorA:B2Vec2, anchorB:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		this.localAnchorA.SetV(bodyA.GetLocalPoint(anchorA));
		this.localAnchorB.SetV(bodyB.GetLocalPoint(anchorB));
		var _loc5_ = anchorB.x - anchorA.x;
		var _loc6_ = anchorB.y - anchorA.y;
		this.length = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
		this.frequencyHz = 0;
		this.dampingRatio = 0;
	}
}
