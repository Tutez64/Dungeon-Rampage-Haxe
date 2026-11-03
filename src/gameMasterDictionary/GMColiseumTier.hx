package gameMasterDictionary;

import flash.Boot;

class GMColiseumTier extends GMItem {
	public var TotalFloors:Int = 0;

	public var MusicFilepath:String;

	public var MinLevel:Int = 0;

	public var BonusGold:Float = Math.NaN;

	public var BonusExp:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			MusicFilepath = jsonAsset.MusicFilepath;
			BonusGold = ASCompat.toNumber(jsonAsset.Gold);
			BonusExp = ASCompat.toNumber(jsonAsset.Exp);
			MinLevel = ASCompat.toInt(jsonAsset.MinLevel);
			TotalFloors = ASCompat.toInt(jsonAsset.MinFloors);
		}
	}
}
