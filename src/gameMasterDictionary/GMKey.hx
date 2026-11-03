package gameMasterDictionary;

import flash.Boot;

class GMKey {
	public var OfferId:UInt = 0;

	public var ChestId:UInt = 0;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		OfferId = (ASCompat.toInt(jsonAsset.OfferId) : UInt);
		ChestId = (ASCompat.toInt(jsonAsset.ChestId) : UInt);
	}
}
