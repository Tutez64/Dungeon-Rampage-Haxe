package box2D.common.math;

class B2Vec3 {
	public var z:Float = Math.NaN;

	public var y:Float = Math.NaN;

	public var x:Float = Math.NaN;

	public function new(x:Float = 0, y:Float = 0, z:Float = 0) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function subtract(v:B2Vec3) {
		Subtract(v);
	}

	public function setZero() {
		SetZero();
	}

	public function setV(v:B2Vec3) {
		SetV(v);
	}

	public function set(x:Float, y:Float, z:Float) {
		Set(x, y, z);
	}

	public function negativeSelf() {
		NegativeSelf();
	}

	public function multiply(a:Float) {
		Multiply(a);
	}

	public function getNegative():B2Vec3 {
		return GetNegative();
	}

	public function copy():B2Vec3 {
		return Copy();
	}

	public function add(v:B2Vec3) {
		Add(v);
	}

	public function Subtract(v:B2Vec3) {
		x -= v.x;
		y -= v.y;
		z -= v.z;
	}

	public function SetZero() {
		x = y = z = 0;
	}

	public function SetV(v:B2Vec3) {
		x = v.x;
		y = v.y;
		z = v.z;
	}

	public function Set(x:Float, y:Float, z:Float) {
		this.x = x;
		this.y = y;
		this.z = z;
	}

	public function NegativeSelf() {
		x = -x;
		y = -y;
		z = -z;
	}

	public function Multiply(a:Float) {
		x *= a;
		y *= a;
		z *= a;
	}

	public function GetNegative():B2Vec3 {
		return new B2Vec3(-x, -y, -z);
	}

	public function Copy():B2Vec3 {
		return new B2Vec3(x, y, z);
	}

	public function Add(v:B2Vec3) {
		x += v.x;
		y += v.y;
		z += v.z;
	}
}
