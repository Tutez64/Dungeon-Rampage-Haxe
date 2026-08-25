package gameMasterDictionary;

class GMItem {
	public var Id:UInt = 0;

	public var Constant:String;

	var mName:String;

	var mSecurityValue:Int = 0;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		Constant = jsonAsset.Constant;
		mName = jsonAsset.Name;
		var _loc2_:ASObject;
		if (checkNullIteratee(jsonAsset))
			for (_tmp_ in iterateDynamicValues(jsonAsset)) {
				_loc2_ = _tmp_;
				if (ASCompat.getQualifiedClassName(_loc2_) == "int") {
					mSecurityValue += Std.int(Math.abs(ASCompat.toInt(_loc2_)) % 17 + Math.abs(ASCompat.toInt(_loc2_)) / 19);
				}
			}
		mSecurityValue %= 541;
	}

	@:isVar public var Name(get, never):String;

	public function get_Name():String {
		return mName;
	}

	@:isVar public var SecurityValue(get, never):Int;

	public function get_SecurityValue():Int {
		return mSecurityValue;
	}
}
