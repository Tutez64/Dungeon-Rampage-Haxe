package box2D.dynamics.contacts;

import box2D.collision.B2Manifold;
import box2D.common.math.B2Mat22;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;
import box2D.dynamics.B2Body;
import box2D.collision.B2ManifoldType;

class B2ContactConstraint {
	public var type:B2ManifoldType;

	public var restitution:Float = Math.NaN;

	public var radius:Float = Math.NaN;

	public var points:Array<ASAny>;

	public var pointCount:Int = 0;

	public var normalMass:B2Mat22;

	public var normal:B2Vec2;

	public var manifold:B2Manifold;

	public var localPoint:B2Vec2;

	public var localPlaneNormal:B2Vec2;

	public var friction:Float = Math.NaN;

	public var bodyB:B2Body;

	public var bodyA:B2Body;

	public var K:B2Mat22;

	public function new() {
		var _loc3_ = 0;
		pointCount = 0;
		restitution = 0;
		friction = 0;
		radius = 0;
		localPlaneNormal = new B2Vec2();
		localPoint = new B2Vec2();
		normal = new B2Vec2();
		normalMass = new B2Mat22();
		K = new B2Mat22();
		points = [];
		var _loc1_ = 0;
		var _loc2_ = B2Settings.b2_maxManifoldPoints;
		while (_loc1_ < _loc2_) {
			_loc3_ = _loc1_++;
			points[_loc3_] = new B2ContactConstraintPoint();
		}
	}
}
