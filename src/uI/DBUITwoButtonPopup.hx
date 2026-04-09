package uI
;
   import brain.assetRepository.SwfAsset;
   import brain.uI.UIButton;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   
    class DBUITwoButtonPopup extends DBUIPopup
   {
      
      var mLeftButton:UIButton;
      
      var mLeftCallback:ASFunction;
      
      var mLeftText:String;
      
      var mRightButton:UIButton;
      
      var mRightCallback:ASFunction;
      
      var mRightText:String;
      
      public function new(param1:DBFacade, param2:String, param3:ASAny, param4:String, param5:ASFunction, param6:String, param7:ASFunction, param8:Bool = true, param9:ASFunction = null)
      {
         mLeftText = param4;
         mLeftCallback = param5;
         mRightText = param6;
         mRightCallback = param7;
         super(param1,param2,param3,param8,useCurtain(),param9);
      }
      
      override public function destroy() 
      {
         if(mLeftButton != null)
         {
            mLeftButton.destroy();
            mLeftButton = null;
         }
         if(mRightButton != null)
         {
            mRightButton.destroy();
            mRightButton = null;
         }
         mLeftCallback = null;
         mRightCallback = null;
         super.destroy();
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         if(ASCompat.stringAsBool(mLeftText))
         {
            ASCompat.setProperty((mPopup : ASAny).left_button, "visible", true);
            mLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).left_button, flash.display.MovieClip));
            mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mLeftButton.label.text = mLeftText;
            mLeftButton.releaseCallback = function()
            {
               close(mLeftCallback);
            };
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
         }
         if(ASCompat.stringAsBool(mRightText))
         {
            ASCompat.setProperty((mPopup : ASAny).right_button, "visible", true);
            mRightButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).right_button, flash.display.MovieClip));
            mRightButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mRightButton.label.text = mRightText;
            mRightButton.releaseCallback = function()
            {
               close(mRightCallback);
            };
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).right_button, "visible", false);
         }
      }
      
      override function getClassName() : String
      {
         return "popup";
      }
   }


