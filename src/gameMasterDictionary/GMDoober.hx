package gameMasterDictionary;

class GMDoober extends GMItem {
	public var DooberType:String;

	public var SharedReward:String;

	public var InstantReward:String;

	public var ScaleVisual:Float = Math.NaN;

	public var AssetClassName:String;

	public var SwfFilePath:String;

	public var PickupSound:String;

	public var PickupVolume:Float = Math.NaN;

	public var Exp:UInt = 0;

	public var ChestId:UInt = 0;

	public var Rarity:String;

	public var HPPercentage:Float = Math.NaN;

	public var MPPercentage:Float = Math.NaN;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		DooberType = jsonAsset.DooberType;
		SharedReward = jsonAsset.SharedReward;
		ScaleVisual = 1;
		if (ASCompat.toBool(jsonAsset.ScaleVisual)) {
			ScaleVisual = ASCompat.toNumberField(jsonAsset, "ScaleVisual");
		}
		InstantReward = jsonAsset.InstantReward;
		AssetClassName = jsonAsset.AssetClassName;
		SwfFilePath = jsonAsset.SwfFilepath;
		PickupSound = jsonAsset.PickupSound;
		PickupVolume = ASCompat.toNumberField(jsonAsset, "PickupVol");
		Exp = (ASCompat.toInt(jsonAsset.Exp) : UInt);
		ChestId = (ASCompat.toInt(jsonAsset.ChestId) : UInt);
		Rarity = jsonAsset.Rarity;
		HPPercentage = ASCompat.toNumberField(jsonAsset, "HP_PERCENTAGE");
		MPPercentage = ASCompat.toNumberField(jsonAsset, "MP_PERCENTAGE");
	}

	public function isFood():Bool {
		return DooberType == "FOOD" || DooberType == "FOOD_COOK" || DooberType == "CHEF_FOOD";
	}
}
