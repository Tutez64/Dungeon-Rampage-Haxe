package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

class B2PulleyJointDef extends B2JointDef {
	public var ratio:Float = Math.NaN;

	public var maxLengthB:Float = Math.NaN;

	public var maxLengthA:Float = Math.NaN;

	public var localAnchorB:B2Vec2;

	public var localAnchorA:B2Vec2;

	public var lengthB:Float = Math.NaN;

	public var lengthA:Float = Math.NaN;

	public var groundAnchorB:B2Vec2;

	public var groundAnchorA:B2Vec2;

	public function new() {
		super();
		groundAnchorA = new B2Vec2();
		groundAnchorB = new B2Vec2();
		localAnchorA = new B2Vec2();
		localAnchorB = new B2Vec2();
		type = 4;
		groundAnchorA.set(-1, 1);
		groundAnchorB.set(1, 1);
		localAnchorA.set(-1, 0);
		localAnchorB.set(1, 0);
		lengthA = 0;
		maxLengthA = 0;
		lengthB = 0;
		maxLengthB = 0;
		ratio = 1;
		collideConnected = true;
	}

	public function initialize(bA:B2Body, bB:B2Body, gaA:B2Vec2, gaB:B2Vec2, anchorA:B2Vec2, anchorB:B2Vec2, r:Float) {
		Initialize(bA, bB, gaA, gaB, anchorA, anchorB, r);
	}

	public function Initialize(bA:B2Body, bB:B2Body, gaA:B2Vec2, gaB:B2Vec2, anchorA:B2Vec2, anchorB:B2Vec2, r:Float) {
		bodyA = bA;
		bodyB = bB;
		groundAnchorA.setV(gaA);
		groundAnchorB.setV(gaB);
		localAnchorA = bodyA.getLocalPoint(anchorA);
		localAnchorB = bodyB.getLocalPoint(anchorB);
		var _loc8_ = anchorA.x - gaA.x;
		var _loc9_ = anchorA.y - gaA.y;
		lengthA = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
		var _loc10_ = anchorB.x - gaB.x;
		var _loc11_ = anchorB.y - gaB.y;
		lengthB = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
		ratio = r;
		var _loc12_ = lengthA + ratio * lengthB;
		maxLengthA = _loc12_ - ratio * B2PulleyJoint.b2_minPulleyLength;
		maxLengthB = (_loc12_ - B2PulleyJoint.b2_minPulleyLength) / ratio;
	}
}
