package uI.popup
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMOffer;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
    class DBUIPopup extends UIObject
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_town.swf";
      
      static inline final POPUP_CLASS_NAME= "popup";
      
      static inline final EMPTY_POPUP_CLASS_NAME= "UI_loading_popup";
      
      static inline final CURTAIN_ALPHA:Float = 0.75;
      
      var mUseOriginalPopUp:Bool = false;
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mWantCurtain:Bool = false;
      
      var mCurtainActive:Bool = false;
      
      var mTitle:TextField;
      
      var mMessage:TextField;
      
      var mContent:Sprite;
      
      var mCloseButton:UIButton;
      
      var mCloseCallback:ASFunction;
      
      var mPopup:MovieClip;
      
      var mSwfAsset:SwfAsset;
      
      var mScalePopup:Bool = false;
      
      var mUILayerName:String;
      
      public function new(param1:DBFacade, param2:String = "", param3:ASAny = null, param4:Bool = true, param5:Bool = true, param6:ASFunction = null, param7:Bool = false, param8:Bool = true, param9:String = "")
      {
         var dbFacade= param1;
         
         mDBFacade = dbFacade;
      
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var wantCurtain= param5;
         var closeCallback= param6;
         var useOriginalPopUp= param7;
         var scalePopup= param8;
         var UILayerName= param9;
         super(dbFacade,new MovieClip());
         mUseOriginalPopUp = useOriginalPopUp;
         mScalePopup = scalePopup;
         mWantCurtain = wantCurtain;
         makeCurtain();
         if(allowClose)
         {
            mCloseCallback = closeCallback;
            mDBFacade.stageRef.addEventListener("keyDown",handleKeyDown);
         }
         mUILayerName = UILayerName;
         mDBFacade.sceneGraphManager.addChild(mRoot,105);
         mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(getSwfPath()),function(param1:SwfAsset)
         {
            setupUI(param1,titleText,content,allowClose,closeCallback);
         });
      }
      
      public function getPagination() : MovieClip
      {
         Logger.error("Pagination for UIPopup shouldn\'t be available here.");
         return null;
      }
      
      function useCurtain() : Bool
      {
         return true;
      }
      
      function makeCurtain() 
      {
         if(!mCurtainActive)
         {
            mFacade.sceneGraphManager.showPopupCurtain();
            mCurtainActive = true;
         }
      }
      
      function removeCurtain() 
      {
         if(mCurtainActive)
         {
            mCurtainActive = false;
            mFacade.sceneGraphManager.removePopupCurtain();
         }
      }
      
      function animatedEntrance() 
      {
         makeCurtain();
      }
      
      override public function destroy() 
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(ASCompat.stringAsBool(mUILayerName))
         {
            popMenuNavigationLayer();
         }
         TweenMax.killTweensOf(mRoot);
         removeCurtain();
         mDBFacade.stageRef.removeEventListener("keyDown",handleKeyDown);
         mDBFacade = null;
         mCloseCallback = null;
         if(mCloseButton != null)
         {
            mCloseButton.destroy();
         }
         mAssetLoadingComponent.destroy();
         mPopup = null;
         super.destroy();
      }
      
      function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      function getClassName() : String
      {
         return mUseOriginalPopUp ? "popup" : "UI_loading_popup";
      }
      
      public function colorizeMessage(param1:TextFormat, param2:Int, param3:Int) 
      {
         mMessage.setTextFormat(param1,param2,param3);
      }
      
      function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         mSwfAsset = swfAsset;
         var popupClass= swfAsset.getClass(this.getClassName());
         mPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []) , MovieClip);
         mRoot.addChild(mPopup);
         if(ASCompat.toBool((mPopup : ASAny).message_label))
         {
            ASCompat.setProperty((mPopup : ASAny).message_label, "mouseEnabled", false);
         }
         if(ASCompat.toBool((mPopup : ASAny).left_button))
         {
            ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
         }
         if(ASCompat.toBool((mPopup : ASAny).center_button))
         {
            ASCompat.setProperty((mPopup : ASAny).center_button, "visible", false);
         }
         if(ASCompat.toBool((mPopup : ASAny).right_button))
         {
            ASCompat.setProperty((mPopup : ASAny).right_button, "visible", false);
         }
         if(ASCompat.toBool((mPopup : ASAny).title_label))
         {
            mTitle = ASCompat.dynamicAs((mPopup : ASAny).title_label, flash.text.TextField);
            mTitle.text = titleText;
         }
         if(ASCompat.toBool((mPopup : ASAny).message_label))
         {
            mMessage = ASCompat.dynamicAs((mPopup : ASAny).message_label, flash.text.TextField);
            mMessage.text = "";
         }
         if(Std.isOfType(content , MovieClip))
         {
            mContent = ASCompat.dynamicAs((mPopup : ASAny).content, flash.display.Sprite);
            mContent.addChild(ASCompat.dynamicAs(content, flash.display.DisplayObject));
         }
         else if(Std.isOfType(content , String))
         {
            mMessage.text = content;
         }
         if(ASCompat.toBool((mPopup : ASAny).close))
         {
            if(allowClose)
            {
               mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).close, flash.display.MovieClip));
               mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
               mCloseButton.releaseCallback = function()
               {
                  close(closeCallback);
               };
            }
            else
            {
               ASCompat.setProperty((mPopup : ASAny).close, "visible", false);
            }
         }
         if(mScalePopup)
         {
            scalePopup();
            centerPopup();
         }
         if(mWantCurtain)
         {
            animatedEntrance();
         }
         if(ASCompat.stringAsBool(mUILayerName))
         {
            initializeMenuNavigationLayer();
         }
      }
      
      function handleKeyDown(param1:KeyboardEvent) 
      {
      }
      
      function handleInputCalledClosed() 
      {
         this.close(mCloseCallback);
      }
      
      function close(param1:ASFunction, param2:GMOffer = null) 
      {
         if(param1 != null)
         {
            if(param2 == null)
            {
               param1();
            }
            else
            {
               param1(param2.getDisplayName(mDBFacade.gameMaster,Locale.getString("GIFT_UNKNOWN_NAME")),param2.Id);
            }
         }
         this.destroy();
      }
      
      function scalePopup() 
      {
         mPopup.scaleX = mPopup.scaleY = 1.8;
      }
      
      function centerPopup() 
      {
         var _loc1_= mPopup.getBounds(mDBFacade.stageRef);
         mPopup.x = mDBFacade.stageRef.stageWidth / 2 - _loc1_.width / 2 - _loc1_.x;
         mPopup.y = mDBFacade.stageRef.stageHeight / 2 - _loc1_.height / 2 - _loc1_.y;
      }
      
      function initializeMenuNavigationLayer() 
      {
         mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,mCloseCallback,mCloseButton);
      }
      
      function popMenuNavigationLayer() 
      {
         mDBFacade.menuNavigationController.popLayer(mUILayerName);
      }
      
      function setupMenuNavigation() 
      {
      }
   }


