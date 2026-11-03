package gameMasterDictionary;

import flash.Boot;

class GMActor extends GMItem {
	public static var DESTRUCTION_SMASH:String = "SMASH";

	public static var DESTRUCTION_TIPOVER:String = "TIPOVER";

	public static var CHAR_TYPE_PROP:String = "PROP";

	public var scaled_ProjEmitOffset:Float = Math.NaN;

	public var mIconName:String;

	public var Weapon5:String;

	public var Weapon4:String;

	public var Weapon3:String;

	public var Weapon2:String;

	public var Weapon1:String;

	public var TeleportOutTimeline:String;

	public var TeleportInTimeline:String;

	public var SwfFilepath:String;

	public var SpriteWidth:Float = Math.NaN;

	public var SpriteHeight:Float = Math.NaN;

	public var Species:String;

	public var SpawnEffectFilePath:String;

	public var SpawnEffectClassName:String;

	public var Scale:Float = Math.NaN;

	public var Saturation:Float = Math.NaN;

	public var RespawnT:Float = Math.NaN;

	public var Release:String;

	public var ProjEmitOffset:Float = Math.NaN;

	public var PortraitName:String;

	public var NametagY:Float = Math.NaN;

	public var MP:Float = Math.NaN;

	public var LevelValues:StatVector;

	public var IsMover:Bool = false;

	public var IconSwfFilepath:String;

	public var Hue:Float = Math.NaN;

	public var HitVolume:Float = Math.NaN;

	public var HitSound:String;

	public var HealthbarScale:Float = Math.NaN;

	public var HasOffscreenIndicator:Bool = false;

	public var HP:Float = Math.NaN;

	public var Element:String;

	public var Description:String;

	public var DefaultDestruct:String;

	public var DeathVolume:Float = Math.NaN;

	public var DeathSound:String;

	public var CollisionY:Float = Math.NaN;

	public var CollisionX:Float = Math.NaN;

	public var CollisionSize:Float = Math.NaN;

	public var CollideWithTeam:Bool = false;

	public var ClassType:String;

	public var CharType:String;

	public var CanShakeCamera:Bool = false;

	public var Brightness:Float = Math.NaN;

	public var BaseValues:StatVector;

	public var BaseMove:Float = Math.NaN;

	public var AssetType:String;

	public var AssetClassName:String;

	public var Ability:UInt = 0;

	public function new(jsonAsset:ASObject = /*undefined*/ null) {
		var _loc2_:Float;
		if (!Boot.skip_constructor) {
			HasOffscreenIndicator = false;
			IsMover = true;
			Release = "D";
			super(jsonAsset);
			if (Reflect.hasField(jsonAsset, "Release")) {
				Release = jsonAsset.Release;
			}
			Description = jsonAsset.Description;
			CharType = jsonAsset.CharType;
			ClassType = jsonAsset.ClassType;
			Species = jsonAsset.Species;
			Element = jsonAsset.Element;
			HP = ASCompat.toNumber(jsonAsset.HP);
			MP = ASCompat.toNumber(jsonAsset.MP);
			BaseValues = new StatVector();
			BaseValues.SetFromJSON(jsonAsset);
			LevelValues = new StatVector();
			LevelValues.SetFromJSON(jsonAsset, "LV_");
			AssetClassName = jsonAsset.AssetClassName;
			PortraitName = jsonAsset.PortraitName;
			IconSwfFilepath = jsonAsset.IconSwfFilepath;
			mIconName = jsonAsset.IconName;
			SwfFilepath = jsonAsset.SwfFilepath;
			Description = jsonAsset.Description;
			AssetType = jsonAsset.AssetType;
			SpriteWidth = ASCompat.toNumber(jsonAsset.SpriteWidth);
			SpriteHeight = ASCompat.toNumber(jsonAsset.SpriteHeight);
			NametagY = ASCompat.toNumber(jsonAsset.NametagY);
			HealthbarScale = ASCompat.toNumber(jsonAsset.HealthbarScale);
			IsMover = ASCompat.toInt(jsonAsset.IsMover) == 1;
			HasOffscreenIndicator = ASCompat.toBool(jsonAsset.HasOffscreenIndicator);
			Ability = (0 : UInt);
			Scale = ASCompat.toNumber(jsonAsset.Scale);
			Hue = ASCompat.toNumber(jsonAsset.Hue);
			_loc2_ = ASCompat.toNumber(jsonAsset.Saturation);
			Saturation = _loc2_ > 0 ? (100 + _loc2_) / 100 * 2 : 0;
			Brightness = ASCompat.toNumber(jsonAsset.Brightness);
			BaseMove = ASCompat.toNumber(jsonAsset.BaseMove);
			HitSound = jsonAsset.HitSound;
			HitVolume = ASCompat.toNumber(jsonAsset.HitVol);
			DeathSound = jsonAsset.DeathSound;
			DeathVolume = ASCompat.toNumber(jsonAsset.DeathVol);
			SpawnEffectClassName = jsonAsset.SpawnEffectClassName;
			SpawnEffectFilePath = jsonAsset.SpawnEffectFilePath;
			CollisionX = ASCompat.toNumber(jsonAsset.CollisionX);
			CollisionY = ASCompat.toNumber(jsonAsset.CollisionY);
			CollisionSize = ASCompat.toNumber(jsonAsset.CollisionSize);
			CollideWithTeam = ASCompat.toBool(jsonAsset.CollideWithTeam);
			TeleportInTimeline = jsonAsset.TeleportInTimeline;
			TeleportOutTimeline = jsonAsset.TeleportOutTimeline;
			RespawnT = ASCompat.toNumber(jsonAsset.RespawnT);
			ProjEmitOffset = ASCompat.toNumber(jsonAsset.ProjEmitOffset);
			scaled_ProjEmitOffset = ProjEmitOffset * Scale;
			DefaultDestruct = jsonAsset.DefaultDestruct;
			CanShakeCamera = ASCompat.toBool(jsonAsset.CanShakeCamera);
		}
	}

	public function get_IconName():String {
		return mIconName;
	}

	@:isVar public var IconName(get, never):String;

	public function get_IconName():String {
		return get_IconName();
	}
}
