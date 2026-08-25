package gameMasterDictionary;

class GMWeaponAesthetic {
	public var Release:String;

	public var WeaponItemConstant:String;

	public var Constant:String;

	public var Name:String;

	public var MinLevel:UInt = 0;

	public var MaxLevel:UInt = 0;

	public var ModelName:String;

	public var IconName:String;

	public var IconSwf:String;

	public var SwordTrailOverride:String;

	public var ItemR:Float = Math.NaN;

	public var ItemG:Float = Math.NaN;

	public var ItemB:Float = Math.NaN;

	public var ItemRAdd:Float = Math.NaN;

	public var ItemGAdd:Float = Math.NaN;

	public var ItemBAdd:Float = Math.NaN;

	public var HasColor:Bool = false;

	public var GlowDist:Float = Math.NaN;

	public var GlowStr:Float = Math.NaN;

	public var GlowColor:UInt = 0;

	public var HasGlow:Bool = false;

	public var TrailR:Float = Math.NaN;

	public var TrailG:Float = Math.NaN;

	public var TrailB:Float = Math.NaN;

	public var TrailRAdd:Float = Math.NaN;

	public var TrailGAdd:Float = Math.NaN;

	public var TrailBAdd:Float = Math.NaN;

	public var HasTrailColor:Bool = false;

	public var Description:String;

	public var IsLegendary:Bool = false;

	public function new(jsonAsset:ASObject) {
		Release = jsonAsset.Release;
		WeaponItemConstant = jsonAsset.WeaponItemConstant;
		Constant = jsonAsset.Constant;
		Name = jsonAsset.Name;
		MinLevel = ASCompat.asUint(jsonAsset.MinLvl);
		MaxLevel = ASCompat.asUint(jsonAsset.MaxLvl);
		ModelName = jsonAsset.ModelName;
		IconName = jsonAsset.IconName;
		IconSwf = jsonAsset.UISwfFilepath;
		SwordTrailOverride = jsonAsset.SwordTrailOverride;
		HasColor = jsonAsset.ItemR != null && jsonAsset.ItemG != null && jsonAsset.ItemB != null && jsonAsset.ItemRAdd != null
			&& jsonAsset.ItemGAdd != null && jsonAsset.ItemBAdd != null;
		if (HasColor) {
			ItemR = ASCompat.toNumberField(jsonAsset, "ItemR");
			ItemG = ASCompat.toNumberField(jsonAsset, "ItemG");
			ItemB = ASCompat.toNumberField(jsonAsset, "ItemB");
			ItemRAdd = ASCompat.toNumberField(jsonAsset, "ItemRAdd");
			ItemGAdd = ASCompat.toNumberField(jsonAsset, "ItemGAdd");
			ItemBAdd = ASCompat.toNumberField(jsonAsset, "ItemBAdd");
		}
		HasGlow = jsonAsset.GlowDist != null && jsonAsset.GlowStr != null && jsonAsset.GlowColor != null;
		if (HasGlow) {
			GlowDist = ASCompat.toNumberField(jsonAsset, "GlowDist");
			GlowStr = ASCompat.toNumberField(jsonAsset, "GlowStr");
			GlowColor = (ASCompat.toInt(jsonAsset.GlowColor) : UInt);
		}
		HasTrailColor = jsonAsset.TrailR != null && jsonAsset.TrailG != null && jsonAsset.TrailB != null && jsonAsset.TrailRAdd != null
			&& jsonAsset.TrailGAdd != null && jsonAsset.TrailBAdd != null;
		if (HasTrailColor) {
			TrailR = ASCompat.toNumberField(jsonAsset, "TrailR");
			TrailG = ASCompat.toNumberField(jsonAsset, "TrailG");
			TrailB = ASCompat.toNumberField(jsonAsset, "TrailB");
			TrailRAdd = ASCompat.toNumberField(jsonAsset, "TrailRAdd");
			TrailGAdd = ASCompat.toNumberField(jsonAsset, "TrailGAdd");
			TrailBAdd = ASCompat.toNumberField(jsonAsset, "TrailBAdd");
		}
		Description = jsonAsset.Description;
		IsLegendary = ASCompat.toBool(jsonAsset.IsLegendary);
	}
}
