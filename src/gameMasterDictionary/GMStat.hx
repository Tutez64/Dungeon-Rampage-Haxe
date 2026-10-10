package gameMasterDictionary;

class GMStat extends GMItem {
	public var StatType:String;

	public var Bonus:Float = Math.NaN;

	public var MaxCap:Float = Math.NaN;

	public var IconName:String;

	public var Description:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		StatType = jsonAsset.StatType;
		Bonus = ASCompat.toNumberField(jsonAsset, "Bonus");
		MaxCap = ASCompat.toNumberField(jsonAsset, "MaxCap");
		IconName = jsonAsset.IconName;
		Description = jsonAsset.Description;
	}
}
