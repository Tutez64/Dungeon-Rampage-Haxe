package gameMasterDictionary;

class GMColiseumTier extends GMItem {
	public var MusicFilepath:String;

	public var BonusGold:Float = Math.NaN;

	public var BonusExp:Float = Math.NaN;

	public var MinLevel:UInt = 0;

	public var TotalFloors:UInt = 0;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		MusicFilepath = jsonAsset.MusicFilepath;
		BonusGold = ASCompat.toNumberField(jsonAsset, "Gold");
		BonusExp = ASCompat.toNumberField(jsonAsset, "Exp");
		MinLevel = (ASCompat.toInt(jsonAsset.MinLevel) : UInt);
		TotalFloors = (ASCompat.toInt(jsonAsset.MinFloors) : UInt);
	}
}
