package gameMasterDictionary;

class GMHints {
	public var Constant:String;

	public var MinLevel:UInt = 0;

	public var MaxLevel:UInt = 0;

	public var Type:String;

	public var HintText:String;

	public function new(jsonAsset:ASObject) {
		Constant = jsonAsset.Constant;
		MinLevel = (ASCompat.toInt(jsonAsset.MinLevel) : UInt);
		MaxLevel = (ASCompat.toInt(jsonAsset.MaxLevel) : UInt);
		Type = jsonAsset.Type;
		HintText = jsonAsset.HintText;
	}
}
