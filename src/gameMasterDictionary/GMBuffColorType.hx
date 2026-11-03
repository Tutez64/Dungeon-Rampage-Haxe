package gameMasterDictionary;

import flash.Boot;

class GMBuffColorType {
	public var Id:UInt = 0;

	public var ColorHex:UInt = 0;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		ColorHex = (ASCompat.toInt(jsonAsset.TextColor) : UInt);
	}
}
