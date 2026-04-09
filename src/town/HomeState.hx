package town
;
   import account.AvatarInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.uI.UIButton;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import brain.jsonRPC.JSONRPCService;
   import events.XPBonusEvent;
   import facade.DBFacade;
   import facade.Locale;
   import facade.TrickleCacheLoader;
   import facebookAPI.DBFacebookLevelUpPostController;
   import gameMasterDictionary.GMOffer;
   import gameMasterDictionary.GMSkin;
   import uI.DBUIMoviePopup;
   import uI.DBUIOneButtonPopup;
   import uI.DBUIPopup;
   import uI.dailyRewards.UIDailyRewards;
   import uI.gifting.UIGift;
   import uI.leaderboard.UILeaderboard;
   import uI.options.OptionsPanel;
   import uI.UIDragonKnightUpsellPopup;
   import uI.UIFBInvitePopup;
   import uI.UIFlaggedPopup;
   import uI.UIHeroUpsellPopup;
   import uI.UILevelUpShopPopup;
   import uI.UIPagingPanel;
   import uI.UIWhatsNewPopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IMapIterator;
   
    class HomeState extends TownSubState
   {
      
      public static inline final NAME= "HomeState";
      
      public static inline final ACTIVE_AVATAR_CHANGED_EVENT= "ACTIVE_AVATAR_CHANGED_EVENT";
      
      static inline final MIN_FRIENDS_TO_AVOID_INVITE_POPUP= (4 : UInt);
      
      static inline final MAX_INVITE_POPUPS= (2 : UInt);
      
      static inline final MAX_HERO_UPSELL_POPUPS= (8 : UInt);
      
      static inline final POPUP_DELAY_TIME:Float = 0.5;
      
      public static var mHasPonderedMOD:Bool = false;
      
      var mBattleButton:UIButton;
      
      var mTavernButton:UIButton;
      
      var mInventoryButton:UIButton;
      
      var mSkillsButton:UIButton;
      
      var mTrainButton:UIButton;
      
      var mShopButton:UIButton;
      
      var mGiftButton:UIButton;
      
      var mRewardButton:UIButton;
      
      var mNewsButton:UIButton;
      
      var mCreditsButton:UIButton;
      
      var mOptionsButton:UIButton;
      
      var mOptionsPanel:OptionsPanel;
      
      var mTavernAlertUp:MovieClip;
      
      var mTavernAlertOver:MovieClip;
      
      var mInventoryAlertUp:MovieClip;
      
      var mInventoryAlertOver:MovieClip;
      
      var mSkillsAlertUp:MovieClip;
      
      var mSkillsAlertOver:MovieClip;
      
      var mTrainAlertUp:MovieClip;
      
      var mTrainAlertOver:MovieClip;
      
      var mShopAlertUp:MovieClip;
      
      var mShopAlertOver:MovieClip;
      
      var mShopNewUp:MovieClip;
      
      var mShopNewOver:MovieClip;
      
      var mGiftAlertUp:MovieClip;
      
      var mGiftAlertOver:MovieClip;
      
      var mGiftPopup:UIGift;
      
      var mDailyRewardAlertUp:MovieClip;
      
      var mDailyRewardAlertOver:MovieClip;
      
      var mDailyRewardsPopup:UIDailyRewards;
      
      var mEventComponent:EventComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mRenderer:MovieClipRenderController;
      
      var mPopupDelayTask:Task;
      
      var mUILeaderboard:UILeaderboard;
      
      var mHeroTypesLazilyLoaded:Set;
      
      var mNewsStories:Vector<MessageOfTheDay>;
      
      var mNewsPagination:UIPagingPanel;
      
      var mNewsCurrentPage:UInt = 0;
      
      var mNewsTotalPages:UInt = 0;
      
      var mNewsPopUp:DBUIPopup;
      
      public function new(param1:DBFacade, param2:TownStateMachine)
      {
         super(param1,param2,"HomeState");
         mEventComponent = new EventComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mOptionsPanel = new OptionsPanel(mDBFacade);
         MemoryTracker.track(mOptionsPanel,"OptionsPanel - created in HomeState.HomeState()");
         mHeroTypesLazilyLoaded = new Set();
         mNewsStories = new Vector<MessageOfTheDay>();
      }
      
      override public function destroy() 
      {
         mDBFacade.stageRef.removeEventListener("keyDown",openDaily);
         if(mDailyRewardsPopup != null)
         {
            mDailyRewardsPopup.destroy();
            mDailyRewardsPopup = null;
         }
         mRenderer.destroy();
         mBattleButton.destroy();
         mTavernButton.destroy();
         mInventoryButton.destroy();
         mTrainButton.destroy();
         mShopButton.destroy();
         mGiftButton.destroy();
         mCreditsButton.destroy();
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mLogicalWorkComponent != null)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mUILeaderboard != null)
         {
            mUILeaderboard = null;
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         mOptionsPanel.destroy();
         mOptionsPanel = null;
         super.destroy();
      }
      
      override function setupState() 
      {
         super.setupState();
         mBattleButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_button_battle_instance, flash.display.MovieClip));
         mBattleButton.releaseCallback = mTownStateMachine.enterMapState;
         mInventoryButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_inventory_button_instance, flash.display.MovieClip));
         mInventoryButton.releaseCallback = mTownStateMachine.enterInventoryState;
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_inventory_button_instance.up.label, "text", Locale.getString("INVENTORY_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_inventory_button_instance.over.label, "text", Locale.getString("INVENTORY_BUILDING"));
         mInventoryAlertUp = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_inventory_button_instance.up.alert_icon, flash.display.MovieClip);
         mInventoryAlertOver = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_inventory_button_instance.over.alert_icon, flash.display.MovieClip);
         mInventoryAlertUp.visible = false;
         mInventoryAlertOver.visible = false;
         mTavernButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_tavern_button_instance, flash.display.MovieClip));
         mTavernButton.releaseCallback = mTownStateMachine.enterTavernState;
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_tavern_button_instance.up.label, "text", Locale.getString("TAVERN_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_tavern_button_instance.over.label, "text", Locale.getString("TAVERN_BUILDING"));
         mTavernAlertUp = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_tavern_button_instance.up.alert_icon, flash.display.MovieClip);
         mTavernAlertOver = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_tavern_button_instance.over.alert_icon, flash.display.MovieClip);
         mTavernAlertUp.visible = false;
         mTavernAlertOver.visible = false;
         mTrainButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_train_button_instance, flash.display.MovieClip));
         mTrainButton.releaseCallback = mTownStateMachine.enterTrainState;
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_train_button_instance.up.label, "text", Locale.getString("TRAINING_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_train_button_instance.over.label, "text", Locale.getString("TRAINING_BUILDING"));
         mTrainAlertUp = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_train_button_instance.up.alert_icon, flash.display.MovieClip);
         mTrainAlertOver = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_train_button_instance.over.alert_icon, flash.display.MovieClip);
         mTrainAlertUp.visible = false;
         mTrainAlertOver.visible = false;
         mCreditsButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).news, flash.display.MovieClip));
         mCreditsButton.releaseCallback = mTownStateMachine.enterCreditState;
         ASCompat.setProperty((mRootMovieClip : ASAny).news.up.credit_mc.label, "text", Locale.getString("CREDITS_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).news.over.credit_mc.label, "text", Locale.getString("CREDITS_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_sale_instance, "visible", false);
         mShopButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_shop_button_instance, flash.display.MovieClip));
         mShopButton.releaseCallback = mTownStateMachine.enterShopState;
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_instance.up.label, "text", Locale.getString("SHOP_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_instance.over.label, "text", Locale.getString("SHOP_BUILDING"));
         mShopAlertUp = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_shop_button_instance.up.alert_icon, flash.display.MovieClip);
         mShopAlertOver = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_shop_button_instance.over.alert_icon, flash.display.MovieClip);
         mShopAlertUp.visible = false;
         mShopAlertOver.visible = false;
         mShopNewUp = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_shop_button_instance.up.new_icon, flash.display.MovieClip);
         mShopNewOver = ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_shop_button_instance.over.new_icon, flash.display.MovieClip);
         mGiftButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).gift, flash.display.MovieClip));
         if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
         {
            mGiftButton.releaseCallback = function()
            {
               mDBFacade.errorPopup("GIFTING CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
            };
         }
         else
         {
            mGiftButton.releaseCallback = function()
            {
               mGiftPopup = new UIGift(mDBFacade,mRootMovieClip,giftPopupCloseCallback,giftCallbackToFriendManager);
               mGiftButton.enabled = false;
            };
         }
         mDBFacade.stageRef.addEventListener("keyDown",openDaily);
         if(mDBFacade.mCheckedDailyReward == false)
         {
            mDBFacade.mCheckedDailyReward = true;
            mDailyRewardsPopup = new UIDailyRewards(mDBFacade,rewardPopupCloseCallback,false);
         }
         ASCompat.setProperty((mRootMovieClip : ASAny).gift.up.label, "text", Locale.getString("GIFT_BUILDING"));
         ASCompat.setProperty((mRootMovieClip : ASAny).gift.over.label, "text", Locale.getString("GIFT_BUILDING"));
         mGiftAlertUp = ASCompat.dynamicAs((mRootMovieClip : ASAny).gift.up.alert_icon, flash.display.MovieClip);
         mGiftAlertOver = ASCompat.dynamicAs((mRootMovieClip : ASAny).gift.over.alert_icon, flash.display.MovieClip);
         mGiftAlertUp.visible = false;
         mGiftAlertOver.visible = false;
         mOptionsButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).options_button, flash.display.MovieClip));
         mOptionsButton.releaseCallback = mOptionsPanel.toggleVisible;
         mRenderer = new MovieClipRenderController(mDBFacade,mRootMovieClip);
         loadActiveAvatarIcon(new Event("ACTIVE_AVATAR_CHANGED_EVENT"));
         mEventComponent.addListener("ACTIVE_AVATAR_CHANGED_EVENT",loadActiveAvatarIcon);
         this.refreshAlerts();
      }
      
      function openDaily(param1:KeyboardEvent) 
      {
         if(param1.keyCode == 36 && mDBFacade != null)
         {
            mDailyRewardsPopup = new UIDailyRewards(mDBFacade,rewardPopupCloseCallback,true);
            mDBFacade.stageRef.removeEventListener("keyDown",openDaily);
         }
      }
      
      public function animateEntry() 
      {
         if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
         {
            if(mTownStateMachine.townHeader.rootMovieClip != null)
            {
               mTownStateMachine.townHeader.rootMovieClip.visible = false;
               mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock)
               {
                  mTownStateMachine.townHeader.animateHeader();
               });
            }
         }
      }
      
      function refreshAlerts() 
      {
         var _loc2_= false;
         var _loc1_= false;
         if(mRootMovieClip != null)
         {
            mTavernAlertUp.visible = mTavernAlertOver.visible = this.tavernNeedsAttention;
            mTrainAlertUp.visible = mTrainAlertOver.visible = this.trainingNeedsAttention;
            mShopAlertUp.visible = mShopAlertOver.visible = this.shopNeedsAttention;
            mInventoryAlertUp.visible = mInventoryAlertOver.visible = this.inventoryNeedsAttention;
            if(!mDBFacade.isKongregatePlayer)
            {
               checkGiftAlert();
            }
            _loc2_ = mDBFacade.gameMaster.storeHasSaleNow();
            if(_loc2_)
            {
               ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_sale_instance, "visible", true);
               ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_instance, "visible", false);
               mShopButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_shop_button_sale_instance, flash.display.MovieClip));
               mShopButton.releaseCallback = mTownStateMachine.enterShopState;
            }
            _loc1_ = mDBFacade.gameMaster.storeHasNewOffers();
            mShopNewUp.visible = _loc1_;
            mShopNewOver.visible = _loc1_;
         }
      }
      
      function tryShowBetaRewardsPopup() : Bool
      {
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasBetaPlayerParam())
         {
            if(mDBFacade.dbAccountInfo.dbAccountParams.hasBetaRewardsParam())
            {
               return false;
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
            {
               var swfAsset= param1;
               var popup= new DBUIOneButtonPopup(mDBFacade,Locale.getString("BETA_REWARDS_POPUP_TITLE"),Locale.getString("BETA_REWARDS_POPUP_MESSAGE"),Locale.getString("BETA_REWARDS_POPUP_BUTTON"),function()
               {
               },true,null,"popup_beta_thanks");
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in HomeState.tryShowBetaRewardsPopup()");
            });
            mDBFacade.dbAccountInfo.dbAccountParams.setBetaRewardsParam();
            return true;
         }
         return false;
      }
      
      function tryShowKeyMessagePopup() : Bool
      {
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasKeyIntroParam())
         {
            return false;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var swfAsset= param1;
            var popup= new DBUIOneButtonPopup(mDBFacade,Locale.getString("BETA_KEYS_POPUP_TITLE"),Locale.getString("BETA_KEYS_POPUP_MESSAGE"),Locale.getString("BETA_KEYS_POPUP_BUTTON"),function()
            {
            },true,null,"popup_beta_keys");
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in HomeState.tryShowKeyMessagePopup()");
         });
         mDBFacade.dbAccountInfo.dbAccountParams.setKeyIntroParam();
         return true;
      }
      
      function tryShowHeroUpsellPopup() : Bool
      {
         var _loc4_= 0;
         var _loc6_:GMOffer = null;
         if(!mDBFacade.getSplitTestBoolean("HeroUpsellPopups",false))
         {
            return false;
         }
         var _loc1_= (ASCompat.toInt(mDBFacade.dbAccountInfo.getAttribute("HERO_UPSELL_POPUP")) : UInt);
         if(_loc1_ >= 8)
         {
            return false;
         }
         if(mDBFacade.mainStateMachine.showedHeroUpsellPopup)
         {
            return false;
         }
         var _loc3_= new Vector<GMOffer>();
         var _loc5_:UInt;
         final __ax4_iter_122 = StoreServicesController.HERO_OFFERS;
         if (checkNullIteratee(__ax4_iter_122)) for (_tmp_ in __ax4_iter_122)
         {
            _loc5_ = _tmp_;
            _loc6_ = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(_loc5_), gameMasterDictionary.GMOffer);
            _loc4_ = (_loc6_.Details[0].HeroId : Int);
            if(!mDBFacade.dbAccountInfo.inventoryInfo.ownsItem((_loc4_ : UInt)))
            {
               _loc3_.push(_loc6_);
            }
         }
         if(_loc3_.length == 0)
         {
            return false;
         }
         var _loc7_= _loc1_ % _loc3_.length;
         var _loc8_= _loc3_[(_loc7_ : Int)];
         var _loc2_= new UIHeroUpsellPopup(mTownStateMachine.townHeader,mDBFacade,_loc8_,null);
         MemoryTracker.track(_loc2_,"UIHeroUpsellPopup - created in HomeState.tryShowHeroUpsellPopup()");
         mDBFacade.mainStateMachine.showedHeroUpsellPopup = true;
         mDBFacade.dbAccountInfo.alterAttribute("HERO_UPSELL_POPUP",Std.string(_loc1_ + 1));
         return true;
      }
      
      function tryShowWhatsNewPopup(param1:ASFunction) 
      {
         this.getWhatsNewRPC(param1);
      }
      
      function getWhatsNewCallback(param1:String) : ASFunction
      {
         var callback:ASFunction;
         var gameAction= param1;
         switch(gameAction)
         {
            case "STORE"
               | "SHOP":
               callback = function()
               {
                  mTownStateMachine.enterShopState();
               };
               
            case "BATTLE"
               | "MAP":
               callback = function()
               {
                  mTownStateMachine.enterMapState();
               };
               
            case "INVENTORY":
               callback = function()
               {
                  mTownStateMachine.enterInventoryState();
               };
               
            case "TRAINING":
               callback = function()
               {
                  mTownStateMachine.enterTrainState();
               };
               
            case "GEMS":
               callback = function()
               {
                  StoreServicesController.showCashPage(mDBFacade,"whatsNewPopup");
               };
               
            case "TAVERN":
               callback = function()
               {
                  mTownStateMachine.enterTavernState();
               };
               
            case "CLOSE"
               | "":
               callback = null;
               
            default:
               Logger.warn("Ignoring MOD game_action: action not recognized: " + gameAction);
               callback = null;
         }
         return callback;
      }
      
      function getWhatsNewRPC(param1:ASFunction = null, param2:Bool = false) 
      {
         var platformParameter:UInt;
         var rpcFunc:ASFunction;
         var parseResults:ASFunction;
         var callback= param1;
         var skipPonder= param2;
         var firstLoginConfig= mDBFacade.dbConfigManager.getConfigBoolean("FirstLoginToday",true);
         if(!skipPonder)
         {
            if(mHasPonderedMOD || !firstLoginConfig)
            {
               return;
            }
         }
         mHasPonderedMOD = true;
         platformParameter = (Std.int(mDBFacade.dbConfigManager.networkId) : UInt);
         rpcFunc = JSONRPCService.getFunction("getmod",mDBFacade.rpcRoot + "modrpc");
         parseResults = function(param1:ASAny)
         {
            var _loc5_:ASAny;
            var _loc4_:String = null;
            var _loc2_:String = null;
            var _loc3_:MessageOfTheDay = null;
            if(mDBFacade == null)
            {
               return;
            }
            if(Std.isOfType(param1 , Array) && ASCompat.toNumberField(param1, "length") > 0)
            {
               if (checkNullIteratee(param1)) for (_tmp_ in param1)
               {
                  _loc5_ = _tmp_;
                  _loc4_ = ASCompat.toString(_loc5_.game_action).toUpperCase();
                  _loc2_ = Locale.getString("WHATS_NEW_" + _loc4_);
                  _loc3_ = new MessageOfTheDay(_loc5_.layout_type,_loc5_.headline,_loc5_.body,_loc5_.image_url,_loc2_,getWhatsNewCallback(_loc4_),_loc5_.web_link_name,_loc5_.web_link_url);
                  mNewsStories.push(_loc3_);
               }
               if(mNewsStories.length > 0)
               {
                  displayNews((0 : UInt));
               }
               if(callback != null)
               {
                  callback(true);
               }
            }
            else if(callback != null)
            {
               callback(false);
            }
            mNewsTotalPages = (mNewsStories.length : UInt);
         };
         rpcFunc(platformParameter,parseResults);
      }
      
      function createNewsUI() 
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc2_= param1.getClass("pagination_fm");
            mNewsPagination = new UIPagingPanel(mDBFacade,mNewsTotalPages,ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip),param1.getClass("pagination_button"),setCurrentNewsPage);
            MemoryTracker.track(mNewsPagination,"UIPagingPanel - created in HomeState.showNewsStories()");
            if(mNewsStories.length > 0)
            {
               displayNews((0 : UInt),true);
            }
         });
      }
      
      function displayNews(param1:UInt, param2:Bool = false) 
      {
         var paginationEmptyMC:MovieClip;
         var parentPos:Point;
         var layoutClassName:String;
         var newsNum= param1;
         var showPagination= param2;
         if(mNewsStories[(newsNum : Int)].type == 2)
         {
            mNewsPopUp = new DBUIMoviePopup(mDBFacade,"whatsnew_popup_movie",mNewsStories[(newsNum : Int)].title,mNewsStories[(newsNum : Int)].message,mNewsStories[(newsNum : Int)].imageURL + "?version=3&rel=0",mNewsStories[(newsNum : Int)].mainText,function()
            {
               if(mNewsStories[(newsNum : Int)].mainCallback != null)
               {
                  mNewsStories[(newsNum : Int)].mainCallback();
               }
               if(showPagination)
               {
                  mNewsPagination.destroy();
                  mNewsPagination = null;
               }
            },426,240,showPagination);
            MemoryTracker.track(mNewsPopUp,"DBUIMoviePopup - created in HomeState.displayNews()");
            if(showPagination)
            {
               paginationEmptyMC = mNewsPopUp.getPagination();
               paginationEmptyMC.addChild(mNewsPagination.root);
            }
         }
         else
         {
            layoutClassName = mNewsStories[(newsNum : Int)].type == 0 ? "whatsnew_popup" : "whatsnew_popup_landscape";
            mNewsPopUp = new UIWhatsNewPopup(mDBFacade,layoutClassName,mNewsStories[(newsNum : Int)].title,mNewsStories[(newsNum : Int)].message,mNewsStories[(newsNum : Int)].imageURL,mNewsStories[(newsNum : Int)].mainText,function()
            {
               if(mNewsStories[(newsNum : Int)].mainCallback != null)
               {
                  mNewsStories[(newsNum : Int)].mainCallback();
               }
               if(showPagination)
               {
                  mNewsPagination.destroy();
                  mNewsPagination = null;
               }
            },mNewsStories[(newsNum : Int)].webText,mNewsStories[(newsNum : Int)].webURL,showPagination);
            MemoryTracker.track(mNewsPopUp,"UIWhatsNewPopup - created in HomeState.displayNews()");
            if(showPagination)
            {
               paginationEmptyMC = mNewsPopUp.getPagination();
               paginationEmptyMC.addChild(mNewsPagination.root);
            }
         }
      }
      
      function refreshPagination(param1:UInt) 
      {
         mNewsPagination.currentPage = (Std.int(mNewsTotalPages != 0 ? (Std.int(Math.min(mNewsTotalPages - 1,param1)) : UInt) : (0 : UInt)) : UInt);
         mNewsPagination.numPages = mNewsTotalPages;
         mNewsPagination.visible = true;
      }
      
      function setCurrentNewsPage(param1:UInt) 
      {
         mNewsCurrentPage = param1;
         refreshPagination(param1);
         if(mNewsPopUp != null)
         {
            mNewsPopUp.destroy();
            mNewsPopUp = null;
         }
         displayNews(param1,true);
      }
      
      function tryShowLevelUpShopPopup() : Bool
      {
         var gmOffers:Vector<GMOffer>;
         var popup:UILevelUpShopPopup;
         var leveled= mDBFacade.mainStateMachine.markHasHeroLeveledUp();
         if(!leveled)
         {
            return false;
         }
         gmOffers = UILevelUpShopPopup.getLevelUpWeaponUnlocks(mDBFacade,mDBFacade.dbAccountInfo.activeAvatarInfo);
         if(gmOffers.length == 0)
         {
            return false;
         }
         popup = new UILevelUpShopPopup(mDBFacade,function()
         {
            mTownStateMachine.enterShopState(false,"WEAPON");
         },mDBFacade.dbAccountInfo.activeAvatarInfo,gmOffers);
         MemoryTracker.track(popup,"UILevelUpShopPopup - created in HomeState.tryShowLevelUpPopup()");
         return true;
      }
      
      function shouldShowInvitePopup() : Bool
      {
         if(!mDBFacade.isFacebookPlayer)
         {
            return false;
         }
         var _loc2_= mDBFacade.getSplitTestNumber("MaxInvitePopups",2);
         if(_loc2_ == 0)
         {
            return false;
         }
         var _loc1_= (ASCompat.toInt(mDBFacade.dbAccountInfo.getAttribute("INVITE_POPUP")) : UInt);
         if(mDBFacade.mainStateMachine.showedInvitePopup)
         {
            return false;
         }
         if(_loc1_ == 0)
         {
            return true;
         }
         if(_loc1_ >= _loc2_)
         {
            return false;
         }
         if(mDBFacade.dbAccountInfo.friendInfos.size >= 4)
         {
            return false;
         }
         return true;
      }
      
      function tryShowInvitePopup() : Bool
      {
         var _loc2_:UIFBInvitePopup = null;
         var _loc1_= 0;
         if(this.shouldShowInvitePopup())
         {
            _loc2_ = new UIFBInvitePopup(mDBFacade,mDBFacade.facebookController.genericFriendRequests);
            MemoryTracker.track(_loc2_,"UIFBInvitePopup - created in HomeState.tryShowInvitePopup()");
            mDBFacade.mainStateMachine.showedInvitePopup = true;
            _loc1_ = ASCompat.toInt(mDBFacade.dbAccountInfo.getAttribute("INVITE_POPUP"));
            mDBFacade.dbAccountInfo.alterAttribute("INVITE_POPUP",ASCompat.toString(_loc1_ + 1));
            return true;
         }
         return false;
      }
      
      function tryShowRewardPopup(param1:UInt) 
      {
         var offer:GMOffer;
         var rewardOfferId= param1;
         mDBFacade.mainStateMachine.showedRewardPopup = true;
         offer = ASCompat.dynamicAs(mDBFacade.gameMaster.offerById.itemFor(rewardOfferId), gameMasterDictionary.GMOffer);
         if(offer == null)
         {
            return;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var centerCloseButton:UIButton;
            var topCloseButton:UIButton;
            var curtain:Sprite = null;
            var swfAsset= param1;
            var rewardPopupClass= swfAsset.getClass("rewards_popup");
            var rewardPopup= ASCompat.dynamicAs(ASCompat.createInstance(rewardPopupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((rewardPopup : ASAny).title_label, "text", Locale.getString("REWARD_POPUP_TITLE"));
            ASCompat.setProperty((rewardPopup : ASAny).header_label, "text", Locale.getString("REWARD_POPUP_HEADER"));
            ASCompat.setProperty((rewardPopup : ASAny).description_label, "text", offer.getDisplayName(mDBFacade.gameMaster));
            centerCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((rewardPopup : ASAny).close_button, flash.display.MovieClip));
            topCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((rewardPopup : ASAny).close, flash.display.MovieClip));
            centerCloseButton.label.text = Locale.getString("REWARD_POPUP_BUTTON");
            centerCloseButton.releaseCallback = topCloseButton.releaseCallback = function()
            {
               DBFacebookLevelUpPostController.removeCurtain(curtain,mSceneGraphComponent);
               mSceneGraphComponent.removeChild(rewardPopup);
               rewardPopup = null;
            };
            if(ASCompat.stringAsBool(offer.BundleSwfFilepath) && ASCompat.stringAsBool(offer.BundleIcon))
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer.BundleSwfFilepath),function(param1:brain.assetRepository.SwfAsset)
               {
                  var _loc3_= param1.getClass(offer.BundleIcon);
                  var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                  _loc2_.scaleX = _loc2_.scaleY = 0.66;
                  (rewardPopup : ASAny).icon.addChild(_loc2_);
               });
            }
            curtain = DBFacebookLevelUpPostController.makeCurtain(mDBFacade,mSceneGraphComponent);
            mSceneGraphComponent.addChild(rewardPopup,(105 : UInt));
         });
      }
      
      function tryShowRewardErrorPopup(param1:String) 
      {
         var rewardErrorTitle:String;
         var rewardErrorClose:String;
         var rewardErrorHelp:String;
         var rewardErrorDescription:String;
         var rewardErrorCode= param1;
         mDBFacade.mainStateMachine.showedRewardPopup = true;
         rewardErrorTitle = Locale.getString("REWARD_ERROR_POPUP_TITLE_" + rewardErrorCode);
         rewardErrorClose = Locale.getString("REWARD_ERROR_POPUP_CLOSE");
         rewardErrorHelp = Locale.getString("REWARD_ERROR_POPUP_HELP");
         rewardErrorDescription = Locale.getError(ASCompat.toInt(rewardErrorCode));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:brain.assetRepository.SwfAsset)
         {
            var closeButton:UIButton;
            var closeButton2:UIButton;
            var curtain:Sprite = null;
            var helpURL:String;
            var helpButton:UIButton;
            var swfAsset= param1;
            var errorPopupClass= swfAsset.getClass("reward_errors_popup");
            var errorPopup= ASCompat.dynamicAs(ASCompat.createInstance(errorPopupClass, []), flash.display.MovieClip);
            ASCompat.setProperty((errorPopup : ASAny).title_label, "text", rewardErrorTitle);
            ASCompat.setProperty((errorPopup : ASAny).message_label, "text", rewardErrorDescription);
            ASCompat.setProperty((errorPopup : ASAny).question_label, "text", rewardErrorHelp);
            closeButton = new UIButton(mDBFacade,ASCompat.dynamicAs((errorPopup : ASAny).button, flash.display.MovieClip));
            closeButton2 = new UIButton(mDBFacade,ASCompat.dynamicAs((errorPopup : ASAny).close, flash.display.MovieClip));
            closeButton.label.text = rewardErrorClose;
            closeButton2.releaseCallback = closeButton.releaseCallback = function()
            {
               DBFacebookLevelUpPostController.removeCurtain(curtain,mSceneGraphComponent);
               mSceneGraphComponent.removeChild(errorPopup);
               errorPopup = null;
            };
            helpURL = "http://help.dungeonrampage.com/";
            helpButton = new UIButton(mDBFacade,ASCompat.dynamicAs((errorPopup : ASAny).help, flash.display.MovieClip));
            helpButton.releaseCallback = function()
            {
               var _loc1_= new URLRequest(helpURL);
               flash.Lib.getURL(_loc1_,"_blank");
            };
            curtain = DBFacebookLevelUpPostController.makeCurtain(mDBFacade,mSceneGraphComponent);
            mSceneGraphComponent.addChild(errorPopup,(105 : UInt));
         });
      }
      
      function setUpHacksToRecalculateWeaponPowers() 
      {
         mDBFacade.stageRef.addEventListener("keyDown",hackToHandleKeyPressToRecalculateWeaponPowers);
      }
      
      function tearDownHacksToRecalculateWeaponPowers() 
      {
         mDBFacade.stageRef.removeEventListener("keyDown",hackToHandleKeyPressToRecalculateWeaponPowers);
      }
      
      function hackToHandleKeyPressToRecalculateWeaponPowers(param1:KeyboardEvent) 
      {
      }
      
      function TryShowDragonKnightPopup() : Bool
      {
         return UIDragonKnightUpsellPopup.ShouldDisplayDragonKnightUpsell(mDBFacade);
      }
      
      override public function enterState() 
      {
         super.enterState();
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_RECALCULATE_WEAPON_POWERS",false))
         {
            setUpHacksToRecalculateWeaponPowers();
         }
         lazyLoadActiveAvatar();
         mRenderer.play((0 : UInt),true);
         mUILeaderboard = mTownStateMachine.leaderboard;
         if(mUILeaderboard != null)
         {
            mUILeaderboard.setRootMovieClip(mRootMovieClip);
            mUILeaderboard.currentStateName = "HomeState";
            mUILeaderboard.hidePopup();
         }
         mTownStateMachine.townHeader.title = Locale.getString("TOWN_HEADER");
         mTownStateMachine.townHeader.inHomeState = true;
         mTownStateMachine.townHeader.showCloseButton(true);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:events.DBAccountResponseEvent)
         {
            refreshAlerts();
         });
         this.refreshAlerts();
         mEventComponent.dispatchEvent(new XPBonusEvent("XP_BONUS_EVENT",false));
         animateEntry();
         if(mDBFacade != null && mDBFacade.hud != null && mDBFacade.hud.chatLog != null)
         {
            mDBFacade.hud.chatLog.hideChatLog();
         }
         if(mPopupDelayTask != null)
         {
            mPopupDelayTask.destroy();
         }
         mPopupDelayTask = mLogicalWorkComponent.doLater(0.5,showPopups);
      }
      
      function showPopups(param1:GameClock = null) 
      {
         var flaggedPopupClass:UIFlaggedPopup;
         var dkPopupClass:UIDragonKnightUpsellPopup;
         var gameClock= param1;
         var rewardOfferId= (ASCompat.toInt(mDBFacade.dbConfigManager.getConfigString("RewardOfferId","0")) : UInt);
         var rewardErrorCode= mDBFacade.dbConfigManager.getConfigString("RewardErrorMessage","");
         if(mDBFacade.mSteamIsFlagged && !mDBFacade.mSeenFlaggedPopup)
         {
            mDBFacade.mSeenFlaggedPopup = true;
            flaggedPopupClass = new UIFlaggedPopup(mDBFacade,mDBFacade.mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged,mDBFacade.mSteamIsFlaggedDueToFamilySharingOwnerName,mDBFacade.mSteamFlaggedUntilAfterDateString);
            MemoryTracker.track(flaggedPopupClass,"UIFlaggedPopup - created in HomeState.showPopups()");
         }
         if(rewardOfferId != 0 && !mDBFacade.mainStateMachine.showedRewardPopup)
         {
            this.tryShowRewardPopup(rewardOfferId);
         }
         else if(rewardErrorCode != "" && !mDBFacade.mainStateMachine.showedRewardPopup)
         {
            this.tryShowRewardErrorPopup(rewardErrorCode);
         }
         else if(TryShowDragonKnightPopup())
         {
            dkPopupClass = new UIDragonKnightUpsellPopup(mDBFacade);
            MemoryTracker.track(dkPopupClass,"UIDragonKnightUpsellPopup - created in HomeState.showPopups()");
         }
         else
         {
            this.tryShowWhatsNewPopup(function(param1:Bool)
            {
               var _loc2_= false;
               if(!param1 && mDBFacade != null)
               {
                  _loc2_ = tryShowInvitePopup();
                  if(!_loc2_)
                  {
                     if(!tryShowHeroUpsellPopup())
                     {
                        tryShowBetaRewardsPopup();
                     }
                  }
               }
            });
         }
      }
      
      public function loadActiveAvatarIcon(param1:Event) 
      {
         var gmSkin:GMSkin;
         var event= param1;
         var mActiveAvatar= mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(mActiveAvatar == null)
         {
            return;
         }
         gmSkin = mDBFacade.gameMaster.getSkinByType(mActiveAvatar.skinId);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath),function(param1:brain.assetRepository.SwfAsset)
         {
            var _loc4_= param1.getClass(gmSkin.IconName);
            var _loc5_= ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_tavern_button_instance.up.avatar, flash.display.MovieClip);
            var _loc2_= ASCompat.dynamicAs((mRootMovieClip : ASAny).townScreen_tavern_button_instance.over.avatar, flash.display.MovieClip);
            var _loc3_= _loc5_.getChildByName("avatarPic");
            if(_loc3_ != null)
            {
               _loc5_.removeChild(_loc3_);
            }
            _loc3_ = _loc2_.getChildByName("avatarPic");
            if(_loc3_ != null)
            {
               _loc2_.removeChild(_loc3_);
            }
            if(_loc4_ != null)
            {
               _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.DisplayObject);
               _loc3_.name = "avatarPic";
               _loc5_.addChild(_loc3_);
               _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc4_, []), flash.display.DisplayObject);
               _loc3_.name = "avatarPic";
               _loc2_.addChild(_loc3_);
            }
         });
      }
      
      override public function exitState() 
      {
         mTownStateMachine.townHeader.inHomeState = false;
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_RECALCULATE_WEAPON_POWERS",false))
         {
            tearDownHacksToRecalculateWeaponPowers();
         }
         if(mPopupDelayTask != null)
         {
            mPopupDelayTask.destroy();
            mPopupDelayTask = null;
         }
         mRenderer.stop();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         super.exitState();
      }
      
      @:isVar public var leaderboard(get,never):UILeaderboard;
public function  get_leaderboard() : UILeaderboard
      {
         return mUILeaderboard;
      }
      
      @:isVar var tavernNeedsAttention(get,never):Bool;
function  get_tavernNeedsAttention() : Bool
      {
         return false;
      }
      
      @:isVar var trainingNeedsAttention(get,never):Bool;
function  get_trainingNeedsAttention() : Bool
      {
         var _loc1_:AvatarInfo = null;
         var _loc2_= ASCompat.reinterpretAs(mDBFacade.dbAccountInfo.inventoryInfo.avatars.iterator() , IMapIterator);
         while(_loc2_.hasNext())
         {
            _loc1_ = ASCompat.dynamicAs(_loc2_.next(), account.AvatarInfo);
            if(_loc1_.skillPointsAvailable > 0)
            {
               return true;
            }
         }
         return false;
      }
      
      @:isVar var inventoryNeedsAttention(get,never):Bool;
function  get_inventoryNeedsAttention() : Bool
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.hasNewEquippableItems;
      }
      
      @:isVar var shopNeedsAttention(get,never):Bool;
function  get_shopNeedsAttention() : Bool
      {
         return false;
      }
      
      public function getGifts() 
      {
         mDBFacade.dbAccountInfo.getGiftData(checkGiftAlert);
      }
      
      @:isVar var giftNeedsAttention(get,never):Bool;
function  get_giftNeedsAttention() : Bool
      {
         if(mDBFacade.dbAccountInfo.gifts.size > 0)
         {
            return true;
         }
         return false;
      }
      
      function checkGiftAlert() 
      {
         if(mDBFacade == null)
         {
            return;
         }
         mGiftAlertUp.visible = mGiftAlertOver.visible = this.giftNeedsAttention;
      }
      
      function giftPopupCloseCallback() 
      {
         mGiftButton.enabled = true;
         checkGiftAlert();
         mGiftPopup = null;
      }
      
      function checkRewardAlert() 
      {
         if(mDBFacade == null)
         {
            return;
         }
      }
      
      function rewardPopupCloseCallback() 
      {
         if(mRewardButton != null)
         {
            mRewardButton.enabled = true;
         }
         mDBFacade.stageRef.addEventListener("keyDown",openDaily);
         checkRewardAlert();
         mDailyRewardsPopup = null;
      }
      
      function giftCallbackToFriendManager() 
      {
         mTownStateMachine.setFriendManagementTabCategory((1 : UInt));
         mTownStateMachine.enterFriendManagementState();
         mGiftPopup.destroy();
         mGiftPopup = null;
      }
      
      function lazyLoadActiveAvatar() 
      {
         var _loc1_= mDBFacade.dbAccountInfo.activeAvatarInfo.skinId;
         if(!mHeroTypesLazilyLoaded.has(_loc1_))
         {
            TrickleCacheLoader.loadHero(mDBFacade,_loc1_);
            mHeroTypesLazilyLoaded.add(_loc1_);
         }
      }
   }


