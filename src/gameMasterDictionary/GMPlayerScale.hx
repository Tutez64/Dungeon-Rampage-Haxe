package gameMasterDictionary;

class GMPlayerScale {
	public static var HPBoostByPlayers:GMMap = new GMMap();

	public var Players:UInt = 0;

	public var HPBoost:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		Players = (ASCompat.toInt(jsonAsset.Players) : UInt);
		HPBoost = ASCompat.toNumber(jsonAsset.HP_BOOST);
		GMPlayerScale.HPBoostByPlayers.add(Players, HPBoost);
	}
}
