package box2D.common.math;

class B2Mat33 {
	public var col1:B2Vec3 = new B2Vec3();

	public var col2:B2Vec3 = new B2Vec3();

	public var col3:B2Vec3 = new B2Vec3();

	public function new(c1:B2Vec3 = null, c2:B2Vec3 = null, c3:B2Vec3 = null) {
		if (c1 == null && c2 == null && c3 == null) {
			this.col1.SetZero();
			this.col2.SetZero();
			this.col3.SetZero();
		} else {
			this.col1.SetV(c1);
			this.col2.SetV(c2);
			this.col3.SetV(c3);
		}
	}

	public function SetVVV(c1:B2Vec3, c2:B2Vec3, c3:B2Vec3) {
		this.col1.SetV(c1);
		this.col2.SetV(c2);
		this.col3.SetV(c3);
	}

	public function Copy():B2Mat33 {
		return new B2Mat33(this.col1, this.col2, this.col3);
	}

	public function SetM(m:B2Mat33) {
		this.col1.SetV(m.col1);
		this.col2.SetV(m.col2);
		this.col3.SetV(m.col3);
	}

	public function AddM(m:B2Mat33) {
		this.col1.x += m.col1.x;
		this.col1.y += m.col1.y;
		this.col1.z += m.col1.z;
		this.col2.x += m.col2.x;
		this.col2.y += m.col2.y;
		this.col2.z += m.col2.z;
		this.col3.x += m.col3.x;
		this.col3.y += m.col3.y;
		this.col3.z += m.col3.z;
	}

	public function SetIdentity() {
		this.col1.x = 1;
		this.col2.x = 0;
		this.col3.x = 0;
		this.col1.y = 0;
		this.col2.y = 1;
		this.col3.y = 0;
		this.col1.z = 0;
		this.col2.z = 0;
		this.col3.z = 1;
	}

	public function SetZero() {
		this.col1.x = 0;
		this.col2.x = 0;
		this.col3.x = 0;
		this.col1.y = 0;
		this.col2.y = 0;
		this.col3.y = 0;
		this.col1.z = 0;
		this.col2.z = 0;
		this.col3.z = 0;
	}

	public function Solve22(out:B2Vec2, bX:Float, bY:Float):B2Vec2 {
		var _loc4_ = Math.NaN;
		var _loc6_ = Math.NaN;
		_loc4_ = this.col1.x;
		var _loc5_ = this.col2.x;
		_loc6_ = this.col1.y;
		var _loc7_ = this.col2.y;
		var _loc8_ = _loc4_ * _loc7_ - _loc5_ * _loc6_;
		if (_loc8_ != 0) {
			_loc8_ = 1 / _loc8_;
		}
		out.x = _loc8_ * (_loc7_ * bX - _loc5_ * bY);
		out.y = _loc8_ * (_loc4_ * bY - _loc6_ * bX);
		return out;
	}

	public function Solve33(out:B2Vec3, bX:Float, bY:Float, bZ:Float):B2Vec3 {
		var _loc5_ = this.col1.x;
		var _loc6_ = this.col1.y;
		var _loc7_ = this.col1.z;
		var _loc8_ = this.col2.x;
		var _loc9_ = this.col2.y;
		var _loc10_ = this.col2.z;
		var _loc11_ = this.col3.x;
		var _loc12_ = this.col3.y;
		var _loc13_ = this.col3.z;
		var _loc14_ = _loc5_ * (_loc9_ * _loc13_ - _loc10_ * _loc12_) + _loc6_ * (_loc10_ * _loc11_ - _loc8_ * _loc13_)
			+ _loc7_ * (_loc8_ * _loc12_ - _loc9_ * _loc11_);
		if (_loc14_ != 0) {
			_loc14_ = 1 / _loc14_;
		}
		out.x = _loc14_ * (bX * (_loc9_ * _loc13_ - _loc10_ * _loc12_) + bY * (_loc10_ * _loc11_ - _loc8_ * _loc13_)
			+ bZ * (_loc8_ * _loc12_ - _loc9_ * _loc11_));
		out.y = _loc14_ * (_loc5_ * (bY * _loc13_ - bZ * _loc12_) + _loc6_ * (bZ * _loc11_ - bX * _loc13_) + _loc7_ * (bX * _loc12_ - bY * _loc11_));
		out.z = _loc14_ * (_loc5_ * (_loc9_ * bZ - _loc10_ * bY) + _loc6_ * (_loc10_ * bX - _loc8_ * bZ) + _loc7_ * (_loc8_ * bY - _loc9_ * bX));
		return out;
	}
}
