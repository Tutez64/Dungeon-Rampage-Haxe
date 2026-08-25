package gameMasterDictionary;

class GMRarity {
	public var Id:UInt = 0;

	public var Constant:String;

	public var Type:String;

	public var NumberOfModifiers:UInt = 0;

	public var MaxModifierLevel:UInt = 0;

	public var MinModifierLevel:UInt = 0;

	public var HasColoredBackground:Bool = false;

	public var BackgroundIcon:String;

	public var BackgroundIconBorder:String;

	public var BackgroundSwf:String;

	public var KeyOfferId:Float = Math.NaN;

	public var MinSellPercent:Float = Math.NaN;

	public var MaxSellPercent:Float = Math.NaN;

	public var LevelWeight:Float = Math.NaN;

	public var ModifierWeight:Float = Math.NaN;

	public var BasePowerScale:Float = Math.NaN;

	public var BasePowerConstant:Float = Math.NaN;

	public var HasGlow:Bool = false;

	public var GlowColor:UInt = 0;

	public var GlowStr:UInt = 0;

	public var GlowDist:UInt = 0;

	public var TextColor:UInt = 0;

	public function new(jsonAsset:ASObject) {
		Id = (ASCompat.toInt(jsonAsset.Id) : UInt);
		KeyOfferId = ASCompat.toNumberField(jsonAsset, "KeyOfferId");
		Constant = Type = jsonAsset.Type;
		NumberOfModifiers = (ASCompat.toInt(jsonAsset.NumberOfModifiers) : UInt);
		HasColoredBackground = ASCompat.toBool(jsonAsset.HasColoredBackground);
		MaxModifierLevel = (ASCompat.toInt(jsonAsset.MaxModifierLevel) : UInt);
		MinModifierLevel = (ASCompat.toInt(jsonAsset.MinModifierLevel) : UInt);
		MinSellPercent = ASCompat.toNumberField(jsonAsset, "MinSellPercent");
		MaxSellPercent = ASCompat.toNumberField(jsonAsset, "MaxSellPercent");
		LevelWeight = ASCompat.toNumberField(jsonAsset, "LevelWeight");
		ModifierWeight = ASCompat.toNumberField(jsonAsset, "ModifierWeight");
		HasGlow = ASCompat.toBool(jsonAsset.HasGlow);
		GlowColor = (ASCompat.toInt(jsonAsset.GlowColor) : UInt);
		TextColor = (ASCompat.toInt(jsonAsset.TextColor) : UInt);
		GlowDist = (ASCompat.toInt(jsonAsset.GlowDist) : UInt);
		GlowStr = (ASCompat.toInt(jsonAsset.GlowStr) : UInt);
		BasePowerScale = ASCompat.toNumberField(jsonAsset, "BasePowerScale");
		BasePowerConstant = ASCompat.toNumberField(jsonAsset, "BasePowerConstant");
		if (HasColoredBackground) {
			BackgroundIcon = jsonAsset.BackgroundIcon;
			BackgroundIconBorder = jsonAsset.BackgroundIconBorder != null ? jsonAsset.BackgroundIconBorder : "";
			BackgroundSwf = jsonAsset.BackgroundSwf;
		}
	}
}
