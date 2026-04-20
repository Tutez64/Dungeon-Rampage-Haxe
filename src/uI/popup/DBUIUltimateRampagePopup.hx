package uI.popup
;
   import facade.DBFacade;
   import facade.Locale;
   
    class DBUIUltimateRampagePopup extends DBUIPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_map.swf";
      
      static inline final POPUP_CLASS_NAME= "ultimate_rampage_popup";
      
      public function new(param1:DBFacade)
      {
         var _loc3_= Locale.getString("INFINITE_MAP_POPUP_TITLE");
         var _loc2_= Locale.getString("INFINITE_MAP_POPUP_MESSAGE");
         super(param1,_loc3_,_loc2_);
         ASCompat.setProperty((mPopup : ASAny).message_label1, "text", Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_1"));
         ASCompat.setProperty((mPopup : ASAny).message_label2, "text", Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_2"));
         ASCompat.setProperty((mPopup : ASAny).message_label3, "text", Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_3"));
         ASCompat.setProperty((mPopup : ASAny).message_label4, "text", Locale.getString("INFINITE_MAP_POPUP_MESSAGE_LABEL_4"));
      }
      
      override function getClassName() : String
      {
         return "ultimate_rampage_popup";
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_map.swf";
      }
   }


