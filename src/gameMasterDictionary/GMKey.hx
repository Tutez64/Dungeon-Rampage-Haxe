package gameMasterDictionary;

class GMKey {
	public var OfferId:UInt = 0;

	public var ChestId:UInt = 0;

	public function new(jsonAsset:ASObject) {
		OfferId = (ASCompat.toInt(jsonAsset.OfferId) : UInt);
		ChestId = (ASCompat.toInt(jsonAsset.ChestId) : UInt);
	}
}
