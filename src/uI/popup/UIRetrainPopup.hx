package uI.popup
;
   import brain.assetRepository.SwfAsset;
   import facade.DBFacade;
   import facade.Locale;
   
    class UIRetrainPopup extends DBUITwoButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final POPUP_CLASS_NAME= "popup_retrain";
      
      var mPrice:UInt = 0;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:UInt)
      {
         mPrice = param3;
         super(param1,Locale.getString("RETRAIN_POPUP_TITLE"),Locale.getString("RETRAIN_POPUP_MESSAGE"),Locale.getString("RETRAIN_BUY"),param2,Locale.getString("CANCEL"),null,true,null,true,true,"RETRAIN_POPUP");
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         super.setupUI(param1,param2,param3,param4,param5);
         mLeftButton.label.text = Std.string(mPrice);
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override function getClassName() : String
      {
         return "popup_retrain";
      }
      
      override function setupMenuNavigation() 
      {
         mCloseButton.clearNavigationAndInteractions();
         mLeftButton.clearNavigationAndInteractions();
         mRightButton.clearNavigationAndInteractions();
         mRightButton.isToTheLeftOf(mLeftButton);
         mCloseButton.isAbove(mRightButton);
         mLeftButton.upNavigation = mCloseButton;
         mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,mCloseCallback,mCloseButton);
      }
   }


