package box2D.collision;

import flash.Boot;

class B2ContactID {
	public var features:Features;

	public var _key:Int = 0;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		_key = 0;
		features = new Features();
		features._m_id = this;
	}

	public function set_key(value:Int):Int {
		_key = value;
		features._referenceEdge = _key & 0xFF;
		features._incidentEdge = (_key & 0xFF00) >> 8 & 0xFF;
		features._incidentVertex = (_key & 0xFF0000) >> 16 & 0xFF;
		features._flip = (_key & -16777216) >> 24 & 0xFF;
		return _key;
	}

	public function set(id:B2ContactID) {
		Set(id);
	}

	public function get_key():Int {
		return _key;
	}

	public function copy():B2ContactID {
		return Copy();
	}

	public function Set(id:B2ContactID) {
		set_key(id._key);
	}

	public function Copy():B2ContactID {
		var _loc1_ = new B2ContactID();
		_loc1_.set_key(get_key());
		return _loc1_;
	}
}
