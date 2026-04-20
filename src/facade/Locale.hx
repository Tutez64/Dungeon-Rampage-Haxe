package facade
;
   import brain.assetRepository.AssetLoaderInfo;
   import brain.logger.Logger;
   
    class Locale
   {
      
      public static inline final DEFAULT_NAMETAG= "DEFAULT_NAMETAG";
      
      static var mDefaultStringTable:ASObject;
      
      static var mOverrideStringTable:ASObject;
      
      static var dbFacade:DBFacade;
      
      public function new()
      {
         
      }
      
      @:isVar public static var isDefaultLoaded(get,never):Bool;
static public function  get_isDefaultLoaded() : Bool
      {
         return mDefaultStringTable != null;
      }
      
      public static function loadStrings(param1:DBFacade, param2:ASFunction) 
      {
         var defaultLanguageAssetInfo:AssetLoaderInfo;
         var facade= param1;
         var callback= param2;
         dbFacade = facade;
         var overrideLanguageAssetInfo= new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.override.json"),false);
         facade.assetRepository.getJsonAsset(overrideLanguageAssetInfo,function(param1:brain.assetRepository.JsonAsset)
         {
            Logger.debugch("Locale","Override Locale loaded!");
            mOverrideStringTable = param1.json;
            callback();
         },function()
         {
            Logger.warnch("Locale","Failed to load Override Locale JSON.");
         });
         defaultLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.default.json"),false);
         facade.assetRepository.getJsonAsset(defaultLanguageAssetInfo,function(param1:brain.assetRepository.JsonAsset)
         {
            Logger.debugch("Locale","Default Locale loaded!");
            mDefaultStringTable = param1.json;
            callback();
         },function()
         {
            Logger.fatal("Default Locale File \'Locale.default.json\' failed to Load, cannot proceed with loading the game. Please run \'Verify integrity of game files\' on Steam.");
         });
      }
      
      public static function getString(param1:String) : String
      {
         var _loc4_= false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getString before load has finished: " + param1);
            return param1;
         }
         var _loc3_:String = null;
         if(mOverrideStringTable != null && mOverrideStringTable.strings != null)
         {
            _loc3_ = mOverrideStringTable.strings[param1];
            _loc4_ = true;
            if(_loc3_ != null)
            {
               return _loc3_;
            }
         }
         var _loc2_:String = mDefaultStringTable.strings[param1];
         if(_loc4_)
         {
            Logger.warnch("Locale","Localized string not found: " + param1);
         }
         if(_loc2_ == null)
         {
            Logger.warnch("Locale","Default string not found: " + param1);
            return "mia:" + param1;
         }
         return _loc2_;
      }
      
      public static function getSubString(param1:String, param2:String) : String
      {
         var _loc7_= false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getSubString before load has finished: " + param1 + " subKey: " + param2);
            return param1;
         }
         var _loc5_:ASObject = null;
         if(mOverrideStringTable != null && mOverrideStringTable.strings != null)
         {
            _loc5_ = mOverrideStringTable.strings[param1];
            _loc7_ = true;
         }
         var _loc3_:ASObject = mDefaultStringTable.strings[param1];
         if(_loc5_ == null && _loc3_ == null)
         {
            Logger.error("Unable to find in the `strings` table a dictionary for key: " + param1 + " (when looking up subKey: " + param2 + ")");
            return "mia:" + param1;
         }
         var _loc6_:String = null;
         if(_loc5_ != null)
         {
            _loc6_ = _loc5_[param2];
            if(_loc6_ != null)
            {
               return _loc6_;
            }
         }
         var _loc4_:String = _loc3_ != null ? _loc3_[param2] : null;
         if(_loc7_)
         {
            Logger.warnch("Locale","Localized sub string not found: " + param1 + " subKey: " + param2 + " Using English default value of: `" + _loc4_ + "`");
         }
         if(_loc4_ == null)
         {
            Logger.error("Default sub string not found: " + param1 + " subKey: " + param2);
            return "mia:" + param1;
         }
         return _loc4_;
      }
      
      public static function getError(param1:Int) : String
      {
         var _loc4_= false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getError before load has finished: " + Std.string(param1));
            return "Error (" + Std.string(param1) + ")";
         }
         var _loc3_:String = null;
         if(mOverrideStringTable != null && mOverrideStringTable.errors != null)
         {
            _loc3_ = mOverrideStringTable.errors[Std.string(param1)];
            _loc4_ = true;
            if(_loc3_ != null)
            {
               return _loc3_;
            }
         }
         var _loc2_:String = mDefaultStringTable.errors[Std.string(param1)];
         if(_loc4_)
         {
            Logger.warnch("Locale","Localized error string not found: " + Std.string(param1));
         }
         if(_loc2_ == null)
         {
            Logger.warnch("Locale","Default error string not found: " + Std.string(param1));
            _loc2_ = mDefaultStringTable.errors["DEF"];
            if(_loc2_ == null)
            {
               _loc2_ = "Error ";
            }
            _loc2_ += "(" + Std.string(param1) + ")";
         }
         return _loc2_;
      }
   }


