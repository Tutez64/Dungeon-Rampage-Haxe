package gameMasterDictionary;

class GMBuffColorType {
	public var Id:UInt = 0;

	public var ColorHex:UInt = 0;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		ColorHex = (ASCompat.toInt(jsonAsset.TextColor) : UInt);
	}
}
