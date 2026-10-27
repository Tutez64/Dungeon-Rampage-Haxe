package gameMasterDictionary;

import org.as3commons.collections.Map;

class GMPlayerScale {
	public static var HPBoostByPlayers:Map = new Map();

	public var Players:UInt = 0;

	public var HPBoost:Float = Math.NaN;

	public function new(jsonAsset:ASObject) {
		Players = (ASCompat.toInt(jsonAsset.Players) : UInt);
		HPBoost = ASCompat.toNumberField(jsonAsset, "HP_BOOST");
		HPBoostByPlayers.add(Players, HPBoost);
	}
}
