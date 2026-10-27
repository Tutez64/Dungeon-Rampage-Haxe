package box2D.dynamics.joints;

import box2D.common.math.B2Vec2;
import box2D.dynamics.B2Body;

/*use*/ /*namespace*/ /*b2internal*/ class B2PulleyJointDef extends B2JointDef {
	public var groundAnchorA:B2Vec2 = new B2Vec2();

	public var groundAnchorB:B2Vec2 = new B2Vec2();

	public var localAnchorA:B2Vec2 = new B2Vec2();

	public var localAnchorB:B2Vec2 = new B2Vec2();

	public var lengthA:Float = Math.NaN;

	public var maxLengthA:Float = Math.NaN;

	public var lengthB:Float = Math.NaN;

	public var maxLengthB:Float = Math.NaN;

	public var ratio:Float = Math.NaN;

	public function new() {
		super();
		type = B2Joint.e_pulleyJoint;
		this.groundAnchorA.Set(-1, 1);
		this.groundAnchorB.Set(1, 1);
		this.localAnchorA.Set(-1, 0);
		this.localAnchorB.Set(1, 0);
		this.lengthA = 0;
		this.maxLengthA = 0;
		this.lengthB = 0;
		this.maxLengthB = 0;
		this.ratio = 1;
		collideConnected = true;
	}

	public function Initialize(bA:B2Body, bB:B2Body, gaA:B2Vec2, gaB:B2Vec2, anchorA:B2Vec2, anchorB:B2Vec2, r:Float) {
		bodyA = bA;
		bodyB = bB;
		this.groundAnchorA.SetV(gaA);
		this.groundAnchorB.SetV(gaB);
		this.localAnchorA = bodyA.GetLocalPoint(anchorA);
		this.localAnchorB = bodyB.GetLocalPoint(anchorB);
		var _loc8_ = anchorA.x - gaA.x;
		var _loc9_ = anchorA.y - gaA.y;
		this.lengthA = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
		var _loc10_ = anchorB.x - gaB.x;
		var _loc11_ = anchorB.y - gaB.y;
		this.lengthB = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
		this.ratio = r;
		var _loc12_ = this.lengthA + this.ratio * this.lengthB;
		this.maxLengthA = _loc12_ - this.ratio * B2PulleyJoint.b2_minPulleyLength;
		this.maxLengthB = (_loc12_ - B2PulleyJoint.b2_minPulleyLength) / this.ratio;
	}
}
