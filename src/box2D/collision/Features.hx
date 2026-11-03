package box2D.collision;

import flash.Boot;

class Features {
	public var _referenceEdge:Int = 0;

	public var _m_id:B2ContactID;

	public var _incidentVertex:Int = 0;

	public var _incidentEdge:Int = 0;

	public var _flip:Int = 0;

	public function new() {
		if (Boot.skip_constructor) {
			return;
		}
		_flip = 0;
		_incidentVertex = 0;
		_incidentEdge = 0;
		_referenceEdge = 0;
	}

	public function set_referenceEdge(value:Int):Int {
		_referenceEdge = value;
		_m_id._key = _m_id._key & -256 | (_referenceEdge & 0xFF);
		return value;
	}

	public function set_incidentVertex(value:Int):Int {
		_incidentVertex = value;
		_m_id._key = _m_id._key & -16711681 | (_incidentVertex << 16 & 0xFF0000);
		return value;
	}

	public function set_incidentEdge(value:Int):Int {
		_incidentEdge = value;
		_m_id._key = _m_id._key & -65281 | (_incidentEdge << 8 & 0xFF00);
		return value;
	}

	public function set_flip(value:Int):Int {
		_flip = value;
		_m_id._key = _m_id._key & 0xFFFFFF | (_flip << 24 & -16777216);
		return value;
	}

	public function get_referenceEdge():Int {
		return _referenceEdge;
	}

	public function get_incidentVertex():Int {
		return _incidentVertex;
	}

	public function get_incidentEdge():Int {
		return _incidentEdge;
	}

	public function get_flip():Int {
		return _flip;
	}
}
