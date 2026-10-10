package box2D.common.math;

class B2Vec3 {
	public var x:Float = Math.NaN;

	public var y:Float = Math.NaN;

	public var z:Float = Math.NaN;

	public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function SetZero() {
		this.x = this.y = this.z = 0;
	}

	public function Set(x:Float, y:Float, z:Float) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function SetV(v:B2Vec3) {
		this.x = v.x;
		this.y = v.y;
		this.z = v.z;
	}

	public function GetNegative():B2Vec3 {
		return new B2Vec3(-this.x, -this.y, -this.z);
	}

	public function NegativeSelf() {
		this.x = -this.x;
		this.y = -this.y;
		this.z = -this.z;
	}

	public function Copy():B2Vec3 {
		return new B2Vec3(this.x, this.y, this.z);
	}

	public function Add(v:B2Vec3) {
		this.x += v.x;
		this.y += v.y;
		this.z += v.z;
	}

	public function Subtract(v:B2Vec3) {
		this.x -= v.x;
		this.y -= v.y;
		this.z -= v.z;
	}

	public function Multiply(a:Float) {
		this.x *= a;
		this.y *= a;
		this.z *= a;
	}
}
