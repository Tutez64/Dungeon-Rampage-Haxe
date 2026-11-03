package gameMasterDictionary;

import dBGlobals.As3Compat;
import flash.Boot;

class GMDoober extends GMItem {
	public var SwfFilePath:String;

	public var SharedReward:String;

	public var ScaleVisual:Float = Math.NaN;

	public var Rarity:String;

	public var PickupVolume:Float = Math.NaN;

	public var PickupSound:String;

	public var MPPercentage:Float = Math.NaN;

	public var InstantReward:String;

	public var HPPercentage:Float = Math.NaN;

	public var Exp:UInt = 0;

	public var DooberType:String;

	public var ChestId:UInt = 0;

	public var AssetClassName:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (!Boot.skip_constructor) {
			super(jsonAsset);
			DooberType = jsonAsset.DooberType;
			SharedReward = jsonAsset.SharedReward;
			ScaleVisual = 1;
			if (As3Compat.truthy(ASCompat.toNumber(jsonAsset.ScaleVisual))) {
				ScaleVisual = ASCompat.toNumber(jsonAsset.ScaleVisual);
			}
			InstantReward = jsonAsset.InstantReward;
			AssetClassName = jsonAsset.AssetClassName;
			SwfFilePath = jsonAsset.SwfFilepath;
			PickupSound = jsonAsset.PickupSound;
			PickupVolume = ASCompat.toNumber(jsonAsset.PickupVol);
			Exp = (ASCompat.toInt(jsonAsset.Exp) : UInt);
			ChestId = (ASCompat.toInt(jsonAsset.ChestId) : UInt);
			Rarity = jsonAsset.Rarity;
			HPPercentage = ASCompat.toNumber(jsonAsset.HP_PERCENTAGE);
			MPPercentage = ASCompat.toNumber(jsonAsset.MP_PERCENTAGE);
		}
	}

	public function isFood():Bool {
		if (!(DooberType == "FOOD" || DooberType == "FOOD_COOK")) {
			return DooberType == "CHEF_FOOD";
		}
		return true;
	}
}
