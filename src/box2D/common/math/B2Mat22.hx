package box2D.common.math;

import flash.Boot;

class B2Mat22 {
	public var col2:B2Vec2;

	public var col1:B2Vec2;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		col1 = new B2Vec2(1, 0);
		col2 = new B2Vec2(0, 1);
	}

	public static function fromAngle(angle:Float):B2Mat22 {
		var _loc2_ = new B2Mat22();
		_loc2_.set(angle);
		return _loc2_;
	}

	public static function fromVV(c1:B2Vec2, c2:B2Vec2):B2Mat22 {
		var _loc3_ = new B2Mat22();
		_loc3_.setVV(c1, c2);
		return _loc3_;
	}

	public static function FromAngle(angle:Float):B2Mat22 {
		return B2Mat22.fromAngle(angle);
	}

	public static function FromVV(c1:B2Vec2, c2:B2Vec2):B2Mat22 {
		return B2Mat22.fromVV(c1, c2);
	}

	public function solve(out:B2Vec2, bX:Float, bY:Float):B2Vec2 {
		return Solve(out, bX, bY);
	}

	public function setZero() {
		SetZero();
	}

	public function setVV(c1:B2Vec2, c2:B2Vec2) {
		SetVV(c1, c2);
	}

	public function setM(m:B2Mat22) {
		SetM(m);
	}

	public function setIdentity() {
		SetIdentity();
	}

	public function set(angle:Float) {
		Set(angle);
	}

	public function getInverse(out:B2Mat22):B2Mat22 {
		return GetInverse(out);
	}

	public function getAngle():Float {
		return GetAngle();
	}

	public function copy():B2Mat22 {
		return Copy();
	}

	public function addM(m:B2Mat22) {
		AddM(m);
	}

	public function abs() {
		Abs();
	}

	public function Solve(out:B2Vec2, bX:Float, bY:Float):B2Vec2 {
		var _loc4_ = col1.x;
		var _loc5_ = col2.x;
		var _loc6_ = col1.y;
		var _loc7_ = col2.y;
		var _loc8_ = _loc4_ * _loc7_ - _loc5_ * _loc6_;
		if (_loc8_ != 0) {
			_loc8_ = 1 / _loc8_;
		}
		out.x = _loc8_ * (_loc7_ * bX - _loc5_ * bY);
		out.y = _loc8_ * (_loc4_ * bY - _loc6_ * bX);
		return out;
	}

	public function SetZero() {
		col1.x = 0;
		col2.x = 0;
		col1.y = 0;
		col2.y = 0;
	}

	public function SetVV(c1:B2Vec2, c2:B2Vec2) {
		col1.setV(c1);
		col2.setV(c2);
	}

	public function SetM(m:B2Mat22) {
		col1.setV(m.col1);
		col2.setV(m.col2);
	}

	public function SetIdentity() {
		col1.x = 1;
		col2.x = 0;
		col1.y = 0;
		col2.y = 1;
	}

	public function Set(angle:Float) {
		var _loc2_ = Math.cos(angle);
		var _loc3_ = Math.sin(angle);
		col1.x = _loc2_;
		col2.x = -_loc3_;
		col1.y = _loc3_;
		col2.y = _loc2_;
	}

	public function GetInverse(out:B2Mat22):B2Mat22 {
		var _loc2_ = col1.x;
		var _loc3_ = col2.x;
		var _loc4_ = col1.y;
		var _loc5_ = col2.y;
		var _loc6_ = _loc2_ * _loc5_ - _loc3_ * _loc4_;
		if (_loc6_ != 0) {
			_loc6_ = 1 / _loc6_;
		}
		out.col1.x = _loc6_ * _loc5_;
		out.col2.x = -_loc6_ * _loc3_;
		out.col1.y = -_loc6_ * _loc4_;
		out.col2.y = _loc6_ * _loc2_;
		return out;
	}

	public function GetAngle():Float {
		return Math.atan2(col1.y, col1.x);
	}

	public function Copy():B2Mat22 {
		var _loc1_ = new B2Mat22();
		_loc1_.setM(this);
		return _loc1_;
	}

	public function AddM(m:B2Mat22) {
		col1.x += m.col1.x;
		col1.y += m.col1.y;
		col2.x += m.col2.x;
		col2.y += m.col2.y;
	}

	public function Abs() {
		col1.abs();
		col2.abs();
	}
}
