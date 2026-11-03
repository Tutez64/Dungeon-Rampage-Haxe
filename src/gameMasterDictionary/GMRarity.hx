package gameMasterDictionary;

import flash.Boot;

class GMRarity {
	public var Type:String;

	public var TextColor:UInt = 0;

	public var NumberOfModifiers:UInt = 0;

	public var ModifierWeight:Float = Math.NaN;

	public var MinSellPercent:Float = Math.NaN;

	public var MinModifierLevel:UInt = 0;

	public var MaxSellPercent:Float = Math.NaN;

	public var MaxModifierLevel:UInt = 0;

	public var LevelWeight:Float = Math.NaN;

	public var KeyOfferId:Float = Math.NaN;

	public var Id:UInt = 0;

	public var HasGlow:Bool = false;

	public var HasColoredBackground:Bool = false;

	public var GlowStr:UInt = 0;

	public var GlowDist:UInt = 0;

	public var GlowColor:UInt = 0;

	public var Constant:String;

	public var BasePowerScale:Float = Math.NaN;

	public var BasePowerConstant:Float = Math.NaN;

	public var BackgroundSwf:String;

	public var BackgroundIconBorder:String;

	public var BackgroundIcon:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		if (Boot.skip_constructor) {
			return;
		}
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		KeyOfferId = ASCompat.toNumber(jsonAsset.KeyOfferId);
		Type = jsonAsset.Type;
		Constant = Type;
		NumberOfModifiers = (ASCompat.toInt(jsonAsset.NumberOfModifiers) : UInt);
		HasColoredBackground = ASCompat.toBool(jsonAsset.HasColoredBackground);
		MaxModifierLevel = (ASCompat.toInt(jsonAsset.MaxModifierLevel) : UInt);
		MinModifierLevel = (ASCompat.toInt(jsonAsset.MinModifierLevel) : UInt);
		MinSellPercent = ASCompat.toNumber(jsonAsset.MinSellPercent);
		MaxSellPercent = ASCompat.toNumber(jsonAsset.MaxSellPercent);
		LevelWeight = ASCompat.toNumber(jsonAsset.LevelWeight);
		ModifierWeight = ASCompat.toNumber(jsonAsset.ModifierWeight);
		HasGlow = ASCompat.toBool(jsonAsset.HasGlow);
		GlowColor = (ASCompat.toInt(jsonAsset.GlowColor) : UInt);
		TextColor = (ASCompat.toInt(jsonAsset.TextColor) : UInt);
		GlowDist = (ASCompat.toInt(jsonAsset.GlowDist) : UInt);
		GlowStr = (ASCompat.toInt(jsonAsset.GlowStr) : UInt);
		BasePowerScale = ASCompat.toNumber(jsonAsset.BasePowerScale);
		BasePowerConstant = ASCompat.toNumber(jsonAsset.BasePowerConstant);
		if (HasColoredBackground) {
			BackgroundIcon = jsonAsset.BackgroundIcon;
			BackgroundIconBorder = jsonAsset.BackgroundIconBorder != null ? jsonAsset.BackgroundIconBorder : "";
			BackgroundSwf = jsonAsset.BackgroundSwf;
		}
	}
}
