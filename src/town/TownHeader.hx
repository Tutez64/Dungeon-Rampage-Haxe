package town
;
   import account.BoosterInfo;
   import account.CurrencyUpdatedAccountEvent;
   import account.DBAccountInfo;
   import account.StoreServicesController;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import dBGlobals.DBGlobal;
   import events.BoostersParsedEvent;
   import events.TrophiesUpdatedAccountEvent;
   import facade.DBFacade;
   import facade.Locale;
   import uI.CountdownTextTimer;
   import uI.UIExitPopup;
   import uI.UIShop;
   import uI.UITownTweens;
   import flash.display.MovieClip;
   import flash.filters.DropShadowFilter;
   import flash.text.TextField;
   
    class TownHeader
   {
      
      static inline final TOWN_HEADER_CLASS_NAME= "UI_header";
      
      var mDBFacade:DBFacade;
      
      var mRoot:MovieClip;
      
      var mSceneGraphComponent:SceneGraphComponent;
      
      var mEventComponent:EventComponent;
      
      var mLogicalWorkComponent:LogicalWorkComponent;
      
      var mAssetLoadingComponent:AssetLoadingComponent;
      
      var mDefaultCloseCallback:ASFunction;
      
      var mMapStateCallback:ASFunction;
      
      var mTitle:String;
      
      var mCashUI:UIObject;
      
      var mCoinUI:UIObject;
      
      var mTrophiesUI:UIObject;
      
      var mTeamBonusUI:UIObject;
      
      var mCoinBoosterUI:UIObject;
      
      var mXPBoosterUI:UIObject;
      
      var mGemIcon:MovieClip;
      
      var mAddCashSaleButton:UIButton;
      
      var mSaleEfx:MovieClip;
      
      var mSaleLabel:TextField;
      
      var mAddCoinButton:UIButton;
      
      var mAddCashButton:UIButton;
      
      var mCloseButton:UIButton;
      
      var mCashLabel:TextField;
      
      var mCoinLabel:TextField;
      
      var mTrophyLabel:TextField;
      
      var mShowCloseButton:Bool = true;
      
      var mJumpToMapState:Bool = false;
      
      var mInHomeState:Bool = false;
      
      var mKeyPanelButton:UIButton;
      
      var mKeyPanel:KeyPanel;
      
      var mShopUI:UIShop;
      
      var mTownSwf:SwfAsset;
      
      var mInTownFromKeyPanel:Bool = false;
      
      var mPreviousTitleBeforeKeyPanel:String;
      
      var mBoosterXP:BoosterInfo;
      
      var mBoosterGold:BoosterInfo;
      
      var mCountDownTextXP:CountdownTextTimer;
      
      var mCountDownTextGold:CountdownTextTimer;
      
      public function new(param1:DBFacade, param2:ASFunction, param3:ASFunction = null)
      {
         
         mDBFacade = param1;
         mDefaultCloseCallback = param2;
         mMapStateCallback = param3;
         mTitle = Locale.getString("TOWN_HEADER");
         mInTownFromKeyPanel = false;
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("CurrencyUpdatedAccountEvent",this.currencyUpdated);
         mEventComponent.addListener("TrophiesUpdatedAccountEvent",this.trophiesUpdated);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
      }
      
      public function destroy() 
      {
         if(mCountDownTextXP != null)
         {
            mCountDownTextXP.destroy();
         }
         if(mCountDownTextGold != null)
         {
            mCountDownTextGold.destroy();
         }
         mTeamBonusUI.destroy();
         if(mKeyPanel != null)
         {
            mKeyPanel.destroy();
         }
         mKeyPanel = null;
         mCashUI.destroy();
         mCoinUI.destroy();
         mTeamBonusUI.destroy();
         mAddCoinButton.destroy();
         mAddCashButton.destroy();
         mCloseButton.destroy();
         mGemIcon = null;
         mSaleLabel = null;
         mSaleEfx = null;
         mAddCashSaleButton.destroy();
         mEventComponent.destroy();
         mLogicalWorkComponent.destroy();
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         mDefaultCloseCallback = null;
         mMapStateCallback = null;
      }
      
      function swfLoaded(param1:SwfAsset) 
      {
         mTownSwf = param1;
         var _loc2_= mTownSwf.getClass("UI_header");
         mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mRoot.filters = cast([new DropShadowFilter(6,90,(0 : UInt),0.5,6,6,1)]);
         setupUI();
         show();
      }
      
      @:isVar public var rootMovieClip(get,never):MovieClip;
public function  get_rootMovieClip() : MovieClip
      {
         return mRoot;
      }
      
      function setupUI() 
      {
         var acctInfo:DBAccountInfo;
         mRoot.x = mDBFacade.viewWidth * 0.5;
         mRoot.y = 0;
         (mRoot : ASAny).currency.cash;
         mCashUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).currency.cash, flash.display.MovieClip));
         ASCompat.setProperty((mCashUI.tooltip : ASAny).title_label, "text", Locale.getString("CASH_TOOLTIP_TITLE"));
         ASCompat.setProperty((mCashUI.tooltip : ASAny).description_label, "text", Locale.getString("CASH_TOOLTIP_DESCRIPTION"));
         mCoinUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).currency.coin, flash.display.MovieClip));
         ASCompat.setProperty((mCoinUI.tooltip : ASAny).title_label, "text", Locale.getString("COIN_TOOLTIP_TITLE"));
         ASCompat.setProperty((mCoinUI.tooltip : ASAny).description_label, "text", Locale.getString("COIN_TOOLTIP_DESCRIPTION"));
         mTeamBonusUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).currency.crewbonus, flash.display.MovieClip));
         ASCompat.setProperty((mTeamBonusUI.tooltip : ASAny).title_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_TITLE"));
         ASCompat.setProperty((mTeamBonusUI.tooltip : ASAny).description_label, "text", Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION"));
         ASCompat.setProperty((mTeamBonusUI.root : ASAny).header_crew_bonus_number, "text", mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1);
         (mTeamBonusUI.root : ASAny).header_crew_bonus_anim.stop();
         mCoinBoosterUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).currency.boosterCoin, flash.display.MovieClip));
         mXPBoosterUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).currency.boosterXP, flash.display.MovieClip));
         mAddCashButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mCashUI.root : ASAny).add_cash, flash.display.MovieClip));
         mAddCashButton.label.text = Locale.getString("HOW");
         mGemIcon = ASCompat.dynamicAs((mCashUI.root : ASAny).gem_icon, flash.display.MovieClip);
         mSaleEfx = ASCompat.dynamicAs((mCashUI.root : ASAny).lable_sale_efx, flash.display.MovieClip);
         mSaleEfx.visible = false;
         mAddCashSaleButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mCashUI.root : ASAny).add_cash_sale, flash.display.MovieClip));
         mAddCashSaleButton.visible = false;
         mAddCashSaleButton.label.text = Locale.getString("HOW");
         mSaleLabel = ASCompat.dynamicAs((mCashUI.root : ASAny).label_sale, flash.text.TextField);
         mSaleLabel.visible = false;
         mAddCashSaleButton.rolloverFilter = mAddCashButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mAddCashSaleButton.releaseCallback = mAddCashButton.releaseCallback = function()
         {
            mDBFacade.metrics.log("TownHeaderAddCash");
            StoreServicesController.showCashPage(mDBFacade,"TownHeaderAddCash");
         };
         mGemIcon.filters = cast([]);
         mAddCoinButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mCoinUI.root : ASAny).add_coin, flash.display.MovieClip));
         mAddCoinButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mAddCoinButton.releaseCallback = function()
         {
            StoreServicesController.showCoinPage(mDBFacade);
         };
         mAddCoinButton.label.text = Locale.getString("HOW");
         mCoinLabel = ASCompat.dynamicAs((mCoinUI.root : ASAny).coin , TextField);
         mCoinLabel.mouseEnabled = false;
         mCashLabel = ASCompat.dynamicAs((mCashUI.root : ASAny).cash , TextField);
         mCashLabel.mouseEnabled = false;
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mRoot : ASAny).UI_town_home_button_instance, flash.display.MovieClip));
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = determineCallback;
         title = mTitle;
         showCloseButton(mShowCloseButton);
         acctInfo = mDBFacade.dbAccountInfo;
         setCurrency(acctInfo.basicCurrency,acctInfo.premiumCurrency);
         setTrophies(acctInfo.trophies);
         setBoosters();
         mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE",this.handleBoostersParsedEvent);
      }
      
      public function updateTeamBonusUI() 
      {
         ASCompat.setProperty((mTeamBonusUI.root : ASAny).header_crew_bonus_number, "text", mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1);
      }
      
      function createKeyPanel() 
      {
         if(mKeyPanel != null)
         {
            closeKeyPanel();
         }
         else
         {
            mSceneGraphComponent.fadeOut(0.5,0.75);
            mKeyPanel = new KeyPanel(mDBFacade,mAssetLoadingComponent,buyKeysPressed,closeKeyPanel,mDBFacade.mainStateMachine.currentStateName);
            MemoryTracker.track(mKeyPanel,"KeyPanel - created in TownHeader.createKeyPanel()");
         }
      }
      
      public function refreshKeyPanel() 
      {
         if(mKeyPanel != null)
         {
            mKeyPanel.refresh();
         }
      }
      
      function buyKeysPressed() 
      {
         closeKeyPanel();
         if(mShopUI != null)
         {
            return;
         }
         var _loc1_= mTownSwf.getClass("DR_UI_town_shop");
         mShopUI = new UIShop(mDBFacade,mTownSwf,ASCompat.dynamicAs(ASCompat.createInstance(_loc1_, []) , MovieClip),this);
         mShopUI.refresh("KEY");
         mShopUI.animateEntry();
         mSceneGraphComponent.addChild(mShopUI.root,(50 : UInt));
         showCloseButton(true);
         mInTownFromKeyPanel = true;
         mPreviousTitleBeforeKeyPanel = mTitle;
         title = Locale.getString("SHOP");
      }
      
      function closeShopPanel() 
      {
         mSceneGraphComponent.removeChild(mShopUI.root);
         mShopUI.destroy();
         mShopUI = null;
         mInTownFromKeyPanel = false;
         title = mPreviousTitleBeforeKeyPanel;
      }
      
      function closeKeyPanel() 
      {
         mSceneGraphComponent.fadeIn(0.5);
         mKeyPanelButton.enabled = true;
         mKeyPanel.destroy();
         mKeyPanel = null;
      }
      
      public function animateHeader() 
      {
         UITownTweens.headerTweenSequence(mRoot,mDBFacade);
      }
      
      public function show() 
      {
         if(mRoot != null && !mSceneGraphComponent.contains(mRoot,(105 : UInt)))
         {
            mSceneGraphComponent.addChild(mRoot,(75 : UInt));
         }
      }
      
      public function hide() 
      {
         if(mRoot != null)
         {
            mSceneGraphComponent.removeChild(mRoot);
         }
      }
      
      public function showCloseButton(param1:Bool) 
      {
         mShowCloseButton = param1;
         if(mCloseButton != null)
         {
            mCloseButton.visible = mShowCloseButton;
         }
      }
      
      @:isVar public var jumpToMapState(never,set):Bool;
public function  set_jumpToMapState(param1:Bool) :Bool      {
         return mJumpToMapState = param1;
      }
      
      @:isVar public var inHomeState(never,set):Bool;
public function  set_inHomeState(param1:Bool) :Bool      {
         return mInHomeState = param1;
      }
      
      function showExitPopup() 
      {
         var _loc1_= new UIExitPopup(mDBFacade);
         MemoryTracker.track(_loc1_,"UIExitPopup - created in TownHeader.showExitPopup()");
      }
      
      function determineCallback() 
      {
         if(mInHomeState)
         {
            showExitPopup();
            return;
         }
         if(mInTownFromKeyPanel)
         {
            closeShopPanel();
            return;
         }
         if(mJumpToMapState && mMapStateCallback != null)
         {
            mMapStateCallback();
         }
         else
         {
            mDefaultCloseCallback();
         }
         mJumpToMapState = false;
      }
      
      function setCurrency(param1:UInt, param2:UInt) 
      {
         if(mRoot != null)
         {
            mCoinLabel.text = Std.string(param1);
            mCashLabel.text = Std.string(param2);
         }
      }
      
      function currencyUpdated(param1:CurrencyUpdatedAccountEvent) 
      {
         this.setCurrency(param1.basicCurrency,param1.premiumCurrency);
      }
      
      function setTrophies(param1:UInt) 
      {
         if(mRoot != null)
         {
         }
      }
      
      function handleBoostersParsedEvent(param1:BoostersParsedEvent) 
      {
         resetBoosters();
      }
      
      function resetBoosters() 
      {
         setBoosters();
      }
      
      function setBoosters() 
      {
         var _loc1_= mDBFacade.dbAccountInfo.inventoryInfo;
         mXPBoosterUI.visible = false;
         mCoinBoosterUI.visible = false;
         mBoosterXP = _loc1_.findHighestBoosterXP();
         mBoosterGold = _loc1_.findHighestBoosterGold();
         if(mCountDownTextXP != null)
         {
            mCountDownTextXP.destroy();
         }
         if(mCountDownTextGold != null)
         {
            mCountDownTextGold.destroy();
         }
         if(mBoosterXP != null)
         {
            ASCompat.setProperty((mRoot : ASAny).currency.boosterXP.label, "text", mBoosterXP.BuffInfo.Exp + "X");
            ASCompat.setProperty((mXPBoosterUI.tooltip : ASAny).title_label, "text", mBoosterXP.StackInfo.Name);
            mXPBoosterUI.visible = true;
            mCountDownTextXP = new CountdownTextTimer(ASCompat.dynamicAs((mXPBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),mBoosterXP.getEndDate(),GameClock.getWebServerDate,setBoosters,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mCountDownTextXP.start();
         }
         if(mBoosterGold != null)
         {
            ASCompat.setProperty((mRoot : ASAny).currency.boosterCoin.label, "text", mBoosterGold.BuffInfo.Gold + "X");
            ASCompat.setProperty((mCoinBoosterUI.tooltip : ASAny).title_label, "text", mBoosterGold.StackInfo.Name);
            mCoinBoosterUI.visible = true;
            mCountDownTextGold = new CountdownTextTimer(ASCompat.dynamicAs((mCoinBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),mBoosterGold.getEndDate(),GameClock.getWebServerDate,setBoosters,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mCountDownTextGold.start();
         }
      }
      
      function trophiesUpdated(param1:TrophiesUpdatedAccountEvent) 
      {
         this.setTrophies(param1.trophyCount);
      }
      
      @:isVar public var title(never,set):String;
public function  set_title(param1:String) :String      {
         mTitle = param1;
         if(mRoot != null)
         {
            ASCompat.setProperty((mRoot : ASAny).page_title, "text", mTitle);
            ASCompat.setProperty((mRoot : ASAny).page_title, "mouseEnabled", false);
         }
return param1;
      }
   }


