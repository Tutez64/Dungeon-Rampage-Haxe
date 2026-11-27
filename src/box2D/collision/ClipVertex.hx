package box2D.collision;

import box2D.common.math.B2Vec2;

class ClipVertex {
	public var v:B2Vec2;

	public var id:B2ContactID;

	public function new() {
		v = new B2Vec2();
		id = new B2ContactID();
	}

	public function set(other:ClipVertex) {
		Set(other);
	}

	public function Set(other:ClipVertex) {
		v.setV(other.v);
		id.set(other.id);
	}
}
