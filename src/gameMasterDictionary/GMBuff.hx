package gameMasterDictionary;

import dBGlobals.DBGlobal;

class GMBuff extends GMItem {
	public var Team:String;

	public var Duration:Float = Math.NaN;

	public var LayerPriority:Float = Math.NaN;

	public var SwapDisplay:Bool = false;

	public var Type:String;

	public var Ability:UInt = 0;

	public var DeltaValues:StatVector;

	public var Exp:Float = Math.NaN;

	public var EventExp:Float = Math.NaN;

	public var Gold:Float = Math.NaN;

	public var VFX:String;

	public var VFXFilepath:String;

	public var TintColor:Float = Math.NaN;

	public var TintAmountF:Float = Math.NaN;

	public var Description:String;

	public var SortLayer:String;

	public var BuffFloaterColor:UInt = 0;

	public var Scale:Float = Math.NaN;

	public var ScaleStartDelay:Float = Math.NaN;

	public var ShakeLocalCamera:Bool = false;

	public var ScaleUpIncrementTime:Float = Math.NaN;

	public var ScaleUpIncrementScale:Float = Math.NaN;

	public var ShowInHUD:Bool = false;

	public var IconSwf:String;

	public var IconName:String;

	public var DescriptionPercentForEachStack:Float = Math.NaN;

	public var AttackCooldownMultiplier:Float = Math.NaN;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		Team = jsonAsset.Team;
		Duration = ASCompat.toNumberField(jsonAsset, "Duration");
		LayerPriority = ASCompat.toNumberField(jsonAsset, "LayerPriority");
		SwapDisplay = jsonAsset.SwapDisplay != null;
		Type = jsonAsset.BuffType;
		Ability = (0 : UInt);
		Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability1) : UInt) : UInt);
		Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability2) : UInt) : UInt);
		Ability = ((Ability | DBGlobal.mapAbilityMask(jsonAsset.Ability3) : UInt) : UInt);
		DeltaValues = new StatVector();
		DeltaValues.SetFromJSON(jsonAsset);
		Exp = ASCompat.toNumberField(jsonAsset, "EXP");
		EventExp = ASCompat.toNumberField(jsonAsset, "EVENT_EXP");
		Gold = ASCompat.toNumber(ASCompat.toBool(jsonAsset.Gold) ? ASCompat.toNumberField(jsonAsset, "Gold") : 1);
		VFX = jsonAsset.VFX;
		VFXFilepath = ASCompat.toBool(jsonAsset.VFXFilepath) ? jsonAsset.VFXFilepath : "Resources/Art2D/FX/db_fx_library.swf";
		SortLayer = jsonAsset.SortLayer;
		TintColor = -1;
		TintAmountF = 1;
		var _loc2_:String = jsonAsset.TintColor;
		if (_loc2_ != null) {
			TintColor = ASCompat.parseInt(_loc2_, 16);
			TintAmountF = ASCompat.toNumberField(jsonAsset, "TintAmount");
		}
		Description = jsonAsset.Description;
		BuffFloaterColor = (ASCompat.toInt(jsonAsset.BuffFloaterColor) : UInt);
		Scale = ASCompat.toNumberField(jsonAsset, "Scale");
		ShakeLocalCamera = ASCompat.toBool(jsonAsset.ShakeLocalCamera);
		ScaleStartDelay = ASCompat.toNumberField(jsonAsset, "ScaleUpStartDelay");
		ScaleUpIncrementTime = ASCompat.toNumberField(jsonAsset, "ScaleUpIncrementTime");
		ScaleUpIncrementScale = ASCompat.toNumberField(jsonAsset, "ScaleUpIncrementScale");
		ShowInHUD = ASCompat.toBool(jsonAsset.ShowInHUD);
		IconSwf = jsonAsset.IconSwf;
		IconName = jsonAsset.IconName;
		DescriptionPercentForEachStack = ASCompat.toNumber(ASCompat.toBool(jsonAsset.DescriptionPercentForEachStack) ? ASCompat.toNumberField(jsonAsset,
			"DescriptionPercentForEachStack") : 0);
		AttackCooldownMultiplier = 1;
		if (jsonAsset.AttackCooldownMultiplier != null) {
			AttackCooldownMultiplier = ASCompat.toNumberField(jsonAsset, "AttackCooldownMultiplier");
		}
	}

	public function getStacksDescription(stacks:Int):String {
		var _loc2_ = DescriptionPercentForEachStack * stacks;
		if (_loc2_ > 0) {
			return Std.string(_loc2_) + "%";
		}
		return "";
	}
}
