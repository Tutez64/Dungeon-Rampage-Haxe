package actor
;
   import distributedObjects.HeroGameObject;
   import facade.DBFacade;
   import gameMasterDictionary.GMSkin;
   
    class HeroData extends ActorData
   {
      
      var mHeroGameObject:HeroGameObject;
      
      var mGMSkin:GMSkin;
      
      public function new(param1:DBFacade, param2:HeroGameObject, param3:GMSkin)
      {
         super(param1,param2);
         mHeroGameObject = param2;
         mGMSkin = param3;
      }
      
      override public function getSwfFilePath() : String
      {
         if(ASCompat.stringAsBool(mGMSkin.HDSwfFilepath))
         {
            return DBFacade.buildFullDownloadPath(mGMSkin.HDSwfFilepath);
         }
         return DBFacade.buildFullDownloadPath(mGMSkin.SwfFilepath);
      }
      
      override public function getSpriteSheetClassName(param1:String) : String
      {
         return mGMSkin.AssetClassName + "_" + param1 + ".png";
      }
      
      override public function getMovieClipClassName() : String
      {
         return mGMSkin.AssetClassName;
      }
      
      override public function getOffSpriteSheetClassName(param1:String) : String
      {
         return mGMSkin.AssetClassName + "_off_" + param1 + ".png";
      }
      
      override public function getOffMovieClipClassName() : String
      {
         return ASCompat.stringAsBool(mGMSkin.AssetClassName) ? mGMSkin.AssetClassName + "_off" : "";
      }
      
      override public function  get_assetClassName() : String
      {
         return mGMSkin.AssetClassName;
      }
      
      override public function  get_hue() : Float
      {
         return mGMSkin.Hue;
      }
      
      override public function  get_saturation() : Float
      {
         return mGMSkin.Saturation;
      }
      
      override public function  get_brightness() : Float
      {
         return mGMSkin.Brightness;
      }
      
      override public function  get_scale() : Float
      {
         return mGMSkin.Scale;
      }
      
      override public function  get_hitSound() : String
      {
         return mGMSkin.HitSound;
      }
      
      override public function  get_hitVolume() : Float
      {
         return mGMSkin.HitVol;
      }
      
      override public function  get_deathSound() : String
      {
         return mGMSkin.DeathSound;
      }
      
      override public function  get_deathVolume() : Float
      {
         return mGMSkin.DeathVol;
      }
      
      override public function  get_scale3DModel() : Float
      {
         return mGMSkin.Scale3DModel;
      }
   }


