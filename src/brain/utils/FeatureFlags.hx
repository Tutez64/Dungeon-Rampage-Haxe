package brain.utils
;
   import brain.logger.Logger;
   
    class FeatureFlags
   {
      
      public static inline final USE_HD_ASSETS= "use-hd-assets";
      
      public static inline final WANT_ZOOM= "want-zoom";
      
      public static inline final WANT_DYNAMIC_RARITY_BACKGROUNDS= "want-dynamic-rarity-backgrounds";
      
      public static inline final WANT_DAMAGE_FLOATERS= "want-damage-floaters";
      
      public static inline final WANT_TOWN_ANIMATIONS= "want-town-animations";
      
      public static inline final WANT_BUSTER_BACKGROUND_FADE= "want-buster-background-fade";

      public static inline final WANT_PICKUP_UI_POP= "want-pickup-ui-pop";
      
      public static inline final WANT_MANA_BARS= "want-mana-bars";
      
      public static inline final QUALITY_CONTROL_BUTTON= "quality-control-button";
      
      public static inline final WANT_NUMBERS_ON_BARS= "want-numbered-hud";
      
      public static inline final WANT_REFRESH_HUD_ON_FLOOR_TRANSITION= "want-hud-refresh-on-floor-transition";
      
      public static inline final EXPERIMENTAL_USE_STEAM_INPUT= "experimental-use-steam-input";
      
      public static inline final WANT_STEAM_ACHIEVEMENTS= "want-steam-achievements";

      public static inline final USE_FALLBACK_SOCKET_PORT= "use-fallback-socket-port";
      
      var mFeatureFlags:ASDictionary<ASAny,ASAny>;
      
      public function new()
      {
         
         mFeatureFlags = new ASDictionary<ASAny,ASAny>();
         MemoryTracker.track(mFeatureFlags,"Dictionary - feature flags storage in FeatureFlags()","brain");
         addFeatureFlag("use-hd-assets",false,"--experimental-use-hd-assets","experimental_use_hd_assets");
         addFeatureFlag("want-zoom",false);
         addFeatureFlag("want-dynamic-rarity-backgrounds",false);
         addFeatureFlag("want-damage-floaters",false);
         addFeatureFlag("want-town-animations",false);
         addFeatureFlag("want-buster-background-fade",false);
         addFeatureFlag("want-pickup-ui-pop",false);
         addFeatureFlag("want-mana-bars",false);
         addFeatureFlag("quality-control-button",true);
         addFeatureFlag("want-numbered-hud",false);
         addFeatureFlag("want-hud-refresh-on-floor-transition",false);
         addFeatureFlag("experimental-use-steam-input",false);
         addFeatureFlag("want-steam-achievements",false);
         addFeatureFlag("use-fallback-socket-port",false);
      }
      
      function addFeatureFlag(param1:String, param2:Bool, param3:String = null, param4:String = null) 
      {
         mFeatureFlags[param1] = FeatureFlag.featureFlagFactory(param1,param2,param3,param4);
      }
      
      public function getFlagValue(param1:String) : Bool
      {
         return ASCompat.toBool(mFeatureFlags[param1].currentValue);
      }
      
      public function setFlagDatabaseValueOnFirstLoad(param1:String, param2:Bool) 
      {
         mFeatureFlags[param1].setDbValue(param2);
      }
      
      public function setFlagOverrideValue(param1:String, param2:Bool) 
      {
         mFeatureFlags[param1].setOverrideValue(param2);
      }
      
      public function loadFeatureFlagValuesFromCli(param1:Array<ASAny>) 
      {
         var _loc2_:ASAny;
         var __ax4_iter_56:ASDictionary<ASAny,ASAny>;
         var _loc6_= 0;
         var _loc5_:String = null;
         var _loc8_:ASAny = null;
         var _loc7_= false;
         var _loc3_:String = null;
         var _loc4_:String = null;
         _loc6_ = 0;
         while(_loc6_ < param1.length)
         {
            _loc5_ = param1[_loc6_];
            if(_loc5_.indexOf("--") == 0)
            {
               _loc8_ = null;
               __ax4_iter_56 = mFeatureFlags;
               if (checkNullIteratee(__ax4_iter_56)) for (_tmp_ in __ax4_iter_56)
               {
                  _loc2_ = _tmp_;
                  if(_loc2_.commandLineFlag == _loc5_)
                  {
                     _loc8_ = _loc2_;
                     break;
                  }
               }
               if(_loc8_ != null)
               {
                  _loc7_ = true;
                  if(_loc6_ + 1 < param1.length)
                  {
                     _loc3_ = param1[_loc6_ + 1];
                     _loc4_ = _loc3_.toLowerCase();
                     if(_loc4_ == "true" || _loc4_ == "false")
                     {
                        _loc7_ = _loc4_ == "true";
                        _loc6_++;
                     }
                  }
                  _loc8_.setCliValue(_loc7_);
               }
            }
            _loc6_++;
         }
      }
      
      public function loadFeatureFlagValuesFromConfigs(param1:ConfigManager) 
      {
         var _loc4_:ASObject = null;
         var _loc3_= false;
         var _loc2_:ASAny;
         final __ax4_iter_57 = mFeatureFlags;
         if (checkNullIteratee(__ax4_iter_57)) for (_tmp_ in __ax4_iter_57)
         {
            _loc2_ = _tmp_;
            _loc4_ = param1.getConfigObject(_loc2_.configFileAttributeName,null);
            if(_loc4_ != null)
            {
               _loc3_ = ASCompat.asBool(_loc4_ );
               _loc2_.setConfigFileValue(_loc3_);
            }
         }
      }
      
      public function logFeatureFlagNamesAndValues() 
      {
         var _loc1_:ASAny;
         final __ax4_iter_58 = mFeatureFlags;
         if (checkNullIteratee(__ax4_iter_58)) for (_tmp_ in __ax4_iter_58)
         {
            _loc1_ = _tmp_;
            Logger.log("Flag Name: " + Std.string(_loc1_.name) + " Flag Value:" + getFlagValue(_loc1_.name));
         }
      }
   }


