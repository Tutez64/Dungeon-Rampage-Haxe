package gameMasterDictionary;

class GMItem {
	public var mSecurityValue:Int = 0;

	public var mName:String;

	public var Id:UInt = 0;

	public var Constant:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		var _loc4_:ASAny = ASCompat.asString(null);
		var _loc5_:ASAny = null;
		var _loc6_ = 0;
		mSecurityValue = 0;
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Constant = jsonAsset.Constant;
		mName = jsonAsset.Name;
		var _loc2_ = 0;
		var _loc3_ = Reflect.fields(jsonAsset);
		while (_loc2_ < _loc3_.length) {
			_loc4_ = _loc3_[_loc2_];
			_loc2_++;
			_loc5_ = Reflect.field(jsonAsset, _loc4_);
			if (Std.isOfType(_loc5_, Int)) {
				_loc6_ = ASCompat.toInt(_loc5_);
				mSecurityValue += ASCompat.floatToInt(Math.abs(_loc6_) % 17 + Math.abs(_loc6_) / 19);
			}
		}
		mSecurityValue %= 541;
	}

	@:isVar public var SecurityValue(get, never):Int;

	public function get_SecurityValue():Int {
		return mSecurityValue;
	}

	@:isVar public var Name(get, never):String;

	public function get_Name():String {
		return mName;
	}
}
