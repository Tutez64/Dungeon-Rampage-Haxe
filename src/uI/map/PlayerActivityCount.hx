package uI.map
;
   import brain.assetRepository.AssetLoaderInfo;
   import brain.assetRepository.AssetRepository;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import facade.DBFacade;
   import facade.Locale;
   
    class PlayerActivityCount
   {
      
      static inline final PLAYER_ACTIVITY_LOCALE_PREFIX= "PLAYER_ACTIVITY_";
      
      public var publicDungeonActivityLevel:ASObject = {};
      
      var mAssetRepository:AssetRepository;
      
      var mStatusURL:String;
      
      public function new(param1:DBFacade)
      {
         
         mAssetRepository = param1.assetRepository;
         mStatusURL = param1.webServicesUrl + "/game-status";
         fetchPublicDungeonActivityLevel();
      }
      
      public function fetchPublicDungeonActivityLevel(param1:GameClock = null) 
      {
         var gameClock= param1;
         var info= new AssetLoaderInfo(mStatusURL,false);
         mAssetRepository.getJsonAsset(info,function(param1:brain.assetRepository.JsonAsset)
         {
            if(ASCompat.toBool(param1.json) && ASCompat.toBool(param1.json.publicDungeonActivityLevel))
            {
               publicDungeonActivityLevel = param1.json.publicDungeonActivityLevel;
            }
         },function()
         {
            Logger.warn("game-status request failed: " + mStatusURL);
         });
      }
      
      public function getActivityString(param1:Int) : String
      {
         var _loc2_= ASCompat.asString(publicDungeonActivityLevel[Std.string(param1)] );
         if(ASCompat.stringAsBool(_loc2_))
         {
            return getLocalizedActivityString(_loc2_.toUpperCase());
         }
         return getLocalizedActivityString("UNKNOWN");
      }
      
      function getLocalizedActivityString(param1:String) : String
      {
         return Locale.getString("PLAYER_ACTIVITY_" + param1);
      }
   }


