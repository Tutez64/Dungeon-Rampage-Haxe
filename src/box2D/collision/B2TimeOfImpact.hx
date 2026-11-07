package box2D.collision;

import box2D.common.math.B2Math;
import box2D.common.math.B2Transform;
import box2D.common.B2Settings;

class B2TimeOfImpact {
	public static var b2_toiCalls:Int = 0;

	public static var b2_toiIters:Int = 0;

	public static var b2_toiMaxIters:Int = 0;

	public static var b2_toiRootIters:Int = 0;

	public static var b2_toiMaxRootIters:Int = 0;

	public static var s_cache:B2SimplexCache = new B2SimplexCache();

	public static var s_distanceInput:B2DistanceInput = new B2DistanceInput();

	public static var s_xfA:B2Transform = new B2Transform();

	public static var s_xfB:B2Transform = new B2Transform();

	public static var s_fcn:B2SeparationFunction = new B2SeparationFunction();

	public static var s_distanceOutput:B2DistanceOutput = new B2DistanceOutput();

	public function new() {}

	public static function timeOfImpact(input:B2TOIInput):Float {
		var _loc12_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc18_ = 0;
		var _loc19_ = Math.NaN;
		var _loc20_ = Math.NaN;
		++B2TimeOfImpact.b2_toiCalls;
		var _loc2_ = input.proxyA;
		var _loc3_ = input.proxyB;
		var _loc4_ = input.sweepA;
		var _loc5_ = input.sweepB;
		B2Settings.b2Assert(_loc4_.t0 == _loc5_.t0);
		B2Settings.b2Assert(1 - _loc4_.t0 > ASCompat.MIN_FLOAT);
		var _loc6_ = _loc2_.m_radius + _loc3_.m_radius;
		var _loc7_ = input.tolerance;
		var _loc8_:Float = 0;
		var _loc9_ = 1000;
		var _loc10_ = 0;
		var _loc11_:Float = 0;
		B2TimeOfImpact.s_cache.count = 0;
		B2TimeOfImpact.s_distanceInput.useRadii = false;
		do {
			_loc4_.getTransform(B2TimeOfImpact.s_xfA, _loc8_);
			_loc5_.getTransform(B2TimeOfImpact.s_xfB, _loc8_);
			B2TimeOfImpact.s_distanceInput.proxyA = _loc2_;
			B2TimeOfImpact.s_distanceInput.proxyB = _loc3_;
			B2TimeOfImpact.s_distanceInput.transformA = B2TimeOfImpact.s_xfA;
			B2TimeOfImpact.s_distanceInput.transformB = B2TimeOfImpact.s_xfB;
			B2Distance.distance(B2TimeOfImpact.s_distanceOutput, B2TimeOfImpact.s_cache, B2TimeOfImpact.s_distanceInput);
			if (B2TimeOfImpact.s_distanceOutput.distance <= 0) {
				_loc8_ = 1;
				break;
			}
			B2TimeOfImpact.s_fcn.initialize(B2TimeOfImpact.s_cache, _loc2_, B2TimeOfImpact.s_xfA, _loc3_, B2TimeOfImpact.s_xfB);
			_loc12_ = B2TimeOfImpact.s_fcn.evaluate(B2TimeOfImpact.s_xfA, B2TimeOfImpact.s_xfB);
			if (_loc12_ <= 0) {
				_loc8_ = 1;
				break;
			}
			if (_loc10_ == 0) {
				if (_loc12_ > _loc6_) {
					_loc11_ = B2Math.max(_loc6_ - _loc7_, 0.75 * _loc6_);
				} else {
					_loc11_ = B2Math.max(_loc12_ - _loc7_, 0.02 * _loc6_);
				}
			}
			if (_loc12_ - _loc11_ < 0.5 * _loc7_) {
				if (_loc10_ == 0) {
					_loc8_ = 1;
				}
				break;
			}
			_loc13_ = _loc8_;
			_loc14_ = _loc8_;
			_loc15_ = 1;
			_loc16_ = _loc12_;
			_loc4_.getTransform(B2TimeOfImpact.s_xfA, _loc15_);
			_loc5_.getTransform(B2TimeOfImpact.s_xfB, _loc15_);
			_loc17_ = B2TimeOfImpact.s_fcn.evaluate(B2TimeOfImpact.s_xfA, B2TimeOfImpact.s_xfB);
			if (_loc17_ >= _loc11_) {
				_loc8_ = 1;
				break;
			}
			_loc18_ = 0;
			do {
				if ((_loc18_ & 1) != 0) {
					_loc19_ = _loc14_ + (_loc11_ - _loc16_) * (_loc15_ - _loc14_) / (_loc17_ - _loc16_);
				} else {
					_loc19_ = 0.5 * (_loc14_ + _loc15_);
				}
				_loc4_.getTransform(B2TimeOfImpact.s_xfA, _loc19_);
				_loc5_.getTransform(B2TimeOfImpact.s_xfB, _loc19_);
				_loc20_ = B2TimeOfImpact.s_fcn.evaluate(B2TimeOfImpact.s_xfA, B2TimeOfImpact.s_xfB);
				if (B2Math.abs(_loc20_ - _loc11_) < 0.025 * _loc7_) {
					_loc13_ = _loc19_;
					break;
				}
				if (_loc20_ > _loc11_) {
					_loc14_ = _loc19_;
					_loc16_ = _loc20_;
				} else {
					_loc15_ = _loc19_;
					_loc17_ = _loc20_;
				}
				_loc18_++;
				++B2TimeOfImpact.b2_toiRootIters;
			} while (_loc18_ != 50);
			B2TimeOfImpact.b2_toiMaxRootIters = ASCompat.floatToInt(B2Math.max(B2TimeOfImpact.b2_toiMaxRootIters, _loc18_));
			if (_loc13_ < (1 + 100 * ASCompat.MIN_FLOAT) * _loc8_) {
				break;
			}
			_loc8_ = _loc13_;
			_loc10_++;
			++B2TimeOfImpact.b2_toiIters;
		} while (_loc10_ != _loc9_);
		B2TimeOfImpact.b2_toiMaxIters = ASCompat.floatToInt(B2Math.max(B2TimeOfImpact.b2_toiMaxIters, _loc10_));
		return _loc8_;
	}

	public static function TimeOfImpact(input:B2TOIInput):Float {
		return B2TimeOfImpact.timeOfImpact(input);
	}
}
