package box2D.collision;

import box2D.common.math.B2Math;
import box2D.common.math.B2Vec2;
import box2D.common.B2Settings;

class B2Distance {
	public static var b2_gjkCalls:Int = 0;

	public static var b2_gjkIters:Int = 0;

	public static var b2_gjkMaxIters:Int = 0;

	public static var s_simplex:B2Simplex = new B2Simplex();

	public static var s_saveA:Array<ASAny>;

	public static var s_saveB:Array<ASAny>;

	public function new() {}

	public static function distance(output:B2DistanceOutput, cache:B2SimplexCache, input:B2DistanceInput) {
		var _loc18_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc20_ = 0;
		var _loc21_ = 0;
		var _loc22_ = 0;
		var _loc23_ = false;
		var _loc24_ = ASCompat.dynamicAs(null, B2Vec2);
		var _loc25_:ASAny = ASCompat.dynamicAs(null, B2SimplexVertex);
		var _loc26_ = false;
		var _loc27_ = Math.NaN;
		var _loc28_ = Math.NaN;
		var _loc29_ = Math.NaN;
		++B2Distance.b2_gjkCalls;
		var _loc4_ = input.proxyA;
		var _loc5_ = input.proxyB;
		var _loc6_ = input.transformA;
		var _loc7_ = input.transformB;
		var _loc8_ = B2Distance.s_simplex;
		_loc8_.readCache(cache, _loc4_, _loc6_, _loc5_, _loc7_);
		var _loc9_ = _loc8_.m_vertices;
		var _loc10_ = 20;
		var _loc11_ = B2Distance.s_saveA;
		var _loc12_ = B2Distance.s_saveB;
		var _loc13_ = 0;
		var _loc14_ = _loc8_.getClosestPoint();
		var _loc15_:Float;
		var _loc16_ = _loc15_ = _loc14_.lengthSquared();
		var _loc19_ = 0;
		while (_loc19_ < _loc10_) {
			_loc13_ = _loc8_.m_count;
			_loc20_ = 0;
			_loc21_ = _loc13_;
			while (_loc20_ < _loc21_) {
				_loc22_ = _loc20_++;
				_loc11_[_loc22_] = _loc9_[_loc22_].indexA;
				_loc12_[_loc22_] = _loc9_[_loc22_].indexB;
			}
			switch (_loc8_.m_count) {
				case 1:

				case 2:
					_loc8_.solve2();

				case 3:
					_loc8_.solve3();

				default:
					B2Settings.b2Assert(false);
			}
			if (_loc8_.m_count == 3) {
				break;
			}
			_loc18_ = _loc8_.getClosestPoint();
			_loc16_ = ASCompat.toNumber(_loc18_.lengthSquared());
			_loc23_ = _loc16_ > _loc15_;
			_loc15_ = _loc16_;
			_loc24_ = _loc8_.getSearchDirection();
			if (ASCompat.toNumber(_loc24_.lengthSquared()) < ASCompat.MIN_FLOAT * ASCompat.MIN_FLOAT) {
				break;
			}
			_loc25_ = _loc9_[_loc8_.m_count];
			ASCompat.setProperty(_loc25_, "indexA",
				ASCompat.floatToInt(_loc4_.getSupport(B2Math.mulTMV(_loc6_.R, ASCompat.coerce(_loc24_.getNegative(), box2D.common.math.B2Vec2)))));
			ASCompat.setProperty(_loc25_, "wA", B2Math.mulX(_loc6_, _loc4_.getVertex(ASCompat.toInt(_loc25_.indexA))));
			ASCompat.setProperty(_loc25_, "indexB", ASCompat.floatToInt(_loc5_.getSupport(B2Math.mulTMV(_loc7_.R, _loc24_))));
			ASCompat.setProperty(_loc25_, "wB", B2Math.mulX(_loc7_, _loc5_.getVertex(ASCompat.toInt(_loc25_.indexB))));
			ASCompat.setProperty(_loc25_, "w",
				B2Math.subtractVV(ASCompat.coerce(_loc25_.wB, box2D.common.math.B2Vec2), ASCompat.coerce(_loc25_.wA, box2D.common.math.B2Vec2)));
			_loc19_++;
			++B2Distance.b2_gjkIters;
			_loc26_ = false;
			_loc20_ = 0;
			_loc21_ = _loc13_;
			while (_loc20_ < _loc21_) {
				_loc22_ = _loc20_++;
				if (ASCompat.toNumberField(_loc25_, "indexA") == ASCompat.toInt(_loc11_[_loc22_])
					&& ASCompat.toNumberField(_loc25_, "indexB") == ASCompat.toInt(_loc12_[_loc22_])) {
					_loc26_ = true;
					break;
				}
			}
			if (_loc26_) {
				break;
			}
			++_loc8_.m_count;
		}
		B2Distance.b2_gjkMaxIters = ASCompat.floatToInt(B2Math.max(B2Distance.b2_gjkMaxIters, _loc19_));
		_loc8_.getWitnessPoints(output.pointA, output.pointB);
		output.distance = B2Math.subtractVV(output.pointA, output.pointB).length();
		output.iterations = _loc19_;
		_loc8_.writeCache(cache);
		if (input.useRadii) {
			_loc27_ = _loc4_.m_radius;
			_loc28_ = _loc5_.m_radius;
			if (output.distance > _loc27_ + _loc28_ && output.distance > ASCompat.MIN_FLOAT) {
				output.distance -= _loc27_ + _loc28_;
				_loc24_ = B2Math.subtractVV(output.pointB, output.pointA);
				_loc24_.normalize();
				output.pointA.x += _loc27_ * ASCompat.toNumberField(_loc24_, "x");
				output.pointA.y += _loc27_ * ASCompat.toNumberField(_loc24_, "y");
				output.pointB.x -= _loc28_ * ASCompat.toNumberField(_loc24_, "x");
				output.pointB.y -= _loc28_ * ASCompat.toNumberField(_loc24_, "y");
			} else {
				_loc18_ = new B2Vec2();
				ASCompat.setProperty(_loc18_, "x", 0.5 * (output.pointA.x + output.pointB.x));
				ASCompat.setProperty(_loc18_, "y", 0.5 * (output.pointA.y + output.pointB.y));
				output.pointA.x = output.pointB.x = ASCompat.toNumberField(_loc18_, "x");
				output.pointA.y = output.pointB.y = ASCompat.toNumberField(_loc18_, "y");
				output.distance = 0;
			}
		}
	}

	public static function Distance(output:B2DistanceOutput, cache:B2SimplexCache, input:B2DistanceInput) {
		B2Distance.distance(output, cache, input);
	}

	static function __init__() {
		s_saveA = [];
		s_saveB = [];
	}
}
