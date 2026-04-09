package uI
;
   import brain.assetRepository.SwfAsset;
   import facade.DBFacade;
   import facade.Locale;
   import flash.desktop.NativeApplication;
   
    class UIExitPopup extends DBUITwoButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final POPUP_CLASS_NAME= "popup_exit";
      
      public function new(param1:DBFacade)
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         var _loc2_:String = null;
         var _loc5_:ASFunction = null;
         var _loc8_:String = null;
         var _loc3_:ASFunction = null;
         var _loc7_= param1.dbConfigManager.getConfigBoolean("show_wishlist_on_exit_popup",false);
         if(_loc7_)
         {
            _loc4_ = Locale.getString("EXIT_POPUP_TITLE");
            _loc6_ = Locale.getString("EXIT_POPUP_MESSAGE_CALL_TO_ACTION");
            _loc2_ = Locale.getString("EXIT_WISHLIST");
            _loc5_ = wishlistAction;
            _loc8_ = Locale.getString("EXIT_GAME");
            _loc3_ = exitApplicationAction;
         }
         else
         {
            _loc4_ = Locale.getString("EXIT_POPUP_TITLE_CHICKEN_OUT");
            _loc6_ = Locale.getString("EXIT_POPUP_MESSAGE");
            _loc2_ = Locale.getString("EXIT_GAME_GIVE_UP");
            _loc5_ = exitApplicationAction;
            _loc8_ = Locale.getString("EXIT_KEEP_PLAYING");
            _loc3_ = closePopupAction;
         }
         super(param1,_loc4_,_loc6_,_loc2_,_loc5_,_loc8_,_loc3_,true,null);
      }
      
      function wishlistAction() 
      {
         mDBFacade.openSteamPage();
      }
      
      function exitApplicationAction() 
      {
         NativeApplication.nativeApplication.exit();
      }
      
      function closePopupAction() 
      {
         this.destroy();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         super.setupUI(param1,param2,param3,param4,param5);
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override function getClassName() : String
      {
         return "popup_exit";
      }
   }


