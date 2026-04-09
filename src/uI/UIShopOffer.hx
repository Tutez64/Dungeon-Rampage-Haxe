package uI
;
   import account.StoreServices;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.sceneGraph.SceneGraphManager;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.utils.MemoryTracker;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMRarity;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   
    class UIShopOffer extends UIObject
   {
      
      static inline final DEFAULT_SHOP_OFFER_SCALE:Float = 1.8;
      
      static inline final SHOP_OFFER_SCALE:Float = 1;
      
      static inline final DEFAULT_ROLL_OVER_SCALE:Float = 1.98;
      
      static inline final ROLL_OVER_SCALE:Float = 1.1;
      
      static inline final DAY_THRESHOLD_TO_ENUMERATE_DAYS_LEFT:Float = 8;
      
      static inline final ONE_DAY_MS:Float = 86400000;
      
      static inline final ONE_HOUR_MS:Float = 3600000;
      
      var mWantNewRollOverScale:Bool = false;
      
      var mDBFacade:DBFacade;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mTitle:TextField;
      
      var mTitleY:Float = Math.NaN;
      
      var mRibbon:MovieClip;
      
      var mLevelStarLabel:TextField;
      
      var mOriginalPrice:TextField;
      
      var mStrikePrice:Sprite;
      
      var mCashIcon:MovieClip;
      
      var mCoinIcon:MovieClip;
      
      var mBuyButton:UIButton;
      
      var mBuyButtonCoin:UIButton;
      
      var mBuyButtonCash:UIButton;
      
      var mExclusiveOfferButton:UIButton;
      
      var mBuyButtonTimerBasedSale:UIButton;
      
      var mGiftIcon:MovieClip;
      
      var mIconParent:UIObject;
      
      var mIcon:MovieClip;
      
      var mBgIcon:MovieClip;
      
      var mBgIconBorder:MovieClip;
      
      var mBg:MovieClip;
      
      var mBgGrey:MovieClip;
      
      var mStar:MovieClip;
      
      var mRenderer:MovieClipRenderController;
      
      var mDescriptionLabel:TextField;
      
      var mLimitLabel:TextField;
      
      var mSaleLabel:TextField;
      
      var mRequiresLabel:TextField;
      
      var mAlreadyOwnedLabel:TextField;
      
      var mBuySuccessCallback:ASFunction;
      
      var mHeroRequiredLabel:MovieClip;
      
      var mGMOffer:GMOffer;
      
      var mSaleOffer:GMOffer;
      
      var mCoinOffer:GMOffer;
      
      var mCoinSaleOffer:GMOffer;
      
      var mGMHero:GMHero;
      
      var mNumSold:UInt = 0;
      
      var mUseIconScaling:Bool = false;
      
      var mStackCountTF:TextField;
      
      public function new(param1:DBFacade, param2:Dynamic, param3:ASFunction = null, param4:Bool = true, param5:Bool = true)
      {
         mDBFacade = param1;
         super(param1,ASCompat.dynamicAs(ASCompat.createInstance(param2, []), flash.display.MovieClip));
         mWantNewRollOverScale = param5;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mTitle = ASCompat.dynamicAs((mRoot : ASAny).offer_title, flash.text.TextField);
         mTitleY = mTitle.y;
         mRibbon = ASCompat.dynamicAs((mRoot : ASAny).ribbon, flash.display.MovieClip);
         mLevelStarLabel = ASCompat.dynamicAs((mRoot : ASAny).level_star_label, flash.text.TextField);
         mOriginalPrice = ASCompat.dynamicAs((mRoot : ASAny).buy_button.original_price, flash.text.TextField);
         mStrikePrice = ASCompat.dynamicAs((mRoot : ASAny).buy_button.strike, flash.display.Sprite);
         mCashIcon = ASCompat.dynamicAs((mRoot : ASAny).buy_button.icons_bundle.cash, flash.display.MovieClip);
         mCoinIcon = ASCompat.dynamicAs((mRoot : ASAny).buy_button.icons_bundle.coin, flash.display.MovieClip);
         mGiftIcon = ASCompat.dynamicAs((mRoot : ASAny).buy_button.icons_bundle.gift_icon, flash.display.MovieClip);
         mStar = ASCompat.dynamicAs((mRoot : ASAny).star, flash.display.MovieClip);
         mBg = ASCompat.dynamicAs((mRoot : ASAny).bg, flash.display.MovieClip);
         mBgGrey = ASCompat.dynamicAs((mRoot : ASAny).bg_grey, flash.display.MovieClip);
         mDescriptionLabel = ASCompat.dynamicAs((mRoot : ASAny).description_label, flash.text.TextField);
         mLimitLabel = ASCompat.dynamicAs((mRoot : ASAny).limit_label, flash.text.TextField);
         mSaleLabel = ASCompat.dynamicAs((mRoot : ASAny).sale_label, flash.text.TextField);
         mRequiresLabel = ASCompat.dynamicAs((mRoot : ASAny).requires_title, flash.text.TextField);
         mUseIconScaling = param4;
         mStackCountTF = ASCompat.dynamicAs((mRoot : ASAny).number_label, flash.text.TextField);
         if(mStackCountTF != null)
         {
            mStackCountTF.visible = false;
         }
         mAlreadyOwnedLabel = ASCompat.dynamicAs((mRoot : ASAny).already_owned_label, flash.text.TextField);
         mAlreadyOwnedLabel.visible = false;
         mHeroRequiredLabel = ASCompat.dynamicAs((mRoot : ASAny).shop_herorequired, flash.display.MovieClip);
         ASCompat.setProperty((mHeroRequiredLabel : ASAny).hero_label, "text", Locale.getString("PURCHASE_HERO_BEFORE_BUYING_SYTLE_TAVERN_LABEL"));
         mHeroRequiredLabel.visible = false;
         if(ASCompat.toBool((mRoot : ASAny).timer))
         {
            ASCompat.setProperty((mRoot : ASAny).timer, "visible", false);
         }
         mBuyButtonCoin = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).buy_button_coins, flash.display.MovieClip));
         mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin.releaseCallback = this.buyButtonCoinCallback;
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.cash, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "visible", false);
         mBuyButtonCash = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).buy_button_gems, flash.display.MovieClip));
         mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCash.releaseCallback = this.buyButtonCallback;
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.coin, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "visible", false);
         mBuyButtonTimerBasedSale = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).buy_button_sale, flash.display.MovieClip));
         mBuyButtonTimerBasedSale.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonTimerBasedSale.releaseCallback = this.buyButtonCallback;
         ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.coin, "visible", false);
         ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "visible", false);
         ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "mouseEnabled", false);
         ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "mouseEnabled", false);
         mBuyButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).buy_button, flash.display.MovieClip));
         mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuySuccessCallback = param3;
         mBuyButton.releaseCallback = this.buyButtonCallback;
         mExclusiveOfferButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).exclusive_offer, flash.display.MovieClip));
         mExclusiveOfferButton.releaseCallback = buyButtonCallback;
         mIconParent = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).icon, flash.display.MovieClip));
         mBuyButtonTimerBasedSale.visible = false;
         if(!mDBFacade.dbConfigManager.getConfigBoolean("want_skins",true))
         {
            ASCompat.setProperty((mRoot : ASAny).required_text, "visible", false);
            ASCompat.setProperty((mRoot : ASAny).shop_herorequired, "visible", false);
         }
      }
      
      function buyButtonCallback() 
      {
         return this.buyButtonInternal(this.offer);
      }
      
      function buyButtonCoinCallback() 
      {
         return this.buyButtonInternal(this.coinOffer);
      }
      
      function buyButtonInternal(param1:GMOffer) 
      {
         var popup:DBUIOneButtonPopup;
         var buyOffer= param1;
         var callback= mBuySuccessCallback;
         if(buyOffer == null)
         {
            return;
         }
         if(IsCashPageExclusiveOffer())
         {
            StoreServicesController.showCashPage(mDBFacade,"shopBuyButtonExclusiveOfferDragonKnight");
         }
         else if(this.canBuyOffer())
         {
            StoreServicesController.tryBuyOffer(mDBFacade,buyOffer,function(param1:ASAny)
            {
               if(mDBFacade != null && buyOffer.Tab != "KEY")
               {
                  showOffer(buyOffer,mGMHero);
               }
               if(callback != null)
               {
                  callback(buyOffer);
               }
            });
         }
         else if(this.canGiftOffer())
         {
            popup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SHOP_GIFT_CONFIRM_TITLE"),Locale.getString("SHOP_GIFT_CONFIRM_DESC"),Locale.getString("OK"),null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIShopOffer.buyOffer()");
            if(callback != null)
            {
               callback(buyOffer);
            }
         }
         else
         {
            Logger.warn("Offer that you cannot buy or gift: " + Std.string(buyOffer.Id));
         }
      }
      
      override public function destroy() 
      {
         mDBFacade = null;
         mBuySuccessCallback = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mBuyButton.destroy();
         mBuyButton = null;
         mExclusiveOfferButton.destroy();
         mExclusiveOfferButton = null;
         mBuyButtonCash.destroy();
         mBuyButtonCash = null;
         mBuyButtonCoin.destroy();
         mBuyButtonCoin = null;
         mBuyButtonTimerBasedSale.destroy();
         mBuyButtonTimerBasedSale = null;
         mIconParent.destroy();
         mIconParent = null;
         mBgIcon = null;
         mIcon = null;
         if(mRenderer != null)
         {
            mRenderer.destroy();
            mRenderer = null;
         }
         super.destroy();
      }
      
      override function onRollOver(param1:MouseEvent) 
      {
         super.onRollOver(param1);
         if(mWantNewRollOverScale)
         {
            mRoot.scaleX = mRoot.scaleY = 1.98;
         }
         else
         {
            mRoot.scaleX = mRoot.scaleY = 1.1;
         }
      }
      
      override function onRollOut(param1:MouseEvent) 
      {
         super.onRollOut(param1);
         if(mWantNewRollOverScale)
         {
            mRoot.scaleX = mRoot.scaleY = 1.8;
         }
         else
         {
            mRoot.scaleX = mRoot.scaleY = 1;
         }
      }
      
      function getQuantityString() : String
      {
         var _loc1_= 0;
         if(this.offer.LimitedQuantity > 0)
         {
            if(mNumSold >= this.offer.LimitedQuantity)
            {
               return Locale.getString("SHOP_SOLD_OUT");
            }
            _loc1_ = (this.offer.LimitedQuantity - mNumSold : Int);
            return Std.string(_loc1_) + Locale.getString("SHOP_REMAINING");
         }
         return "";
      }
      
      function getDateString() : String
      {
         var _loc6_= Math.NaN;
         var _loc2_= Math.NaN;
         var _loc7_= Math.NaN;
         var _loc5_= Math.NaN;
         var _loc1_= Math.NaN;
         var _loc8_= Math.NaN;
         var _loc9_= getStartDate();
         var _loc3_= getEndDate();
         var _loc4_= getSoldOutDate();
         var _loc10_= GameClock.getWebServerTime();
         if(_loc9_ != null)
         {
            _loc6_ = _loc9_.getTime();
            if(_loc6_ > _loc10_)
            {
               return Locale.getString("SHOP_COMING_SOON");
            }
         }
         if(_loc4_ != null)
         {
            _loc2_ = _loc4_.getTime();
            if(_loc2_ < _loc10_)
            {
               return Locale.getString("SHOP_SOLD_OUT");
            }
         }
         if(_loc3_ != null)
         {
            _loc7_ = _loc3_.getTime();
            if(_loc7_ < _loc10_)
            {
               return Locale.getString("SHOP_SOLD_OUT");
            }
            _loc5_ = _loc7_ - _loc10_;
            _loc1_ = _loc5_ / 86400000;
            if(_loc1_ > 8)
            {
               return Locale.getString("LIMITED_TIME_OFFER");
            }
            if(_loc1_ > 2)
            {
               return Std.string(Math.ffloor(_loc1_)) + Locale.getString("SHOP_DAYS_LEFT");
            }
            if(_loc1_ > 1)
            {
               return Std.string(Math.ffloor(_loc1_)) + Locale.getString("SHOP_DAY_LEFT");
            }
            _loc8_ = _loc5_ / 3600000;
            if(_loc8_ > 2)
            {
               return Std.string(Math.ffloor(_loc8_)) + Locale.getString("SHOP_HOURS_LEFT");
            }
            if(_loc8_ > 1)
            {
               return Std.string(Math.ffloor(_loc8_)) + Locale.getString("SHOP_HOUR_LEFT");
            }
            return Locale.getString("SHOP_ALMOST_GONE");
         }
         return "";
      }
      
      @:isVar var offerDescription(get,never):String;
function  get_offerDescription() : String
      {
         return "";
      }
      
      @:isVar var offerIconName(get,never):String;
function  get_offerIconName() : String
      {
         return "";
      }
      
      @:isVar var offerSwfPath(get,never):String;
function  get_offerSwfPath() : String
      {
         return "";
      }
      
      function getTextRarityColor() : UInt
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
         return (ASCompat.toInt(_loc1_ != null && _loc1_.TextColor != 0 ? _loc1_.TextColor : (15463921 : UInt)) : UInt);
      }
      
      @:isVar var hasColoredBackground(get,never):Bool;
function  get_hasColoredBackground() : Bool
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.HasColoredBackground : false;
      }
      
      @:isVar var backgroundIconName(get,never):String;
function  get_backgroundIconName() : String
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.BackgroundIcon : "";
      }
      
      @:isVar var backgroundIconBorderName(get,never):String;
function  get_backgroundIconBorderName() : String
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.BackgroundIconBorder : "";
      }
      
      @:isVar var backgroundSwfPath(get,never):String;
function  get_backgroundSwfPath() : String
      {
         var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity), gameMasterDictionary.GMRarity);
         return _loc1_ != null ? _loc1_.BackgroundSwf : "";
      }
      
      function loadOfferIcon() 
      {
         var bgColoredExists:Bool;
         var bgSwfPath:String;
         var bgIconName:String;
         var bgIconBorderName:String;
         var swfPath:String;
         var iconName:String;
         if(mRenderer != null)
         {
            mRenderer.destroy();
            mRenderer = null;
         }
         if(mBgIcon != null && mBgIcon.parent != null)
         {
            mBgIcon.parent.removeChild(mBgIcon);
            mBgIcon = null;
         }
         if(mBgIconBorder != null && mBgIconBorder.parent != null)
         {
            mBgIconBorder.parent.removeChild(mBgIconBorder);
            mBgIconBorder = null;
         }
         if(mIcon != null && mIcon.parent != null)
         {
            mIcon.parent.removeChild(mIcon);
            mIcon = null;
         }
         bgColoredExists = this.hasColoredBackground;
         bgSwfPath = this.backgroundSwfPath;
         bgIconName = this.backgroundIconName;
         bgIconBorderName = this.backgroundIconBorderName;
         swfPath = this.offerSwfPath;
         iconName = this.offerIconName;
         if(ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName))
         {
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc3_= param1.getClass(bgIconBorderName);
                  if(_loc3_ != null)
                  {
                     mBgIconBorder = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                     mIconParent.root.addChild(mBgIconBorder);
                  }
                  var _loc2_= param1.getClass(bgIconName);
                  if(_loc2_ != null)
                  {
                     mBgIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
                     mRenderer = new MovieClipRenderController(mDBFacade,mBgIcon);
                     mRenderer.play((0 : UInt),true);
                     if(mBgIconBorder != null)
                     {
                        mBgIconBorder.addChild(mBgIcon);
                     }
                     else
                     {
                        mIconParent.root.addChild(mBgIcon);
                     }
                  }
               });
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc2_= param1.getClass(iconName);
               if(_loc2_ != null)
               {
                  mIcon = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
                  mRenderer = new MovieClipRenderController(mDBFacade,mIcon);
                  mRenderer.play((0 : UInt),true);
                  if(mUseIconScaling)
                  {
                     mIcon.scaleX = mIcon.scaleY = 72 / nativeIconSize;
                  }
                  mIconParent.root.addChild(mIcon);
               }
            });
         }
      }
      
      @:isVar var nativeIconSize(get,never):Float;
function  get_nativeIconSize() : Float
      {
         return 100;
      }
      
      function hasRequirements() : Bool
      {
         return false;
      }
      
      @:isVar var nodesToGrey(get,never):Vector<DisplayObject>;
function  get_nodesToGrey() : Vector<DisplayObject>
      {
         return Vector.ofArray(([mBg,mIconParent.root,mRibbon,mBuyButton.root,mBuyButtonCash.root,mBuyButtonCoin.root,mBuyButtonTimerBasedSale.root,mStar] : Array<DisplayObject>));
      }
      
      function greyOffer(param1:Bool) 
      {
         var _loc3_:DisplayObject;
         var __ax4_iter_110:Vector<DisplayObject>;
         var _loc2_:ColorMatrixFilter = null;
         if(param1)
         {
            _loc2_ = SceneGraphManager.getGrayScaleSaturationFilter(5);
            __ax4_iter_110 = this.nodesToGrey;
            if (checkNullIteratee(__ax4_iter_110)) for (_tmp_ in __ax4_iter_110)
            {
               _loc3_ = _tmp_;
               if(_loc3_ != null)
               {
                  ASCompat.setProperty(_loc3_, "filters", [_loc2_]);
               }
            }
            if(mBgGrey != null)
            {
               mBg.visible = false;
               mBgGrey.visible = true;
               mBgGrey.filters = cast([_loc2_]);
            }
            mLevelStarLabel.textColor = mRequiresLabel.textColor = (15535124 : UInt);
            if(mDescriptionLabel != null)
            {
               mDescriptionLabel.textColor = (15535124 : UInt);
            }
            mTitle.textColor = (8947848 : UInt);
         }
      }
      
      function shouldGreyOffer(param1:GMHero) : Bool
      {
         return false;
      }
      
      @:isVar var coinOffer(get,never):GMOffer;
function  get_coinOffer() : GMOffer
      {
         return mCoinSaleOffer != null ? mCoinSaleOffer : mCoinOffer;
      }
      
            
      @:isVar var offer(get,set):GMOffer;
function  get_offer() : GMOffer
      {
         return mSaleOffer != null ? mSaleOffer : mGMOffer;
      }
      
      public function getVisibleDate() : Date
      {
         return mGMOffer.VisibleDate;
      }
      
      public function getStartDate() : Date
      {
         return mGMOffer.StartDate;
      }
      
      public function getEndDate() : Date
      {
         return mGMOffer.EndDate;
      }
      
      public function getSoldOutDate() : Date
      {
         return mGMOffer.SoldOutDate;
      }
function  set_offer(param1:GMOffer) :GMOffer      {
         mGMOffer = param1;
         mSaleOffer = mGMOffer.isOnSaleNow;
         mCoinOffer = mGMOffer.CoinOffer;
         mCoinSaleOffer = ASCompat.dynamicAs(mCoinOffer != null ? mCoinOffer.isOnSaleNow : null, gameMasterDictionary.GMOffer);
return param1;
      }
      
      public function showOffer(param1:GMOffer, param2:GMHero) 
      {
         var _loc4_= false;
         var _loc5_= false;
         this.offer = param1;
         mGMHero = param2;
         mTitle.text = this.offer.getDisplayName(mDBFacade.gameMaster,Locale.getString("SHOP_UNKNOWN_NAME"));
         mTitle.textColor = this.getTextRarityColor();
         if(mTitle.numLines == 1)
         {
            mTitle.y = mTitleY + mTitle.height * 0.2;
         }
         else
         {
            mTitle.y = mTitleY;
         }
         loadOfferIcon();
         if(param1.Details.length > 0)
         {
            if(param1.Details[0].StackableId != 0)
            {
               mStackCountTF.visible = true;
               mStackCountTF.text = "x" + Std.string(param1.Details[0].StackableCount);
            }
         }
         mRequiresLabel.text = Locale.getString("REQUIRES");
         mRequiresLabel.visible = this.hasRequirements();
         if(mDescriptionLabel != null)
         {
            mDescriptionLabel.text = this.offerDescription;
         }
         if(IsCashPageExclusiveOffer())
         {
            mBuyButton.visible = false;
            mExclusiveOfferButton.visible = true;
            mExclusiveOfferButton.label.text = Locale.getString("UI_SHOP_CASH_PAGE_EXCLUSIVE");
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            ASCompat.setProperty((mRoot : ASAny).label_or, "visible", false);
         }
         else if(this.coinOffer != null)
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = true;
            mBuyButtonCash.visible = true;
            ASCompat.setProperty((mRoot : ASAny).label_or, "visible", true);
            mExclusiveOfferButton.visible = false;
            mBuyButtonCash.label.text = this.offer.Price > 0 ? Std.string(this.offer.Price) : Locale.getString("SHOP_FREE");
            mBuyButtonCoin.label.text = this.coinOffer.Price > 0 ? Std.string(this.coinOffer.Price) : Locale.getString("SHOP_FREE");
         }
         else
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            ASCompat.setProperty((mRoot : ASAny).label_or, "visible", false);
            mExclusiveOfferButton.visible = false;
            mBuyButton.label.text = this.offer.Price > 0 ? Std.string(this.offer.Price) : Locale.getString("SHOP_FREE");
         }
         if(mSaleOffer != null)
         {
            ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", true);
            ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", true);
            ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", false);
            if(mSaleOffer.percentOff != 0)
            {
               mSaleLabel.visible = true;
               mSaleLabel.text = Std.string(mSaleOffer.percentOff) + Locale.getString("SHOP_PERCENT_OFF");
               mOriginalPrice.visible = true;
               mOriginalPrice.text = Std.string(mGMOffer.Price);
               mStrikePrice.visible = true;
               mStrikePrice.width = mOriginalPrice.textWidth + 4;
            }
            else
            {
               mStrikePrice.visible = false;
               mSaleLabel.visible = false;
               mOriginalPrice.visible = false;
            }
            ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "visible", true);
            ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).original_price, "text", Std.string(mGMOffer.Price));
            ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "visible", true);
            ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).strike, "width", (mBuyButtonTimerBasedSale.root : ASAny).original_price.textWidth + 4);
            if(mCoinOffer != null && mCoinSaleOffer != null && mCoinOffer.Price != mCoinSaleOffer.Price)
            {
               ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "visible", true);
               ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "text", Std.string(mCoinOffer.Price));
               ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "visible", true);
               ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "width", (mBuyButtonCoin.root : ASAny).original_price.textWidth + 4);
            }
            ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "visible", true);
            ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "text", Std.string(mGMOffer.Price));
            ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "visible", true);
            ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "width", (mBuyButtonCash.root : ASAny).original_price.textWidth + 4);
         }
         else
         {
            if(mGMOffer.LimitedQuantity > 0)
            {
               ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", true);
               ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", false);
               ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "text", Locale.getString("SHOP_RARE"));
               ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", true);
            }
            else if(mGMOffer.isNew)
            {
               ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", true);
               ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", false);
               ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "text", Locale.getString("SHOP_NEW"));
               ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", true);
            }
            else
            {
               ASCompat.setProperty((mRoot : ASAny).sale_ribbon, "visible", false);
               ASCompat.setProperty((mRoot : ASAny).sale_ribbon_label, "visible", false);
               ASCompat.setProperty((mRoot : ASAny).new_ribbon_label, "visible", false);
            }
            mOriginalPrice.visible = false;
            mStrikePrice.visible = false;
            mSaleLabel.visible = false;
         }
         if(this.offer.LimitedQuantity > 0)
         {
            mNumSold = StoreServices.getOfferQuantitySold(this.offer);
         }
         var _loc8_= this.canBuyOffer();
         var _loc7_= this.canGiftOffer();
         if(_loc7_)
         {
            mGiftIcon.visible = true;
            mCashIcon.visible = false;
            mCoinIcon.visible = false;
         }
         else
         {
            mGiftIcon.visible = false;
            _loc4_ = this.offer.Price > 0 && this.offer.CurrencyType == "PREMIUM";
            _loc5_ = this.offer.Price > 0 && this.offer.CurrencyType == "BASIC";
            mCashIcon.visible = _loc4_;
            mCoinIcon.visible = _loc5_;
            ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.cash, "visible", _loc4_);
            ASCompat.setProperty((mBuyButtonTimerBasedSale.root : ASAny).icons_bundle.coin, "visible", _loc5_);
         }
         var _loc6_= StoreServicesController.getOfferLevelReq(mDBFacade,this.offer);
         mLevelStarLabel.text = Std.string(_loc6_);
         mLevelStarLabel.visible = mStar.visible = false;
         if(getStartDate() != null || getEndDate() != null)
         {
            if(ASCompat.toBool((mRoot : ASAny).timer))
            {
               ASCompat.setProperty((mRoot : ASAny).timer, "visible", true);
               ASCompat.setProperty((mRoot : ASAny).timer, "text", getDateString());
            }
            mBuyButton.visible = false;
            if(this.coinOffer != null)
            {
               mBuyButtonCoin.visible = true;
               mBuyButtonCash.visible = true;
               mBuyButtonTimerBasedSale.visible = false;
            }
            else
            {
               mBuyButtonCoin.visible = false;
               mBuyButtonCash.visible = false;
               mBuyButtonTimerBasedSale.visible = true;
               mBuyButtonTimerBasedSale.label.text = Std.string(this.offer.Price);
            }
         }
         if(this.offer.LimitedQuantity > 0)
         {
            if(mLimitLabel != null)
            {
               mLimitLabel.visible = true;
               mLimitLabel.text = getQuantityString();
            }
         }
         else if(mLimitLabel != null)
         {
            mLimitLabel.visible = false;
         }
         mAlreadyOwnedLabel.visible = !this.requirementsMetForPurchase();
         var _loc3_= _loc8_ || _loc7_;
         mBuyButton.enabled = _loc3_;
         mBuyButtonCoin.enabled = _loc3_;
         mBuyButtonCash.enabled = _loc3_;
         mBuyButtonTimerBasedSale.enabled = _loc3_;
         this.greyOffer(!_loc8_ && !_loc7_ || this.shouldGreyOffer(mGMHero));
      }
      
      function requirementsMetForPurchase() : Bool
      {
         return false;
      }
      
      function isAvailableTime() : Bool
      {
         if(mGMOffer.SaleOffers != null && mGMOffer.SaleOffers.length > 0)
         {
            return mGMOffer.SaleOffers[0].isAvailableTime();
         }
         return this.offer.isAvailableTime();
      }
      
      function isAvailableQuantity() : Bool
      {
         if(this.offer.LimitedQuantity != 0 && mNumSold >= this.offer.LimitedQuantity)
         {
            return false;
         }
         return true;
      }
      
      function canBuyOffer() : Bool
      {
         if(this.offer.Gift)
         {
            return false;
         }
         if(!this.isAvailableTime())
         {
            return false;
         }
         if(!this.requirementsMetForPurchase())
         {
            return false;
         }
         if(!this.isAvailableQuantity())
         {
            return false;
         }
         return true;
      }
      
      function IsCashPageExclusiveOffer() : Bool
      {
         return false;
      }
      
      function canGiftOffer() : Bool
      {
         if(!this.offer.Gift)
         {
            return false;
         }
         if(!this.isAvailableTime())
         {
            return false;
         }
         if(!this.isAvailableQuantity())
         {
            return false;
         }
         return true;
      }
   }


