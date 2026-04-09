package gameMasterDictionary
;
    class GMActor extends GMItem
   {
      
      public static inline final DESTRUCTION_SMASH= "SMASH";
      
      public static inline final DESTRUCTION_TIPOVER= "TIPOVER";
      
      public static inline final CHAR_TYPE_PROP= "PROP";
      
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
      
      public function new(param1:ASObject)
      {
         super(param1);
         if(param1.hasOwnProperty("Release"))
         {
            Release = param1.Release;
         }
         Description = param1.Description;
         CharType = param1.CharType;
         ClassType = param1.ClassType;
         Species = param1.Species;
         Element = param1.Element;
         HP = ASCompat.toNumberField(param1, "HP");
         MP = ASCompat.toNumberField(param1, "MP");
         BaseValues = new StatVector();
         BaseValues.SetFromJSON(param1);
         LevelValues = new StatVector();
         LevelValues.SetFromJSON(param1,"LV_");
         AssetClassName = param1.AssetClassName;
         PortraitName = param1.PortraitName;
         IconSwfFilepath = param1.IconSwfFilepath;
         mIconName = param1.IconName;
         SwfFilepath = param1.SwfFilepath;
         Description = param1.Description;
         AssetType = param1.AssetType;
         SpriteWidth = ASCompat.toNumberField(param1, "SpriteWidth");
         SpriteHeight = ASCompat.toNumberField(param1, "SpriteHeight");
         NametagY = ASCompat.toNumberField(param1, "NametagY");
         HealthbarScale = ASCompat.toNumberField(param1, "HealthbarScale");
         IsMover = ASCompat.toNumberField(param1, "IsMover") == 1;
         HasOffscreenIndicator = ASCompat.toBool(param1.HasOffscreenIndicator);
         Ability = (0 : UInt);
         Scale = ASCompat.toNumberField(param1, "Scale");
         Hue = ASCompat.toNumberField(param1, "Hue");
         Saturation = ASCompat.toNumberField(param1, "Saturation") > 0 ? ASCompat.toNumber(100 + param1.Saturation) / 100 * 2 : 0;
         Brightness = ASCompat.toNumberField(param1, "Brightness");
         BaseMove = ASCompat.toNumberField(param1, "BaseMove");
         HitSound = param1.HitSound;
         HitVolume = ASCompat.toNumberField(param1, "HitVol");
         DeathSound = param1.DeathSound;
         DeathVolume = ASCompat.toNumberField(param1, "DeathVol");
         SpawnEffectClassName = param1.SpawnEffectClassName;
         SpawnEffectFilePath = param1.SpawnEffectFilePath;
         CollisionX = ASCompat.toNumberField(param1, "CollisionX");
         CollisionY = ASCompat.toNumberField(param1, "CollisionY");
         CollisionSize = ASCompat.toNumberField(param1, "CollisionSize");
         CollideWithTeam = ASCompat.toBool(param1.CollideWithTeam);
         TeleportInTimeline = param1.TeleportInTimeline;
         TeleportOutTimeline = param1.TeleportOutTimeline;
         RespawnT = ASCompat.toNumberField(param1, "RespawnT");
         ProjEmitOffset = ASCompat.toNumberField(param1, "ProjEmitOffset");
         scaled_ProjEmitOffset = ASCompat.toNumber(ASCompat.toNumberField(param1, "ProjEmitOffset") * Scale);
         DefaultDestruct = param1.DefaultDestruct;
         CanShakeCamera = ASCompat.toBool(param1.CanShakeCamera);
      }
      
      @:isVar public var IconName(get,never):String;
public function  get_IconName() : String
      {
         return mIconName;
      }
   }


