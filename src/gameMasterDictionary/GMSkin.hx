package gameMasterDictionary;

class GMSkin extends GMItem {
	public var specialFXSwfPath_Front:String;

	public var specialFXSwfPath_Back:String;

	public var specialFXName_Front:String;

	public var specialFXName_Back:String;

	public var UISwfFilepath:String;

	public var SwfFilepath:String;

	public var StoreDescription:String;

	public var SpriteWidth:UInt = 0;

	public var SpriteHeight:UInt = 0;

	public var Scale:Float = Math.NaN;

	public var Saturation:Float = Math.NaN;

	public var ProjEmitOffset:Float = Math.NaN;

	public var PortraitName:String;

	public var PortraitClassName:String;

	public var NametagY:Float = Math.NaN;

	public var IconSwfFilepath:String;

	public var IconName:String;

	public var Hue:Float = Math.NaN;

	public var HitVol:Float = Math.NaN;

	public var HitSound:String;

	public var HealthbarScale:Float = Math.NaN;

	public var ForHero:String;

	public var Description:String;

	public var DeathVol:Float = Math.NaN;

	public var DeathSound:String;

	public var CharUnlockLocation:String;

	public var CharNickname:String;

	public var CharLikes:String;

	public var CharDislikes:String;

	public var Brightness:Float = Math.NaN;

	public var BackgroundClassName:String;

	public var AssetType:String;

	public var AssetClassName:String;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		super(jsonAsset);
		ForHero = jsonAsset.ForHero;
		AssetType = jsonAsset.AssetType;
		SpriteWidth = (ASCompat.toInt(jsonAsset.SpriteWidth) : UInt);
		SpriteHeight = (ASCompat.toInt(jsonAsset.SpriteHeight) : UInt);
		AssetClassName = jsonAsset.AssetClassName;
		PortraitName = jsonAsset.PortraitName;
		IconSwfFilepath = jsonAsset.IconSwfFilepath;
		IconName = jsonAsset.IconName;
		BackgroundClassName = jsonAsset.BackgroundClassName;
		PortraitClassName = jsonAsset.PortraitClassName;
		SwfFilepath = jsonAsset.SwfFilepath;
		UISwfFilepath = jsonAsset.UISwfFilepath;
		Scale = ASCompat.toNumber(jsonAsset.Scale);
		NametagY = ASCompat.toNumber(jsonAsset.NametagY);
		HealthbarScale = ASCompat.toNumber(jsonAsset.HealthbarScale);
		ProjEmitOffset = ASCompat.toNumber(jsonAsset.ProjEmitOffset);
		Hue = ASCompat.toNumber(jsonAsset.Hue);
		var _loc2_ = ASCompat.toNumber(jsonAsset.Saturation);
		Saturation = _loc2_ != 0 && _loc2_ == _loc2_ ? (100 + _loc2_) / 100 * 2 : 0;
		Brightness = ASCompat.toNumber(jsonAsset.Brightness);
		HitVol = ASCompat.toNumber(jsonAsset.HitVol);
		HitSound = jsonAsset.HitSound;
		DeathVol = ASCompat.toNumber(jsonAsset.DeathVol);
		DeathSound = jsonAsset.DeathSound;
		CharNickname = jsonAsset.CharNickname;
		CharLikes = jsonAsset.CharLikes;
		CharDislikes = jsonAsset.CharDislikes;
		CharUnlockLocation = jsonAsset.CharUnlockLocation;
		Description = jsonAsset.Description;
		StoreDescription = jsonAsset.StoreDescription;
		specialFXSwfPath_Back = jsonAsset.SpecialFXSwfPath_Back;
		specialFXName_Back = jsonAsset.SpecialFXName_Back;
		specialFXSwfPath_Front = jsonAsset.SpecialFXSwfPath_Front;
		specialFXName_Front = jsonAsset.SpecialFXName_Front;
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

	public function doesSpecialFXBackExist():Bool {
		if (specialFXSwfPath_Back == null || specialFXSwfPath_Back == "") {
			return false;
		}
		if (specialFXName_Back == null || specialFXName_Back == "") {
			return false;
		}
		return true;
	}
}
