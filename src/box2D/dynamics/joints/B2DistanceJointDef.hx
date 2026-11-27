package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

class B2DistanceJointDef extends B2JointDef {
	public var localAnchorB:B2Vec2;

	public var localAnchorA:B2Vec2;

	public var length:Float = Math.NaN;

	public var frequencyHz:Float = Math.NaN;

	public var dampingRatio:Float = Math.NaN;

	public function new() {
		super();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		type = 3;
		length = 1;
		frequencyHz = 0;
		dampingRatio = 0;
	}

	public function initialize(bA:B2Body, bB:B2Body, anchorA:B2Vec2, anchorB:B2Vec2) {
		Initialize(bA, bB, anchorA, anchorB);
	}

	public function Initialize(bA:B2Body, bB:B2Body, anchorA:B2Vec2, anchorB:B2Vec2) {
		bodyA = bA;
		bodyB = bB;
		localAnchorA.setV(bodyA.getLocalPoint(anchorA));
		localAnchorB.setV(bodyB.getLocalPoint(anchorB));
		var _loc5_ = anchorB.x - anchorA.x;
		var _loc6_ = anchorB.y - anchorA.y;
		length = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
		frequencyHz = 0;
		dampingRatio = 0;
	}
}
