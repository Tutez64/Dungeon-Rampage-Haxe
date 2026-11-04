package gameMasterDictionary;

class GMSuperStat extends GMItem {
	public var TrapPower:Float = Math.NaN;

	public var IconName:String;

	public var Description:String;

	public var CooldownReduction:Float = Math.NaN;

	public var CookingRarityMinPerPoint:Float = Math.NaN;

	public var CookingRarityMaxPerPoint:Float = Math.NaN;

	public var CookingRarityMaxBase:Float = Math.NaN;

	public var CookingFoodOnHitPerPoint:Float = Math.NaN;

	public var CookingBuffDurationPerPoint:Float = Math.NaN;

	public var BaseValues:StatVector;

	public var Ability3:String;

	public var Ability2:String;

	public var Ability1:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		BaseValues = new StatVector();
		BaseValues.SetFromJSON(jsonAsset);
		Ability1 = jsonAsset.Ability1;
		Ability2 = jsonAsset.Ability2;
		Ability3 = jsonAsset.Ability3;
		IconName = jsonAsset.IconName;
		Description = jsonAsset.Description;
		CooldownReduction = ASCompat.toNumber(jsonAsset.CooldownReduction);
		CookingRarityMinPerPoint = ASCompat.toNumber(jsonAsset.CookingRarityMinPerPoint);
		CookingRarityMaxPerPoint = ASCompat.toNumber(jsonAsset.CookingRarityMaxPerPoint);
		CookingRarityMaxBase = ASCompat.toNumber(jsonAsset.CookingRarityMaxBase);
		CookingBuffDurationPerPoint = ASCompat.toNumber(jsonAsset.CookingBuffDurationPerPoint);
		CookingFoodOnHitPerPoint = ASCompat.toNumber(jsonAsset.CookingFoodOnHitPerPoint);
		TrapPower = ASCompat.toNumber(jsonAsset.TrapPower);
	}
}
