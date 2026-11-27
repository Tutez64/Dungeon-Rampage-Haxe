package gameMasterDictionary;

import dBGlobals.As3Compat;
import dBGlobals.DBGlobal;

class GMBuff extends GMItem {
	public var VFXFilepath:String;

	public var VFX:String;

	public var Type:String;

	public var TintColor:Float = Math.NaN;

	public var TintAmountF:Float = Math.NaN;

	public var Team:String;

	public var SwapDisplay:Bool = false;

	public var SortLayer:String;

	public var ShowInHUD:Bool = false;

	public var ShakeLocalCamera:Bool = false;

	public var ScaleUpIncrementTime:Float = Math.NaN;

	public var ScaleUpIncrementScale:Float = Math.NaN;

	public var ScaleStartDelay:Float = Math.NaN;

	public var Scale:Float = Math.NaN;

	public var LayerPriority:Float = Math.NaN;

	public var IconSwf:String;

	public var IconName:String;

	public var Gold:Float = Math.NaN;

	public var Exp:Float = Math.NaN;

	public var EventExp:Float = Math.NaN;

	public var Duration:Float = Math.NaN;

	public var DescriptionPercentForEachStack:Float = Math.NaN;

	public var Description:String;

	public var DeltaValues:StatVector;

	public var BuffFloaterColor:UInt = 0;

	public var AttackCooldownMultiplier:Float = Math.NaN;

	public var Ability:UInt = 0;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		Team = jsonAsset.Team;
		Duration = ASCompat.toNumber(jsonAsset.Duration);
		LayerPriority = ASCompat.toNumber(jsonAsset.LayerPriority);
		SwapDisplay = jsonAsset.SwapDisplay != null;
		Type = jsonAsset.BuffType;
		Ability = (0 : UInt);
		Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability1) : UInt) : UInt);
		Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability2) : UInt) : UInt);
		Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability3) : UInt) : UInt);
		DeltaValues = new StatVector();
		DeltaValues.SetFromJSON(jsonAsset);
		Exp = ASCompat.toNumber(jsonAsset.EXP);
		EventExp = ASCompat.toNumber(jsonAsset.EVENT_EXP);
		Gold = As3Compat.truthy(jsonAsset.Gold) ? ASCompat.toNumber(jsonAsset.Gold) : 1;
		VFX = jsonAsset.VFX;
		VFXFilepath = As3Compat.truthy(jsonAsset.VFXFilepath) ? jsonAsset.VFXFilepath : "Resources/Art2D/FX/db_fx_library.swf";
		SortLayer = jsonAsset.SortLayer;
		TintColor = -1;
		TintAmountF = 1;
		var _loc2_:String = jsonAsset.TintColor;
		if (_loc2_ != null) {
			TintColor = As3Compat.parseHex(_loc2_);
			TintAmountF = ASCompat.toNumberField(jsonAsset, "TintAmount");
		}
		Description = jsonAsset.Description;
		BuffFloaterColor = (ASCompat.toInt(jsonAsset.BuffFloaterColor) : UInt);
		Scale = ASCompat.toNumber(jsonAsset.Scale);
		ShakeLocalCamera = ASCompat.toBool(jsonAsset.ShakeLocalCamera);
		ScaleStartDelay = ASCompat.toNumber(jsonAsset.ScaleUpStartDelay);
		ScaleUpIncrementTime = ASCompat.toNumber(jsonAsset.ScaleUpIncrementTime);
		ScaleUpIncrementScale = ASCompat.toNumber(jsonAsset.ScaleUpIncrementScale);
		ShowInHUD = ASCompat.toBool(jsonAsset.ShowInHUD);
		IconSwf = jsonAsset.IconSwf;
		IconName = jsonAsset.IconName;
		DescriptionPercentForEachStack = As3Compat.truthy(jsonAsset.DescriptionPercentForEachStack) ? ASCompat.toNumber(jsonAsset.DescriptionPercentForEachStack) : 0;
		AttackCooldownMultiplier = 1;
		if (jsonAsset.AttackCooldownMultiplier != null) {
			AttackCooldownMultiplier = ASCompat.toNumberField(jsonAsset, "AttackCooldownMultiplier");
		}
	}

	public function getStacksDescription(stacks:Int):String {
		var _loc2_ = DescriptionPercentForEachStack * stacks;
		if (_loc2_ > 0) {
			return "" + _loc2_ + "%";
		}
		return "";
	}
}
