package gameMasterDictionary;

class GMStat extends GMItem {
	public var StatType:String;

	public var MaxCap:Float = Math.NaN;

	public var IconName:String;

	public var Description:String;

	public var Bonus:Float = Math.NaN;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		StatType = jsonAsset.StatType;
		Bonus = ASCompat.toNumber(jsonAsset.Bonus);
		MaxCap = ASCompat.toNumber(jsonAsset.MaxCap);
		IconName = jsonAsset.IconName;
		Description = jsonAsset.Description;
	}
}
