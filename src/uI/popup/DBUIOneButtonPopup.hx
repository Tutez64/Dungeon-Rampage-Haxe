package uI.popup
;
   import brain.assetRepository.SwfAsset;
   import brain.uI.UIButton;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   
    class DBUIOneButtonPopup extends DBUIPopup
   {
      
      var mCenterButton:UIButton;
      
      var mCenterCallback:ASFunction;
      
      var mCenterText:String;
      
      var mClassOverride:String;
      
      var mSwfOverride:String;
      
      public function new(param1:DBFacade, param2:String, param3:ASAny, param4:String, param5:ASFunction, param6:Bool = true, param7:ASFunction = null, param8:String = null, param9:String = null, param10:Bool = true, param11:String = "")
      {
         mClassOverride = param8;
         mSwfOverride = param9;
         mCenterText = param4;
         mCenterCallback = param5;
         super(param1,param2,param3,param6,true,param7,true,param10,param11);
      }
      
      override public function destroy() 
      {
         if(mCenterButton != null)
         {
            mCenterButton.destroy();
            mCenterButton = null;
         }
         mCenterCallback = null;
         super.destroy();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         super.setupUI(param1,param2,param3,param4,param5);
         if(ASCompat.stringAsBool(mCenterText))
         {
            ASCompat.setProperty((mPopup : ASAny).center_button, "visible", true);
            mCenterButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).center_button, flash.display.MovieClip));
            mCenterButton.label.text = mCenterText;
            mCenterButton.releaseCallback = this.centerButtonCallback;
            mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            setupMenuNavigation();
         }
         else if(ASCompat.toBool((mPopup : ASAny).center_button))
         {
            ASCompat.setProperty((mPopup : ASAny).center_button, "visible", false);
         }
      }
      
      function centerButtonCallback() 
      {
         this.close(mCenterCallback);
      }
      
      override function getClassName() : String
      {
         if(ASCompat.stringAsBool(mClassOverride))
         {
            return mClassOverride;
         }
         return "popup";
      }
      
      override function getSwfPath() : String
      {
         if(ASCompat.stringAsBool(mSwfOverride))
         {
            return mSwfOverride;
         }
         return super.getSwfPath();
      }
      
      override function setupMenuNavigation() 
      {
         if(mCloseButton != null)
         {
            mCloseButton.isAbove(mCenterButton);
            mCenterButton.isToTheLeftOf(mCloseButton);
         }
      }
   }


