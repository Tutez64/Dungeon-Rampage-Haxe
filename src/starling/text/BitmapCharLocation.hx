package starling.text;

class BitmapCharLocation {
	static var sInstancePool:Vector<BitmapCharLocation> = new Vector((0 : UInt));

	static var sVectorPool:Array<ASAny>;

	static var sInstanceLoan:Vector<BitmapCharLocation> = new Vector((0 : UInt));

	static var sVectorLoan:Array<ASAny>;

	public var char:BitmapChar;

	public var scale:Float = Math.NaN;

	public var x:Float = Math.NaN;

	public var y:Float = Math.NaN;

	public var index:Int = 0;

	public function new(char:BitmapChar) {
		init(char);
	}

	public static function instanceFromPool(char:BitmapChar):BitmapCharLocation {
		var _loc2_ = sInstancePool.length > 0 ? sInstancePool.pop() : new BitmapCharLocation(char);
		_loc2_.init(char);
		sInstanceLoan[sInstanceLoan.length] = _loc2_;
		return _loc2_;
	}

	public static function vectorFromPool():Vector<BitmapCharLocation> {
		var _loc1_ = (sVectorPool.length > 0 ? (sVectorPool.pop() : Vector<BitmapCharLocation>) : new Vector<BitmapCharLocation>((0 : UInt)):Vector<BitmapCharLocation>);
		_loc1_.length = 0;
		sVectorLoan[sVectorLoan.length] = _loc1_;
		return _loc1_;
	}

	public static function rechargePool() {
		var _loc1_:BitmapCharLocation = null;
		var _loc2_:Vector<BitmapCharLocation> = /*undefined*/ null;
		while (sInstanceLoan.length > 0) {
			_loc1_ = sInstanceLoan.pop();
			_loc1_.char = null;
			sInstancePool[sInstancePool.length] = _loc1_;
		}
		while (sVectorLoan.length > 0) {
			_loc2_ = (sVectorLoan.pop() : Vector<BitmapCharLocation>);
			_loc2_.length = 0;
			sVectorPool[sVectorPool.length] = _loc2_;
		}
	}

	function init(char:BitmapChar):BitmapCharLocation {
		this.char = char;
		return this;
	}

	static function __init__() {
		sVectorPool = [];
		sVectorLoan = [];
	}
}
