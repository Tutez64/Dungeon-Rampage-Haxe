package uI
;
   import brain.assetRepository.SwfAsset;
   import facade.DBFacade;
   import facade.Locale;
   
    class UIStorageFullPopup extends DBUITwoButtonPopup
   {
      
      public static inline final STORAGE_POPUP_CLASS_NAME= "popup_add_storage";
      
      public function new(param1:DBFacade, param2:String, param3:ASAny, param4:String, param5:ASFunction, param6:String, param7:ASFunction, param8:Bool = true, param9:ASFunction = null)
      {
         super(param1,param2,param3,param4,param5,param6,param7,param8,param9);
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         super.setupUI(param1,param2,param3,param4,param5);
         ASCompat.setProperty((mPopup : ASAny).title_label, "text", Locale.getString("STORAGE_FULL_TITLE"));
         ASCompat.setProperty((mPopup : ASAny).message_label, "text", Locale.getString("STORAGE_FULL_DESCRIPTION"));
      }
      
      override function getClassName() : String
      {
         return "popup_add_storage";
      }
   }


