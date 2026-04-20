package uI.popup
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import flash.display.MovieClip;
   import flash.net.URLRequest;
   
    class UIWhatsNewPopup extends DBUITwoButtonPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      var mPopUpClassName:String = "whatsnew_popup";
      
      var mImageURL:String;
      
      var mImageLocator:MovieClip;
      
      var massetLoadingComponent:AssetLoadingComponent;
      
      var mLoadingPopUp:DBUIPopup;
      
      var mImageRetreived:Bool = false;
      
      var mUseCurtain:Bool = true;
      
      public function new(param1:DBFacade, param2:String, param3:String, param4:String, param5:String, param6:String, param7:ASFunction, param8:String, param9:String, param10:Bool)
      {
         var webCallback:ASFunction = null;
         var dbFacade= param1;
         var popupClassName= param2;
         var titleText= param3;
         var messageText= param4;
         var imageURL= param5;
         var mainText= param6;
         var mainCallback= param7;
         var webText= param8;
         var webURL= param9;
         var showPagination= param10;
         massetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mImageURL = imageURL;
         mPopUpClassName = popupClassName;
         if(ASCompat.stringAsBool(webURL))
         {
            webCallback = function()
            {
               var _loc1_= new URLRequest(webURL);
               flash.Lib.getURL(_loc1_,"_blank");
            };
         }
         mUseCurtain = !showPagination;
         super(dbFacade,titleText,messageText,mainText,mainCallback,webText,webCallback);
         if(!mImageRetreived)
         {
            mLoadingPopUp = new DBUIPopup(mDBFacade,"LOADING");
            MemoryTracker.track(mLoadingPopUp,"DBUIPopup - created in UIWhatsNewPopup.UIWhatsNewPopup()");
         }
         if(!showPagination)
         {
            ASCompat.setProperty((mPopup : ASAny).left_button_news, "visible", false);
            ASCompat.setProperty((mPopup : ASAny).pagination, "visible", false);
         }
         else
         {
            ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
            mLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).left_button_news, flash.display.MovieClip));
            mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mLeftButton.label.text = mLeftText;
            mLeftButton.releaseCallback = function()
            {
               close(mLeftCallback);
            };
         }
      }
      
      override function animatedEntrance() 
      {
         if(mUseCurtain)
         {
            super.animatedEntrance();
         }
      }
      
      override public function getPagination() : MovieClip
      {
         return ASCompat.dynamicAs((mPopup : ASAny).pagination, flash.display.MovieClip);
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return mPopUpClassName;
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText.toUpperCase(),content,allowClose,closeCallback);
         Logger.debug("MOD: mPopup: " + mPopup);
         mImageLocator = ASCompat.dynamicAs((mPopup : ASAny).whatsnew_image, flash.display.MovieClip);
         Logger.debug("MOD: ImageLocator: " + mImageLocator);
         massetLoadingComponent.getImageAsset(mImageURL,function(param1:brain.assetRepository.ImageAsset)
         {
            if(mLoadingPopUp != null)
            {
               mLoadingPopUp.destroy();
               mLoadingPopUp = null;
            }
            Logger.debug("MOD: ImageAsset: " + param1);
            mImageLocator.addChild(param1.image);
            param1.image.x = param1.image.width * -0.5;
            param1.image.y = param1.image.height * -0.5;
            mImageRetreived = true;
         },function()
         {
            if(mLoadingPopUp != null)
            {
               mLoadingPopUp.destroy();
               mLoadingPopUp = null;
            }
         });
      }
      
      override public function destroy() 
      {
         if(massetLoadingComponent != null)
         {
            massetLoadingComponent.destroy();
            massetLoadingComponent = null;
         }
         super.destroy();
         mImageLocator = null;
      }
   }


