package actor
;
   import facade.DBFacade;
   import gameMasterDictionary.GMActor;
   import gameMasterDictionary.StatVector;
   
    class ActorData
   {
      
      var mFacade:DBFacade;
      
      var mActorGameObject:ActorGameObject;
      
      var mData:GMActor;
      
      public function new(param1:DBFacade, param2:ActorGameObject)
      {
         
         mFacade = param1;
         mActorGameObject = param2;
         var _loc3_= mFacade.gameMaster.getActorMap(mActorGameObject.type);
         mData = ASCompat.dynamicAs(_loc3_.itemFor(mActorGameObject.type), gameMasterDictionary.GMActor);
         if(mData == null)
         {
            throw new Error("type not found in GameMaster");
         }
      }
      
      public function destroy() 
      {
         mFacade = null;
         mActorGameObject = null;
         mData = null;
      }
      
      @:isVar public var gMActor(get,never):GMActor;
public function  get_gMActor() : GMActor
      {
         return mData;
      }
      
      public function getSwfFilePath() : String
      {
         return DBFacade.buildFullDownloadPath(mData.SwfFilepath);
      }
      
      public function getSpriteSheetClassName(param1:String) : String
      {
         return mData.AssetClassName + "_" + param1 + ".png";
      }
      
      public function getMovieClipClassName() : String
      {
         return mData.AssetClassName;
      }
      
      public function getOffSpriteSheetClassName(param1:String) : String
      {
         return mData.AssetClassName + "_off_" + param1 + ".png";
      }
      
      public function getOffMovieClipClassName() : String
      {
         return ASCompat.stringAsBool(mData.AssetClassName) ? mData.AssetClassName + "_off" : "";
      }
      
      @:isVar public var constant(get,never):String;
public function  get_constant() : String
      {
         return mData.Constant;
      }
      
      @:isVar public var hp(get,never):Float;
public function  get_hp() : Float
      {
         return mData.HP;
      }
      
      @:isVar public var mp(get,never):Float;
public function  get_mp() : Float
      {
         return mData.MP;
      }
      
      @:isVar public var movment(get,never):Float;
public function  get_movment() : Float
      {
         return mData.BaseMove;
      }
      
      @:isVar public var baseValues(get,never):StatVector;
public function  get_baseValues() : StatVector
      {
         return mData.BaseValues;
      }
      
      @:isVar public var levelValues(get,never):StatVector;
public function  get_levelValues() : StatVector
      {
         return mData.LevelValues;
      }
      
      @:isVar public var isMover(get,never):Bool;
public function  get_isMover() : Bool
      {
         return mData.IsMover;
      }
      
      @:isVar public var assetType(get,never):String;
public function  get_assetType() : String
      {
         return mData.AssetType;
      }
      
      @:isVar public var spriteWidth(get,never):Float;
public function  get_spriteWidth() : Float
      {
         return mData.SpriteWidth;
      }
      
      @:isVar public var spriteHeight(get,never):Float;
public function  get_spriteHeight() : Float
      {
         return mData.SpriteHeight;
      }
      
      @:isVar public var assetClassName(get,never):String;
public function  get_assetClassName() : String
      {
         return mData.AssetClassName;
      }
      
      @:isVar public var hue(get,never):Float;
public function  get_hue() : Float
      {
         return mData.Hue;
      }
      
      @:isVar public var saturation(get,never):Float;
public function  get_saturation() : Float
      {
         return mData.Saturation;
      }
      
      @:isVar public var brightness(get,never):Float;
public function  get_brightness() : Float
      {
         return mData.Brightness;
      }
      
      @:isVar public var scale(get,never):Float;
public function  get_scale() : Float
      {
         return mData.Scale;
      }
      
      @:isVar public var hitSound(get,never):String;
public function  get_hitSound() : String
      {
         return mData.HitSound;
      }
      
      @:isVar public var hitVolume(get,never):Float;
public function  get_hitVolume() : Float
      {
         return mData.HitVolume;
      }
      
      @:isVar public var deathSound(get,never):String;
public function  get_deathSound() : String
      {
         return mData.DeathSound;
      }
      
      @:isVar public var deathVolume(get,never):Float;
public function  get_deathVolume() : Float
      {
         return mData.DeathVolume;
      }
      
      @:isVar public var scale3DModel(get,never):Float;
public function  get_scale3DModel() : Float
      {
         return mData.Scale3DModel;
      }
   }


