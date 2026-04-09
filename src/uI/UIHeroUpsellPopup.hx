package uI
;
   import account.StoreServicesController;
   import brain.assetRepository.SwfAsset;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import facebookAPI.DBFacebookBragFeedPost;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import town.TownHeader;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   
    class UIHeroUpsellPopup extends DBUIPopup
   {
      
      static inline final SWF_PATH= "Resources/Art2D/UI/db_UI_screens.swf";
      
      static inline final POPUP_CLASS_NAME= "hero_upsell_popup";
      
      static var SCREENSHOTS:ASDictionary<ASAny,ASAny> = new ASDictionary();
      
      static final ___init_SCREENSHOTS = {
         SCREENSHOTS["RANGER"] = ["image_ranger01","image_ranger02"];
         SCREENSHOTS["SORCERER"] = ["image_sorcerer01","image_sorcerer02"];
         SCREENSHOTS["BATTLE_CHEF"] = ["image_chef01","image_chef02"];
         SCREENSHOTS["VAMPIRE_HUNTER"] = ["image_vampireHunter01","image_vampireHunter02"];
         SCREENSHOTS["GHOST_SAMURAI"] = ["image_ghostSamurai01","image_ghostSamurai02"];
         SCREENSHOTS["PYROMANCER"] = ["image_pyro01","image_pyro02"];
         SCREENSHOTS["DRAGON_KNIGHT"] = ["image_dragonKnight01","image_dragonKnight02"];
         null;
      };
      
      var mBuyButton:UIButton;
      
      var mBuyButtonCoin:UIButton;
      
      var mBuyButtonCash:UIButton;
      
      var mGMOffer:GMOffer;
      
      var mSaleOffer:GMOffer ;
      
      var mCoinOffer:GMOffer ;
      
      var mCoinSaleOffer:GMOffer ;
      
      var mGMHero:GMHero;
      
      var mAttackStars:Vector<MovieClip> = new Vector();
      
      var mDefenseStars:Vector<MovieClip> = new Vector();
      
      var mSpeedStars:Vector<MovieClip> = new Vector();
      
      var mTownHeader:TownHeader;
      
      public function new(param1:TownHeader, param2:DBFacade, param3:GMOffer, param4:ASFunction = null)
      {
         mTownHeader = param1;
         mGMOffer = param3;
         mSaleOffer = mGMOffer.isOnSaleNow;
         mCoinOffer = mGMOffer.CoinOffer;
         mCoinSaleOffer = ASCompat.dynamicAs(mCoinOffer != null ? mCoinOffer.isOnSaleNow : null, gameMasterDictionary.GMOffer);
         var _loc5_= mGMOffer.Details[0].HeroId;
         mGMHero = ASCompat.dynamicAs(param2.gameMaster.heroById.itemFor(_loc5_), gameMasterDictionary.GMHero);
         if(_loc5_ == 0 || mGMHero == null)
         {
            Logger.error("Invalid GMOffer: " + param3.Id);
         }
         param2.metrics.log("HeroUpsellPopupPresented",{"heroId":Std.string(_loc5_)});
         super(param2,"",null,true,true,param4);
      }
      
      override public function destroy() 
      {
         mBuyButton.destroy();
         mBuyButtonCash.destroy();
         mBuyButtonCoin.destroy();
         super.destroy();
      }
      
      override function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override function getClassName() : String
      {
         return "hero_upsell_popup";
      }
      
      @:isVar var coinOffer(get,never):GMOffer;
function  get_coinOffer() : GMOffer
      {
         return mCoinSaleOffer != null ? mCoinSaleOffer : mCoinOffer;
      }
      
      @:isVar var offer(get,never):GMOffer;
function  get_offer() : GMOffer
      {
         return mSaleOffer != null ? mSaleOffer : mGMOffer;
      }
      
      override function setupUI(param1:SwfAsset, param2:String, param3:ASAny, param4:Bool, param5:ASFunction) 
      {
         var __ax4_iter_119:Array<ASAny>;
         var i:UInt;
         var character:String;
         var screenshot:String;
         var onSale:Bool;
         var swfAsset= param1;
         var titleText= param2;
         var content:ASAny = param3;
         var allowClose= param4;
         var closeCallback= param5;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mTitle.text = Locale.getSubString("HERO_UPSELL_TITLE",mGMHero.Constant);
         ASCompat.setProperty((mPopup : ASAny).caption_1_label, "text", Locale.getSubString("HERO_UPSELL_CAPTION_1",mGMHero.Constant));
         ASCompat.setProperty((mPopup : ASAny).buster_title_label, "text", Locale.getSubString("HERO_UPSELL_BUSTER_TITLE",mGMHero.Constant));
         ASCompat.setProperty((mPopup : ASAny).buster_message_label, "text", Locale.getSubString("HERO_UPSELL_BUSTER_MESSAGE",mGMHero.Constant));
         ASCompat.ASArray.pushMultiple(mAttackStars, ASCompat.dynamicAs((mPopup : ASAny).attack_star_0, flash.display.MovieClip),(mPopup : ASAny).attack_star_1,(mPopup : ASAny).attack_star_2,(mPopup : ASAny).attack_star_3,(mPopup : ASAny).attack_star_4);
         ASCompat.ASArray.pushMultiple(mDefenseStars, ASCompat.dynamicAs((mPopup : ASAny).defense_star_0, flash.display.MovieClip),(mPopup : ASAny).defense_star_1,(mPopup : ASAny).defense_star_2,(mPopup : ASAny).defense_star_3,(mPopup : ASAny).defense_star_4);
         ASCompat.ASArray.pushMultiple(mSpeedStars, ASCompat.dynamicAs((mPopup : ASAny).speed_star_0, flash.display.MovieClip),(mPopup : ASAny).speed_star_1,(mPopup : ASAny).speed_star_2,(mPopup : ASAny).speed_star_3,(mPopup : ASAny).speed_star_4);
         i = (0 : UInt);
         while(i < (mAttackStars.length : UInt))
         {
            mAttackStars[(i : Int)].visible = mGMHero.AttackRating - 1 >= i;
            mDefenseStars[(i : Int)].visible = mGMHero.DefenseRating - 1 >= i;
            mSpeedStars[(i : Int)].visible = mGMHero.SpeedRating - 1 >= i;
            i = i + 1;
         }
         ASCompat.setProperty((mPopup : ASAny).buy_button_coins, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).buy_button_gems, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).label_or, "visible", false);
         ASCompat.setProperty((mPopup : ASAny).purchase_label, "text", Locale.getString("HERO_UPSELL_PURCHASE"));
         ASCompat.setProperty((mPopup : ASAny).hero_name_label, "text", mGMHero.Name.toUpperCase());
         mBuyButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).buy_button, flash.display.MovieClip));
         mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButton.releaseCallback = this.buyButtonCallback;
         mBuyButtonCoin = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).buy_button_coins, flash.display.MovieClip));
         mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin.releaseCallback = this.buyButtonCoinCallback;
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.cash, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "visible", false);
         mBuyButtonCash = new UIButton(mDBFacade,ASCompat.dynamicAs((mPopup : ASAny).buy_button_gems, flash.display.MovieClip));
         mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCash.releaseCallback = this.buyButtonCallback;
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.coin, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "visible", false);
         if(offerIsCashPageExclusive())
         {
            mBuyButton.visible = true;
            mBuyButton.label.text = Locale.getString("HERO_UPSELL_EXCLUSIVE_OFFER");
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            ASCompat.setProperty((mPopup : ASAny).label_or, "visible", false);
         }
         else if(this.coinOffer != null)
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = this.coinOffer.Price > 0;
            mBuyButtonCash.visible = this.offer.Price > 0;
            ASCompat.setProperty((mPopup : ASAny).label_or, "visible", true);
            mBuyButtonCash.label.text = this.offer.Price > 0 ? Std.string(this.offer.Price) : Locale.getString("SHOP_FREE");
            mBuyButtonCoin.label.text = this.coinOffer.Price > 0 ? Std.string(this.coinOffer.Price) : Locale.getString("SHOP_FREE");
         }
         else
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            ASCompat.setProperty((mPopup : ASAny).label_or, "visible", false);
            mBuyButton.label.text = this.offer.Price > 0 ? Std.string(this.offer.Price) : Locale.getString("SHOP_FREE");
         }
         ASCompat.setProperty((mPopup : ASAny).attack_label, "text", Locale.getString("HERO_UPSELL_ATTACK"));
         ASCompat.setProperty((mPopup : ASAny).defense_label, "text", Locale.getString("HERO_UPSELL_DEFENSE"));
         ASCompat.setProperty((mPopup : ASAny).speed_label, "text", Locale.getString("HERO_UPSELL_SPEED"));
         final __ax4_iter_118 = SCREENSHOTS;
         if (checkNullIteratee(__ax4_iter_118)) for(_tmp_ in __ax4_iter_118.keys())
         {
            character  = _tmp_;
            __ax4_iter_119 = SCREENSHOTS[character];
            if (checkNullIteratee(__ax4_iter_119)) for (_tmp_ in __ax4_iter_119)
            {
               screenshot  = _tmp_;
               ASCompat.setProperty((mPopup : ASAny)[screenshot], "visible", character == mGMHero.Constant);
            }
         }
         onSale = mSaleOffer != null;
         ASCompat.setProperty((mPopup : ASAny).buy_button.original_price, "visible", onSale);
         ASCompat.setProperty((mPopup : ASAny).buy_button.strike, "visible", onSale);
         ASCompat.setProperty((mPopup : ASAny).sale_ribbon, "visible", onSale);
         ASCompat.setProperty((mPopup : ASAny).sale_ribbon_label, "visible", onSale);
         ASCompat.setProperty((mPopup : ASAny).sale_label, "visible", onSale);
         if(onSale)
         {
            ASCompat.setProperty((mPopup : ASAny).buy_button.original_price, "text", Std.string(mGMOffer.Price));
            ASCompat.setProperty((mPopup : ASAny).sale_label, "text", Std.string(mSaleOffer.percentOff) + Locale.getString("SHOP_PERCENT_OFF"));
            ASCompat.setProperty((mPopup : ASAny).buy_button.strike, "width", mBuyButton.label.textWidth + 4);
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mGMHero.PortraitName),function(param1:SwfAsset)
         {
            var _loc3_= param1.getClass(mGMHero.IconName);
            var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            _loc4_.scaleX = _loc4_.scaleY = 0.82;
            var _loc2_= new MovieClipRenderController(mDBFacade,_loc4_);
            _loc2_.play();
            var _loc5_= ASCompat.dynamicAs((mPopup : ASAny).hero_origin, flash.display.DisplayObjectContainer);
            if(_loc5_.numChildren > 0)
            {
               _loc5_.removeChildAt(0);
            }
            _loc5_.addChildAt(_loc4_,0);
         });
      }
      
      function offerIsCashPageExclusive() : Bool
      {
         return this.offer.Details[0].HeroId == 108;
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
         var buyOffer= param1;
         if(offerIsCashPageExclusive())
         {
            StoreServicesController.showCashPage(mDBFacade,"heroUpsellPopup");
            return;
         }
         mDBFacade.metrics.log("HeroUpsellPopupPurchaseTry",{"heroId":StoreServicesController.getOfferMetrics(mDBFacade,buyOffer)});
         StoreServicesController.tryBuyOffer(mDBFacade,buyOffer,function(param1:ASAny)
         {
            mDBFacade.metrics.log("HeroUpsellPopupPurchase",{"heroId":StoreServicesController.getOfferMetrics(mDBFacade,buyOffer)});
            var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(buyOffer.Details[0].HeroId), gameMasterDictionary.GMHero);
            if(_loc2_ == null)
            {
               return;
            }
            DBFacebookBragFeedPost.buyHeroSuccess(mTownHeader,_loc2_,mDBFacade,mAssetLoadingComponent);
            close(mCloseCallback);
         });
      }
   }


