package gameMasterDictionary;

import flash.Boot;

class GMHints {
	public var Type:String;

	public var MinLevel:UInt = 0;

	public var MaxLevel:UInt = 0;

	public var HintText:String;

	public var Constant:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		Constant = jsonAsset.Constant;
		MinLevel = (ASCompat.toInt(jsonAsset.MinLevel) : UInt);
		MaxLevel = (ASCompat.toInt(jsonAsset.MaxLevel) : UInt);
		Type = jsonAsset.Type;
		HintText = jsonAsset.HintText;
	}
}
