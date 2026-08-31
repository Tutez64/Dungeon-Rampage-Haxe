package gameMasterDictionary;

class GMActor extends GMItem {
	public static inline final DESTRUCTION_SMASH = "SMASH";

	public static inline final DESTRUCTION_TIPOVER = "TIPOVER";

	public static inline final CHAR_TYPE_PROP = "PROP";

	public var Release:String = "D";

	public var CharType:String;

	public var ClassType:String;

	public var Species:String;

	public var Element:String;

	public var HP:Float = Math.NaN;

	public var MP:Float = Math.NaN;

	public var BaseMove:Float = Math.NaN;

	public var BaseValues:StatVector;

	public var LevelValues:StatVector;

	public var AssetClassName:String;

	public var SwfFilepath:String;

	public var HDSwfFilepath:String;

	public var PortraitName:String;

	public var IconSwfFilepath:String;

	var mIconName:String;

	public var Description:String;

	public var AssetType:String;

	public var SpriteWidth:Float = Math.NaN;

	public var SpriteHeight:Float = Math.NaN;

	public var NametagY:Float = Math.NaN;

	public var HealthbarScale:Float = Math.NaN;

	public var Scale:Float = Math.NaN;

	public var Hue:Float = Math.NaN;

	public var Saturation:Float = Math.NaN;

	public var Brightness:Float = Math.NaN;

	public var Scale3DModel:Float = Math.NaN;

	public var Ability:UInt = 0;

	public var HitSound:String;

	public var HitVolume:Float = Math.NaN;

	public var DeathSound:String;

	public var DeathVolume:Float = Math.NaN;

	public var SpawnEffectClassName:String;

	public var SpawnEffectFilePath:String;

	public var CollisionX:Float = Math.NaN;

	public var CollisionY:Float = Math.NaN;

	public var CollisionSize:Float = Math.NaN;

	public var CollideWithTeam:Bool = false;

	public var TeleportInTimeline:String;

	public var TeleportOutTimeline:String;

	public var RespawnT:Float = Math.NaN;

	public var ProjEmitOffset:Float = Math.NaN;

	public var DefaultDestruct:String;

	public var Weapon1:String;

	public var Weapon2:String;

	public var Weapon3:String;

	public var Weapon4:String;

	public var Weapon5:String;

	public var CanShakeCamera:Bool = false;

	public var IsMover:Bool = true;

	public var HasOffscreenIndicator:Bool = false;

	public var scaled_ProjEmitOffset:Float = Math.NaN;

	public function new(jsonAsset:ASObject) {
		super(jsonAsset);
		if (jsonAsset.hasOwnProperty("Release")) {
			Release = jsonAsset.Release;
		}
		Description = jsonAsset.Description;
		CharType = jsonAsset.CharType;
		ClassType = jsonAsset.ClassType;
		Species = jsonAsset.Species;
		Element = jsonAsset.Element;
		HP = ASCompat.toNumberField(jsonAsset, "HP");
		MP = ASCompat.toNumberField(jsonAsset, "MP");
		BaseValues = new StatVector();
		BaseValues.SetFromJSON(jsonAsset);
		LevelValues = new StatVector();
		LevelValues.SetFromJSON(jsonAsset, "LV_");
		AssetClassName = jsonAsset.AssetClassName;
		PortraitName = jsonAsset.PortraitName;
		IconSwfFilepath = jsonAsset.IconSwfFilepath;
		mIconName = jsonAsset.IconName;
		SwfFilepath = jsonAsset.SwfFilepath;
		HDSwfFilepath = jsonAsset.HDSwfFilepath;
		Description = jsonAsset.Description;
		AssetType = jsonAsset.AssetType;
		SpriteWidth = ASCompat.toNumberField(jsonAsset, "SpriteWidth");
		SpriteHeight = ASCompat.toNumberField(jsonAsset, "SpriteHeight");
		NametagY = ASCompat.toNumberField(jsonAsset, "NametagY");
		HealthbarScale = ASCompat.toNumberField(jsonAsset, "HealthbarScale");
		IsMover = ASCompat.toNumberField(jsonAsset, "IsMover") == 1;
		HasOffscreenIndicator = ASCompat.toBool(jsonAsset.HasOffscreenIndicator);
		Ability = (0 : UInt);
		Scale = ASCompat.toNumberField(jsonAsset, "Scale");
		Hue = ASCompat.toNumberField(jsonAsset, "Hue");
		Saturation = ASCompat.toNumberField(jsonAsset, "Saturation") > 0 ? ASCompat.toNumber(100 + jsonAsset.Saturation) / 100 * 2 : 0;
		Brightness = ASCompat.toNumberField(jsonAsset, "Brightness");
		if (jsonAsset.Scale3DModel == null) {
			Scale3DModel = 1;
		} else {
			Scale3DModel = ASCompat.toNumberField(jsonAsset, "Scale3DModel");
		}
		BaseMove = ASCompat.toNumberField(jsonAsset, "BaseMove");
		HitSound = jsonAsset.HitSound;
		HitVolume = ASCompat.toNumberField(jsonAsset, "HitVol");
		DeathSound = jsonAsset.DeathSound;
		DeathVolume = ASCompat.toNumberField(jsonAsset, "DeathVol");
		SpawnEffectClassName = jsonAsset.SpawnEffectClassName;
		SpawnEffectFilePath = jsonAsset.SpawnEffectFilePath;
		CollisionX = ASCompat.toNumberField(jsonAsset, "CollisionX");
		CollisionY = ASCompat.toNumberField(jsonAsset, "CollisionY");
		CollisionSize = ASCompat.toNumberField(jsonAsset, "CollisionSize");
		CollideWithTeam = ASCompat.toBool(jsonAsset.CollideWithTeam);
		TeleportInTimeline = jsonAsset.TeleportInTimeline;
		TeleportOutTimeline = jsonAsset.TeleportOutTimeline;
		RespawnT = ASCompat.toNumberField(jsonAsset, "RespawnT");
		ProjEmitOffset = ASCompat.toNumberField(jsonAsset, "ProjEmitOffset");
		scaled_ProjEmitOffset = ASCompat.toNumber(ASCompat.toNumberField(jsonAsset, "ProjEmitOffset") * Scale);
		DefaultDestruct = jsonAsset.DefaultDestruct;
		CanShakeCamera = ASCompat.toBool(jsonAsset.CanShakeCamera);
	}

	@:isVar public var IconName(get, never):String;

	public function get_IconName():String {
		return mIconName;
	}
}
