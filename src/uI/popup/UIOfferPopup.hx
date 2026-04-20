package uI.popup
;
   import brain.assetRepository.SwfAsset;
   import brain.uI.UIButton;
   import facade.DBFacade;
   import gameMasterDictionary.GMOffer;
   import uI.*;
   import uI.shop.UIShopBundleOffer;
   import uI.shop.UIShopOffer;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   
    class UIOfferPopup extends DBUIPopup
   {
      
      static inline final TEMPLATE_CLASSNAME= "shop_offer_template";
      
      static inline final PREMIUM_TEMPLATE_CLASSNAME= "shop_offer_premium_template";
      
      static inline final DLC_TEMPLATE_CLASSNAME= "shop_offer_dlc_template";
      
      static inline final POPUP_CLASS_NAME= "coin_purchase_popup";
      
      var mOfferIds:Vector<UInt>;
      
      var mBuyCallback:ASFunction;
      
      var mOfferTemplateClass:Dynamic;
      
      var mPremiumOfferTemplateClass:Dynamic;
      
      var mDLCOfferTemplateClass:Dynamic;
      
      var mUIOffers:Vector<UIShopOffer> = new Vector();
      
      var mEmptyOffers:Vector<MovieClip> = new Vector();
      
      var mUseIconScaling:Bool = false;
      
      var mWantNewRollOverScale:Bool = false;
      
      public function new(param1:DBFacade, param2:String, param3:Vector<UInt>, param4:ASFunction, param5:ASFunction, param6:Bool = true, param7:Bool = true)
      {
         mOfferIds = param3;
         mBuyCallback = param4;
         mUseIconScaling = param6;
         mWantNewRollOverScale = param7;
         super(param1,param2,null,true,true,param5);
      }
      
      override public function destroy() 
      {
         mBuyCallback = null;
         mUIOffers = null;
         mEmptyOffers = null;
         mOfferTemplateClass = null;
         super.destroy();
      }
      
      override function getClassName() : String
      {
         return "coin_purchase_popup";
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var bounds:Rectangle;
         var offerId:UInt;
         var emptyOffer:MovieClip;
         var gmOffer:GMOffer;
         var uiShopOffer:UIShopBundleOffer;
         var offerClass:Dynamic;
         var i:UInt;
         var callback:GMOffer->Void;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         var popupClass= swfAsset.getClass(this.getClassName());
         mPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
         mRoot.addChild(mPopup);
         mPopup.scaleY = mPopup.scaleX = 1.8;
         bounds = mPopup.getBounds(mDBFacade.stageRef);
         mPopup.x = mDBFacade.stageRef.stageWidth / 2 - bounds.width / 2 - bounds.x;
         mPopup.y = mDBFacade.stageRef.stageHeight / 2 - bounds.height / 2 - bounds.y;
         mTitle = ASCompat.dynamicAs((mPopup : ASAny).title_label, flash.text.TextField);
         mTitle.text = titleText;
         mEmptyOffers.push(ASCompat.dynamicAs((mPopup : ASAny).coin_shop_empty_slot_1, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mPopup : ASAny).coin_shop_empty_slot_2, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mPopup : ASAny).coin_shop_empty_slot_3, flash.display.MovieClip));
         mOfferTemplateClass = swfAsset.getClass("shop_offer_template");
         mPremiumOfferTemplateClass = swfAsset.getClass("shop_offer_premium_template");
         mDLCOfferTemplateClass = swfAsset.getClass("shop_offer_dlc_template");
         i = (0 : UInt);
         while(i < (mOfferIds.length : UInt))
         {
            callback = function(param1:GMOffer)
            {
               close(mBuyCallback,param1);
            };
            offerId = mOfferIds[(i : Int)];
            gmOffer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(offerId), gameMasterDictionary.GMOffer);
            offerClass = gmOffer.CurrencyType == "PREMIUM" && ASCompat.floatAsBool(gmOffer.Price) ? mPremiumOfferTemplateClass : mOfferTemplateClass;
            uiShopOffer = new UIShopBundleOffer(mDBFacade,offerClass,callback,mUseIconScaling,mWantNewRollOverScale);
            emptyOffer = mEmptyOffers[(i : Int)];
            emptyOffer.parent.addChild(uiShopOffer.root);
            uiShopOffer.root.x = emptyOffer.x;
            uiShopOffer.root.y = emptyOffer.y;
            mUIOffers[(i : Int)] = uiShopOffer;
            uiShopOffer.showOffer(gmOffer,null);
            uiShopOffer.root.visible = true;
            mEmptyOffers[(i : Int)].visible = false;
            i = i + 1;
         }
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = function()
         {
            close(closeCallback);
         };
         animatedEntrance();
      }
   }


