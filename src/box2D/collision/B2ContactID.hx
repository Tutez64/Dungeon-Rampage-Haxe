package box2D.collision;

/*use*/ /*namespace*/ /*b2internal*/ class B2ContactID {
	public var features:Features = new Features();

	/*b2internal*/
	public var _key:UInt = 0;

	public function new() {
		this.features._m_id = this;
	}

	public function Set(id:B2ContactID) {
		this.key = id._key;
	}

	public function Copy():B2ContactID {
		var _loc1_ = new B2ContactID();
		_loc1_.key = this.key;
		return _loc1_;
	}

	@:isVar public var key(get, set):UInt;

	public function get_key():UInt {
		return this._key;
	}

	function set_key(value:UInt):UInt {
		this._key = value;
		this.features._referenceEdge = (this._key : Int) & 0xFF;
		this.features._incidentEdge = ((this._key : Int) & 0xFF00) >> 8 & 0xFF;
		this.features._incidentVertex = ((this._key : Int) & 0xFF0000) >> 16 & 0xFF;
		this.features._flip = ((this._key : Int) & Std.int(0xFF000000)) >> 24 & 0xFF;
		return value;
	}
}
