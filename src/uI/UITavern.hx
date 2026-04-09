package uI
;
   import account.AvatarInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIProgressBar;
   import brain.utils.ColorMatrix;
   import brain.workLoop.LogicalWorkComponent;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import facebookAPI.DBFacebookBragFeedPost;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMSkin;
   import gameMasterDictionary.GMWeaponMastertype;
   import town.TownHeader;
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class UITavern
   {
      
      static inline final ONE_DAY_MS:Float = 86400000;
      
      static inline final ONE_HOUR_MS:Float = 3600000;
      
      var mRootMovieClip:MovieClip;
      
      var mDBFacade:DBFacade;
      
      var mHeroSlots:Vector<UIButton>;
      
      var mWeaponIconsVector:Vector<UIObject>;
      
      var mWeaponIcons3:Vector<UIObject>;
      
      var mWeaponIcons4:Vector<UIObject>;
      
      var mSkinVector:Vector<UITavernSkinButton>;
      
      var mAvatarSelectorStartIndex:Int = 0;
      
      var mSelectorRightScroll:UIButton;
      
      var mSelectorLeftScroll:UIButton;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mBuyButton:UIButton;
      
      var mBuyButtonCoin:UIButton;
      
      var mBuyButtonCash:UIButton;
      
      var mHeroRequiredForSkinPurchase:MovieClip;
      
      var mChosenAvatarID:UInt = 0;
      
      var mAvatarIdToMakeActiveAvatar:UInt = 0;
      
      var mCurrentChosenIndex:Int = 0;
      
      var mActiveAvatar:AvatarInfo;
      
      var mXPBar:UIProgressBar;
      
      var mXPText:TextField;
      
      var mXPLevelText:TextField;
      
      var mXPParentObject:UIObject;
      
      var mSaleLabel:TextField;
      
      var mTavernInfoClip:MovieClip;
      
      var mCharacterInfoClip:MovieClip;
      
      var mSkinInfoClip:MovieClip;
      
      var mSkinNameLabel:TextField;
      
      var mSkinNotAvailableLabel:TextField;
      
      var mStoryInfoClip:MovieClip;
      
      var mAttackStars:Vector<MovieClip>;
      
      var mDefenseStars:Vector<MovieClip>;
      
      var mSpeedStars:Vector<MovieClip>;
      
      var mAvatarSelector:MovieClip;
      
      var mHeroPic:MovieClip;
      
      var mHeroSelectionsToFlush:Map;
      
      var mTownHeader:TownHeader;
      
      var mHeroOffers:Map;
      
      var mSkinOffers:Map;
      
      var mScaledSlotIndex:Int = 0;
      
      var mHeroIds:Vector<UInt>;
      
      var mScrollSkinsLeftButton:UIButton;
      
      var mScrollSkinsRightButton:UIButton;
      
      var mSkinStartIndex:UInt = 0;
      
      var mSelectedSkin:GMSkin;
      
      var mChosenSkin:GMSkin;
      
      var mWantSkins:Bool = false;
      
      var mRecruitButton:UIButton;
      
      public function new(param1:DBFacade, param2:MovieClip, param3:TownHeader)
      {
         
         mHeroSlots = new Vector<UIButton>();
         mHeroSelectionsToFlush = new Map();
         mWeaponIcons3 = new Vector<UIObject>();
         mWeaponIcons4 = new Vector<UIObject>();
         mHeroIds = new Vector<UInt>();
         mHeroOffers = new Map();
         mSkinOffers = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(param1);
         mLogicalWorkComponent = new LogicalWorkComponent(param1);
         mRootMovieClip = param2;
         ASCompat.setProperty((mRootMovieClip : ASAny).select_hero, "visible", false);
         mDBFacade = param1;
         mTownHeader = param3;
         mWantSkins = mDBFacade.dbConfigManager.getConfigBoolean("want_skins",true);
         loadHeroOffers();
         loadSkinOffers();
         mChosenAvatarID = (0 : UInt);
         loadTavernInfo();
         loadAvatarChoiceArray();
      }
      
      function loadTavernInfo() 
      {
         mHeroPic = ASCompat.dynamicAs((mRootMovieClip : ASAny).UI_town_tavern_body.UI_town_tavern_avatar_pic, flash.display.MovieClip);
         var noSkinsMovieClip= ASCompat.dynamicAs((mRootMovieClip : ASAny).UI_town_tavern_body.UI_town_tavern_avatar_info, flash.display.MovieClip);
         var skinsMovieClip= ASCompat.dynamicAs((mRootMovieClip : ASAny).UI_town_tavern_body.UI_town_tavern_avatar_info_skin, flash.display.MovieClip);
         if(mWantSkins)
         {
            mTavernInfoClip = skinsMovieClip;
            noSkinsMovieClip.visible = false;
         }
         else
         {
            ASCompat.setProperty((mRootMovieClip : ASAny).select_hero, "visible", false);
            ASCompat.setProperty((mRootMovieClip : ASAny).skin_frame, "visible", false);
            mTavernInfoClip = noSkinsMovieClip;
            skinsMovieClip.visible = false;
            ASCompat.setProperty((mRootMovieClip : ASAny).UI_town_tavern_body.skin_frame, "visible", false);
         }
         mWeaponIcons3.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_3.weapon_icon_slot_0, flash.display.MovieClip)));
         mWeaponIcons3.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_3.weapon_icon_slot_1, flash.display.MovieClip)));
         mWeaponIcons3.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_3.weapon_icon_slot_2, flash.display.MovieClip)));
         mWeaponIcons4.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_4.weapon_icon_slot_0, flash.display.MovieClip)));
         mWeaponIcons4.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_4.weapon_icon_slot_1, flash.display.MovieClip)));
         mWeaponIcons4.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_4.weapon_icon_slot_2, flash.display.MovieClip)));
         mWeaponIcons4.push(new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.weapons_4.weapon_icon_slot_3, flash.display.MovieClip)));
         mStoryInfoClip = ASCompat.dynamicAs((mTavernInfoClip : ASAny).story_info, flash.display.MovieClip);
         mStoryInfoClip.visible = true;
         mAttackStars = new Vector<MovieClip>();
         ASCompat.ASArray.pushMultiple(mAttackStars, ASCompat.dynamicAs((mStoryInfoClip : ASAny).attack_star_0, flash.display.MovieClip),(mStoryInfoClip : ASAny).attack_star_1,(mStoryInfoClip : ASAny).attack_star_2,(mStoryInfoClip : ASAny).attack_star_3,(mStoryInfoClip : ASAny).attack_star_4);
         mDefenseStars = new Vector<MovieClip>();
         ASCompat.ASArray.pushMultiple(mDefenseStars, ASCompat.dynamicAs((mStoryInfoClip : ASAny).defense_star_0, flash.display.MovieClip),(mStoryInfoClip : ASAny).defense_star_1,(mStoryInfoClip : ASAny).defense_star_2,(mStoryInfoClip : ASAny).defense_star_3,(mStoryInfoClip : ASAny).defense_star_4);
         mSpeedStars = new Vector<MovieClip>();
         ASCompat.ASArray.pushMultiple(mSpeedStars, ASCompat.dynamicAs((mStoryInfoClip : ASAny).speed_star_0, flash.display.MovieClip),(mStoryInfoClip : ASAny).speed_star_1,(mStoryInfoClip : ASAny).speed_star_2,(mStoryInfoClip : ASAny).speed_star_3,(mStoryInfoClip : ASAny).speed_star_4);
         ASCompat.setProperty((mStoryInfoClip : ASAny).likes_text, "text", Locale.getString("TAVERN_LIKES_LABEL"));
         ASCompat.setProperty((mStoryInfoClip : ASAny).dislikes_text, "text", Locale.getString("TAVERN_DISLIKES_LABEL"));
         ASCompat.setProperty((mStoryInfoClip : ASAny).attack_label, "text", Locale.getString("TAVERN_ATTACK_LABEL"));
         ASCompat.setProperty((mStoryInfoClip : ASAny).defense_label, "text", Locale.getString("TAVERN_DEFENSE_LABEL"));
         ASCompat.setProperty((mStoryInfoClip : ASAny).speed_label, "text", Locale.getString("TAVERN_SPEED_LABEL"));
         mCharacterInfoClip = ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info, flash.display.MovieClip);
         mCharacterInfoClip.visible = true;
         ASCompat.setProperty((mCharacterInfoClip : ASAny).weapon_types_text, "text", Locale.getString("TAVERN_USABLE_WEAPON_TYPES_LABEL"));
         mSkinInfoClip = ASCompat.dynamicAs((mRootMovieClip : ASAny).UI_town_tavern_body.UI_town_tavern_skin, flash.display.MovieClip);
         mSkinNameLabel = ASCompat.dynamicAs((mSkinInfoClip : ASAny).skin_name_text, flash.text.TextField);
         mSkinNotAvailableLabel = ASCompat.dynamicAs((mSkinInfoClip : ASAny).label_not_available, flash.text.TextField);
         mSkinNotAvailableLabel.text = Locale.getString("TAVERN_SKIN_NOT_AVAILABLE");
         mSkinNotAvailableLabel.mouseEnabled = false;
         mSkinNotAvailableLabel.visible = false;
         mSkinVector = new Vector<UITavernSkinButton>();
         mSkinVector.push(new UITavernSkinButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).skin_slot_0, flash.display.MovieClip),skinSelected));
         mSkinVector.push(new UITavernSkinButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).skin_slot_1, flash.display.MovieClip),skinSelected));
         mSkinVector.push(new UITavernSkinButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).skin_slot_2, flash.display.MovieClip),skinSelected));
         mScrollSkinsLeftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).moveLeft, flash.display.MovieClip));
         mScrollSkinsLeftButton.releaseCallback = function()
         {
            scrollSkins(-1);
         };
         mScrollSkinsRightButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).moveRight, flash.display.MovieClip));
         mScrollSkinsRightButton.releaseCallback = function()
         {
            scrollSkins(1);
         };
         mBuyButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).skin_buy_button, flash.display.MovieClip));
         mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin = new UIButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).buy_button_coins, flash.display.MovieClip));
         mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.cash, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonCoin.root : ASAny).strike, "visible", false);
         mBuyButtonCash = new UIButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).buy_button_gems, flash.display.MovieClip));
         mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.coin, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).icons_bundle.gift_icon, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).original_price, "visible", false);
         ASCompat.setProperty((mBuyButtonCash.root : ASAny).strike, "visible", false);
         mRecruitButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mSkinInfoClip : ASAny).exclusive_offer, flash.display.MovieClip));
         mRecruitButton.releaseCallback = function()
         {
            StoreServicesController.showCashPage(mDBFacade,"tavernBuyButtonExclusiveOfferDragonKnight");
         };
         mRecruitButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mRecruitButton.visible = false;
         mHeroRequiredForSkinPurchase = ASCompat.dynamicAs((mSkinInfoClip : ASAny).hero_required_label, flash.display.MovieClip);
         ASCompat.setProperty((mHeroRequiredForSkinPurchase : ASAny).hero_label, "text", Locale.getString("PURCHASE_HERO_BEFORE_BUYING_SYTLE_TAVERN_LABEL"));
         mSaleLabel = ASCompat.dynamicAs((mTavernInfoClip : ASAny).sale_label, flash.text.TextField);
         mSaleLabel.visible = false;
         mXPParentObject = new UIObject(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.UI_XP, flash.display.MovieClip));
         mXPBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.UI_XP.xp_bar, flash.display.MovieClip));
         mXPText = ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.UI_XP.xp_points, flash.text.TextField);
         mXPText.scaleY = mXPText.scaleX = 1.8;
         mXPText.x = 80;
         mXPText.y = 25;
         mXPParentObject.setTooltip(mXPText);
         mXPParentObject.tooltipDelay = 0;
         mXPBar.value = 0;
         mXPLevelText = ASCompat.dynamicAs((mTavernInfoClip : ASAny).character_info.UI_XP.xp_level, flash.text.TextField);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("weapon_tavern_tooltip");
            var _loc3_= param1.getClass("tavern_gloat");
            var _loc4_:UIObject;
            final __ax4_iter_100 = mWeaponIcons3;
            if (checkNullIteratee(__ax4_iter_100)) for (_tmp_ in __ax4_iter_100)
            {
               _loc4_ = _tmp_;
               ASCompat.setProperty(_loc4_, "tooltip", ASCompat.createInstance(_loc2_, []));
               ASCompat.setProperty(_loc4_, "tooltipPos", new Point(0,0));
            }
            final __ax4_iter_101 = mWeaponIcons4;
            if (checkNullIteratee(__ax4_iter_101)) for (_tmp_ in __ax4_iter_101)
            {
               _loc4_  = _tmp_;
               ASCompat.setProperty(_loc4_, "tooltip", ASCompat.createInstance(_loc2_, []));
               ASCompat.setProperty(_loc4_, "tooltipPos", new Point(0,0));
            }
         });
      }
      
      function loadAvatarChoiceArray() 
      {
         var i:Int;
         var makeCallbackFunc:ASFunction;
         var keys:Array<ASAny>;
         var avatarStartIndex:UInt;
         mAvatarSelector = ASCompat.dynamicAs((mRootMovieClip : ASAny).UI_town_tavern_body.UI_town_tavern_avatar_selector, flash.display.MovieClip);
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_0, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_1, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_2, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_3, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_4, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_5, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_6, flash.display.MovieClip)));
         mHeroSlots.push(new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).slot_7, flash.display.MovieClip)));
         i = 0;
         while(i < mHeroSlots.length)
         {
            if(ASCompat.toBool((mHeroSlots[i].root : ASAny).chosen))
            {
               ASCompat.setProperty((mHeroSlots[i].root : ASAny).chosen, "visible", false);
            }
            mHeroSlots[i].rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            makeCallbackFunc = function(param1:Int):ASFunction
            {
               var value= param1;
               return function()
               {
                  populateAvatarInfo(value);
               };
            };
            mHeroSlots[i].releaseCallback = ASCompat.asFunction(makeCallbackFunc(i));
            i = i + 1;
         }
         mSelectorLeftScroll = new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).moveLeft, flash.display.MovieClip));
         mSelectorRightScroll = new UIButton(mDBFacade,ASCompat.dynamicAs((mAvatarSelector : ASAny).moveRight, flash.display.MovieClip));
         mSelectorLeftScroll.releaseCallback = scrollLeft;
         mSelectorRightScroll.releaseCallback = scrollRight;
         mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(mActiveAvatar == null && mDBFacade.dbAccountInfo.inventoryInfo.avatars.size > 0)
         {
            keys = mDBFacade.dbAccountInfo.inventoryInfo.avatars.keysToArray();
            mActiveAvatar = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.inventoryInfo.avatars.itemFor(keys[0]), account.AvatarInfo);
         }
         avatarStartIndex = getActiveAvatarIndex();
         if(mHeroIds.length <= mHeroSlots.length)
         {
            mSelectorRightScroll.visible = false;
         }
         if(mAvatarSelectorStartIndex == 0)
         {
            mSelectorLeftScroll.visible = false;
         }
         mCurrentChosenIndex = (avatarStartIndex : Int);
         populateAvatarSelector();
         populateAvatarInfo((avatarStartIndex : Int));
      }
      
      function getActiveAvatarIndex() : UInt
      {
         var _loc2_= 0;
         var _loc1_= (0 : UInt);
         if(mActiveAvatar != null)
         {
            _loc2_ = 0;
            while(_loc2_ < mHeroIds.length)
            {
               if(mHeroIds[_loc2_] == mActiveAvatar.avatarType)
               {
                  _loc1_ = (_loc2_ : UInt);
                  if(_loc2_ >= mHeroSlots.length)
                  {
                     mAvatarSelectorStartIndex = _loc2_ - mHeroSlots.length + 1;
                     _loc1_ = (mHeroSlots.length - 1 : UInt);
                  }
                  break;
               }
               _loc2_++;
            }
         }
         return _loc1_;
      }
      
      function loadHeroOffers() 
      {
         var _loc2_:GMOffer = null;
         var _loc3_= 0;
         var _loc1_= mDBFacade.gameMaster.Offers;
         var _loc4_:GMHero;
         final __ax4_iter_102 = mDBFacade.gameMaster.Heroes;
         if (checkNullIteratee(__ax4_iter_102)) for (_tmp_ in __ax4_iter_102)
         {
            _loc4_ = _tmp_;
            if(!(ASCompat.toBool(_loc4_.Hidden) && !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
            {
               mHeroIds.push((ASCompat.toInt(_loc4_.Id) : UInt));
               _loc3_ = 0;
               while(_loc3_ < _loc1_.length)
               {
                  _loc2_ = _loc1_[_loc3_];
                  if(_loc2_.Tab == "HERO" && _loc2_.Location == "STORE" && !_loc2_.IsBundle && _loc2_.SaleTargetOffer == null && !_loc2_.IsCoinAltOffer)
                  {
                     if(_loc2_.Details[0].HeroId == ASCompat.toNumberField(_loc4_, "Id"))
                     {
                        mHeroOffers.add(_loc4_.Id,_loc2_);
                        break;
                     }
                  }
                  _loc3_++;
               }
            }
         }
         ASCompat.ASVector.sort(mHeroIds, heroIdSort);
      }
      
      function loadSkinOffers() 
      {
         var _loc3_:GMSkin;
         var __ax4_iter_103:Vector<GMSkin>;
         var _loc2_:GMOffer = null;
         var _loc4_= 0;
         var _loc1_= mDBFacade.gameMaster.Offers;
         _loc4_ = 0;
         while(_loc4_ < _loc1_.length)
         {
            _loc2_ = _loc1_[_loc4_];
            if(_loc2_.Tab == "SKIN" && _loc2_.Location == "STORE" && !_loc2_.IsBundle && !_loc2_.IsCoinAltOffer && _loc2_.isVisible())
            {
               __ax4_iter_103 = mDBFacade.gameMaster.Skins;
               if (checkNullIteratee(__ax4_iter_103)) for (_tmp_ in __ax4_iter_103)
               {
                  _loc3_ = _tmp_;
                  if(_loc2_.Details[0].SkinId == ASCompat.toNumberField(_loc3_, "Id"))
                  {
                     mSkinOffers.add(_loc3_.Id,_loc2_);
                     break;
                  }
               }
            }
            _loc4_++;
         }
      }
      
      function getSkinsToDisplay(param1:GMHero) : Vector<GMSkin>
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.getSkinsForHero(param1,mSkinOffers);
      }
      
      function heroIdSort(param1:UInt, param2:UInt) : Int
      {
         if(param1 < param2)
         {
            return -1;
         }
         return 1;
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            UITownTweens.avatarFadeInTweenSequence(mHeroPic);
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock)
            {
               mTownHeader.animateHeader();
            });
            mTavernInfoClip.visible = false;
            mLogicalWorkComponent.doLater(0.16666666666666666,function(param1:GameClock)
            {
               UITownTweens.rightPanelTweenSequence(mTavernInfoClip,mDBFacade);
            });
            mAvatarSelector.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:GameClock)
            {
               UITownTweens.footerTweenSequence(mAvatarSelector,mDBFacade);
            });
         }
      }
      
      public function refresh() 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            if(ASCompat.toBool((mHeroSlots[_loc2_].root : ASAny).chosen))
            {
               ASCompat.setProperty((mHeroSlots[_loc2_].root : ASAny).chosen, "visible", false);
            }
            _loc2_++;
         }
         mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
         var _loc1_= getActiveAvatarIndex();
         mCurrentChosenIndex = (_loc1_ : Int);
         if(ASCompat.toBool((mHeroSlots[mCurrentChosenIndex].root : ASAny).chosen))
         {
            ASCompat.setProperty((mHeroSlots[mCurrentChosenIndex].root : ASAny).chosen, "visible", true);
         }
         populateAvatarInfo((_loc1_ : Int));
         mTownHeader.title = Locale.getString("TAVERN_HEADER");
         populateAvatarSelector();
      }
      
      function populateAvatarSelector() 
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(mHeroIds.length > _loc1_ + mAvatarSelectorStartIndex)
            {
               loadAvatarHolderAtPosition(_loc1_ + mAvatarSelectorStartIndex,_loc1_);
            }
            else
            {
               ASCompat.setProperty((mHeroSlots[_loc1_].root : ASAny).xp_star, "visible", false);
            }
            _loc1_++;
         }
      }
      
      function loadAvatarHolderAtPosition(param1:Int, param2:Int) 
      {
         var gmSkin:GMSkin;
         var iconName:String;
         var swfFilePath:String;
         var heroIndex= param1;
         var vectorIndex= param2;
         var gmHero= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[heroIndex]), gameMasterDictionary.GMHero);
         var avatarID= gmHero.Id;
         var avatarInfo= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(gmHero.Id);
         if(avatarInfo == null)
         {
            ASCompat.setProperty((mHeroSlots[heroIndex].root : ASAny).xp_star, "visible", false);
            gmSkin = mDBFacade.gameMaster.getSkinByConstant(gmHero.DefaultSkin);
         }
         else
         {
            ASCompat.setProperty((mHeroSlots[heroIndex].root : ASAny).xp_star, "visible", true);
            ASCompat.setProperty((mHeroSlots[heroIndex].root : ASAny).xp_star.xp_text, "text", avatarInfo.level);
            gmSkin = mDBFacade.gameMaster.getSkinByType(avatarInfo.skinId);
         }
         iconName = gmSkin.IconName;
         swfFilePath = gmSkin.UISwfFilepath;
         ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).coming_soon, "visible", false);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfFilePath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_:ColorMatrix = null;
            var _loc4_= param1.getClass(iconName);
            if(_loc4_ == null)
            {
               return;
            }
            var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.MovieClip);
            _loc2_.scaleX *= 0.86;
            _loc2_.scaleY *= 0.86;
            if(ASCompat.toNumberField((mHeroSlots[vectorIndex].root : ASAny).avatar_icon, "numChildren") > 0)
            {
               (mHeroSlots[vectorIndex].root : ASAny).avatar_icon.removeChildAt(0);
            }
            (mHeroSlots[vectorIndex].root : ASAny).avatar_icon.addChildAt(_loc2_,0);
            ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).avatar_mask, "visible", false);
            if(mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(avatarID))
            {
               ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).avatar_icon, "filters", []);
            }
            else
            {
               _loc3_ = new ColorMatrix();
               _loc3_.adjustSaturation(0.1);
               _loc3_.adjustBrightness(-64);
               _loc3_.adjustContrast(-0.5);
               ASCompat.setProperty((mHeroSlots[vectorIndex].root : ASAny).avatar_icon, "filters", [_loc3_.filter]);
            }
         });
      }
      
      function scrollLeft() 
      {
         currentChosenIndex = mCurrentChosenIndex + 1;
         avatarSelectorStartIndex = mAvatarSelectorStartIndex - 1;
         handleScaledSlotIndex(1);
      }
      
      function scrollRight() 
      {
         currentChosenIndex = mCurrentChosenIndex - 1;
         avatarSelectorStartIndex = mAvatarSelectorStartIndex + 1;
         handleScaledSlotIndex(-1);
      }
      
      function scrollSkins(param1:Int) 
      {
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[mCurrentChosenIndex]), gameMasterDictionary.GMHero);
         var _loc2_= this.getSkinsToDisplay(_loc3_);
         var _loc4_= (mSkinStartIndex + param1 : UInt);
         if(_loc4_ >= 0 && _loc4_ + mSkinVector.length <= (_loc2_.length : UInt))
         {
            mSkinStartIndex = _loc4_;
            setUpSkinSelector();
         }
      }
      
      function handleScaledSlotIndex(param1:Int) 
      {
         mScaledSlotIndex += param1;
         if(mScaledSlotIndex < 0)
         {
            mScaledSlotIndex = 0;
            populateAvatarInfo(0);
         }
         if(mScaledSlotIndex >= mHeroSlots.length)
         {
            mScaledSlotIndex = mHeroSlots.length - 1;
            populateAvatarInfo(mScaledSlotIndex);
         }
         resizeHeroSlots((mScaledSlotIndex : UInt));
      }
      
      function populateAvatarInfo(param1:Int) 
      {
         resizeHeroSlots((param1 : UInt));
         param1 += mAvatarSelectorStartIndex;
         if(param1 >= mHeroIds.length)
         {
            return;
         }
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[param1]), gameMasterDictionary.GMHero);
         chooseThisHero(_loc3_.Id,param1 - mAvatarSelectorStartIndex);
         ASCompat.setProperty((mTavernInfoClip : ASAny).avatar_name_text, "text", _loc3_.Name.toUpperCase());
         ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_description_text, "text", _loc3_.CharDescription);
         ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_likes_text, "text", _loc3_.CharLikes.toUpperCase());
         ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_dislikes_text, "text", _loc3_.CharDislikes.toUpperCase());
         ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_nickname_text, "text", _loc3_.CharNickname.toUpperCase());
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc3_.Id);
         if(_loc2_ != null)
         {
            setXP(_loc2_.experience,_loc3_);
         }
         mXPParentObject.visible = _loc2_ != null;
         populateWeaponIcons(param1);
         populateHeroStars(_loc3_);
         var _loc4_= determineSkinForHero(_loc3_);
         determineSkinSelectorStartIndex(_loc4_);
         skinSelected(_loc4_);
      }
      
      function populateHeroStars(param1:GMHero) 
      {
         var _loc2_= 0;
         _loc2_ = 0;
         while(_loc2_ < mAttackStars.length)
         {
            mAttackStars[_loc2_].visible = param1.AttackRating - 1 >= _loc2_;
            mDefenseStars[_loc2_].visible = param1.DefenseRating - 1 >= _loc2_;
            mSpeedStars[_loc2_].visible = param1.SpeedRating - 1 >= _loc2_;
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      function setupSkin(param1:GMSkin) 
      {
         var playerOwnsSelectedSkin:Bool;
         var avatarInfo:AvatarInfo;
         var playerOwnsAvatar:Bool;
         var gmHero:GMHero;
         var gmSkin= param1;
         mSkinNotAvailableLabel.visible = false;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.PortraitName),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc3_= param1.getClass(gmSkin.CardName);
            var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
            var _loc2_= new MovieClipRenderController(mDBFacade,_loc4_);
            _loc2_.play();
            if(mHeroPic.numChildren > 0)
            {
               mHeroPic.removeChildAt(0);
            }
            mHeroPic.addChildAt(_loc4_,0);
         });
         playerOwnsSelectedSkin = mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(gmSkin.Id);
         avatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
         playerOwnsAvatar = avatarInfo != null;
         if(playerOwnsAvatar)
         {
            setupBuyButtonWithSkin(gmSkin,true);
         }
         else
         {
            gmHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(gmSkin.ForHero), gameMasterDictionary.GMHero);
            if(gmHero.DefaultSkin == gmSkin.Constant)
            {
               setupBuyButtonForHero(gmHero);
            }
            else
            {
               setupBuyButtonWithSkin(gmSkin,false);
            }
         }
         mSkinNameLabel.text = gmSkin.Name.toUpperCase();
         setUpSkinSelector();
      }
      
      function setupBuyButtonWithSkin(param1:GMSkin, param2:Bool) 
      {
         var nowTime:Float;
         var offer:GMOffer;
         var comingSoonText:String;
         var timeRemaining:Float;
         var daysRemaining:Float;
         var hoursRemaining:Float;
         var saleOffer:GMOffer;
         var currentOffer:GMOffer;
         var gmSkin= param1;
         var ownsHero= param2;
         mBuyButtonCoin.visible = false;
         mBuyButtonCash.visible = false;
         mRecruitButton.visible = false;
         ASCompat.setProperty((mSkinInfoClip : ASAny).label_or, "visible", false);
         mSkinNotAvailableLabel.visible = false;
         if(mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(gmSkin.Id))
         {
            mBuyButton.visible = false;
            mHeroRequiredForSkinPurchase.visible = false;
            return;
         }
         nowTime = GameClock.date.getTime();
         offer = ASCompat.dynamicAs(mSkinOffers.itemFor(gmSkin.Id), gameMasterDictionary.GMOffer);
         if(offer != null)
         {
            if(offer.StartDate != null && offer.StartDate.getTime()>= nowTime)
            {
               mBuyButton.visible = false;
               mHeroRequiredForSkinPurchase.visible = false;
               mSkinNotAvailableLabel.visible = true;
               comingSoonText = Locale.getString("TAVERN_SKIN_COMING_SOON");
               timeRemaining = offer.StartDate.getTime()- nowTime;
               daysRemaining = timeRemaining / 86400000;
               if(daysRemaining > 1)
               {
                  comingSoonText += Std.string(Math.fceil(daysRemaining)) + Locale.getString("SKIN_DAYS_LEFT");
               }
               else
               {
                  hoursRemaining = timeRemaining / 3600000;
                  if(hoursRemaining > 1)
                  {
                     comingSoonText += Std.string(Math.ffloor(hoursRemaining)) + Locale.getString("SKIN_HOURS_LEFT");
                  }
                  else
                  {
                     comingSoonText += Std.string(Math.ffloor(hoursRemaining)) + Locale.getString("SKIN_MINS_LEFT");
                  }
               }
               mSkinNotAvailableLabel.text = comingSoonText;
               return;
            }
            if(offer.EndDate != null && offer.EndDate.getTime()<= nowTime)
            {
               mBuyButton.visible = false;
               mHeroRequiredForSkinPurchase.visible = false;
               mSkinNotAvailableLabel.visible = true;
               mSkinNotAvailableLabel.text = Locale.getString("TAVERN_SKIN_SOLD_OUT");
               return;
            }
         }
         if(offer == null)
         {
            mBuyButton.visible = false;
            mHeroRequiredForSkinPurchase.visible = false;
            mSkinNotAvailableLabel.visible = true;
            mSkinNotAvailableLabel.text = Locale.getString("TAVERN_SKIN_NOT_AVAILABLE");
            return;
         }
         mBuyButton.visible = true;
         mBuyButton.enabled = true;
         mBuyButton.label.text = Locale.getString("SKIN_BUY_BUTTON_BUY_TEXT");
         saleOffer = offer.isOnSaleNow;
         currentOffer = saleOffer != null ? saleOffer : offer;
         ASCompat.setProperty((mBuyButton.root : ASAny).cost_text, "visible", true);
         ASCompat.setProperty((mBuyButton.root : ASAny).cost_text, "text", currentOffer.Price);
         ASCompat.setProperty((mBuyButton.root : ASAny).cash_icon, "visible", currentOffer.CurrencyType == "PREMIUM");
         ASCompat.setProperty((mBuyButton.root : ASAny).coin_icon, "visible", currentOffer.CurrencyType == "BASIC");
         mBuyButton.releaseCallback = function()
         {
            buySkin(gmSkin.Id);
         };
         if(ownsHero)
         {
            mBuyButton.enabled = true;
            mHeroRequiredForSkinPurchase.visible = false;
         }
         else
         {
            mBuyButton.enabled = false;
            mHeroRequiredForSkinPurchase.visible = true;
         }
         if(offer != null && offer.SaleStartDate != null && offer.SaleEndDate != null && offer.SaleStartDate.getTime()<= nowTime && offer.SaleEndDate.getTime()> nowTime)
         {
            mBuyButton.label.text = Locale.getString("TAVERN_SKIN_ON_SALE");
         }
      }
      
      function setupBuyButtonForHero(param1:GMHero) 
      {
         var offer:GMOffer;
         var saleOffer:GMOffer;
         var coinOffer:GMOffer;
         var coinSaleOffer:GMOffer;
         var currentOffer:GMOffer;
         var currentCoinOffer:GMOffer;
         var gmHero= param1;
         mSkinNotAvailableLabel.visible = false;
         mBuyButton.visible = true;
         mBuyButton.enabled = true;
         mBuyButton.label.text = Locale.getString("TAVERN_BUY_HERO_BUTTON_TEXT");
         offer = ASCompat.dynamicAs(mHeroOffers.itemFor(gmHero.Id), gameMasterDictionary.GMOffer);
         saleOffer = offer.isOnSaleNow;
         coinOffer = offer.CoinOffer;
         coinSaleOffer = ASCompat.dynamicAs(coinOffer != null ? coinOffer.isOnSaleNow : null, gameMasterDictionary.GMOffer);
         currentOffer = saleOffer != null ? saleOffer : offer;
         currentCoinOffer = coinSaleOffer != null ? coinSaleOffer : coinOffer;
         mHeroRequiredForSkinPurchase.visible = false;
         if(gmHero.IsExclusive)
         {
            mRecruitButton.visible = true;
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            ASCompat.setProperty((mSkinInfoClip : ASAny).label_or, "visible", false);
            return;
         }
         if(coinOffer != null)
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = true;
            mBuyButtonCash.visible = true;
            ASCompat.setProperty((mSkinInfoClip : ASAny).label_or, "visible", true);
            mRecruitButton.visible = false;
            mBuyButtonCash.label.text = Std.string(currentOffer.Price);
            mBuyButtonCoin.label.text = Std.string(currentCoinOffer.Price);
            mBuyButtonCash.releaseCallback = function()
            {
               buyThisHero(currentOffer,(mCurrentChosenIndex : UInt));
            };
            mBuyButtonCoin.releaseCallback = function()
            {
               buyThisHero(currentCoinOffer,(mCurrentChosenIndex : UInt));
            };
         }
         else
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            ASCompat.setProperty((mSkinInfoClip : ASAny).label_or, "visible", false);
            mRecruitButton.visible = false;
            ASCompat.setProperty((mBuyButton.root : ASAny).cost_text, "visible", true);
            ASCompat.setProperty((mBuyButton.root : ASAny).cost_text, "text", Std.string(currentOffer.Price));
            ASCompat.setProperty((mBuyButton.root : ASAny).cash_icon, "visible", currentOffer.CurrencyType == "PREMIUM");
            ASCompat.setProperty((mBuyButton.root : ASAny).coin_icon, "visible", currentOffer.CurrencyType == "BASIC");
            mBuyButton.releaseCallback = function()
            {
               buyThisHero(currentOffer,(mCurrentChosenIndex : UInt));
            };
         }
      }
      
      function determineSkinForHero(param1:GMHero) : GMSkin
      {
         var _loc3_:GMSkin = null;
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(param1.Id);
         if(_loc2_ != null)
         {
            if(mHeroSelectionsToFlush.hasKey(param1.Id))
            {
               _loc3_ = mDBFacade.gameMaster.getSkinByType((ASCompat.toInt(mHeroSelectionsToFlush.itemFor(param1.Id)) : UInt));
            }
            else
            {
               _loc3_ = mDBFacade.gameMaster.getSkinByType(_loc2_.skinId);
            }
            if(_loc3_ == null)
            {
               Logger.warn("Unable to get gmSKin for skinId: " + _loc2_.skinId);
            }
         }
         if(_loc3_ == null)
         {
            _loc3_ = mDBFacade.dbAccountInfo.inventoryInfo.getDefaultSkinForHero(param1);
         }
         return _loc3_;
      }
      
      function determineSkinSelectorStartIndex(param1:GMSkin) 
      {
         var _loc4_= 0;
         var _loc3_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[mCurrentChosenIndex]), gameMasterDictionary.GMHero);
         var _loc2_= this.getSkinsToDisplay(_loc3_);
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            if(_loc2_[_loc4_].Id == param1.Id)
            {
               if(_loc4_ < mSkinVector.length)
               {
                  mSkinStartIndex = (0 : UInt);
               }
               else
               {
                  mSkinStartIndex = (ASCompat.toInt(_loc4_ - mSkinVector.length + 1) : UInt);
               }
               return;
            }
            _loc4_ = ASCompat.toInt(_loc4_) + 1;
         }
         mSkinStartIndex = (0 : UInt);
      }
      
      function skinSelected(param1:GMSkin) 
      {
         mSelectedSkin = param1;
         if(param1 != null)
         {
            ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_description_text, "text", param1.Description);
            ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_likes_text, "text", param1.CharLikes.toUpperCase());
            ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_dislikes_text, "text", param1.CharDislikes.toUpperCase());
            ASCompat.setProperty((mStoryInfoClip : ASAny).avatar_nickname_text, "text", param1.CharNickname.toUpperCase());
         }
         var _loc4_= mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(param1.Id);
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mChosenAvatarID);
         var _loc2_= _loc3_ != null;
         if(_loc2_)
         {
            if(_loc4_)
            {
               if(mHeroSelectionsToFlush.hasKey(_loc3_.gmHero.Id))
               {
                  mHeroSelectionsToFlush.replaceFor(_loc3_.gmHero.Id,param1.Id);
               }
               else
               {
                  mHeroSelectionsToFlush.add(_loc3_.gmHero.Id,param1.Id);
               }
               mChosenSkin = param1;
            }
         }
         else
         {
            mChosenSkin = null;
         }
         setupSkin(mSelectedSkin);
      }
      
      function setHeroAndSkin() 
      {
         var _loc4_= 0;
         var _loc3_:ASAny = 0;
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mAvatarIdToMakeActiveAvatar);
         if(_loc2_ == null)
         {
            Logger.error("Trying to set active avatar to an avatar the user does no own.");
            return;
         }
         if(mActiveAvatar.id != _loc2_.id)
         {
            changeActiveAvatarRPC(mAvatarIdToMakeActiveAvatar);
         }
         var _loc1_= ASCompat.reinterpretAs(mHeroSelectionsToFlush.iterator() , IMapIterator);
         while(ASCompat.toBool(_loc1_.next()))
         {
            _loc3_ = _loc1_.key;
            _loc4_ = (ASCompat.asUint(_loc1_.current ) : Int);
            setSkinOnAvatar((ASCompat.toInt(_loc3_) : UInt),(_loc4_ : UInt));
         }
         mHeroSelectionsToFlush.clear();
      }
      
      function setSkinOnAvatar(param1:UInt, param2:UInt) 
      {
         var _loc4_= false;
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(param1);
         if(_loc3_ != null)
         {
            _loc4_ = mDBFacade.dbAccountInfo.inventoryInfo.doesPlayerOwnSkin(param2);
            if(!_loc4_)
            {
               Logger.error("Trying to set skin as active that the user does no own.");
               return;
            }
            if(_loc3_.skinId != param2)
            {
               _loc3_.skinId = param2;
               if(mActiveAvatar.id == _loc3_.id)
               {
                  mActiveAvatar.skinId = param2;
               }
               _loc3_.RPC_updateAvatarSkin();
               mDBFacade.metrics.log("StyleSet",{
                  "heroType":param1,
                  "styleType":param2
               });
            }
         }
      }
      
      function setUpSkinSelector() 
      {
         var _loc3_= 0;
         var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mHeroIds[mCurrentChosenIndex]), gameMasterDictionary.GMHero);
         var _loc1_= this.getSkinsToDisplay(_loc2_);
         _loc3_ = 0;
         while(_loc3_ < mSkinVector.length)
         {
            if(_loc1_.length > ASCompat.toNumber(_loc3_ + mSkinStartIndex))
            {
               mSkinVector[_loc3_].selected = false;
               if(mSelectedSkin != null && mSelectedSkin.Id == _loc1_[ASCompat.toInt(_loc3_ + mSkinStartIndex)].Id)
               {
                  mSkinVector[_loc3_].selected = true;
               }
               mSkinVector[_loc3_].chosen = false;
               if(mChosenSkin != null && mChosenSkin.Id == _loc1_[ASCompat.toInt(_loc3_ + mSkinStartIndex)].Id)
               {
                  mSkinVector[_loc3_].chosen = true;
               }
               mSkinVector[_loc3_].gmSkin = _loc1_[ASCompat.toInt(_loc3_ + mSkinStartIndex)];
               mSkinVector[_loc3_].visible = true;
            }
            else
            {
               mSkinVector[_loc3_].visible = false;
            }
            _loc3_ = ASCompat.toInt(_loc3_) + 1;
         }
         mScrollSkinsLeftButton.enabled = false;
         mScrollSkinsRightButton.enabled = false;
         if(_loc1_.length > mSkinVector.length)
         {
            if(mSkinStartIndex > 0)
            {
               mScrollSkinsLeftButton.enabled = true;
            }
            if(mSkinStartIndex + mSkinVector.length < (_loc1_.length : UInt))
            {
               mScrollSkinsRightButton.enabled = true;
            }
         }
      }
      
      function resizeHeroSlots(param1:UInt) 
      {
         var _loc2_= 0;
         mScaledSlotIndex = (param1 : Int);
         _loc2_ = 0;
         while(_loc2_ < mHeroSlots.length)
         {
            if((_loc2_ : UInt) == param1)
            {
               select(mHeroSlots[_loc2_].root);
            }
            else
            {
               deselect(mHeroSlots[_loc2_].root);
            }
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }
      
      public function select(param1:MovieClip) 
      {
         param1.scaleX = 1.25;
         param1.scaleY = 1.25;
      }
      
      public function deselect(param1:MovieClip) 
      {
         param1.scaleX = 1;
         param1.scaleY = 1;
      }
      
      function setXP(param1:UInt, param2:GMHero) 
      {
         mXPBar.value = param1;
         var _loc5_= param2.getLevelFromExp(param1);
         var _loc4_= param1;
         var _loc3_= (param2.getLevelIndex(param1) : UInt);
         var _loc7_= (ASCompat.toInt(_loc3_ > 0 ? param2.getExpFromIndex(_loc3_ - 1) : 0) : UInt);
         var _loc6_= param2.getExpFromIndex(_loc3_);
         mXPLevelText.text = Std.string(_loc5_);
         mXPBar.value = ASCompat.toNumber(_loc4_ - _loc7_) / (_loc6_ - _loc7_);
         mXPText.text = Std.string(_loc4_) + " / " + Std.string(_loc6_);
      }
      
      public function populateWeaponIcons(param1:Int) 
      {
         var masterType:GMWeaponMastertype;
         var masterTypeString:String;
         var weaponIconIndex:UInt;
         var index= param1;
         var weaponIconCallback:ASFunction = function(param1:Int, param2:GMWeaponMastertype):ASFunction
         {
            var index= param1;
            var subType= param2;
            if(subType.DontShowInTavern)
            {
               return null;
            }
            return function(param1:brain.assetRepository.SwfAsset)
            {
               var _loc5_= param1.getClass(subType.Icon);
               var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
               var _loc6_= ASCompat.dynamicAs((mWeaponIconsVector[index].root : ASAny).bg_slot, flash.display.MovieClip);
               var _loc3_= (Std.int(_loc6_.width <= _loc6_.height ? (Std.int(_loc6_.width * (1 / _loc6_.scaleX)) : UInt) : (Std.int(_loc6_.height * (1 / _loc6_.scaleY)) : UInt)) : UInt);
               UIObject.scaleToFit(_loc4_,_loc3_);
               var _loc2_= ASCompat.dynamicAs(cast((mWeaponIconsVector[index].root : ASAny).bg_slot, flash.display.DisplayObjectContainer).getChildByName("weaponIcon"), flash.display.MovieClip);
               if(ASCompat.toNumberField((mWeaponIconsVector[index].root : ASAny).bg_slot, "numChildren") > 0 && _loc2_ != null)
               {
                  (mWeaponIconsVector[index].root : ASAny).bg_slot.removeChild(_loc2_);
               }
               mWeaponIconsVector[index].visible = true;
               (mWeaponIconsVector[index].root : ASAny).bg_slot.addChild(_loc4_);
               _loc4_.name = "weaponIcon";
               ASCompat.setProperty((mWeaponIconsVector[index].tooltip : ASAny).title_label, "text", subType.Name.toUpperCase());
            };
         };
         var allowedWeaponSubTypes= (mDBFacade.gameMaster.heroById.itemFor(mHeroIds[index]).getAllowedWeaponSubTypes() : Vector<String>);
         var masterTypeVector= new Vector<GMWeaponMastertype>();
         if (checkNullIteratee(allowedWeaponSubTypes)) for (_tmp_ in allowedWeaponSubTypes)
         {
            masterTypeString  = _tmp_;
            masterType = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponSubtypeByConstant.itemFor(masterTypeString), gameMasterDictionary.GMWeaponMastertype);
            if(masterType != null)
            {
               if(!masterType.DontShowInTavern)
               {
                  masterTypeVector.push(masterType);
               }
            }
         }
         if(masterTypeVector.length == 3)
         {
            mWeaponIconsVector = mWeaponIcons3;
            ASCompat.setProperty((mTavernInfoClip : ASAny).character_info.weapons_3, "visible", true);
            ASCompat.setProperty((mTavernInfoClip : ASAny).character_info.weapons_4, "visible", false);
         }
         else if(masterTypeVector.length == 4)
         {
            mWeaponIconsVector = mWeaponIcons4;
            ASCompat.setProperty((mTavernInfoClip : ASAny).character_info.weapons_3, "visible", false);
            ASCompat.setProperty((mTavernInfoClip : ASAny).character_info.weapons_4, "visible", true);
         }
         else
         {
            Logger.warn("UITavern is not set up to deal with anything but 3 or 4 weaponSubTypes.");
            mWeaponIconsVector = mWeaponIcons3;
            ASCompat.setProperty((mTavernInfoClip : ASAny).character_info.weapons_3, "visible", true);
            ASCompat.setProperty((mTavernInfoClip : ASAny).character_info.weapons_4, "visible", false);
         }
         weaponIconIndex = (0 : UInt);
         if (checkNullIteratee(masterTypeVector)) for (_tmp_ in masterTypeVector)
         {
            masterType  = _tmp_;
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(masterType.UISwfFilepath),ASCompat.asFunction(weaponIconCallback(weaponIconIndex,masterType)));
            weaponIconIndex = weaponIconIndex + 1;
            if(weaponIconIndex == (mWeaponIconsVector.length : UInt))
            {
               break;
            }
         }
      }
      
      public function processChosenAvatar() 
      {
         setHeroAndSkin();
      }
      
      function chooseThisHero(param1:UInt, param2:Int) 
      {
         var _loc4_= 0;
         var _loc3_= mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(param1);
         if(_loc3_ != null)
         {
            if(_loc3_ != null && mCurrentChosenIndex < mHeroSlots.length && mCurrentChosenIndex >= 0)
            {
               if(ASCompat.toBool((mHeroSlots[mCurrentChosenIndex].root : ASAny).chosen))
               {
                  ASCompat.setProperty((mHeroSlots[mCurrentChosenIndex].root : ASAny).chosen, "visible", false);
               }
            }
            _loc4_ = 0;
            while(_loc4_ < mHeroSlots.length)
            {
               if(ASCompat.toBool((mHeroSlots[_loc4_].root : ASAny).chosen))
               {
                  ASCompat.setProperty((mHeroSlots[_loc4_].root : ASAny).chosen, "visible", false);
               }
               _loc4_ = ASCompat.toInt(_loc4_) + 1;
            }
            mAvatarIdToMakeActiveAvatar = _loc3_.gmHero.Id;
            if(ASCompat.toBool((mHeroSlots[param2].root : ASAny).chosen))
            {
               ASCompat.setProperty((mHeroSlots[param2].root : ASAny).chosen, "visible", true);
            }
         }
         mCurrentChosenIndex = param2;
         mChosenAvatarID = param1;
      }
      
      function buyThisHero(param1:GMOffer, param2:UInt) 
      {
         var offer= param1;
         var index= param2;
         StoreServicesController.tryBuyOffer(mDBFacade,offer,function(param1:ASAny)
         {
            var _loc2_= offer.Details[0].HeroId;
            DBFacebookBragFeedPost.buyHeroSuccess(mTownHeader,ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(_loc2_), gameMasterDictionary.GMHero),mDBFacade,mAssetLoadingComponent);
            populateAvatarInfo((index : Int));
            populateAvatarSelector();
         });
      }
      
      function buySkin(param1:UInt) 
      {
         var skinId= param1;
         var offer= ASCompat.dynamicAs(mSkinOffers.itemFor(skinId), gameMasterDictionary.GMOffer);
         var saleOffer= offer.isOnSaleNow;
         var currentOffer= saleOffer != null ? saleOffer : offer;
         StoreServicesController.tryBuyOffer(mDBFacade,currentOffer,function(param1:ASAny)
         {
            var _loc3_= mDBFacade.gameMaster.getSkinByType(skinId);
            DBFacebookBragFeedPost.buySkinSuccess(_loc3_,mDBFacade,mAssetLoadingComponent);
            var _loc2_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroByConstant.itemFor(_loc3_.ForHero), gameMasterDictionary.GMHero);
            if(_loc2_ == null)
            {
               Logger.error("Unable to find gmHero by constant: " + _loc3_.ForHero);
            }
            if(_loc2_ != null && mHeroSelectionsToFlush.hasKey(_loc2_.Id))
            {
               mHeroSelectionsToFlush.removeKey(_loc2_.Id);
            }
            populateAvatarInfo(mCurrentChosenIndex);
            populateAvatarSelector();
         });
      }
      
            
      @:isVar public var avatarSelectorStartIndex(get,set):Int;
public function  set_avatarSelectorStartIndex(param1:Int) :Int      {
         if(param1 == mAvatarSelectorStartIndex)
         {
            return param1;
         }
         mAvatarSelectorStartIndex = param1;
         populateAvatarSelector();
         if(mSelectorRightScroll.visible && mAvatarSelectorStartIndex + mHeroSlots.length >= mHeroIds.length)
         {
            mSelectorRightScroll.visible = false;
         }
         else if(!mSelectorRightScroll.visible && mAvatarSelectorStartIndex + mHeroSlots.length < mHeroIds.length)
         {
            mSelectorRightScroll.visible = true;
         }
         if(mSelectorLeftScroll.visible && mAvatarSelectorStartIndex == 0)
         {
            mSelectorLeftScroll.visible = false;
         }
         else if(!mSelectorLeftScroll.visible && mAvatarSelectorStartIndex > 0)
         {
            mSelectorLeftScroll.visible = true;
         }
return param1;
      }
      
      @:isVar public var currentChosenIndex(never,set):Int;
public function  set_currentChosenIndex(param1:Int) :Int      {
         return mCurrentChosenIndex = param1;
      }
function  get_avatarSelectorStartIndex() : Int
      {
         return mAvatarSelectorStartIndex;
      }
      
      function changeActiveAvatarRPC(param1:UInt) 
      {
         mDBFacade.dbAccountInfo.changeActiveAvatarRPC(param1);
      }
      
      public function destroy() 
      {
         var _loc1_= 0;
         mAssetLoadingComponent.destroy();
         _loc1_ = 0;
         while(_loc1_ < mHeroSlots.length)
         {
            if(mHeroSlots[_loc1_] != null)
            {
               mHeroSlots[_loc1_].destroy();
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < mWeaponIcons3.length)
         {
            if(mWeaponIcons3[_loc1_] != null)
            {
               mWeaponIcons3[_loc1_].destroy();
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < mWeaponIcons4.length)
         {
            if(mWeaponIcons4[_loc1_] != null)
            {
               mWeaponIcons4[_loc1_].destroy();
            }
            _loc1_++;
         }
         if(mSelectorRightScroll != null)
         {
            mSelectorRightScroll.destroy();
         }
         if(mSelectorLeftScroll != null)
         {
            mSelectorLeftScroll.destroy();
         }
         if(mXPBar != null)
         {
            mXPBar.destroy();
         }
         if(mXPParentObject != null)
         {
            mXPParentObject.destroy();
         }
         mTavernInfoClip = null;
      }
   }


