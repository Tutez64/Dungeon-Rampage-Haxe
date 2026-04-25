package uI.hud
;
   import account.StoreServicesController;
   import actor.buffs.BuffGameObject;
   import actor.buffs.BuffHandler;
   import actor.FloatingMessage;
   import actor.pets.PetPortraitUI;
   import actor.player.input.DungeonBusterControlActivatedEvent;
   import actor.Revealer;
   import brain.assetRepository.AssetLoadingComponent;
   import brain.assetRepository.SwfAsset;
   import brain.clock.GameClock;
   import brain.event.EventComponent;
   import brain.logger.Logger;
   import brain.render.MovieClipRenderController;
   import brain.render.MovieClipRenderer;
   import brain.sceneGraph.SceneGraphComponent;
   import brain.uI.UIButton;
   import brain.uI.UIObject;
   import brain.uI.UIProgressBar;
   import brain.utils.MemoryTracker;
   import brain.workLoop.LogicalWorkComponent;
   import brain.workLoop.Task;
   import combat.weapon.ConsumableWeaponGameObject;
   import combat.weapon.WeaponGameObject;
   import distributedObjects.HeroGameObjectOwner;
   import distributedObjects.NPCGameObject;
   import events.BusterPointsEvent;
   import events.GameObjectEvent;
   import events.UIHudChangeEvent;
   import facade.DBFacade;
   import facade.GameMasterLocale;
   import facade.Locale;
   import dr_floor.DungeonModifierHelper;
   import gameMasterDictionary.GMAttack;
   import gameMasterDictionary.GMSkin;
   import gameMasterDictionary.GMWeaponAesthetic;
   import gameMasterDictionary.GMWeaponItem;
   import uI.*;
   import uI.infiniteIsland.II_UIExitDungeonPopUp;
   import uI.inventory.UIWeaponTooltip;
   import uI.options.OptionsPanel;
   import uI.popup.UILootLossPopup;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.utils.Timer;

    class UIHud
   {

      static inline final CONDENSEDHUD_BUFF_ICON_X_STARTPOS= 455;

      static inline final CONDENSEDHUD_BUFF_ICON_Y_STARTPOS= 865;

      static inline final CONDENSEDHUD_BUFF_ICON_X_DISPLACEMENT= 63;

      static inline final OLDHUD_BUFF_ICON_X_STARTPOS= 424;

      static inline final OLDHUD_BUFF_ICON_Y_STARTPOS= 980;

      static inline final OLDHUD_BUFF_ICON_X_DISPLACEMENT= 63;

      static inline final MAX_CHAT_CHARS= (44 : UInt);

      static inline final TEAMLOOT_POS= -550;

      static inline final TEAMLOOT_VISIBLE_TIME:Float = 2;

      static inline final TEAMLOOT_TWEEN_TIME:Float = 0.5;

      public static inline final UI_HUD_SWF_PATH= "Resources/Art2D/UI/db_UI_HUD.swf";

      public static inline final UI_HUD_CHANGE_EVENT= "UI_HUD_CHANGE_EVENT";

      static inline final PET_PORTRAIT_SPACING= (69 : UInt);

      static inline final PET_PORTRAIT_YPOS= (85 : UInt);

      static inline final PET_PORTRAIT_START_XPOS= (20 : UInt);

      static inline final ORIGINAL_COOLDOWN_ANIM_PLAY_TIME:Float = 4.1;

      public static inline final COMMON_CHEST_ID= (60001 : UInt);

      public static inline final UNCOMMON_CHEST_ID= (60002 : UInt);

      public static inline final RARE_CHEST_ID= (60003 : UInt);

      public static inline final LEGENDARY_CHEST_ID= (60004 : UInt);

      public static inline final SMALL_ITEM_BOX_ID= (60005 : UInt);

      public static inline final ROYAL_ITEM_BOX_ID= (60006 : UInt);

      static final TEAM_DEFAULT:Vector3D = new Vector3D(45,150);

      static final PROFILE_DEFAULT:Vector3D = new Vector3D(112,95);

      static final COINS_DEFAULT:Vector3D = new Vector3D(813,57);

      static final CASH_DEFAULT:Vector3D = new Vector3D(1032,57);

      static final EXP_DEFAULT:Vector3D = new Vector3D(1584,78);

      static final CROWD_DEFAULT:Vector3D = new Vector3D(1869,1041);

      static final TEAM_CONDENSED:Vector3D = new Vector3D(45,150);

      static final PROFILE_CONDENSED:Vector3D = new Vector3D(1550,980);

      static final COINS_CONDENSED:Vector3D = new Vector3D(60,980);

      static final CASH_CONDENSED:Vector3D = new Vector3D(53,1031);

      static final EXP_CONDENSED:Vector3D = new Vector3D(54,915);

      static final CROWD_CONDENSED:Vector3D = new Vector3D(1555,920);

      var mDBFacade:DBFacade;

      var mHeroOwner:HeroGameObjectOwner;

      var mSceneGraphComponent:SceneGraphComponent;

      var mAssetLoadingComponent:AssetLoadingComponent;

      var mWantPets:Bool = false;

      var mAssetsLoaded:Bool = false;

      var mRoot:Sprite;

      var mUIRoot:MovieClip;

      var mAddCoinButton:UIButton;

      var mAddCashButton:UIButton;

      var mProfileBox:MovieClip;

      var mProfileBulgeTask:Task;

      var mProfileRestScale:Float;

      var mFloaterTextClass:Dynamic;

      var mHpBar:UIProgressBar;

      var mHpText:TextField;

      var mFlashingHpBar:UIProgressBar;

      var mHealthFullClip:TextField;

      var mManaFullClip:TextField;

      var mManaBar:UIProgressBar;

      var mManaText:TextField;

      var mBusterBar:UIProgressBar;

      var mBusterValue:UInt = 0;

      var mBusterRoot:MovieClip;

      var mBasicCurrency:UInt = 0;

      var mPremiumCurrency:UInt = 0;

      var mBasicCurrencyUI:UIObject;

      var mPremiumCurrencyUI:UIObject;

      var mBasicCurrencyText:TextField;

      var mPremiumCurrencyText:TextField;

      var mLevelText:TextField;

      var mXpObject:UIObject;

      var mXpBar:UIProgressBar;

      var mXpText:TextField;

      var mXpGotInitialUpdate:Bool = false;

      var mXpBulgeTask:Task;

      var mXpRestScale:Float;

      var mXpValue:UInt = 0;

      var mTeamLootMC:MovieClipRenderController;

      var mLootTween:TweenMax;

      var mLootTask:Task;

      var mLootMouseArea:Sprite;

      var mCloseButton:UIButton;

      var mWeaponZButton:UIButton;

      var mWeaponXButton:UIButton;

      var mWeaponCButton:UIButton;

      var mWeaponButtons:Vector<UIButton>;

      var mConsumable1Button:UIButton;

      var mConsumable2Button:UIButton;

      var mConsumableWeaponButtons:Vector<UIButton>;

      var mCooldowns:Vector<MovieClipRenderer>;

      var mConsumableCooldowns:Vector<MovieClipRenderer>;

      var mDungeonBusterButton:UIButton;

      var mBusterLabel:TextField;

      var mBusterLabelOver:TextField;

      var mBusterGlowMc:MovieClipRenderController;

      var mXPBonusText:TextField;

      var mCoinBonusText:TextField;

      var mOptionsButton:UIButton;

      var mOptionsPanel:OptionsPanel;

      var mStacksHud:UIStacksHud;

      var mEventComponent:EventComponent;

      var mUITask:Task;

      var mLogicalWorkComponent:LogicalWorkComponent;

      var mSwfAsset:SwfAsset;

      var mOffScreenPlayerManager:UIOffScreenPlayerManager;

      var mMaxBusterPoints:UInt = 0;

      var mUIChatLog:UIChatLog;

      var mSaleLabel:TextField;

      var mHealthFullRevealer:Revealer;

      var mManaFullRevealer:Revealer;

      var mHealthFullFloater:FloatingMessage;

      var mManaFullFloater:FloatingMessage;

      var mPetPortraitRoot:MovieClip;

      var mPetPortraitNoneRoot:MovieClip;

      var mPetPortrait:PetPortraitUI;

      var mFloorLabel:TextField;

      var mDungeonModifer1:UIButton;

      var mDungeonModifer2:UIButton;

      var mDungeonModifer3:UIButton;

      var mDungeonModifer4:UIButton;

      var mTeamLootDestination:Vector3D;

      var mProfileDestination:Vector3D;

      var mCoinsDestination:Vector3D;

      var mCashDestination:Vector3D;

      var mExpDestination:Vector3D;

      var mCrowdDestination:Vector3D;

      var mBoosterTimer:Timer;

      var mHudType:UInt = 0;

      var mVerticalYClipping:Float = Math.NaN;

      var mBuffs:Vector<BuffGameObject>;

      var mBuffIconButtons:Vector<UIButton>;

      var mBuffCooldowns:Vector<MovieClipRenderer>;

      public function new(param1:DBFacade)
      {
         var facade= param1;

         mDBFacade = facade;
         mRoot = new Sprite();
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"UIHud");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIHud");
         mMaxBusterPoints = (Std.int(4294967295) : UInt);
         mOptionsPanel = new OptionsPanel(mDBFacade);
         MemoryTracker.track(mOptionsPanel,"OptionsPanel - created in UIHud.UIHud()");
         mStacksHud = new UIStacksHud(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),function(param1:SwfAsset)
         {
            setupUI(param1,(ASCompat.parseInt(mDBFacade.dbAccountInfo.getAttribute("optionsHudStyle")) : UInt));
         });
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),setupOptions);
         mXpBulgeTask = null;
         mProfileBulgeTask = null;
         mBuffs = new Vector<BuffGameObject>();
         mBuffIconButtons = new Vector<UIButton>();
         mBuffCooldowns = new Vector<MovieClipRenderer>();
      }

      public static function isThisAConsumbleChestId(param1:Int) : Bool
      {
         return param1 == 60005 || param1 == 60006;
      }

      function switchHudEvent(param1:UIHudChangeEvent)
      {
         this.setupUI(mSwfAsset,param1.hudType);
         resetBuffButtonPositions();
      }

      @:isVar public var chatLogContainer(get,never):MovieClip;
public function  get_chatLogContainer() : MovieClip
      {
         return ASCompat.dynamicAs((mUIRoot : ASAny).chatLogContainer, flash.display.MovieClip);
      }

      @:isVar public var ownedHero(get,never):HeroGameObjectOwner;
public function  get_ownedHero() : HeroGameObjectOwner
      {
         return mHeroOwner;
      }

      @:isVar public var swfAsset(get,never):SwfAsset;
public function  get_swfAsset() : SwfAsset
      {
         return mSwfAsset;
      }

      function setupOptions(param1:SwfAsset)
      {
         var _loc2_= param1.getClass("options_panel_button");
         var _loc7_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
         mOptionsButton = new UIButton(mDBFacade,_loc7_);
         mOptionsButton.releaseCallback = mOptionsPanel.toggleVisible;
         var _loc4_= mDBFacade.dbConfigManager.getConfigNumber("in_game_options_button_x",1895);
         var _loc3_= mDBFacade.dbConfigManager.getConfigNumber("in_game_options_button_y",65);
         var _loc5_= mDBFacade.dbConfigManager.getConfigNumber("in_game_options_button_scale_x",1);
         var _loc6_= mDBFacade.dbConfigManager.getConfigNumber("in_game_options_button_scale_y",1);
         _loc7_.x = _loc4_;
         _loc7_.y = _loc3_;
         _loc7_.scaleX = _loc5_;
         _loc7_.scaleY = _loc6_;
         setOptionsBasedOnHud();
      }

      function setDooberLocations(param1:UInt)
      {
         switch(param1)
         {
            case 0:
               mTeamLootDestination = TEAM_DEFAULT;
               mProfileDestination = PROFILE_DEFAULT;
               mCoinsDestination = COINS_DEFAULT;
               mCashDestination = CASH_DEFAULT;
               mExpDestination = EXP_DEFAULT;
               mCrowdDestination = CROWD_DEFAULT;

            case 1:
               mTeamLootDestination = TEAM_CONDENSED;
               mProfileDestination = PROFILE_CONDENSED;
               mCoinsDestination = COINS_CONDENSED;
               mCashDestination = CASH_CONDENSED;
               mExpDestination = EXP_CONDENSED;
               mCrowdDestination = CROWD_CONDENSED;

            default:
               mTeamLootDestination = TEAM_DEFAULT;
               mProfileDestination = PROFILE_DEFAULT;
               mCoinsDestination = COINS_DEFAULT;
               mCashDestination = CASH_DEFAULT;
               mExpDestination = EXP_DEFAULT;
               mCrowdDestination = CROWD_DEFAULT;
         }
      }

      function setupUI(param1:SwfAsset, param2:UInt = (0 : UInt))
      {
         var hudClassName:String;
         var hudClass:Dynamic;
         var i:UInt;
         var tooltipOffsset:Point;
         var swfAsset= param1;
         var hudType= param2;
         mHudType = hudType;
         if(mUIRoot != null && mRoot.contains(mUIRoot))
         {
            mRoot.removeChild(mUIRoot);
         }
         mSwfAsset = swfAsset;
         switch(hudType)
         {
            case 0:
               hudClassName = "ui_hud_old";
               mDBFacade.camera.offset = new Point(0,45);
               mVerticalYClipping = 0;

            case 1:
               hudClassName = "ui_hud";
               mDBFacade.camera.offset = new Point(0,0);
               mVerticalYClipping = 90;

            default:
               hudClassName = "ui_hud_old";
               mDBFacade.camera.offset = new Point(0,45);
               mVerticalYClipping = 0;
               Logger.warn("Unable to determine hud with type: " + hudType);
         }
         setOptionsBasedOnHud();
         setDooberLocations(mHudType);
         mDBFacade.camera.yCilppingFromBottom = mVerticalYClipping;
         mDBFacade.camera.forceRedraw();
         hudClass = swfAsset.getClass(hudClassName);
         mUIRoot = ASCompat.dynamicAs(ASCompat.createInstance(hudClass, []), flash.display.MovieClip);
         mRoot.addChild(mUIRoot);
         mFloaterTextClass = swfAsset.getClass("floater_text");
         mStacksHud.initializeHud(swfAsset.getClass("stacks_hud"));
         if(mUIChatLog != null)
         {
            mUIChatLog.destroy();
         }
         mUIChatLog = new UIChatLog(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).chatLogContainer, flash.display.MovieClip),ASCompat.dynamicAs((mUIRoot : ASAny).UI_chat, flash.display.MovieClip),ASCompat.dynamicAs((mUIRoot : ASAny).UI_chat.log_btn, flash.display.MovieClip),ASCompat.dynamicAs((mUIRoot : ASAny).UI_chat.chat_btn, flash.display.MovieClip));
         mCloseButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).close, flash.display.MovieClip));
         mCloseButton.releaseCallback = function()
         {
            var exitPopup:II_UIExitDungeonPopUp;
            var xpLoss:UInt;
            var lootLossPopup:UILootLossPopup;
            var closeCallback:ASFunction = function()
            {
               var _loc1_:ASObject = {};
               ASCompat.setProperty(_loc1_, "buttonDesc", "UIHud Exit Button Clicked");
               ASCompat.setProperty(_loc1_, "areaType", "Dungeon");
               mDBFacade.metrics.log("ButtonClick",_loc1_);
               mUIChatLog.hideChatLog();
               mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
               mDBFacade.dbAccountInfo.dbAccountParams.flushParams();
            };
            if(mHeroOwner.distributedDungeonFloor.isInfiniteDungeon)
            {
               exitPopup = new II_UIExitDungeonPopUp(mDBFacade,closeCallback,null);
            }
            else
            {
               xpLoss = mHeroOwner.distributedDungeonFloor.completionXp;
               lootLossPopup = new UILootLossPopup(mDBFacade,xpLoss,mHeroOwner.distributedDungeonFloor.treasureCollected,closeCallback,null);
               MemoryTracker.track(lootLossPopup,"UILootLossPopup - created in UIHud.setupUI()");
            }
         };
         if(mDBFacade.dbConfigManager.getConfigBoolean("want_pets",true))
         {
            mWantPets = true;
         }
         mProfileBox = ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile, flash.display.MovieClip);
         mProfileRestScale = mProfileBox.scaleX;
         mHpBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.HP_bar, flash.display.MovieClip),ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.HP_bar_delta, flash.display.MovieClip));
         mHpText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.HP_text, flash.text.TextField);
         mHpText.visible = false;
         mFlashingHpBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.HP_bar_invincible, flash.display.MovieClip));
         mFlashingHpBar.visible = false;
         mFlashingHpBar.root.mouseEnabled = false;
         mManaBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.mana_bar, flash.display.MovieClip),ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.mana_bar_delta, flash.display.MovieClip));
         mManaText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.mana_text, flash.text.TextField);
         mManaText.visible = false;
         mHealthFullClip = ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.HP_full_text, flash.text.TextField);
         mManaFullClip = ASCompat.dynamicAs((mUIRoot : ASAny).UI_profile.mana_full_text, flash.text.TextField);
         mHealthFullClip.mouseEnabled = false;
         mManaFullClip.mouseEnabled = false;
         mHealthFullClip.visible = false;
         mManaFullClip.visible = false;
         mBusterRoot = ASCompat.dynamicAs((mUIRoot : ASAny).UI_buster, flash.display.MovieClip);
         mBusterBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_buster.buster_bar, flash.display.MovieClip));
         hideBustSign();
         mBasicCurrencyUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_coin, flash.display.MovieClip));
         mBasicCurrencyUI.setRootMovieClipAsBitMap();
         mBasicCurrencyUI.tooltipDelay = 0.4;
         ASCompat.setProperty((mBasicCurrencyUI.tooltip : ASAny).title_label, "text", Locale.getString("COIN_TOOLTIP_TITLE"));
         ASCompat.setProperty((mBasicCurrencyUI.tooltip : ASAny).description_label, "text", Locale.getString("COIN_TOOLTIP_DESCRIPTION"));
         mPremiumCurrencyUI = new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_cash, flash.display.MovieClip));
         mPremiumCurrencyUI.setRootMovieClipAsBitMap();
         mPremiumCurrencyUI.tooltipDelay = 0.4;
         ASCompat.setProperty((mPremiumCurrencyUI.tooltip : ASAny).title_label, "text", Locale.getString("CASH_TOOLTIP_TITLE"));
         ASCompat.setProperty((mPremiumCurrencyUI.tooltip : ASAny).description_label, "text", Locale.getString("CASH_TOOLTIP_DESCRIPTION"));
         mSaleLabel = ASCompat.dynamicAs((mPremiumCurrencyUI.root : ASAny).label_sale, flash.text.TextField);
         mSaleLabel.visible = false;
         mBasicCurrencyText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_coin.game_currency_text, flash.text.TextField);
         mBasicCurrencyText.mouseEnabled = false;
         mPremiumCurrencyText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_cash.cash_text, flash.text.TextField);
         mPremiumCurrencyText.mouseEnabled = false;
         mAddCoinButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_coin.coin.add_coin_button, flash.display.MovieClip));
         mAddCoinButton.releaseCallback = function()
         {
            StoreServicesController.showCoinPage(mDBFacade);
         };
         mAddCoinButton.visible = false;
         mAddCashButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_cash.cash.add_cash_button, flash.display.MovieClip));
         mAddCashButton.releaseCallback = function()
         {
            mDBFacade.metrics.log("UIHudAddCash");
            StoreServicesController.showCashPage(mDBFacade,"inDungeonUIHudAddCash");
         };
         mAddCashButton.visible = false;
         if(mDBFacade.dbAccountInfo != null)
         {
            setCurrency((mDBFacade.dbAccountInfo.basicCurrency : Int),(mDBFacade.dbAccountInfo.premiumCurrency : Int));
         }
         mLevelText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_XP.xp_level, flash.text.TextField);
         mXpObject = new UIObject(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_XP, flash.display.MovieClip));
         mXpRestScale = mXpObject.root.scaleX;
         mXpBar = new UIProgressBar(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_XP.xp_bar, flash.display.MovieClip),ASCompat.dynamicAs((mUIRoot : ASAny).UI_XP.xp_bar_delta, flash.display.MovieClip));
         ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_bar_delta, "alpha", 0.3);
         mXpText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_XP.xp_points, flash.text.TextField);
         mXpText.visible = false;
         ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", false);
         mXPBonusText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_XP.doublexp_text, flash.text.TextField);
         mCoinBonusText = ASCompat.dynamicAs((mUIRoot : ASAny).UI_currency_coin.doublecoin_text, flash.text.TextField);
         mCoinBonusText.visible = false;
         mWeaponZButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_weapons.weapon_z, flash.display.MovieClip));
         mWeaponXButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_weapons.weapon_x, flash.display.MovieClip));
         mWeaponCButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_weapons.weapon_c, flash.display.MovieClip));
         mWeaponButtons = Vector.ofArray([mWeaponZButton,mWeaponXButton,mWeaponCButton]);
         if(!mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds"))
         {
            mWeaponZButton.setRootMovieClipAsBitMap();
            mWeaponXButton.setRootMovieClipAsBitMap();
            mWeaponCButton.setRootMovieClipAsBitMap();
         }
         i = (0 : UInt);
         while(i < (mWeaponButtons.length : UInt))
         {
            this.createWeaponTooltip(mWeaponButtons[(i : Int)],i);
            i = i + 1;
         }
         mCooldowns = new Vector<MovieClipRenderer>();
         mCooldowns.push(new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_weapons.weapon_z.cooldown, flash.display.MovieClip)));
         ASCompat.setProperty((mUIRoot : ASAny).UI_weapons.weapon_z.cooldown, "visible", false);
         mCooldowns.push(new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_weapons.weapon_x.cooldown, flash.display.MovieClip)));
         ASCompat.setProperty((mUIRoot : ASAny).UI_weapons.weapon_x.cooldown, "visible", false);
         mCooldowns.push(new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_weapons.weapon_c.cooldown, flash.display.MovieClip)));
         ASCompat.setProperty((mUIRoot : ASAny).UI_weapons.weapon_c.cooldown, "visible", false);
         mConsumable1Button = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).consumables_01, flash.display.MovieClip));
         mConsumable2Button = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).consumables_02, flash.display.MovieClip));
         mConsumableWeaponButtons = Vector.ofArray([mConsumable1Button,mConsumable2Button]);
         mConsumable1Button.setRootMovieClipAsBitMap();
         mConsumable2Button.setRootMovieClipAsBitMap();
         mConsumableCooldowns = new Vector<MovieClipRenderer>();
         mConsumableCooldowns.push(new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).consumables_01.cooldown, flash.display.MovieClip)));
         ASCompat.setProperty((mUIRoot : ASAny).consumables_01.cooldown, "visible", false);
         mConsumableCooldowns.push(new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).consumables_02.cooldown, flash.display.MovieClip)));
         ASCompat.setProperty((mUIRoot : ASAny).consumables_02.cooldown, "visible", false);
         ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", false);
         mPetPortraitRoot = ASCompat.dynamicAs((mUIRoot : ASAny).pet, flash.display.MovieClip);
         if(ASCompat.toBool((mUIRoot : ASAny).pet_none))
         {
            mPetPortraitNoneRoot = ASCompat.dynamicAs((mUIRoot : ASAny).pet_none, flash.display.MovieClip);
         }
         mAssetsLoaded = true;
         mFloorLabel = ASCompat.dynamicAs((mUIRoot : ASAny).label_floor, flash.text.TextField);
         mFloorLabel.cacheAsBitmap = true;
         tooltipOffsset = new Point(0,-15);
         mDungeonModifer1 = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).floor_modifier01, flash.display.MovieClip));
         mDungeonModifer1.tooltip = ASCompat.dynamicAs((mUIRoot : ASAny).tooltip_modifier01, flash.display.MovieClip);
         mDungeonModifer1.tooltipPos = tooltipOffsset;
         mDungeonModifer2 = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).floor_modifier02, flash.display.MovieClip));
         mDungeonModifer2.tooltip = ASCompat.dynamicAs((mUIRoot : ASAny).tooltip_modifier02, flash.display.MovieClip);
         mDungeonModifer2.tooltipPos = tooltipOffsset;
         mDungeonModifer3 = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).floor_modifier03, flash.display.MovieClip));
         mDungeonModifer3.tooltip = ASCompat.dynamicAs((mUIRoot : ASAny).tooltip_modifier03, flash.display.MovieClip);
         mDungeonModifer3.tooltipPos = tooltipOffsset;
         mDungeonModifer4 = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).floor_modifier04, flash.display.MovieClip));
         mDungeonModifer4.tooltip = ASCompat.dynamicAs((mUIRoot : ASAny).tooltip_modifier04, flash.display.MovieClip);
         mDungeonModifer4.tooltipPos = tooltipOffsset;
         if(mHeroOwner != null)
         {
            this.initializeHud(mHeroOwner);
         }
      }

      function setOptionsBasedOnHud()
      {
         if(mOptionsPanel == null || mOptionsButton == null)
         {
            return;
         }
         var _loc2_= new Point(0,0);
         var _loc1_= new Point(1,1);
         switch(mHudType)
         {
            case 0:
               _loc2_ = new Point(1875,100);
               _loc1_ = new Point(0.9,0.9);

            case 1:
               _loc2_ = new Point(1875,100);
               _loc1_ = new Point(0.9,0.9);

            default:
               _loc2_ = new Point(1875,100);
               _loc1_ = new Point(0.9,0.9);
               Logger.warn("Unable to determine hud with type: " + mHudType);
         }
         mOptionsButton.root.x = _loc2_.x;
         mOptionsButton.root.y = _loc2_.y;
         mOptionsButton.root.scaleX = _loc1_.x;
         mOptionsButton.root.scaleY = _loc1_.y;
      }

      function mouseOverXpListener(param1:Event)
      {
         ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", false);
         mXpText.visible = true;
      }

      function mouseOutXpListener(param1:Event)
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-numbered-hud"))
         {
            ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", true);
            mXpText.visible = false;
         }
      }

      public function showHealthFullMessage()
      {
         if(mHealthFullRevealer != null || mHealthFullFloater != null)
         {
            return;
         }
         mHealthFullClip.visible = true;
         mHealthFullClip.scaleX = 1;
         mHealthFullClip.scaleY = 1;
         mHealthFullRevealer = new Revealer(mHealthFullClip,mDBFacade,(8 : UInt),function()
         {
            if(mHealthFullRevealer != null)
            {
               mHealthFullRevealer = null;
            }
            mHealthFullFloater = new FloatingMessage(mHealthFullClip,mDBFacade,(2 : UInt),(16 : UInt),1.125,0,null,function()
            {
               mHealthFullClip.scaleX = 1;
               mHealthFullClip.scaleY = 1;
               mHealthFullFloater = null;
            },"DAMAGE_MOVEMENT_TYPE",true);
         },(1 : UInt));
      }

      public function showManaFullMessage()
      {
         if(mManaFullRevealer != null || mManaFullFloater != null)
         {
            return;
         }
         mManaFullClip.visible = true;
         mManaFullClip.scaleX = 1;
         mManaFullClip.scaleY = 1;
         mManaFullRevealer = new Revealer(mManaFullClip,mDBFacade,(8 : UInt),function()
         {
            if(mManaFullRevealer != null)
            {
               mManaFullRevealer = null;
            }
            mManaFullFloater = new FloatingMessage(mManaFullClip,mDBFacade,(2 : UInt),(16 : UInt),1.125,0,null,function()
            {
               mManaFullClip.scaleX = 1;
               mManaFullClip.scaleY = 1;
               mManaFullFloater = null;
            },"DAMAGE_MOVEMENT_TYPE",true);
         },(1 : UInt));
      }

      public function handleBoosterTimeUp(param1:TimerEvent)
      {
         if(mBoosterTimer != null)
         {
            mBoosterTimer.stop();
            mBoosterTimer = null;
         }
         showBonusXPEffects(null);
         showBonusCoinEffects(null);
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
         if(_loc2_ >= 0)
         {
            mBoosterTimer = new Timer(_loc2_,0);
            mBoosterTimer.addEventListener("timer",handleBoosterTimeUp);
            mBoosterTimer.start();
         }
      }

      function handleBoostersParsedEvent(param1:Event)
      {
         showBonusXPEffects(param1);
         showBonusCoinEffects(param1);
      }

      function showBonusXPEffects(param1:Event)
      {
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
         if(mDBFacade.accountBonus.isXPBonusActive)
         {
            mXPBonusText.visible = true;
            mXPBonusText.text = mDBFacade.accountBonus.xpBonusText;
         }
         else if(_loc2_ != null && _loc2_.BuffInfo.Exp > 1)
         {
            mXPBonusText.visible = true;
            mXPBonusText.text = _loc2_.BuffInfo.Exp + Locale.getString("BOOSTER_XP");
         }
         else
         {
            mXPBonusText.visible = false;
         }
      }

      function showBonusCoinEffects(param1:Event)
      {
         var _loc2_= mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
         if(mDBFacade.accountBonus.isCoinBonusActive)
         {
            mCoinBonusText.visible = true;
            mCoinBonusText.text = mDBFacade.accountBonus.coinBonusText;
         }
         else if(_loc2_ != null && _loc2_.BuffInfo.Gold > 1)
         {
            mCoinBonusText.visible = true;
            mCoinBonusText.text = _loc2_.BuffInfo.Gold + Locale.getString("BOOSTER_GOLD");
         }
         else
         {
            mCoinBonusText.visible = false;
         }
      }

      public function registerPet(param1:NPCGameObject)
      {
         if(mPetPortrait != null)
         {
            mPetPortrait.destroy();
         }
         if(mWantPets)
         {
            mPetPortrait = new PetPortraitUI(mDBFacade,mPetPortraitRoot,mPetPortraitNoneRoot,param1);
         }
      }

      public function unregisterPet(param1:NPCGameObject)
      {
         if(mPetPortrait != null)
         {
            if(mPetPortrait.petNPCGameObject == param1)
            {
               mPetPortrait.petDeath();
            }
            if(mPetPortrait.petNPCGameObject == null && param1.gmNpc.RespawnT <= 0)
            {
               mPetPortrait.destroy();
               mPetPortrait = null;
            }
         }
      }

      function createWeaponTooltip(param1:UIButton, param2:UInt)
      {
         var button= param1;
         var num= param2;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset)
         {
            var _loc2_= num == 0 ? param1.getClass("DR_weapon_tooltip_z") : param1.getClass("DR_weapon_tooltip");
            var _loc4_= new UIWeaponTooltip(mDBFacade,_loc2_);
            button.tooltip = _loc4_;
            var _loc3_= new Point();
            _loc3_.y -= button.root.height * 0.5;
            button.tooltipPos = _loc3_;
            button.tooltipDelay = 0.4;
         });
      }

      public function openTeamLoot(param1:UInt)
      {
         var _loc4_= "";
         switch(param1 - 60001)
         {
            case 0:
               _loc4_ = "UI_teamloot_basic";

            case 1:
               _loc4_ = "UI_teamloot_uncommon";

            case 2:
               _loc4_ = "UI_teamloot_rare";

            case 3:
               _loc4_ = "UI_teamloot_legendary";

            case 4:
               _loc4_ = "UI_teamloot_box_small";

            case 5:
               _loc4_ = "UI_teamloot_box_royal";
         }
         var _loc3_= mSwfAsset.getClass(_loc4_);
         var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []) , MovieClip);
         mTeamLootMC = new MovieClipRenderController(mDBFacade,_loc2_);
         mUIRoot.addChild(mTeamLootMC.clip);
         mTeamLootMC.clip.scaleX = mTeamLootMC.clip.scaleY = 1.8;
         mTeamLootMC.clip.x = -550;
         mTeamLootMC.clip.y = -150;
         if(mLootTween != null)
         {
            mLootTween.kill();
         }
         mTeamLootMC.play((0 : UInt),true);
         mLootTween = TweenMax.to(mTeamLootMC.clip,0.5,{"x":-550});
         if(mLootTask != null)
         {
            mLootTask.destroy();
         }
         mLootTask = mLogicalWorkComponent.doLater(2,closeTeamLoot);
      }

      public function closeTeamLoot(param1:GameClock = null)
      {
         var gameClock= param1;
         var cleanupFunc:ASFunction = function()
         {
            mTeamLootMC.stop();
            mTeamLootMC.clip.visible = false;
         };
         if(mLootTask != null)
         {
            mLootTask.destroy();
         }
         if(mLootTween != null)
         {
            mLootTween.kill();
         }
         mLootTween = TweenMax.to(mTeamLootMC.clip,0.5,{
            "x":-250,
            "onComplete":cleanupFunc
         });
      }

      public function detachHero()
      {
         hide();
         hideBustSign();
         mOffScreenPlayerManager.destroy();
         mOffScreenPlayerManager = null;
         mHeroOwner = null;
         mEventComponent.removeAllListeners();
         (mUIRoot : ASAny).UI_XP.removeEventListener("mouseOver",mouseOverXpListener);
         (mUIRoot : ASAny).UI_XP.removeEventListener("mouseOut",mouseOutXpListener);
      }

      public function initializeHud(param1:HeroGameObjectOwner)
      {
         var boosterTime:Int;
         var equippedWeapons:Vector<WeaponGameObject>;
         var i:Int;
         var equippedConsumableWeapons:Vector<ConsumableWeaponGameObject>;
         var j:Int;
         var gmSkin:GMSkin;
         var busterConstant:String;
         var busterAttack:GMAttack;
         var busterName:String;
         var heroOwner= param1;
         show();
         mHeroOwner = heroOwner;
         if(mAssetsLoaded && mHeroOwner != null)
         {
            mUIChatLog.heroOwner = mHeroOwner;
            mUIChatLog.enable();
            hideInvulnerable();
            setHp(mHeroOwner.hitPoints,(Std.int(mHeroOwner.maxHitPoints) : UInt));
            setMana(mHeroOwner.manaPoints,(Std.int(mHeroOwner.maxManaPoints) : UInt));
            setXp(mHeroOwner.experiencePoints);
            bulgeXpBar();
            bulgeProfileBox();
            setBusterPoints(mHeroOwner.dungeonBusterPoints);
            this.addListeners();
            boosterTime = mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
            if(boosterTime >= 0)
            {
               mBoosterTimer = new Timer(boosterTime,0);
               mBoosterTimer.addEventListener("timer",handleBoosterTimeUp);
               mBoosterTimer.start();
            }
            mOffScreenPlayerManager = new UIOffScreenPlayerManager(mDBFacade,mUIRoot,mHeroOwner);
            equippedWeapons = new Vector<WeaponGameObject>();
            i = 0;
            while(i < mHeroOwner.weaponControllers.length)
            {
               equippedWeapons.push(ASCompat.dynamicAs(mHeroOwner.weaponControllers[i] != null ? mHeroOwner.weaponControllers[i].weapon : null, combat.weapon.WeaponGameObject));
               i = i + 1;
            }
            this.setupWeaponUI(equippedWeapons);
            equippedConsumableWeapons = new Vector<ConsumableWeaponGameObject>();
            j = 0;
            while(j < 2)
            {
               equippedConsumableWeapons.push(ASCompat.dynamicAs(mHeroOwner.consumables[j] != null ? mHeroOwner.consumables[j] : null, combat.weapon.ConsumableWeaponGameObject));
               j = j + 1;
            }
            this.setupConsumableWeaponUI(equippedConsumableWeapons);
            gmSkin = mHeroOwner.gmSkin;
            if(gmSkin == null)
            {
               Logger.error("GMSkin on hero is null.  HeroType: " + mHeroOwner.type + " AccountId: " + mDBFacade.accountId);
            }
            else
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath),function(param1:SwfAsset)
               {
                  var _loc3_= param1.getClass(gmSkin.IconName);
                  var _loc2_= ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
                  if(ASCompat.toBool((mUIRoot : ASAny).UI_profile.avatar))
                  {
                     (mUIRoot : ASAny).UI_profile.avatar.addChild(_loc2_);
                  }
                  if(ASCompat.toBool((mUIRoot : ASAny).avatar))
                  {
                     (mUIRoot : ASAny).avatar.addChild(_loc2_);
                  }
               });
            }
            mStacksHud.setupStacksUI();
            mDungeonBusterButton = new UIButton(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_buster_active.buster_activated, flash.display.MovieClip));
            mDungeonBusterButton.releaseCallback = handleBusterBarClickEvent;
            mBusterLabel = ASCompat.dynamicAs((mUIRoot : ASAny).UI_buster_active.buster_activated.up.name_mc.name_label, flash.text.TextField);
            mBusterLabelOver = ASCompat.dynamicAs((mUIRoot : ASAny).UI_buster_active.buster_activated.over.mc.name_label, flash.text.TextField);
            busterConstant = mHeroOwner.gMHero.DBuster1;
            busterAttack = ASCompat.dynamicAs(mDBFacade.gameMaster.attackByConstant.itemFor(busterConstant), gameMasterDictionary.GMAttack);
            busterName = busterAttack != null ? GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME",busterAttack.Constant) : "BUSTER!";
            mBusterLabel.text = mBusterLabelOver.text = busterName.toUpperCase();
            mBusterGlowMc = new MovieClipRenderController(mDBFacade,ASCompat.dynamicAs((mUIRoot : ASAny).UI_buster_glow, flash.display.MovieClip));
            ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow.buster_text.buster_text_label.name_label, "text", busterName.toUpperCase());
            if(mDBFacade.dbAccountInfo != null)
            {
               setCurrency((mDBFacade.dbAccountInfo.basicCurrency : Int),(mDBFacade.dbAccountInfo.premiumCurrency : Int));
            }
            mMaxBusterPoints = mHeroOwner.maxBusterPoints;
            setBusterPoints(mHeroOwner.dungeonBusterPoints);
            initializePetPortraits();
            setCurrentFloorLabel();
            setDungeonModifiers();
            mUIChatLog.heroOwner = mHeroOwner;
            mLogicalWorkComponent.doEveryFrame(updateBuffDisplay);
            setupStatsForResourceBars();
         }
      }

      function setCurrentFloorLabel()
      {
         mFloorLabel.text = Locale.getString("UI_HUD_FLOOR_LABEL") + Std.string(mHeroOwner.distributedDungeonFloor.getCurrentFloorNum());
      }

      function setDungeonModifiers()
      {
         var _loc1_:UIButton = null;
         var _loc2_= 0;
         mDungeonModifer1.visible = false;
         mDungeonModifer2.visible = false;
         mDungeonModifer3.visible = false;
         mDungeonModifer4.visible = false;
         _loc2_ = 0;
         while(_loc2_ < mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers.length)
         {
            switch(_loc2_)
            {
               case 0:
                  _loc1_ = mDungeonModifer1;

               case 1:
                  _loc1_ = mDungeonModifer2;

               case 2:
                  _loc1_ = mDungeonModifer3;

               case 3:
                  _loc1_ = mDungeonModifer4;
            }
            setupModifiers(_loc1_,mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers[_loc2_]);
            _loc2_ = ASCompat.toInt(_loc2_) + 1;
         }
      }

      function setupModifiers(param1:UIButton, param2:DungeonModifierHelper)
      {
         var dungeonModButton= param1;
         var gmDungeonModifier= param2;
         ASCompat.setProperty((dungeonModButton.tooltip : ASAny).title_label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME",gmDungeonModifier.GMDungeonMod.Constant));
         ASCompat.setProperty((dungeonModButton.tooltip : ASAny).description_label, "text", GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION",gmDungeonModifier.GMDungeonMod.Constant));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmDungeonModifier.GMDungeonMod.IconFilepath),function(param1:SwfAsset)
         {
            var _loc2_= param1.getClass(gmDungeonModifier.GMDungeonMod.IconName);
            if(_loc2_ == null)
            {
               return;
            }
            var _loc3_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
            UIObject.scaleToFit(_loc3_,dungeonModButton.root.width);
            _loc3_.x += 10;
            _loc3_.y += 10;
            dungeonModButton.root.removeChildren();
            dungeonModButton.root.addChild(_loc3_);
            dungeonModButton.root.visible = true;
         });
      }

      function initializePetPortraits()
      {
         var _loc1_:NPCGameObject = null;
         if(mPetPortrait != null)
         {
            _loc1_ = mPetPortrait.petNPCGameObject;
         }
         registerPet(_loc1_);
      }

      public function show()
      {
         mSceneGraphComponent.addChild(mRoot,(50 : UInt));
         mSceneGraphComponent.addChild(mOptionsButton.root,(50 : UInt));
         mStacksHud.show();
         mDBFacade.camera.yCilppingFromBottom = mVerticalYClipping;
         initializePetPortraits();
      }

      public function hide()
      {
         mSceneGraphComponent.removeChild(mRoot);
         mSceneGraphComponent.removeChild(mOptionsButton.root);
         mDBFacade.camera.yCilppingFromBottom = 0;
         mDBFacade.camera.forceRedraw();
         mOptionsPanel.hide();
         mStacksHud.hide();
         if(mUIChatLog != null)
         {
            mUIChatLog.disable();
            mUIChatLog.hideChatLog();
         }
         if(mPetPortrait != null)
         {
            mPetPortrait.destroy();
            mPetPortrait = null;
         }
      }

      public function showStacks()
      {
         mStacksHud.show();
      }

      public function hideStacks()
      {
         mStacksHud.hide();
      }

      function resetButtons(param1:Vector<UIButton>)
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:UIButton;
         if (checkNullIteratee(param1)) for (_tmp_ in param1)
         {
            _loc2_ = _tmp_;
            ASCompat.setProperty(_loc2_, "pressCallback", null);
            ASCompat.setProperty(_loc2_, "pressRollOutCallback", null);
            if(ASCompat.toBool(_loc2_.tooltip))
            {
               ASCompat.setProperty(_loc2_.tooltip, "visible", false);
            }
            if(ASCompat.toNumberField((_loc2_.root : ASAny).graphic, "numChildren") > 0)
            {
               (_loc2_.root : ASAny).graphic.removeChildAt(0);
            }
            _loc3_ = ASCompat.dynamicAs(cast(_loc2_.root, flash.display.DisplayObjectContainer).getChildByName("rarityIcon"), flash.display.DisplayObject);
            if(_loc3_ != null)
            {
               _loc2_.root.removeChild(_loc3_);
            }
            ASCompat.setProperty((_loc2_.root : ASAny).selectionFrame, "visible", false);
            ASCompat.setProperty(_loc2_, "enabled", true);
            ASCompat.setProperty(_loc2_.root, "filters", []);
         }
      }

      function setupWeaponUI(param1:Vector<WeaponGameObject>)
      {
         var weaponGameObject:WeaponGameObject;
         var gmWeapon:GMWeaponItem;
         var gmWeaponAesthetic:GMWeaponAesthetic;
         var weapon:MovieClip;
         var button:UIButton;
         var tooltip:UIWeaponTooltip;
         var i:UInt;
         var makeCallback:ASFunction;
         var equippedWeapons= param1;
         var slotSize:Float = 56;
         resetButtons(mWeaponButtons);
         i = (0 : UInt);
         while(i < (equippedWeapons.length : UInt))
         {
            if(equippedWeapons[(i : Int)] != null)
            {
               weaponGameObject = equippedWeapons[(i : Int)];
               gmWeapon = weaponGameObject.weaponData;
               gmWeaponAesthetic = weaponGameObject.weaponAesthetic;
               button = mWeaponButtons[(i : Int)];
               ASCompat.setProperty(button.root, "weaponIndex", i);
               tooltip = cast(button.tooltip, UIWeaponTooltip);
               tooltip.setWeaponItemFromWeaponGameObject(weaponGameObject);
               tooltip.visible = true;
               button.pressCallbackThis = function(param1:UIButton)
               {
                  if(mHeroOwner.currentWeaponIndex != ASCompat.toNumberField((param1.root : ASAny), "weaponIndex"))
                  {
                     mHeroOwner.currentWeaponIndex = ASCompat.toInt((param1.root : ASAny).weaponIndex);
                  }
                  else
                  {
                     mHeroOwner.PlayerAttack.addToPotentialWeaponInputQueue((ASCompat.toInt((param1.root : ASAny).weaponIndex) : UInt),true,true);
                  }
               };
               button.releaseCallbackThis = function(param1:UIButton)
               {
                  if(mHeroOwner.currentWeaponIndex == ASCompat.toNumberField((param1.root : ASAny), "weaponIndex"))
                  {
                     mHeroOwner.PlayerAttack.addToPotentialWeaponInputQueue((ASCompat.toInt((param1.root : ASAny).weaponIndex) : UInt),false,true);
                  }
               };
               button.pressRollOutCallback = function()
               {
                  mDBFacade.inputManager.onMouseDown(null);
               };
               makeCallback = function(param1:UIButton, param2:GMWeaponAesthetic, param3:gameMasterDictionary.GMRarity):ASFunction
               {
                  var weaponButton= param1;
                  var weaponAesthetic= param2;
                  var rarity= param3;
                  return function(param1:SwfAsset)
                  {
                     var bgColoredExists:Bool;
                     var bgSwfPath:String;
                     var bgIconName:String;
                     var swfAsset= param1;
                     var weaponClass= swfAsset.getClass(weaponAesthetic.IconName);
                     if(weaponClass == null)
                     {
                        return;
                     }
                     weapon = ASCompat.dynamicAs(ASCompat.createInstance(weaponClass, []), flash.display.MovieClip);
                     weapon.name = "weaponIcon";
                     weapon.scaleX = weapon.scaleY = 60 / 100;
                     (weaponButton.root : ASAny).graphic.addChildAt(weapon,0);
                     bgColoredExists = rarity.HasColoredBackground;
                     bgSwfPath = rarity.BackgroundSwf;
                     bgIconName = rarity.BackgroundIcon;
                     if(bgColoredExists && mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds"))
                     {
                        mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset)
                        {
                           var _loc3_:MovieClip = null;
                           var _loc2_= param1.getClass(bgIconName);
                           if(_loc2_ != null)
                           {
                              _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
                              _loc3_.name = "rarityIcon";
                              weaponButton.root.addChildAt(_loc3_,2);
                              _loc3_.scaleX = _loc3_.scaleY = 0.85;
                              _loc3_.y -= 6;
                           }
                        });
                     }
                  };
               };
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmWeaponAesthetic.IconSwf),ASCompat.asFunction(makeCallback(button,gmWeaponAesthetic,weaponGameObject.gmRarity)));
            }
            i = i + 1;
         }
      }

      function setupConsumableWeaponUI(param1:Vector<ConsumableWeaponGameObject>)
      {
         var consumableWeaponGameObject:ConsumableWeaponGameObject;
         var gmWeapon:GMWeaponItem;
         var gmWeaponAesthetic:GMWeaponAesthetic;
         var weapon:MovieClip;
         var button:UIButton;
         var tooltip:MovieClip = null;
         var i:UInt;
         var makeCallback:ASFunction;
         var equippedConsumableWeapons= param1;
         var slotSize:Float = 56;
         resetButtons(mConsumableWeaponButtons);
         ASCompat.setProperty((mUIRoot : ASAny).consumable_tooltip01, "visible", false);
         ASCompat.setProperty((mUIRoot : ASAny).consumable_tooltip02, "visible", false);
         i = (0 : UInt);
         while(i < (equippedConsumableWeapons.length : UInt))
         {
            button = mConsumableWeaponButtons[(i : Int)];
            ASCompat.setProperty((button.root : ASAny).quantity, "visible", false);
            ASCompat.setProperty((button.root : ASAny).textx, "visible", false);
            if(equippedConsumableWeapons[(i : Int)] != null)
            {
               consumableWeaponGameObject = equippedConsumableWeapons[(i : Int)];
               gmWeapon = consumableWeaponGameObject.weaponData;
               ASCompat.setProperty(button.root, "weaponIndex", i);
               ASCompat.setProperty((button.root : ASAny).quantity, "visible", true);
               ASCompat.setProperty((button.root : ASAny).textx, "visible", true);
               ASCompat.setProperty((button.root : ASAny).quantity, "text", Std.string(consumableWeaponGameObject.getConsumableCount()));
               switch(i)
               {
                  case 0:
                     tooltip = ASCompat.dynamicAs((mUIRoot : ASAny).consumable_tooltip01, flash.display.MovieClip);

                  case 1:
                     tooltip = ASCompat.dynamicAs((mUIRoot : ASAny).consumable_tooltip02, flash.display.MovieClip);
               }
               button.tooltip = tooltip;
               ASCompat.setProperty((button.tooltip : ASAny).description_label, "text", GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION",consumableWeaponGameObject.getGMStackable().Constant));
               tooltip.visible = true;
               button.setTooltipToBeParentedToStage();
               button.tooltipPos = new Point(button.root.x,button.root.y);
               button.releaseCallbackThis = function(param1:UIButton)
               {
                  mHeroOwner.tryToUseConsumable((ASCompat.toInt((param1.root : ASAny).weaponIndex) : UInt));
               };
               makeCallback = function(param1:UIButton, param2:gameMasterDictionary.GMStackable):ASFunction
               {
                  var weaponButton= param1;
                  var gmStackable= param2;
                  return function(param1:SwfAsset)
                  {
                     var _loc2_= param1.getClass(gmStackable.IconName);
                     if(_loc2_ == null)
                     {
                        return;
                     }
                     weapon = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
                     weapon.name = "weaponIcon";
                     weapon.scaleX = weapon.scaleY = 60 / 100;
                     (weaponButton.root : ASAny).graphic.addChildAt(weapon,0);
                  };
               };
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(consumableWeaponGameObject.getGMStackable().UISwfFilepath),ASCompat.asFunction(makeCallback(button,consumableWeaponGameObject.getGMStackable())));
            }
            i = i + 1;
         }
      }

      function addListeners()
      {
         var heroOwnerId:UInt;
         mEventComponent.removeAllListeners();
         heroOwnerId = mHeroOwner.id;
         mEventComponent.addListener("BONUS_XP_CHANGED_EVENT",showBonusXPEffects);
         showBonusXPEffects(new Event("BONUS_XP_CHANGED_EVENT"));
         mEventComponent.addListener("BONUS_COIN_CHANGED_EVENT",showBonusCoinEffects);
         showBonusCoinEffects(new Event("BONUS_COIN_CHANGED_EVENT"));
         mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE",this.handleBoostersParsedEvent);
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",heroOwnerId),function(param1:events.HpEvent)
         {
            setHp(param1.hp,param1.maxHp);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("ManaEvent_MANA_UPDATE",heroOwnerId),function(param1:events.ManaEvent)
         {
            setMana(param1.mana,param1.maxMana);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("ExperienceEvent_EXPERIENCE_UPDATE",heroOwnerId),function(param1:events.ExperienceEvent)
         {
            setXp(param1.experience);
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",heroOwnerId),handleBusterPointsEvent);
         mEventComponent.addListener("CurrencyUpdatedAccountEvent",function(param1:account.CurrencyUpdatedAccountEvent)
         {
            setCurrency((param1.basicCurrency : Int),(param1.premiumCurrency : Int));
         });
         mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.ACTOR_INVULNERABLE,heroOwnerId),function(param1:events.ActorInvulnerableEvent)
         {
            if(param1.mIsInvulnerable)
            {
               showInvulnerable();
            }
            else
            {
               hideInvulnerable();
            }
         });
         mEventComponent.addListener("UI_HUD_CHANGE_EVENT",switchHudEvent);
         mProfileBox.addEventListener("mouseOver",mouseOverProfileBox);
         mProfileBox.addEventListener("mouseOut",mouseOutProfileBox);
         (mUIRoot : ASAny).UI_XP.addEventListener("mouseOver",mouseOverXpListener);
         (mUIRoot : ASAny).UI_XP.addEventListener("mouseOut",mouseOutXpListener);
      }

      function mouseOutProfileBox(param1:Event)
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-numbered-hud"))
         {
            mHpText.visible = false;
            mManaText.visible = false;
         }
      }

      function mouseOverProfileBox(param1:Event)
      {
         mHpText.visible = true;
         mManaText.visible = true;
      }

      function setupStatsForResourceBars()
      {
         if(mDBFacade.featureFlags.getFlagValue("want-numbered-hud"))
         {
            mHpText.visible = true;
            mManaText.visible = true;
            mXpText.visible = true;
            ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", false);
         }
         else
         {
            mHpText.visible = false;
            mManaText.visible = false;
            mXpText.visible = false;
            ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", true);
         }
      }

      function handleBusterPointsEvent(param1:BusterPointsEvent)
      {
         mMaxBusterPoints = param1.maxBusterPoints;
         setBusterPoints(param1.busterPoints);
      }

      function showInvulnerable()
      {
         mFlashingHpBar.value = mHpBar.value;
         mFlashingHpBar.visible = true;
         mHpBar.visible = false;
      }

      function hideInvulnerable()
      {
         mFlashingHpBar.visible = false;
         mHpBar.visible = true;
      }

      @:isVar public var floaterTextClass(get,never):Dynamic;
public function  get_floaterTextClass() : Dynamic
      {
         return mFloaterTextClass;
      }

      function floaterCallback(param1:MovieClip) : ASFunction
      {
         var clip= param1;
         return function()
         {
            mDBFacade.sceneGraphManager.removeChild(clip);
         };
      }

      function spawnFloater(param1:String, param2:Float, param3:Float, param4:UInt, param5:Float, param6:UInt, param7:UInt, param8:Float, param9:Float)
      {
         var _loc10_= ASCompat.dynamicAs(ASCompat.createInstance(mFloaterTextClass, []) , MovieClip);
         ASCompat.setProperty((_loc10_ : ASAny).label, "text", param1);
         ASCompat.setProperty((_loc10_ : ASAny).label, "textColor", param4);
         _loc10_.x = param2;
         _loc10_.y = param3;
         _loc10_.scaleX = param5;
         _loc10_.scaleY = param5;
         var _loc11_= new FloatingMessage(_loc10_,mDBFacade,param6,param7,param8,param9,null,floaterCallback(_loc10_));
         mDBFacade.sceneGraphManager.addChild(_loc10_,50);
      }

      public function setHp(param1:UInt, param2:UInt)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc3_= param1 / param2;
         mHpBar.value = _loc3_;
         mFlashingHpBar.value = _loc3_;
         mHpText.text = Std.string(param1) + " / " + Std.string(param2);
      }

      public function setMana(param1:UInt, param2:UInt)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mManaBar.value = param1 / param2;
         mManaText.text = Std.string(param1) + " / " + Std.string(param2);
      }

      function spawnBusterFloater(param1:Int, param2:Float)
      {
      }

      public function setBusterPoints(param1:UInt)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mBusterBar.value = param1 / mMaxBusterPoints;
         var _loc2_= (param1 - mBusterValue : Int);
         if(_loc2_ > 0)
         {
            spawnBusterFloater(_loc2_,mBusterBar.value * 75);
         }
         mBusterValue = param1;
         if(mBusterValue >= mMaxBusterPoints)
         {
            this.showBustSign();
         }
         else
         {
            this.hideBustSign();
         }
      }

      public function setCurrency(param1:Int, param2:Int)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         mBasicCurrencyText.text = Std.string(param1);
         mPremiumCurrencyText.text = Std.string(param2);
      }

      function spawnCoinFloater(param1:Int)
      {
      }

      public function setBasicCurrency(param1:Int)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc2_= (param1 - mBasicCurrency : Int);
         if(_loc2_ > 0)
         {
            spawnCoinFloater(_loc2_);
         }
         mBasicCurrencyText.text = Std.string(param1);
         mBasicCurrency = (param1 : UInt);
      }

      function spawnCashFloater(param1:Int)
      {
      }

      public function setPremiumCurrency(param1:Int)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc2_= (param1 - mPremiumCurrency : Int);
         if(_loc2_ > 0)
         {
            spawnCashFloater(_loc2_);
         }
         mPremiumCurrencyText.text = Std.string(param1);
         mPremiumCurrency = (param1 : UInt);
      }

      function spawnXpFloater(param1:Int, param2:Float)
      {
      }

      public function setXp(param1:UInt)
      {
         if(!mAssetsLoaded)
         {
            return;
         }
         var _loc5_= mHeroOwner.level;
         var _loc4_= param1;
         var _loc2_= (mHeroOwner.gMHero.getLevelIndex(param1) : UInt);
         var _loc7_= (ASCompat.toInt(_loc2_ > 0 ? mHeroOwner.gMHero.getExpFromIndex(_loc2_ - 1) : 0) : UInt);
         var _loc6_= mHeroOwner.gMHero.getExpFromIndex(_loc2_);
         mLevelText.text = Std.string(_loc5_);
         var _loc3_= ASCompat.toNumber(_loc4_ - _loc7_) / (_loc6_ - _loc7_);
         mXpBar.value = _loc3_;
         mXpText.text = Std.string(_loc4_) + " / " + Std.string(_loc6_);
         spawnXpFloater((param1 - mXpValue : Int),_loc3_ * 100);
         mXpValue = param1;
         if(!mXpGotInitialUpdate)
         {
            mXpGotInitialUpdate = true;
            bulgeXpBar();
         }
      }

      function updateXpBulge(param1:GameClock)
      {
         var _loc3_= mXpObject.root;
         var _loc2_= _loc3_.scaleX - mXpRestScale;
         _loc2_ *= Math.pow(0.75,param1.tickLength / GameClock.ANIMATION_FRAME_DURATION);
         _loc3_.scaleX = mXpRestScale + _loc2_;
         _loc3_.scaleY = mXpRestScale + _loc2_;
         if(Math.abs(_loc2_) <= 0.01)
         {
            _loc3_.scaleX = mXpRestScale;
            _loc3_.scaleY = mXpRestScale;
            mXpBulgeTask.destroy();
            mXpBulgeTask = null;
         }
      }

      public function bulgeXpBar()
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-pickup-ui-pop"))
         {
            return;
         }
         mXpObject.root.scaleX *= 1.08;
         mXpObject.root.scaleY *= 1.08;
         if(mXpBulgeTask == null)
         {
            mXpBulgeTask = mLogicalWorkComponent.doEveryFrame(updateXpBulge);
         }
      }

      function updateProfileBulge(param1:GameClock)
      {
         var _loc2_= mProfileBox.scaleX - mProfileRestScale;
         _loc2_ *= Math.pow(0.75,param1.tickLength / GameClock.ANIMATION_FRAME_DURATION);
         mProfileBox.scaleX = mProfileRestScale + _loc2_;
         mProfileBox.scaleY = mProfileRestScale + _loc2_;
         if(Math.abs(_loc2_) <= 0.01)
         {
            mProfileBox.scaleX = mProfileRestScale;
            mProfileBox.scaleY = mProfileRestScale;
            mProfileBulgeTask.destroy();
            mProfileBulgeTask = null;
         }
      }

      public function bulgeProfileBox()
      {
         if(!mDBFacade.featureFlags.getFlagValue("want-pickup-ui-pop"))
         {
            return;
         }
         mProfileBox.scaleX *= 1.08;
         mProfileBox.scaleY *= 1.08;
         if(mProfileBulgeTask == null)
         {
            mProfileBulgeTask = mLogicalWorkComponent.doEveryFrame(updateProfileBulge);
         }
      }

      public function destroy()
      {
         var _loc2_= 0;
         var _loc1_:UIButton = null;
         if(mProfileBox != null)
         {
            mProfileBox.removeEventListener("mouseOver",mouseOverProfileBox);
            mProfileBox.removeEventListener("mouseOut",mouseOutProfileBox);
         }
         mBuffs.splice(0,(mBuffs.length : UInt));
         mBuffs = null;
         _loc2_ = 0;
         while(_loc2_ < mBuffIconButtons.length)
         {
            if(mBuffIconButtons[_loc2_] != null)
            {
               mBuffIconButtons[_loc2_].destroy();
            }
            _loc2_++;
         }
         mBuffIconButtons = null;
         _loc2_ = 0;
         while(_loc2_ < mBuffCooldowns.length)
         {
            if(mBuffCooldowns[_loc2_] != null)
            {
               mBuffCooldowns[_loc2_].destroy();
            }
            _loc2_++;
         }
         mBuffCooldowns = null;
         if(mBoosterTimer != null)
         {
            mBoosterTimer.stop();
            mBoosterTimer = null;
         }
         mDBFacade = null;
         mOptionsPanel.destroy();
         mOptionsPanel = null;
         mStacksHud.destroy();
         mStacksHud = null;
         if(mOffScreenPlayerManager != null)
         {
            mOffScreenPlayerManager.destroy();
            mOffScreenPlayerManager = null;
         }
         mLogicalWorkComponent.destroy();
         mLogicalWorkComponent = null;
         mSceneGraphComponent.destroy();
         mSceneGraphComponent = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mEventComponent.destroy();
         mEventComponent = null;
         mHeroOwner = null;
         mRoot = null;
         mUIRoot = null;
         if(mAddCoinButton != null)
         {
            mAddCoinButton.destroy();
         }
         mAddCoinButton = null;
         if(mAddCashButton != null)
         {
            mAddCashButton.destroy();
         }
         mAddCashButton = null;
         if(mProfileBulgeTask != null)
         {
            mProfileBulgeTask.destroy();
         }
         mProfileBulgeTask = null;
         if(mHpBar != null)
         {
            mHpBar.destroy();
         }
         mHpBar = null;
         if(mFlashingHpBar != null)
         {
            mFlashingHpBar.destroy();
         }
         mFlashingHpBar = null;
         if(mManaBar != null)
         {
            mManaBar.destroy();
         }
         mManaBar = null;
         if(mBusterBar != null)
         {
            mBusterBar.destroy();
         }
         mBusterBar = null;
         if(mXpBar != null)
         {
            mXpBar.destroy();
         }
         mXpBar = null;
         if(mXpBulgeTask != null)
         {
            mXpBulgeTask.destroy();
         }
         mXpBulgeTask = null;
         if(mLootTask != null)
         {
            mLootTask.destroy();
         }
         mLootTask = null;
         if(mCloseButton != null)
         {
            mCloseButton.destroy();
         }
         mCloseButton = null;
         if(mWeaponZButton != null)
         {
            mWeaponZButton.destroy();
         }
         mWeaponZButton = null;
         if(mWeaponXButton != null)
         {
            mWeaponXButton.destroy();
         }
         mWeaponXButton = null;
         if(mWeaponCButton != null)
         {
            mWeaponCButton.destroy();
         }
         mWeaponCButton = null;
         if(mConsumable1Button != null)
         {
            mConsumable1Button.destroy();
         }
         mConsumable1Button = null;
         if(mConsumable2Button != null)
         {
            mConsumable2Button.destroy();
         }
         mConsumable2Button = null;
         if(mDungeonBusterButton != null)
         {
            mDungeonBusterButton.destroy();
         }
         mDungeonBusterButton = null;
         if(mBusterGlowMc != null)
         {
            mBusterGlowMc.destroy();
         }
         mBusterGlowMc = null;
         if(mOptionsButton != null)
         {
            mOptionsButton.destroy();
         }
         mOptionsButton = null;
         if(mOptionsPanel != null)
         {
            mOptionsPanel.destroy();
         }
         mOptionsPanel = null;
         if(mStacksHud != null)
         {
            mStacksHud.destroy();
         }
         mStacksHud = null;
         if(mUITask != null)
         {
            mUITask.destroy();
         }
         mUITask = null;
         if(mUIChatLog != null)
         {
            mUIChatLog.destroy();
         }
         mUIChatLog = null;
         if(mPetPortrait != null)
         {
            mPetPortrait.destroy();
         }
         final __ax4_iter_81 = mWeaponButtons;
         if (checkNullIteratee(__ax4_iter_81)) for (_tmp_ in __ax4_iter_81)
         {
            _loc1_  = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         final __ax4_iter_82 = mConsumableWeaponButtons;
         if (checkNullIteratee(__ax4_iter_82)) for (_tmp_ in __ax4_iter_82)
         {
            _loc1_  = _tmp_;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
            _loc1_ = null;
         }
         mSaleLabel = null;
         mProfileBox = null;
         mFloaterTextClass = null;
         mHpText = null;
         mManaText = null;
         mBusterRoot = null;
         mBasicCurrencyText = null;
         mPremiumCurrencyText = null;
         mLevelText = null;
         mXpObject = null;
         mXpText = null;
         mTeamLootMC.destroy();
         mTeamLootMC = null;
         mLootTween = null;
         mLootMouseArea = null;
         mBusterLabel = null;
         mBusterLabelOver = null;
         mSwfAsset = null;
      }

      @:isVar public var offScreenPlayerManager(get,never):UIOffScreenPlayerManager;
public function  get_offScreenPlayerManager() : UIOffScreenPlayerManager
      {
         return mOffScreenPlayerManager;
      }

      public function showBustSign()
      {
         ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow, "visible", true);
         mBusterGlowMc.play((1 : UInt),false,function()
         {
            ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow, "visible", false);
            ASCompat.setProperty((mUIRoot : ASAny).UI_buster_active, "visible", true);
            ASCompat.setProperty((mUIRoot : ASAny).UI_buster.buster_activated_glow, "visible", true);
         });
      }

      public function hideBustSign()
      {
         ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow, "visible", false);
         ASCompat.setProperty((mUIRoot : ASAny).UI_buster_active, "visible", false);
         ASCompat.setProperty((mUIRoot : ASAny).UI_buster.buster_activated_glow, "visible", false);
      }

      public function handleBusterBarClickEvent()
      {
         if(mHeroOwner != null && mHeroOwner.dungeonBusterPoints >= mHeroOwner.maxBusterPoints)
         {
            mEventComponent.dispatchEvent(new DungeonBusterControlActivatedEvent());
         }
      }

      public function setWeaponHighlight(param1:Int)
      {
         var _loc2_:UIButton;
         final __ax4_iter_83 = mWeaponButtons;
         if (checkNullIteratee(__ax4_iter_83)) for (_tmp_ in __ax4_iter_83)
         {
            _loc2_ = _tmp_;
            ASCompat.setProperty((_loc2_.root : ASAny).selectionFrame, "visible", false);
         }
         ASCompat.setProperty((mWeaponButtons[param1].root : ASAny).selectionFrame, "visible", true);
      }

      public function hideNotEnoughMana()
      {
         ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", false);
      }

      public function showNotEnoughMana()
      {
         ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", true);
         ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "text", Locale.getString("NOT_ENOUGH_MANA"));
      }

      @:isVar public var chatLog(get,never):UIChatLog;
public function  get_chatLog() : UIChatLog
      {
         return mUIChatLog;
      }

      public function isInCooldown()
      {
         showText("IS_IN_COOLDOWN");
      }

      public function startCooldown(param1:Int, param2:Float)
      {
         mCooldowns[param1].clip.visible = true;
         mCooldowns[param1].playRate = 1 / param2 * 4.1;
         mCooldowns[param1].play();
         ASCompat.setProperty((mWeaponButtons[param1].root : ASAny).graphic, "alpha", 0.5);
      }

      public function stopCooldown(param1:Int)
      {
         var currentWeaponIndex= param1;
         mCooldowns[currentWeaponIndex].stop();
         mCooldowns[currentWeaponIndex].clip.visible = false;
         ASCompat.setProperty((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic, "alpha", 1);
         TweenMax.to((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic,0.25,{
            "scaleX":1.25,
            "scaleY":1.25,
            "tint":16777215,
            "onComplete":function()
            {
               TweenMax.to((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic,0.25,{
                  "scaleX":1,
                  "scaleY":1,
                  "removeTint":true
               });
            }
         });
      }

      public function startConsumableCooldown(param1:Int, param2:Float)
      {
         mConsumableCooldowns[param1].clip.visible = true;
         mConsumableCooldowns[param1].playRate = 1 / param2 * 4.1;
         mConsumableCooldowns[param1].play();
         ASCompat.setProperty((mConsumableWeaponButtons[param1].root : ASAny).graphic, "alpha", 0.5);
      }

      public function stopConsumableCooldown(param1:Int)
      {
         var currentWeaponIndex= param1;
         mConsumableCooldowns[currentWeaponIndex].stop();
         mConsumableCooldowns[currentWeaponIndex].clip.visible = false;
         ASCompat.setProperty((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic, "alpha", 1);
         TweenMax.to((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic,0.25,{
            "scaleX":1.25,
            "scaleY":1.25,
            "tint":16777215,
            "onComplete":function()
            {
               TweenMax.to((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic,0.25,{
                  "scaleX":1,
                  "scaleY":1,
                  "removeTint":true
               });
            }
         });
      }

      public function decrementConsumableCount(param1:UInt)
      {
         ASCompat.setProperty((mConsumableWeaponButtons[(param1 : Int)].root : ASAny).quantity, "text", Std.string((ASCompat.toInt((mConsumableWeaponButtons[(param1 : Int)].root : ASAny).quantity.text) - 1)));
      }

      public function totalConsumableCountReached(param1:UInt)
      {
         mConsumableWeaponButtons[(param1 : Int)].enabled = false;
         mConsumableWeaponButtons[(param1 : Int)].root.filters = cast([new ColorMatrixFilter(cast([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0]))]);
      }

      public function showText(param1:String)
      {
         var localeTextName= param1;
         if((mUIRoot : ASAny).UI_center_message.visible == false)
         {
            ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", true);
            ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "text", Locale.getString(localeTextName));
            mLogicalWorkComponent.doLater(0.35,function()
            {
               ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", false);
            });
         }
         else
         {
            ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "text", Locale.getString(localeTextName));
         }
      }

      @:isVar public var teamLootDestination(get,never):Vector3D;
public function  get_teamLootDestination() : Vector3D
      {
         return mTeamLootDestination;
      }

      @:isVar public var profileDestination(get,never):Vector3D;
public function  get_profileDestination() : Vector3D
      {
         return mProfileDestination;
      }

      @:isVar public var coinsDestination(get,never):Vector3D;
public function  get_coinsDestination() : Vector3D
      {
         return mCoinsDestination;
      }

      @:isVar public var cashDestination(get,never):Vector3D;
public function  get_cashDestination() : Vector3D
      {
         return mCashDestination;
      }

      @:isVar public var expDestination(get,never):Vector3D;
public function  get_expDestination() : Vector3D
      {
         return mExpDestination;
      }

      @:isVar public var crowdDestination(get,never):Vector3D;
public function  get_crowdDestination() : Vector3D
      {
         return mCrowdDestination;
      }

      public function showBuffDisplay(param1:BuffGameObject)
      {
         var buffGO= param1;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(buffGO.buffData.IconSwf),function(param1:SwfAsset)
         {
            var _loc6_= param1.getClass(buffGO.buffData.IconName);
            var _loc5_= ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []) , MovieClip);
            var _loc2_= mSwfAsset.getClass("buff_cooldown_icon");
            var _loc4_= ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []) , MovieClip);
            var _loc7_= new MovieClipRenderer(mDBFacade,ASCompat.dynamicAs((_loc4_ : ASAny).cooldown, flash.display.MovieClip));
            _loc5_.alpha = 0.75;
            _loc5_.scaleX = _loc5_.scaleY = 0.75;
            (_loc4_ : ASAny).graphic.addChild(_loc5_);
            mRoot.addChild(_loc4_);
            var _loc3_= new UIButton(mDBFacade,_loc4_);
            _loc3_.tooltip = ASCompat.dynamicAs((_loc4_ : ASAny).tooltip, flash.display.MovieClip);
            ASCompat.setProperty((_loc4_ : ASAny).tooltip.title_label, "text", GameMasterLocale.getGameMasterSubString("BUFF_NAME",buffGO.buffData.Constant));
            ASCompat.setProperty((_loc4_ : ASAny).tooltip.description_label, "text", GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",buffGO.buffData.Constant) + buffGO.buffData.getStacksDescription((buffGO.instanceCount : Int)));
            mBuffIconButtons.push(_loc3_);
            mBuffs.push(buffGO);
            mBuffCooldowns.push(_loc7_);
            ASCompat.setProperty((_loc4_ : ASAny).quantity, "text", buffGO.instanceCount);
            resetBuffButtonPositions();
            startBuffCooldown(mBuffIconButtons.length - 1,buffGO.buffData.Duration);
         });
      }

      public function startBuffCooldown(param1:Int, param2:Float)
      {
         mBuffCooldowns[param1].playRate = 1 / param2 * 4.1;
         mBuffCooldowns[param1].play();
      }

      public function updateBuffDisplay(param1:GameClock)
      {
         var _loc3_= 0;
         var _loc2_:BuffGameObject = null;
         _loc3_ = 0;
         while(_loc3_ < mBuffs.length)
         {
            _loc2_ = mBuffs[_loc3_];
            if(_loc2_.isDestroyed)
            {
               mRoot.removeChild(mBuffIconButtons[_loc3_].root);
               mBuffIconButtons[_loc3_].destroy();
               mBuffCooldowns[_loc3_].destroy();
               mBuffs.splice(_loc3_,(1 : UInt));
               mBuffIconButtons.splice(_loc3_,(1 : UInt));
               mBuffCooldowns.splice(_loc3_,(1 : UInt));
            }
            _loc3_++;
         }
      }

      public function updateBuffInstance(param1:BuffGameObject)
      {
         var _loc2_:BuffGameObject = null;
         var _loc3_= 0;
         _loc3_ = 0;
         while(_loc3_ < mBuffs.length)
         {
            _loc2_ = mBuffs[_loc3_];
            if(_loc2_ == param1)
            {
               ASCompat.setProperty((mBuffIconButtons[_loc3_].root : ASAny).quantity, "text", _loc2_.instanceCount);
               ASCompat.setProperty((mBuffIconButtons[_loc3_].root : ASAny).tooltip.description_label, "text", GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",_loc2_.buffData.Constant) + _loc2_.buffData.getStacksDescription((_loc2_.instanceCount : Int)));
               startBuffCooldown(_loc3_,_loc2_.buffData.Duration);
               return;
            }
            _loc3_++;
         }
      }

      public function resetBuffButtonPositions()
      {
         var _loc1_= 0;
         _loc1_ = 0;
         while(_loc1_ < mBuffs.length)
         {
            if(mHudType == 1)
            {
               mBuffIconButtons[_loc1_].root.x = 455 + _loc1_ * 63;
               mBuffIconButtons[_loc1_].root.y = 865;
            }
            else
            {
               mBuffIconButtons[_loc1_].root.x = 424 + _loc1_ * 63;
               mBuffIconButtons[_loc1_].root.y = 980;
            }
            _loc1_++;
         }
      }

      public function refreshHUD()
      {
         this.setupUI(mSwfAsset,mHudType);
      }
   }


