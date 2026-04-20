package uI.popup
;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
    class DBUIConfirmChestPurchasePopup extends UIObject
   {
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mChestOffer:GMOffer;
      
      var mSelectedHeroSkin:GMSkin;
      
      var mCloseButton:UIButton;
      
      var mCancelButton:UIButton;
      
      var mBuyButton:UIButton;
      
      var mTitleLabel:TextField;
      
      var mHeroLabel:TextField;
      
      var mTextContentLabel:TextField;
      
      var mItemIcon:MovieClip;
      
      var mAvatarIcon:MovieClip;
      
      var mBuyCallback:ASFunction;
      
      var mCloseCallback:ASFunction;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:ASFunction, param4:ASFunction, param5:GMOffer, param6:UInt, param7:Bool = true, param8:ASFunction = null)
      {
         super(param1,param2);
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mSceneGraphComponent = new SceneGraphComponent(mFacade,"DBUIConfirmChestPurchasePopup");
         mChestOffer = param5;
         mCloseCallback = param4;
         mBuyCallback = param3;
         mSelectedHeroSkin = ASCompat.dynamicAs(param1.gameMaster.skinsById.itemFor(param6) , GMSkin);
         if(mSelectedHeroSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin id: " + param6);
         }
         setupGui();
      }
      
      function setupGui() 
      {
         mCloseButton = new UIButton(mFacade,ASCompat.dynamicAs((mRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = mCloseCallback;
         mCancelButton = new UIButton(mFacade,ASCompat.dynamicAs((mRoot : ASAny).button_cancel, flash.display.MovieClip));
         mCancelButton.releaseCallback = mCloseCallback;
         mCancelButton.label.text = Locale.getString("CANCEL");
         mBuyButton = new UIButton(mFacade,ASCompat.dynamicAs((mRoot : ASAny).buy_button_gems, flash.display.MovieClip));
         mBuyButton.releaseCallback = mBuyCallback;
         mBuyButton.label.text = Std.string(mChestOffer.Price);
         ASCompat.setProperty((mBuyButton.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButton.root : ASAny).icons_bundle.coin, "visible", false);
         ASCompat.setProperty((mBuyButton.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButton.root : ASAny).strike, "visible", false);
         mTitleLabel = ASCompat.dynamicAs((mRoot : ASAny).label, flash.text.TextField);
         mTitleLabel.text = Locale.getString("CONFIRM_SHOP_CHEST_PURCHASE");
         mItemIcon = ASCompat.dynamicAs((mRoot : ASAny).icon_slot, flash.display.MovieClip);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mChestOffer.BundleSwfFilepath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass(mChestOffer.BundleIcon);
            var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            mItemIcon.addChild(_loc2_);
         });
         mHeroLabel = ASCompat.dynamicAs((mRoot : ASAny).hero_label, flash.text.TextField);
         mHeroLabel.text = Locale.getString("OPENING_WITH");
         mTextContentLabel = ASCompat.dynamicAs((mRoot : ASAny).text, flash.text.TextField);
         mTextContentLabel.text = Locale.getString("PURCHASE_AND_OPEN_CHEST_TEXT_CONTENT");
         mAvatarIcon = ASCompat.dynamicAs((mRoot : ASAny).avatar, flash.display.MovieClip);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mSelectedHeroSkin.IconSwfFilepath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass(mSelectedHeroSkin.IconName);
            var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
            mAvatarIcon.addChild(_loc3_);
         });
         mSceneGraphComponent.addChild(mRoot,(105 : UInt));
         mSceneGraphComponent.showPopupCurtain();
         mRoot.x = mFacade.viewWidth * 0.5;
         mRoot.y = mFacade.viewHeight * 0.5 - 50;
      }
      
      function close() 
      {
         this.destroy();
      }
      
      override public function destroy() 
      {
         super.destroy();
         if(mCloseButton != null)
         {
            mCloseButton.destroy();
            mCloseButton = null;
         }
         if(mCancelButton != null)
         {
            mCancelButton.destroy();
            mCancelButton = null;
         }
         if(mBuyButton != null)
         {
            mBuyButton.destroy();
            mBuyButton = null;
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.removePopupCurtain();
            mSceneGraphComponent.removeChild(mRoot);
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
      }
   }


