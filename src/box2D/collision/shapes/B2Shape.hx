package box2D.collision.shapes;

import box2D.collision.B2AABB;
import box2D.collision.B2Distance;
import box2D.collision.B2DistanceInput;
import box2D.collision.B2DistanceOutput;
import box2D.collision.B2DistanceProxy;
import box2D.collision.B2RayCastInput;
import box2D.collision.B2RayCastOutput;
import box2D.collision.B2SimplexCache;
import box2D.common.math.B2Transform;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;

class B2Shape {
	public static var e_hitCollide:Int = 1;

	public static var e_missCollide:Int = 0;

	public static var e_startsInsideCollide:Int = -1;

	public var m_type:Int = 0;

	public var m_radius:Float = Math.NaN;

	public function new() {
		m_type = 0;
		m_radius = B2Settings.b2_linearSlop;
	}

	public static function testOverlap(shape1:B2Shape, transform1:B2Transform, shape2:B2Shape, transform2:B2Transform):Bool {
		var _loc5_ = new B2DistanceInput();
		_loc5_.proxyA = new B2DistanceProxy();
		_loc5_.proxyA.set(shape1);
		_loc5_.proxyB = new B2DistanceProxy();
		_loc5_.proxyB.set(shape2);
		_loc5_.transformA = transform1;
		_loc5_.transformB = transform2;
		_loc5_.useRadii = true;
		var _loc6_ = new B2SimplexCache();
		_loc6_.count = 0;
		var _loc7_ = new B2DistanceOutput();
		B2Distance.distance(_loc7_, _loc6_, _loc5_);
		return _loc7_.distance < 10 * ASCompat.MIN_FLOAT;
	}

	public static function TestOverlap(shape1:B2Shape, transform1:B2Transform, shape2:B2Shape, transform2:B2Transform):Bool {
		return B2Shape.testOverlap(shape1, transform1, shape2, transform2);
	}

	public function testPoint(xf:B2Transform, p:B2Vec2):Bool {
		return TestPoint(xf, p);
	}

	public function set(other:B2Shape) {
		Set(other);
	}

	public function rayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		return RayCast(output, input, transform);
	}

	public function getType():Int {
		return GetType();
	}

	public function copy():B2Shape {
		return Copy();
	}

	public function computeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		return ComputeSubmergedArea(normal, offset, xf, c);
	}

	public function computeMass(massData:B2MassData, density:Float) {
		ComputeMass(massData, density);
	}

	public function computeAABB(aabb:B2AABB, xf:B2Transform) {
		ComputeAABB(aabb, xf);
	}

	public function TestPoint(xf:B2Transform, p:B2Vec2):Bool {
		return false;
	}

	public function Set(other:B2Shape) {
		m_radius = other.m_radius;
	}

	public function RayCast(output:B2RayCastOutput, input:B2RayCastInput, transform:B2Transform):Bool {
		return false;
	}

	public function GetType():Int {
		return m_type;
	}

	public function Copy():B2Shape {
		return null;
	}

	public function ComputeSubmergedArea(normal:B2Vec2, offset:Float, xf:B2Transform, c:B2Vec2):Float {
		return 0;
	}

	public function ComputeMass(massData:B2MassData, density:Float) {}

	public function ComputeAABB(aabb:B2AABB, xf:B2Transform) {}
}
