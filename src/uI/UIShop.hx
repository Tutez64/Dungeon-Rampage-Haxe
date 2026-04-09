package uI
;
   import account.AvatarInfo;
   import account.StoreServices;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIRadioButton;
   import brain.utils.MemoryTracker;
   import brain.utils.TimeSpan;
   import brain.workLoop.LogicalWorkComponent;
   import dBGlobals.DBGlobal;
   import facade.DBFacade;
   import facade.Locale;
   import facebookAPI.DBFacebookBragFeedPost;
   import gameMasterDictionary.GMHero;
   import gameMasterDictionary.GMNpc;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMWeaponItem;
   import town.TownHeader;
   import uI.equipPicker.HeroWithEquipPicker;
   import flash.display.MovieClip;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
    class UIShop
   {
      
      public static inline final WEAPON_LEVEL_DISPLAY_RANGE= (10 : UInt);
      
      static inline final SELECTED_TAB_SCALE:Float = 1.15;
      
      public static inline final SPECIAL_CATEGORY= "SPECIAL";
      
      public static inline final CHEST_CATEGORY= "CHEST";
      
      public static inline final KEY_CATEGORY= "KEY";
      
      public static inline final HERO_CATEGORY= "HERO";
      
      public static inline final WEAPON_CATEGORY= "WEAPON";
      
      public static inline final STUFF_CATEGORY= "STUFF";
      
      public static inline final PET_CATEGORY= "PET";
      
      public static inline final SKIN_CATEGORY= "SKIN";
      
      static inline final DEFAULT_CATEGORY= "SPECIAL";
      
      static inline final NUM_OFFERS_PER_PAGE= (6 : UInt);
      
      static inline final NUM_WEAPON_OFFERS_PER_PAGE= (3 : UInt);
      
      static inline final TEMPLATE_CLASSNAME= "shop_offer_template";
      
      static inline final KEY_TEMPLATE_CLASSNAME= "shop_offer_key_template";
      
      static inline final PREMIUM_TEMPLATE_CLASSNAME= "shop_offer_premium_template";
      
      static inline final NEW_WEAPONS_TEMPLATE_CLASSNAME= "shop_offer_weapon_template";
      
      static inline final LIMITED_OFFER_REFRESH_TIME:Float = 60000;
      
      static final CATEGORIES:Vector<String> = Vector.ofArray(["SPECIAL","CHEST","KEY","HERO","STUFF","WEAPON","PET","SKIN"]);
      
      var mDBFacade:DBFacade;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mRoot:MovieClip;
      
      var mSwfAsset:SwfAsset;
      
      var mOfferTemplateClass:Dynamic;
      
      var mKeyOfferTemplateClass:Dynamic;
      
      var mPremiumOfferTemplateClass:Dynamic;
      
      var mWeaponOfferTemplateClass:Dynamic;
      
      var mTownHeader:TownHeader;
      
      var mSelectedHero:GMHero;
      
      var mCurrentPage:UInt = (0 : UInt);
      
      var mCurrentTab:String;
      
      var mNextLimitedOfferRefreshTime:Float = Math.NaN;
      
      var mUIOffers:Vector<UIShopOffer>;
      
      var mEmptyOffers:Vector<MovieClip>;
      
      var mZeroOfferClip:MovieClip;
      
      var mCategorizedGMOffers:Map;
      
      var mFilteredGMOffers:Map;
      
      var mTabButtons:Map;
      
      var mPagination:UIPagingPanel;
      
      var mHeroWithEquipPicker:HeroWithEquipPicker;
      
      var mEventComponent:EventComponent;
      
      var mWeaponsLogicalWorkComponent:LogicalWorkComponent;
      
      var mWeaponTabEndDate:Date;
      
      public function new(param1:DBFacade, param2:SwfAsset, param3:MovieClip, param4:TownHeader)
      {
         
         mDBFacade = param1;
         mSwfAsset = param2;
         mTownHeader = param4;
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mWeaponsLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mUIOffers = new Vector<UIShopOffer>();
         mEmptyOffers = new Vector<MovieClip>();
         mTabButtons = new Map();
         mFilteredGMOffers = new Map();
         this.processGMOffers();
         this.sortOffers();
         this.filterOffers();
         this.setupUI(param3);
         mNextLimitedOfferRefreshTime = GameClock.getWebServerTime();
      }
      
      public function regenerateOffers() 
      {
         mDBFacade.regenerateGameMaster();
         this.processGMOffers();
         this.sortOffers();
         this.filterOffers();
         displayCategoryPage();
      }
      
      public function destroy() 
      {
         var _loc2_:UIRadioButton = null;
         cleanUpTodaysShopTimerUI();
         mWeaponsLogicalWorkComponent.destroy();
         mWeaponsLogicalWorkComponent = null;
         mLogicalWorkComponent.destroy();
         mDBFacade = null;
         mSwfAsset = null;
         var _loc1_= ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(_loc1_.hasNext())
         {
            _loc2_ = ASCompat.dynamicAs(_loc1_.next(), brain.uI.UIRadioButton);
            _loc2_.destroy();
         }
         mTabButtons.clear();
         mTabButtons = null;
         mUIOffers = null;
         mEmptyOffers = null;
         mZeroOfferClip = null;
         mCategorizedGMOffers.clear();
         if(mFilteredGMOffers != null)
         {
            mFilteredGMOffers.clear();
         }
         mPagination.destroy();
         mHeroWithEquipPicker.destroy();
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
      }
      
      @:isVar public var root(get,never):MovieClip;
public function  get_root() : MovieClip
      {
         return mRoot;
      }
      
      public function refresh(param1:String = "") 
      {
         var owned:Bool;
         var popup:DBUIPopup;
         var startAtCategoryTab= param1;
         mTownHeader.title = Locale.getString("SHOP_HEADER");
         if(!ASCompat.stringAsBool(mCurrentTab))
         {
            mCurrentTab = "SPECIAL";
         }
         if(startAtCategoryTab != "")
         {
            mCurrentTab = startAtCategoryTab;
            startAtCategoryTab = "";
         }
         mHeroWithEquipPicker.refresh(true);
         mSelectedHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mDBFacade.dbAccountInfo.activeAvatarInfo.avatarType), gameMasterDictionary.GMHero);
         owned = mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mSelectedHero.Id);
         this.heroSelected(mSelectedHero,owned);
         if(mDBFacade.gameClock.realTime >= mNextLimitedOfferRefreshTime && !mDBFacade.mInDailyReward)
         {
            mNextLimitedOfferRefreshTime = GameClock.getWebServerTime() + 60000;
            popup = new DBUIPopup(mDBFacade,Locale.getString("SHOP_UPDATING"),null,false);
            MemoryTracker.track(popup,"DBUIPopup - created in UIShop.refresh()");
            StoreServices.getLimitedOfferUsage(mDBFacade,null,function(param1:ASAny)
            {
               popup.destroy();
               showTab(mCurrentTab);
            },function(param1:Error)
            {
               StoreServicesController.showErrorPopup(mDBFacade,param1);
            });
         }
         else
         {
            showTab(mCurrentTab);
         }
         if(mTownHeader != null)
         {
            mTownHeader.refreshKeyPanel();
         }
      }
      
      function processGMOffers() 
      {
         var _loc6_:String = null;
         var _loc2_:Vector<GMOffer> = /*undefined*/null;
         var _loc7_:GMOffer = null;
         var _loc4_:ASAny = null;
         var _loc5_= 0;
         mCategorizedGMOffers = new Map();
         final __ax4_iter_111 = CATEGORIES;
         if (checkNullIteratee(__ax4_iter_111)) for (_tmp_ in __ax4_iter_111)
         {
            _loc6_  = _tmp_;
            mCategorizedGMOffers.add(_loc6_,new Vector<GMOffer>());
         }
         var _loc1_= mDBFacade.gameMaster.Offers;
         var _loc3_= (mCategorizedGMOffers.itemFor("SPECIAL") : Vector<GMOffer>);
         _loc5_ = 0;
         while(_loc5_ < _loc1_.length)
         {
            _loc7_ = _loc1_[_loc5_];
            if(_loc7_.Location == "STORE")
            {
               if(!_loc7_.Gift)
               {
                  _loc6_ = _loc7_.Tab;
                  _loc2_ = mCategorizedGMOffers.itemFor(_loc6_);
                  if(_loc2_ != null)
                  {
                     _loc2_.push(_loc7_);
                  }
                  else
                  {
                     Logger.debug("Categoryoffers are null for category: " + _loc6_);
                  }
                  if(_loc7_.Special && _loc3_.indexOf(_loc7_) == -1)
                  {
                     _loc3_.push(_loc7_);
                  }
               }
            }
            _loc5_ = ASCompat.toInt(_loc5_) + 1;
         }
      }
      
      function specialSortComparator(param1:GMOffer, param2:GMOffer) : Int
      {
         var _loc4_= param1.isOnSaleNow != null;
         var _loc3_= param2.isOnSaleNow != null;
         if(_loc4_ && _loc3_)
         {
            return (param1.Id - param2.Id : Int);
         }
         if(_loc4_ && !_loc3_)
         {
            return -1;
         }
         if(_loc3_ && !_loc4_)
         {
            return 1;
         }
         if(param1.isNew && !param2.isNew)
         {
            return -1;
         }
         if(param2.isNew && !param1.isNew)
         {
            return 1;
         }
         return (param1.Id - param2.Id : Int);
      }
      
      function potionSortComparator(param1:GMOffer, param2:GMOffer) : Int
      {
         return Std.int(param1.Price - param2.Price);
      }
      
      function keySortComparator(param1:GMOffer, param2:GMOffer) : Int
      {
         var _loc6_= param1.Details[0];
         var _loc5_= param2.Details[0];
         var _loc7_= _loc6_.BasicKeys + _loc6_.UncommonKeys + _loc6_.RareKeys + _loc6_.LegendaryKeys;
         var _loc8_= _loc5_.BasicKeys + _loc5_.UncommonKeys + _loc5_.RareKeys + _loc5_.LegendaryKeys;
         var _loc4_= param1.isAvailableTime();
         var _loc3_= param2.isAvailableTime();
         if(_loc4_ && !_loc3_)
         {
            return -1;
         }
         if(_loc3_ && !_loc4_)
         {
            return 1;
         }
         if(_loc7_ == _loc8_)
         {
            return Std.int(param1.Price - param2.Price);
         }
         return (_loc7_ - _loc8_ : Int);
      }
      
      function weaponSortComparator(param1:GMOffer, param2:GMOffer) : Int
      {
         if(param1.IsBundle && param2.IsBundle)
         {
            return Std.int(param1.Price - param2.Price);
         }
         if(param1.IsBundle && !param2.IsBundle)
         {
            return -1;
         }
         if(param2.IsBundle && !param1.IsBundle)
         {
            return 1;
         }
         var _loc4_= param1.Details[0];
         var _loc3_= param2.Details[0];
         var _loc6_= ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(_loc4_.WeaponId), gameMasterDictionary.GMWeaponItem);
         var _loc7_= ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(_loc3_.WeaponId), gameMasterDictionary.GMWeaponItem);
         var _loc5_= GMWeaponItem.ALL_WEAPON_SORT.indexOf(_loc6_.MasterType);
         var _loc8_= GMWeaponItem.ALL_WEAPON_SORT.indexOf(_loc7_.MasterType);
         if(_loc5_ == -1)
         {
            Logger.error("Mastertype not found: " + _loc6_.MasterType);
         }
         if(_loc8_ == -1)
         {
            Logger.error("Mastertype not found: " + _loc7_.MasterType);
         }
         if(param1.Details[0].Level == param2.Details[0].Level)
         {
            return _loc5_ - _loc8_;
         }
         return (param1.Details[0].Level - param2.Details[0].Level : Int);
      }
      
      function sortOffers() 
      {
         var _loc4_= (mCategorizedGMOffers.itemFor("WEAPON") : Vector<GMOffer>);
         ASCompat.ASVector.sort(_loc4_, weaponSortComparator);
         var _loc2_= (mCategorizedGMOffers.itemFor("KEY") : Vector<GMOffer>);
         ASCompat.ASVector.sort(_loc2_, keySortComparator);
         var _loc3_= (mCategorizedGMOffers.itemFor("STUFF") : Vector<GMOffer>);
         ASCompat.ASVector.sort(_loc3_, potionSortComparator);
         var _loc1_= (mCategorizedGMOffers.itemFor("SPECIAL") : Vector<GMOffer>);
         ASCompat.ASVector.sort(_loc1_, specialSortComparator);
      }
      
      function setupUI(param1:MovieClip) 
      {
         var group:String;
         var tabButton:UIRadioButton;
         var iter:IMapIterator;
         var weaponTooltipClass:Dynamic;
         var heroTooltipClass:Dynamic;
         var rootClip= param1;
         mRoot = rootClip;
         mPagination = new UIPagingPanel(mDBFacade,(0 : UInt),ASCompat.dynamicAs((mRoot : ASAny).pagination, flash.display.MovieClip),mSwfAsset.getClass("pagination_button"),this.setCurrentPage);
         MemoryTracker.track(mPagination,"UIPagingPanel - created in UIShop.setupUI()");
         ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer, "visible", false);
         group = "UIShopTabGroup";
         mTabButtons.add("SPECIAL",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_special, flash.display.MovieClip),group));
         mTabButtons.add("CHEST",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_chests, flash.display.MovieClip),group));
         mTabButtons.add("KEY",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_keys, flash.display.MovieClip),group));
         mTabButtons.add("HERO",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_heroes, flash.display.MovieClip),group));
         mTabButtons.add("SKIN",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_skins, flash.display.MovieClip),group));
         mTabButtons.add("STUFF",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_stuff, flash.display.MovieClip),group));
         mTabButtons.add("WEAPON",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_melee, flash.display.MovieClip),group));
         mTabButtons.add("PET",new UIRadioButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).tab_pets, flash.display.MovieClip),group));
         iter = ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(iter.hasNext())
         {
            tabButton = ASCompat.dynamicAs(iter.next(), brain.uI.UIRadioButton);
            ASCompat.setProperty((tabButton.root : ASAny).new_label, "text", Locale.getString("SHOP_NEW"));
            ASCompat.setProperty((tabButton.root : ASAny).new_label, "visible", this.categoryHasAnyNewOffers(iter.key));
            ASCompat.setProperty(tabButton.root, "category", iter.key);
            tabButton.releaseCallbackThis = function(param1:brain.uI.UIButton)
            {
               showTab((param1.root : ASAny).category);
            };
            tabButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            tabButton.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         }
         mEmptyOffers.push(ASCompat.dynamicAs((mRoot : ASAny).shop_empty_slot_0, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mRoot : ASAny).shop_empty_slot_1, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mRoot : ASAny).shop_empty_slot_2, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mRoot : ASAny).shop_empty_slot_3, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mRoot : ASAny).shop_empty_slot_4, flash.display.MovieClip));
         mEmptyOffers.push(ASCompat.dynamicAs((mRoot : ASAny).shop_empty_slot_5, flash.display.MovieClip));
         mOfferTemplateClass = mSwfAsset.getClass("shop_offer_template");
         mKeyOfferTemplateClass = mSwfAsset.getClass("shop_offer_key_template");
         mPremiumOfferTemplateClass = mSwfAsset.getClass("shop_offer_premium_template");
         mWeaponOfferTemplateClass = mSwfAsset.getClass("shop_offer_weapon_template");
         weaponTooltipClass = mSwfAsset.getClass("DR_weapon_tooltip");
         heroTooltipClass = mSwfAsset.getClass("avatar_tooltip");
         mHeroWithEquipPicker = new HeroWithEquipPicker(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).hero_picker, flash.display.MovieClip),weaponTooltipClass,heroTooltipClass,heroSelected);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",accountInfoUpdated);
      }
      
      function accountInfoUpdated(param1:Event) 
      {
         refresh();
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            mTownHeader.rootMovieClip.visible = false;
            mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock)
            {
               mTownHeader.animateHeader();
            });
            mHeroWithEquipPicker.visible = false;
            mLogicalWorkComponent.doLater(0.5,function(param1:GameClock)
            {
               UITownTweens.footerTweenSequence(mHeroWithEquipPicker.root,mDBFacade);
            });
         }
      }
      
      function numOffersInCurrentCategory() : UInt
      {
         var _loc1_= (mFilteredGMOffers.itemFor(mCurrentTab) : Vector<GMOffer>);
         if(_loc1_ != null)
         {
            return (_loc1_.length : UInt);
         }
         return (0 : UInt);
      }
      
      function numPagesInCurrentCategory() : UInt
      {
         var _loc1_= (1 : UInt);
         if(mCurrentTab == "WEAPON")
         {
            return (Math.ceil(numOffersInCurrentCategory() / 3) : UInt);
         }
         return (Math.ceil(numOffersInCurrentCategory() / 6) : UInt);
      }
      
      function displayCategoryPage() 
      {
         var gmOffer:GMOffer = null;
         var uiShopOffer:UIShopOffer;
         var onscreenIndex:UInt;
         var emptyOffer:MovieClip;
         var chargeTooltipClass:Dynamic;
         var weaponDescTooltipClass:Dynamic;
         var numOffersPerPage:UInt;
         var startIndex:UInt;
         var templateClass:Dynamic;
         var successCallback:ASFunction;
         var categoryOffers= (mFilteredGMOffers.itemFor(mCurrentTab) : Vector<GMOffer>);
         var i= (0 : UInt);
         while(i < 6)
         {
            if(i < (mUIOffers.length : UInt))
            {
               uiShopOffer = mUIOffers[(i : Int)];
               uiShopOffer.detach();
               uiShopOffer.destroy();
            }
            mEmptyOffers[(i : Int)].visible = false;
            i = i + 1;
         }
         mUIOffers.length = 0;
         if(mZeroOfferClip != null)
         {
            mEmptyOffers[1].parent.removeChild(mZeroOfferClip);
            mZeroOfferClip = null;
         }
         if(categoryOffers.length == 0)
         {
            emptyOffer = mEmptyOffers[1];
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset)
            {
               var _loc2_= param1.getClass("shop_offer_inventory_empty");
               mZeroOfferClip = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
               emptyOffer.parent.addChild(mZeroOfferClip);
               mZeroOfferClip.x = emptyOffer.x;
               mZeroOfferClip.y = emptyOffer.y;
               mZeroOfferClip.scaleX = mZeroOfferClip.scaleY = 1.8;
               ASCompat.setProperty((mZeroOfferClip : ASAny).title, "text", Locale.getString("ZERO_OFFER_TITLE"));
               ASCompat.setProperty((mZeroOfferClip : ASAny).description, "text", Locale.getString("ZERO_OFFER_DESCRIPTION"));
            });
            return;
         }
         chargeTooltipClass = mSwfAsset.getClass("DR_charge_tooltip");
         weaponDescTooltipClass = mSwfAsset.getClass("weapon_desc_tooltip");
         numOffersPerPage = (mCurrentTab == "WEAPON" ? (3 : UInt) : (6 : UInt) : UInt);
         startIndex = mCurrentPage * numOffersPerPage;
         i = startIndex;
         while(i < startIndex + numOffersPerPage)
         {
            if(i >= (categoryOffers.length : UInt))
            {
               break;
            }
            gmOffer = categoryOffers[(i : Int)];
            onscreenIndex = i % numOffersPerPage;
            templateClass = gmOffer.CurrencyType == "PREMIUM" && ASCompat.floatAsBool(gmOffer.Price) ? mPremiumOfferTemplateClass : mOfferTemplateClass;
            templateClass = gmOffer.Tab == "KEY" || gmOffer.Tab == "CHEST" ? mKeyOfferTemplateClass : templateClass;
            templateClass = gmOffer.Tab == "WEAPON" ? mWeaponOfferTemplateClass : templateClass;
            if(gmOffer.Details[0].ChestId != 0)
            {
               uiShopOffer = new UIChestOffer(mDBFacade,templateClass,this.mHeroWithEquipPicker.currentlySelectedAvatarInfo,chestRevealResponse);
            }
            else if(gmOffer.IsBundle)
            {
               uiShopOffer = new UIShopBundleOffer(mDBFacade,templateClass);
            }
            else if(gmOffer.Details[0].WeaponId != 0)
            {
               uiShopOffer = new UIShopWeaponOffer(mDBFacade,templateClass,weaponDescTooltipClass,chargeTooltipClass);
               cast(uiShopOffer, UIShopWeaponOffer).setRolloverCallbacks(onWeaponRollOver,onWeaponRollOut);
            }
            else if(gmOffer.Details[0].HeroId != 0)
            {
               successCallback = function(param1:UInt):ASFunction
               {
                  var heroId= param1;
                  return function()
                  {
                     if(mDBFacade == null)
                     {
                        return;
                     }
                     var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(heroId), gameMasterDictionary.GMHero);
                     if(_loc1_ == null)
                     {
                        return;
                     }
                     DBFacebookBragFeedPost.buyHeroSuccess(mTownHeader,_loc1_,mDBFacade,mAssetLoadingComponent);
                  };
               };
               uiShopOffer = new UIShopHeroOffer(mTownHeader,mDBFacade,templateClass,ASCompat.asFunction(successCallback(gmOffer.Details[0].HeroId)));
            }
            else if(gmOffer.Details[0].PetId != 0)
            {
               successCallback = function(param1:UInt):ASFunction
               {
                  var petId= param1;
                  return function()
                  {
                     if(mDBFacade == null)
                     {
                        return;
                     }
                     var _loc1_= ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(petId), gameMasterDictionary.GMNpc);
                     if(_loc1_ == null)
                     {
                        return;
                     }
                     DBFacebookBragFeedPost.buyPetSuccess(_loc1_,mDBFacade,mAssetLoadingComponent);
                  };
               };
               uiShopOffer = new UIShopPetOffer(mDBFacade,templateClass,ASCompat.asFunction(successCallback(gmOffer.Details[0].PetId)));
            }
            else if(gmOffer.Details[0].SkinId != 0)
            {
               successCallback = function(param1:UInt):ASFunction
               {
                  var skinId= param1;
                  return function()
                  {
                     if(mDBFacade == null)
                     {
                        return;
                     }
                     var _loc1_= mDBFacade.gameMaster.getSkinByType(skinId);
                     if(_loc1_ == null)
                     {
                        return;
                     }
                     DBFacebookBragFeedPost.buySkinSuccess(_loc1_,mDBFacade,mAssetLoadingComponent);
                  };
               };
               uiShopOffer = new UIShopSkinOffer(mDBFacade,templateClass,ASCompat.asFunction(successCallback(gmOffer.Details[0].SkinId)));
            }
            else
            {
               uiShopOffer = new UIShopOffer(mDBFacade,templateClass);
            }
            emptyOffer = mEmptyOffers[(onscreenIndex : Int)];
            emptyOffer.parent.addChild(uiShopOffer.root);
            uiShopOffer.root.x = emptyOffer.x;
            uiShopOffer.root.y = emptyOffer.y;
            mUIOffers[(onscreenIndex : Int)] = uiShopOffer;
            uiShopOffer.showOffer(gmOffer,mSelectedHero);
            uiShopOffer.root.visible = true;
            uiShopOffer.root.scaleX = uiShopOffer.root.scaleY = 1.8;
            mEmptyOffers[(onscreenIndex : Int)].visible = false;
            if(mCurrentTab == "WEAPON")
            {
               uiShopOffer.root.y += 72;
            }
            i = i + 1;
         }
         if(mCurrentTab == "WEAPON")
         {
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer, "visible", true);
            createTodaysShopTimerUI(gmOffer);
         }
         else
         {
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer, "visible", false);
            cleanUpTodaysShopTimerUI();
         }
      }
      
      function createTodaysShopTimerUI(param1:GMOffer) 
      {
         ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.offer_title, "text", Locale.getString("TODAYS_WEAPONS"));
         ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_date, "text", getDate());
         if(param1 != null)
         {
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_timer, "visible", true);
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_remaining, "visible", true);
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_remaining, "text", Locale.getString("TODAYS_WEAPONS_REMAINING"));
            mWeaponTabEndDate = param1.EndDate;
            mWeaponsLogicalWorkComponent.doEverySeconds(1,updateRemainingTimeText);
         }
         else
         {
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_timer, "visible", false);
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_remaining, "visible", false);
            cleanUpTodaysShopTimerUI();
         }
      }
      
      function cleanUpTodaysShopTimerUI() 
      {
         mWeaponsLogicalWorkComponent.clear();
      }
      
      function updateRemainingTimeText(param1:GameClock = null) 
      {
         var _loc6_:TimeSpan = null;
         var _loc2_:String = null;
         var _loc4_:String = null;
         var _loc3_:String = null;
         var _loc5_= GameClock.getWebServerDate();
         if(_loc5_.getTime() > mWeaponTabEndDate.getTime())
         {
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_timer, "text", "00:00:00");
            regenerateOffers();
         }
         else
         {
            _loc6_ = new TimeSpan(mWeaponTabEndDate.getTime() - _loc5_.getTime());
            _loc2_ = Std.string(_loc6_.hours);
            if(_loc2_.length == 1)
            {
               _loc2_ = "0" + _loc2_;
            }
            _loc4_ = Std.string(_loc6_.minutes);
            if(_loc4_.length == 1)
            {
               _loc4_ = "0" + _loc4_;
            }
            _loc3_ = Std.string(_loc6_.seconds);
            if(_loc3_.length == 1)
            {
               _loc3_ = "0" + _loc3_;
            }
            ASCompat.setProperty((mRoot : ASAny).UI_town_shop_timer.label_timer, "text", _loc2_ + ":" + _loc4_ + ":" + _loc3_);
         }
      }
      
      function chestRevealResponse(param1:ASObject) 
      {
         trace("Made it to here.");
      }
      
      function getDate() : String
      {
         var _loc4_:String = null;
         var _loc2_:String = null;
         var _loc5_= GameClock.getWebServerDate();
         var _loc3_= Std.string(_loc5_.getFullYear());
         switch(_loc5_.getDay())
         {
            case 0:
               _loc4_ = "Sunday";
               
            case 1:
               _loc4_ = "Monday";
               
            case 2:
               _loc4_ = "Tuesday";
               
            case 3:
               _loc4_ = "Wednesday";
               
            case 4:
               _loc4_ = "Thursday";
               
            case 5:
               _loc4_ = "Friday";
               
            case 6:
               _loc4_ = "Saturday";
         }
         switch(_loc5_.getMonth())
         {
            case 0:
               _loc2_ = "January";
               
            case 1:
               _loc2_ = "February";
               
            case 2:
               _loc2_ = "March";
               
            case 3:
               _loc2_ = "April";
               
            case 4:
               _loc2_ = "May";
               
            case 5:
               _loc2_ = "June";
               
            case 6:
               _loc2_ = "July";
               
            case 7:
               _loc2_ = "August";
               
            case 8:
               _loc2_ = "September";
               
            case 9:
               _loc2_ = "October";
               
            case 10:
               _loc2_ = "November";
               
            case 11:
               _loc2_ = "December";
         }
         var _loc1_= Std.string(_loc5_.getDate());
         return _loc4_ + " " + _loc2_ + " " + _loc1_;
      }
      
      function onWeaponRollOver(param1:GMWeaponItem, param2:UInt) 
      {
         mHeroWithEquipPicker.showWeaponComparison(param1,param2);
      }
      
      function onWeaponRollOut(param1:GMWeaponItem, param2:UInt) 
      {
         mHeroWithEquipPicker.hideWeaponComparison();
      }
      
      public function showTab(param1:String, param2:UInt = (0 : UInt)) 
      {
         var _loc3_:UIRadioButton = null;
         mCurrentTab = param1;
         var _loc4_= ASCompat.reinterpretAs(mTabButtons.iterator() , IMapIterator);
         while(_loc4_.hasNext())
         {
            _loc3_ = ASCompat.dynamicAs(_loc4_.next(), brain.uI.UIRadioButton);
            _loc3_.enabled = true;
         }
         _loc3_ = ASCompat.dynamicAs(mTabButtons.itemFor(mCurrentTab), brain.uI.UIRadioButton);
         _loc3_.selected = true;
         _loc3_.enabled = false;
         _loc3_.label.visible = true;
         if(mCurrentTab == "WEAPON")
         {
            param2 = this.firstWeaponPageForActiveHero();
         }
         this.refreshPagination(param2);
         mDBFacade.metrics.log("ShopDisplay",{
            "category":mCurrentTab,
            "page":mCurrentPage
         });
         displayCategoryPage();
      }
      
      function firstWeaponPageForActiveHero() : UInt
      {
         var _loc1_= 0;
         var _loc5_:Vector<GMOffer> = /*undefined*/null;
         var _loc3_= 0;
         var _loc6_= 0;
         var _loc8_:GMOffer = null;
         var _loc2_:GMWeaponItem = null;
         var _loc7_= (0 : UInt);
         var _loc4_= ASCompat.dynamicAs(mSelectedHero != null ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id) : null, account.AvatarInfo);
         if(_loc4_ != null)
         {
            _loc1_ = (_loc4_.level : Int);
            _loc5_ = mFilteredGMOffers.itemFor(mCurrentTab);
            _loc3_ = mCurrentTab == "WEAPON" ? 3 : 6;
            _loc6_ = 0;
            while(_loc6_ < ASCompat.toNumberField(_loc5_, "length"))
            {
               _loc8_ = ASCompat.dynamicAs(_loc5_[_loc6_], gameMasterDictionary.GMOffer);
               if(_loc8_.Details[0].WeaponId != 0)
               {
                  _loc2_ = ASCompat.dynamicAs(mDBFacade.gameMaster.weaponItemById.itemFor(_loc8_.Details[0].WeaponId), gameMasterDictionary.GMWeaponItem);
                  _loc7_ = (Math.floor(_loc6_ / _loc3_) : UInt);
                  if(_loc8_.Details[0].Level >= (_loc1_ : UInt))
                  {
                     return _loc7_;
                  }
                  return (0 : UInt);
               }
               _loc6_ = ASCompat.toInt(_loc6_) + 1;
            }
         }
         return _loc7_;
      }
      
      function refreshPagination(param1:UInt) 
      {
         var _loc2_= this.numPagesInCurrentCategory();
         mPagination.currentPage = mCurrentPage = (Std.int(_loc2_ != 0 ? (Std.int(Math.min(_loc2_ - 1,param1)) : UInt) : (0 : UInt)) : UInt);
         mPagination.numPages = _loc2_;
         mPagination.visible = _loc2_ > 1;
      }
      
      function setCurrentPage(param1:UInt) 
      {
         this.refreshPagination(param1);
         mDBFacade.metrics.log("ShopDisplay",{
            "category":mCurrentTab,
            "page":mCurrentPage
         });
         displayCategoryPage();
      }
      
      public function jumpToOffer(param1:UInt) : Bool
      {
         var _loc6_= ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(param1), gameMasterDictionary.GMOffer);
         if(_loc6_ == null)
         {
            return false;
         }
         var _loc5_= _loc6_.Tab;
         var _loc2_= (mFilteredGMOffers.itemFor(_loc5_) : Vector<GMOffer>);
         var _loc3_= _loc2_.indexOf(_loc6_);
         if(_loc3_ == -1)
         {
            return false;
         }
         var _loc4_= (Math.floor(_loc3_ / 6) : UInt);
         this.showTab(_loc5_,_loc4_);
         return true;
      }
      
      function categoryHasAnyNewOffers(param1:String) : Bool
      {
         var _loc2_:GMOffer = null;
         var _loc3_= (mFilteredGMOffers.itemFor(param1) : Vector<GMOffer>);
         if(_loc3_ == null)
         {
            Logger.error("invalid category: " + param1);
         }
         if (checkNullIteratee(_loc3_)) for (_tmp_ in _loc3_)
         {
            _loc2_  = _tmp_;
            if(ASCompat.toBool(_loc2_.isNew))
            {
               return true;
            }
         }
         return false;
      }
      
      function filterOffers() 
      {
         var __ax4_iter_113:Vector<GMOffer>;
         var _loc10_:String = null;
         var _loc1_:Vector<GMOffer> = /*undefined*/null;
         var _loc2_:GMOffer = null;
         var _loc8_= 0;
         var _loc9_= 0;
         var _loc11_= 0;
         var _loc7_= 0;
         var _loc4_:String = null;
         var _loc3_= 0;
         var _loc6_:GMHero = null;
         trace("UIShop:filterOffers");
         var _loc5_= ASCompat.dynamicAs(mSelectedHero != null ? mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(mSelectedHero.Id) : null, account.AvatarInfo);
         mFilteredGMOffers.clear();
         final __ax4_iter_112 = CATEGORIES;
         if (checkNullIteratee(__ax4_iter_112)) for (_tmp_ in __ax4_iter_112)
         {
            _loc10_  = _tmp_;
            _loc1_ = new Vector<GMOffer>();
            mFilteredGMOffers.add(_loc10_,_loc1_);
            __ax4_iter_113 = mCategorizedGMOffers.itemFor(_loc10_);
            if (checkNullIteratee(__ax4_iter_113)) for (_tmp_ in __ax4_iter_113)
            {
               _loc2_  = _tmp_;
               if(!ASCompat.toBool(_loc2_.SaleTargetOffer))
               {
                  if(!ASCompat.toBool(_loc2_.IsCoinAltOffer))
                  {
                     if(!(_loc10_ == "SPECIAL" && StoreServicesController.alreadyOwns(mDBFacade,_loc2_)))
                     {
                        if(!(ASCompat.toBool(_loc2_.IsBundle) && StoreServicesController.alreadyOwns(mDBFacade,_loc2_)))
                        {
                           if(mSelectedHero != null)
                           {
                              _loc11_ = (StoreServicesController.requiredHeroForWeapon(mDBFacade,_loc2_) : Int);
                              if(_loc11_ != 0 && (_loc11_ : UInt) != mSelectedHero.Id)
                              {
                                 continue;
                              }
                              _loc7_ = (StoreServicesController.getOfferLevelReq(mDBFacade,_loc2_) : Int);
                              _loc3_ = ASCompat.toInt(_loc5_ != null ? _loc5_.level : 1);
                              _loc4_ = StoreServicesController.getWeaponMastertype(mDBFacade,_loc2_);
                              if(ASCompat.stringAsBool(_loc4_) && !mSelectedHero.AllowedWeapons.hasKey(_loc4_))
                              {
                                 continue;
                              }
                           }
                           _loc8_ = (StoreServicesController.getHeroId(mDBFacade,_loc2_) : Int);
                           _loc6_ = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(_loc8_), gameMasterDictionary.GMHero);
                           if(!(_loc6_ != null && _loc6_.Hidden && !mDBFacade.dbConfigManager.getConfigBoolean("want_hidden_heroes",false)))
                           {
                              if(!(_loc8_ != 0 && mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((_loc8_ : UInt))))
                              {
                                 _loc9_ = (StoreServicesController.getSkinId(mDBFacade,_loc2_) : Int);
                                 if(!(_loc9_ != 0 && mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((_loc9_ : UInt))))
                                 {
                                    _loc1_.push(_loc2_);
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
      }
      
      function heroSelected(param1:GMHero, param2:Bool) 
      {
         mSelectedHero = param1;
         this.filterOffers();
         if(mCurrentTab == "WEAPON")
         {
            this.refreshPagination(this.firstWeaponPageForActiveHero());
         }
         this.displayCategoryPage();
      }
      
      public function processChosenAvatar() 
      {
         var _loc1_= mHeroWithEquipPicker.currentlySelectedHero.Id;
         if(mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Id != _loc1_)
         {
            mDBFacade.dbAccountInfo.changeActiveAvatarRPC(_loc1_);
         }
      }
   }


