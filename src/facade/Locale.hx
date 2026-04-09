package facade
;
   import brain.assetRepository.AssetLoaderInfo;
   import brain.logger.Logger;
   
    class Locale
   {
      
      public static inline final DEFAULT_NAMETAG= "DEFAULT_NAMETAG";
      
      static var mStringTable:ASObject;
      
      public function new()
      {
         
      }
      
      public static function loadStrings(param1:DBFacade, param2:String, param3:ASFunction) 
      {
         var facade= param1;
         var locale= param2;
         var callback= param3;
         var AsstetInfo= new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/" + locale + ".json"),false);
         facade.assetRepository.getJsonAsset(AsstetInfo,function(param1:brain.assetRepository.JsonAsset)
         {
            Logger.debug("Loaded locale: " + locale);
            mStringTable = param1.json;
            callback();
         });
      }
      
      public static function getString(param1:String) : String
      {
         if(mStringTable == null)
         {
            Logger.warn("You cannot call getString before load has finished: " + param1);
            return param1;
         }
         var _loc2_:String = mStringTable.strings[param1];
         if(_loc2_ == null)
         {
            Logger.warn("Localized string not found: " + param1);
            return "mia:" + param1;
         }
         return _loc2_;
      }
      
      public static function getSubString(param1:String, param2:String) : String
      {
         if(mStringTable == null)
         {
            Logger.warn("You cannot call getSubString before load has finished: " + param1 + " subKey: " + param2);
            return param1;
         }
         var _loc3_:ASObject = mStringTable.strings[param1];
         if(_loc3_ == null)
         {
            Logger.error("Localized sub string not found: " + param1 + " subKey: " + param2);
            return param1;
         }
         var _loc4_:String = _loc3_[param2];
         if(_loc4_ == null)
         {
            Logger.error("Localized sub string not found: " + param2);
            return param1;
         }
         return _loc4_;
      }
      
      public static function getError(param1:Int) : String
      {
         if(mStringTable == null)
         {
            Logger.warn("You cannot call getError before load has finished: " + Std.string(param1));
            return "Error (" + Std.string(param1) + ")";
         }
         var _loc2_:String = mStringTable.errors[Std.string(param1)];
         if(_loc2_ == null)
         {
            Logger.warn("Localized error string not found: " + Std.string(param1));
            _loc2_ = mStringTable.errors["DEF"];
            if(_loc2_ == null)
            {
               _loc2_ = "Error ";
            }
            _loc2_ += "(" + Std.string(param1) + ")";
         }
         return _loc2_;
      }
      
      public static function getStringForMastertype(param1:String) : String
      {
         var _loc2_= "MASTER_TYPE_" + param1;
         var _loc3_= getString(_loc2_);
         if(_loc3_ == _loc2_)
         {
            return param1;
         }
         return _loc2_;
      }
   }


