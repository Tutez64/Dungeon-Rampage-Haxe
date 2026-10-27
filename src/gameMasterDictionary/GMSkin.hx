package gameMasterDictionary;

class GMSkin extends GMItem {
	public var ForHero:String;

	public var AssetType:String;

	public var SpriteWidth:UInt = 0;

	public var SpriteHeight:UInt = 0;

	public var AssetClassName:String;

	public var PortraitName:String;

	public var IconSwfFilepath:String;

	public var IconName:String;

	public var CardName:String;

	public var SwfFilepath:String;

	public var HDSwfFilepath:String;

	public var UISwfFilepath:String;

	public var FeedPostPicture:String;

	public var Scale:Float = Math.NaN;

	public var NametagY:Float = Math.NaN;

	public var HealthbarScale:Float = Math.NaN;

	public var ProjEmitOffset:Float = Math.NaN;

	public var Hue:Float = Math.NaN;

	public var Saturation:Float = Math.NaN;

	public var Brightness:Float = Math.NaN;

	public var Scale3DModel:Float = Math.NaN;

	public var HitVol:Float = Math.NaN;

	public var HitSound:String;

	public var DeathVol:Float = Math.NaN;

	public var DeathSound:String;

	public var CharNickname:String;

	public var CharLikes:String;

	public var CharDislikes:String;

	public var CharUnlockLocation:String;

	public var Description:String;

	public var StoreDescription:String;

	public var specialFXSwfPath_Back:String;

	public var specialFXName_Back:String;

	public var specialFXSwfPath_Front:String;

	public var specialFXName_Front:String;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		ForHero = ASCompat.asString(jsonAsset.ForHero);
		AssetType = ASCompat.asString(jsonAsset.AssetType);
		SpriteWidth = ASCompat.asUint(jsonAsset.SpriteWidth);
		SpriteHeight = ASCompat.asUint(jsonAsset.SpriteHeight);
		AssetClassName = ASCompat.asString(jsonAsset.AssetClassName);
		PortraitName = ASCompat.asString(jsonAsset.PortraitName);
		IconSwfFilepath = ASCompat.asString(jsonAsset.IconSwfFilepath);
		IconName = ASCompat.asString(jsonAsset.IconName);
		CardName = ASCompat.asString(jsonAsset.CardName);
		SwfFilepath = ASCompat.asString(jsonAsset.SwfFilepath);
		HDSwfFilepath = jsonAsset.HDSwfFilepath;
		UISwfFilepath = ASCompat.asString(jsonAsset.UISwfFilepath);
		FeedPostPicture = jsonAsset.FeedPostPicture;
		Scale = ASCompat.asNumber(jsonAsset.Scale);
		NametagY = ASCompat.asNumber(jsonAsset.NametagY);
		HealthbarScale = ASCompat.asNumber(jsonAsset.HealthbarScale);
		ProjEmitOffset = ASCompat.asNumber(jsonAsset.ProjEmitOffset);
		Hue = ASCompat.toNumberField(jsonAsset, "Hue");
		Saturation = ASCompat.toBool(jsonAsset.Saturation) ? ASCompat.toNumber(100 + jsonAsset.Saturation) / 100 * 2 : 0;
		Brightness = ASCompat.toNumberField(jsonAsset, "Brightness");
		if (jsonAsset.Scale3DModel == null) {
			Scale3DModel = 1;
		} else {
			Scale3DModel = ASCompat.toNumberField(jsonAsset, "Scale3DModel");
		}
		HitVol = ASCompat.asNumber(jsonAsset.HitVol);
		HitSound = ASCompat.asString(jsonAsset.HitSound);
		DeathVol = ASCompat.asNumber(jsonAsset.DeathVol);
		DeathSound = ASCompat.asString(jsonAsset.DeathSound);
		CharNickname = ASCompat.asString(jsonAsset.CharNickname);
		CharLikes = ASCompat.asString(jsonAsset.CharLikes);
		CharDislikes = ASCompat.asString(jsonAsset.CharDislikes);
		CharUnlockLocation = ASCompat.asString(jsonAsset.CharUnlockLocation);
		Description = ASCompat.asString(jsonAsset.Description);
		StoreDescription = ASCompat.asString(jsonAsset.StoreDescription);
		specialFXSwfPath_Back = jsonAsset.SpecialFXSwfPath_Back;
		specialFXName_Back = jsonAsset.SpecialFXName_Back;
		specialFXSwfPath_Front = jsonAsset.SpecialFXSwfPath_Front;
		specialFXName_Front = jsonAsset.SpecialFXName_Front;
	}

	public function doesSpecialFXBackExist():Bool {
		if (specialFXSwfPath_Back == null || specialFXSwfPath_Back == "") {
			return false;
		}
		if (specialFXName_Back == null || specialFXName_Back == "") {
			return false;
		}
		return true;
	}

	public function doesSpecialFXFrontExist():Bool {
		if (specialFXSwfPath_Front == null || specialFXSwfPath_Front == "") {
			return false;
		}
		if (specialFXName_Front == null || specialFXName_Front == "") {
			return false;
		}
		return true;
	}
}
