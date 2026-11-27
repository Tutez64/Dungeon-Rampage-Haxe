package box2D.common.math;

class B2Transform {
	public var position:B2Vec2;

	public var R:B2Mat22;

	public function new(pos:B2Vec2 = /*undefined*/ null, r:B2Mat22 = /*undefined*/ null) {
		position = new B2Vec2();
		R = new B2Mat22();
		if (pos != null) {
			position.setV(pos);
			R.setM(r);
		}
	}

	public function setIdentity() {
		SetIdentity();
	}

	public function set(x:B2Transform) {
		Set(x);
	}

	public function initialize(pos:B2Vec2, r:B2Mat22) {
		Initialize(pos, r);
	}

	public function getAngle():Float {
		return GetAngle();
	}

	public function SetIdentity() {
		position.setZero();
		R.setIdentity();
	}

	public function Set(x:B2Transform) {
		position.setV(x.position);
		R.setM(x.R);
	}

	public function Initialize(pos:B2Vec2, r:B2Mat22) {
		position.setV(pos);
		R.setM(r);
	}

	public function GetAngle():Float {
		return Math.atan2(R.col1.y, R.col1.x);
	}
}
