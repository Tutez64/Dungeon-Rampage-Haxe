package box2D.collision;

/*use*/ /*namespace*/ /*b2internal*/ class Features {
	/*b2internal*/
	public var _referenceEdge:Int = 0;

	/*b2internal*/
	public var _incidentEdge:Int = 0;

	/*b2internal*/
	public var _incidentVertex:Int = 0;

	/*b2internal*/
	public var _flip:Int = 0;

	/*b2internal*/
	public var _m_id:B2ContactID;

	public function new() {}

	@:isVar public var referenceEdge(get, set):Int;

	public function get_referenceEdge():Int {
		return this._referenceEdge;
	}

	function set_referenceEdge(value:Int):Int {
		this._referenceEdge = value;
		this._m_id._key = ((this._m_id._key : Int) & Std.int(0xFFFFFF00) | this._referenceEdge & 0xFF : UInt);
		return value;
	}

	@:isVar public var incidentEdge(get, set):Int;

	public function get_incidentEdge():Int {
		return this._incidentEdge;
	}

	function set_incidentEdge(value:Int):Int {
		this._incidentEdge = value;
		this._m_id._key = ((this._m_id._key : Int) & Std.int(0xFFFF00FF) | this._incidentEdge << 8 & 0xFF00 : UInt);
		return value;
	}

	@:isVar public var incidentVertex(get, set):Int;

	public function get_incidentVertex():Int {
		return this._incidentVertex;
	}

	function set_incidentVertex(value:Int):Int {
		this._incidentVertex = value;
		this._m_id._key = ((this._m_id._key : Int) & Std.int(0xFF00FFFF) | this._incidentVertex << 16 & 0xFF0000 : UInt);
		return value;
	}

	@:isVar public var flip(get, set):Int;

	public function get_flip():Int {
		return this._flip;
	}

	function set_flip(value:Int):Int {
		this._flip = value;
		this._m_id._key = ((this._m_id._key : Int) & 0xFFFFFF | this._flip << 24 & Std.int(0xFF000000) : UInt);
		return value;
	}
}
