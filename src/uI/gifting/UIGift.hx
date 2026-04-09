package uI.gifting
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.sceneGraph.SceneGraphManager;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import facade.Locale;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   
    class UIGift
   {
      
      public static inline final GIFT_POPUP_CLASS_NAME= "gift_popup";
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mTownRoot:MovieClip;
      
      var mGiftPopup:MovieClip;
      
      var mCurtainActive:Bool = false;
      
      var mCloseCallback:ASFunction;
      
      var mStoreCallback:ASFunction;
      
      var mCloseButton:UIButton;
      
      var mAcceptAllGiftsButton:UIButton;
      
      var mSendGiftButton:UIButton;
      
      var mScrollUpButton:UIButton;
      
      var mScrollDownButton:UIButton;
      
      var mScrollIndex:Int = 0;
      
      var mGiftsVector:Vector<UIGiftMessage>;
      
      var mInfoMessageTF:TextField;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ASFunction, param4:ASFunction)
      {
         
         mDBFacade = param1;
         mTownRoot = param2;
         mCloseCallback = param3;
         mStoreCallback = param4;
         mGiftsVector = new Vector<UIGiftMessage>();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),giftPopupLoaded);
         mDBFacade.stageRef.addEventListener("keyDown",handleKeyDown);
      }
      
      function giftPopupLoaded(param1:SwfAsset) 
      {
         var swfAsset= param1;
         var popupClass= swfAsset.getClass("gift_popup");
         mGiftPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
         ASCompat.setProperty((mGiftPopup : ASAny).title_label, "text", Locale.getString("GIFT_POPUP_TITLE"));
         mGiftPopup.scaleY = mGiftPopup.scaleX = 1.8;
         mGiftPopup.x = 300;
         mSendGiftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).left_button, flash.display.MovieClip));
         mSendGiftButton.label.text = Locale.getString("GIFT_POPUP_SEND_GIFT");
         mSendGiftButton.releaseCallback = function()
         {
            if(mStoreCallback != null)
            {
               mStoreCallback();
            }
         };
         mAcceptAllGiftsButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).right_button, flash.display.MovieClip));
         mAcceptAllGiftsButton.label.text = Locale.getString("GIFT_POPUP_ACCEPT_ALL");
         if(mDBFacade.dbAccountInfo.gifts.size > 0)
         {
            mAcceptAllGiftsButton.releaseCallback = function()
            {
               mDBFacade.dbAccountInfo.acceptAllGifts(refresh);
            };
         }
         else
         {
            mAcceptAllGiftsButton.enabled = false;
            SceneGraphManager.setGrayScaleSaturation(mAcceptAllGiftsButton.root,10);
         }
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = this.destroy;
         mGiftsVector.push(new UIGiftMessage(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).message_1, flash.display.MovieClip),this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).message_2, flash.display.MovieClip),this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).message_3, flash.display.MovieClip),this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).message_4, flash.display.MovieClip),this));
         mGiftsVector.push(new UIGiftMessage(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).message_5, flash.display.MovieClip),this));
         mScrollUpButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).up, flash.display.MovieClip));
         mScrollDownButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mGiftPopup : ASAny).down, flash.display.MovieClip));
         if(mDBFacade.dbAccountInfo.gifts.size < (mGiftsVector.length : UInt))
         {
            mScrollDownButton.visible = false;
            mScrollUpButton.visible = false;
         }
         mScrollUpButton.releaseCallback = function()
         {
            scrollIndex = -1;
         };
         mScrollDownButton.releaseCallback = function()
         {
            scrollIndex = 1;
         };
         mScrollIndex = 0;
         mSceneGraphComponent.addChild(mGiftPopup,(105 : UInt));
         showCurtain();
         scrollIndex = 0;
         mInfoMessageTF = ASCompat.dynamicAs((mGiftPopup : ASAny).message_label, flash.text.TextField);
         mInfoMessageTF.text = Locale.getString("GIFT_POPUP_INFO_MESSAGE");
      }
      
      function showCurtain() 
      {
         if(!mCurtainActive)
         {
            mCurtainActive = true;
            mSceneGraphComponent.showPopupCurtain();
         }
      }
      
      function removeCurtain() 
      {
         if(mCurtainActive)
         {
            mCurtainActive = false;
            mSceneGraphComponent.removePopupCurtain();
         }
      }
      
      function populateGiftMessages() 
      {
         var _loc2_= 0;
         var _loc3_= 0;
         var _loc1_= mDBFacade.dbAccountInfo.gifts.keysToArray();
         if(_loc1_.length < mGiftsVector.length)
         {
            hideGiftMessages();
         }
         _loc2_ = 0;
         while(_loc2_ < mGiftsVector.length)
         {
            _loc3_ = ASCompat.toInt(_loc2_ + mScrollIndex);
            if(_loc3_ >= _loc1_.length)
            {
               break;
            }
            mGiftsVector[_loc2_].root.visible = true;
            mGiftsVector[_loc2_].populateGiftMessage(ASCompat.dynamicAs(mDBFacade.dbAccountInfo.gifts.itemFor(_loc1_[_loc3_]), account.GiftInfo));
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      @:isVar public var scrollIndex(never,set):Int;
public function  set_scrollIndex(param1:Int) :Int      {
         mScrollIndex += param1;
         var _loc2_= (0 : UInt);
         if(mDBFacade.dbAccountInfo.gifts.size > (mGiftsVector.length : UInt))
         {
            _loc2_ = (mDBFacade.dbAccountInfo.gifts.size - mGiftsVector.length : UInt);
         }
         if(mScrollIndex <= 0)
         {
            mScrollIndex = 0;
         }
         if((mScrollIndex : UInt) >= _loc2_)
         {
            mScrollIndex = (_loc2_ : Int);
         }
         if(mScrollIndex == 0)
         {
            mScrollUpButton.enabled = false;
         }
         else
         {
            mScrollUpButton.enabled = true;
         }
         if((mScrollIndex : UInt) == _loc2_)
         {
            mScrollDownButton.enabled = false;
         }
         else
         {
            mScrollDownButton.enabled = true;
         }
         populateGiftMessages();
return param1;
      }
      
      function hideGiftMessages() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mGiftsVector.length)
         {
            mGiftsVector[_loc1_].root.visible = false;
            _loc1_ = ASCompat.toInt(_loc1_) + 1;
         }
      }
      
      public function refresh() 
      {
         populateGiftMessages();
         if(mDBFacade.dbAccountInfo.gifts.size == 0)
         {
            destroy();
         }
      }
      
      function handleKeyDown(param1:KeyboardEvent) 
      {
         if(param1.keyCode == 27)
         {
            this.destroy();
         }
      }
      
      public function destroy() 
      {
         mDBFacade.stageRef.removeEventListener("keyDown",handleKeyDown);
         mDBFacade = null;
         if(mGiftPopup != null)
         {
            mSceneGraphComponent.removeChild(mGiftPopup);
         }
         removeCurtain();
         mGiftPopup = null;
         mTownRoot = null;
         mStoreCallback = null;
         if(mCloseButton != null)
         {
            mCloseButton.destroy();
         }
         mCloseButton = null;
         if(mAcceptAllGiftsButton != null)
         {
            mAcceptAllGiftsButton.root.filters = cast([]);
            mAcceptAllGiftsButton.destroy();
         }
         mAcceptAllGiftsButton = null;
         if(mSendGiftButton != null)
         {
            mSendGiftButton.destroy();
         }
         mSendGiftButton = null;
         var _loc1_:ASAny;
         final __ax4_iter_18 = mGiftsVector;
         if (checkNullIteratee(__ax4_iter_18)) for (_tmp_ in __ax4_iter_18)
         {
            _loc1_ = _tmp_;
            _loc1_.destroy();
            _loc1_ = null;
         }
         mGiftsVector.splice(0,(mGiftsVector.length : UInt));
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mCloseCallback != null)
         {
            mCloseCallback();
         }
         mCloseCallback = null;
      }
   }


