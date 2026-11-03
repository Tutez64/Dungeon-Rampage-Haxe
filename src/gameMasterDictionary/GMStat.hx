package gameMasterDictionary;

import flash.Boot;

class GMStat extends GMItem {
	public var StatType:String;

	public var MaxCap:Float = Math.NaN;

	public var IconName:String;

	public var Description:String;

	public var Bonus:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			StatType = jsonAsset.StatType;
			Bonus = ASCompat.toNumber(jsonAsset.Bonus);
			MaxCap = ASCompat.toNumber(jsonAsset.MaxCap);
			IconName = jsonAsset.IconName;
			Description = jsonAsset.Description;
		}
	}
}
