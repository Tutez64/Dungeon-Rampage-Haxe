package box2D.common.math;

class B2Transform {
	public var position:B2Vec2 = new B2Vec2();

	public var R:B2Mat22 = new B2Mat22();

	public function new(pos:B2Vec2 = null, r:B2Mat22 = null) {
		if (pos != null) {
			this.position.SetV(pos);
			this.R.SetM(r);
		}
	}

	public function Initialize(pos:B2Vec2, r:B2Mat22) {
		this.position.SetV(pos);
		this.R.SetM(r);
	}

	public function SetIdentity() {
		this.position.SetZero();
		this.R.SetIdentity();
	}

	public function Set(x:B2Transform) {
		this.position.SetV(x.position);
		this.R.SetM(x.R);
	}

	public function GetAngle():Float {
		return Math.atan2(this.R.col1.y, this.R.col1.x);
	}
}
