package uI.hud;

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
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.render.MovieClipRenderer;
import brain.render.tweens.TweenHandle;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIProgressBar;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.utils.Timers;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import combat.weapon.ConsumableWeaponGameObject;
import combat.weapon.WeaponGameObject;
import dBGlobals.DBGlobal;
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
import input.keyBindings.KeyBindings;
import settings.model.SettingsModel;
import settings.SettingsPopup;
import steamInput.OnSteamInputButtonReleasedEvent;
import uI.*;
import uI.hud.starlingConverted.IGameHud;
import uI.infiniteIsland.II_UIExitDungeonPopUp;
import uI.inventory.UIWeaponTooltip;
import uI.popup.UILootLossPopup;
import flash.display.Bitmap;
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

class UIHud implements IGameHud {
	static inline final CONDENSEDHUD_BUFF_ICON_X_STARTPOS = 455;

	static inline final CONDENSEDHUD_BUFF_ICON_Y_STARTPOS = 865;

	static inline final CONDENSEDHUD_BUFF_ICON_X_DISPLACEMENT = 63;

	static inline final OLDHUD_BUFF_ICON_X_STARTPOS = 424;

	static inline final OLDHUD_BUFF_ICON_Y_STARTPOS = 980;

	static inline final OLDHUD_BUFF_ICON_X_DISPLACEMENT = 63;

	static inline final MAX_CHAT_CHARS = (44 : UInt);

	static inline final TEAMLOOT_POS = -550;

	static inline final TEAMLOOT_VISIBLE_TIME:Float = 2;

	static inline final TEAMLOOT_TWEEN_TIME:Float = 0.5;

	public static inline final UI_HUD_SWF_PATH = "Resources/Art2D/UI/db_UI_HUD.swf";

	public static inline final UI_HUD_CHANGE_EVENT = "UI_HUD_CHANGE_EVENT";

	static inline final PET_PORTRAIT_SPACING = (69 : UInt);

	static inline final PET_PORTRAIT_YPOS = (85 : UInt);

	static inline final PET_PORTRAIT_START_XPOS = (20 : UInt);

	static inline final ORIGINAL_COOLDOWN_ANIM_PLAY_TIME:Float = 4.1;

	public static inline final COMMON_CHEST_ID = (60001 : UInt);

	public static inline final UNCOMMON_CHEST_ID = (60002 : UInt);

	public static inline final RARE_CHEST_ID = (60003 : UInt);

	public static inline final LEGENDARY_CHEST_ID = (60004 : UInt);

	public static inline final SMALL_ITEM_BOX_ID = (60005 : UInt);

	public static inline final ROYAL_ITEM_BOX_ID = (60006 : UInt);

	static inline final BUSTER_PRESS_TEXT_CONTROLLER_OFFSET_X:Float = -5;

	static final TEAM_DEFAULT:Vector3D = new Vector3D(45, 150);

	static final PROFILE_DEFAULT:Vector3D = new Vector3D(112, 95);

	static final COINS_DEFAULT:Vector3D = new Vector3D(813, 57);

	static final CASH_DEFAULT:Vector3D = new Vector3D(1032, 57);

	static final EXP_DEFAULT:Vector3D = new Vector3D(1584, 78);

	static final CROWD_DEFAULT:Vector3D = new Vector3D(1869, 1041);

	static final TEAM_CONDENSED:Vector3D = new Vector3D(45, 150);

	static final PROFILE_CONDENSED:Vector3D = new Vector3D(1550, 980);

	static final COINS_CONDENSED:Vector3D = new Vector3D(60, 980);

	static final CASH_CONDENSED:Vector3D = new Vector3D(53, 1031);

	static final EXP_CONDENSED:Vector3D = new Vector3D(54, 915);

	static final CROWD_CONDENSED:Vector3D = new Vector3D(1555, 920);

	static final CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS:Vector3D = new Vector3D(13, -50);

	static final CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS:Point = new Point(25, 25);

	static final CONTROLLER_ICON_POSITION_FOR_CLOSE_BUTTON:Vector3D = new Vector3D(-5, -27);

	static final CONTROLLER_GLYPH_SCALE_CLOSE_BUTTON:Point = new Point(25, 25);

	static final CONTROLLER_ICON_POSITION_FOR_CHAT_SEND_BUTTON:Vector3D = new Vector3D(32, -10);

	static final CONTROLLER_ICON_POSITION_FOR_CHAT_LOG_BUTTON:Vector3D = new Vector3D(25, -10);

	static final CONTROLLER_GLYPH_SCALE_CHAT_BUTTONS:Point = new Point(20, 20);

	static final CONTROLLER_ICON_POSITION_FOR_DUNGEON_BUSTER:Vector3D = new Vector3D(8, -8);

	static final CONTROLLER_GLYPH_SCALE_DUNGEON_BUSTER:Point = new Point(25, 25);

	var mDBFacade:DBFacade;

	var mHeroOwner:HeroGameObjectOwner;

	var mSceneGraphComponent:SceneGraphComponent;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mWantPets:Bool = false;

	var mAssetsLoaded:Bool = false;

	var mRoot:Sprite;

	var mUIRoot:MovieClip;

	var mProfileBox:MovieClip;

	var mProfileBulgeTask:Task;

	var mProfileRestScale:Float = Math.NaN;

	var mBuffDisplayTask:Task;

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

	var mXpRestScale:Float = Math.NaN;

	var mXpValue:UInt = 0;

	var mTeamLootMC:MovieClipRenderController;

	var mLootTween:TweenHandle;

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

	var mBusterPulseMc:MovieClipRenderController;

	var mXPBonusText:TextField;

	var mCoinBonusText:TextField;

	var mSettingsPopup:SettingsPopup;

	var mSettingsModel:SettingsModel;

	var mStacksHud:UIStacksHud;

	var mEventComponent:EventComponent;

	var mUITask:Task;

	var mLogicalWorkComponent:LogicalWorkComponent;

	var mSwfAsset:SwfAsset;

	var mOffScreenPlayerManager:UIOffScreenPlayerManager;

	var mMaxBusterPoints:UInt = 0;

	var mUIChatLog:UIChatLog;

	var mHealthFullRevealer:Revealer;

	var mManaFullRevealer:Revealer;

	var mHealthFullFloater:FloatingMessage;

	var mManaFullFloater:FloatingMessage;

	var mPetPortraitRoot:MovieClip;

	var mPetPortraitNoneRoot:MovieClip;

	var mPetPortrait:PetPortraitUI;

	var mPetCarriedAcrossRebuild:NPCGameObject;

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

	var mHudControllerIcons:Vector<ControllerIconData>;

	var mExternalControllerIcons:Vector<ControllerIconData>;

	var mBusterPressTextOriginals:ASDictionary<ASAny, ASAny>;

	var mInitControllerIconsLater:Task;

	var mControllerIconLoadDelay:Int = 1;

	var mLootLossPopup:UILootLossPopup;

	var mInfiniteExitPopup:II_UIExitDungeonPopUp;

	var mSuppressNextExitMenuToggle:Bool = false;

	public function new(facade:DBFacade) {
		var settingsModel:SettingsModel;
		mHudControllerIcons = new Vector<ControllerIconData>();
		mExternalControllerIcons = new Vector<ControllerIconData>();
		mBusterPressTextOriginals = new ASDictionary<ASAny, ASAny>(true);

		mDBFacade = facade;
		mRoot = new Sprite();
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIHud");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "UIHud");
		mMaxBusterPoints = (ASCompat.floatToInt(4294967295) : UInt);
		settingsModel = mDBFacade.settingsModel;
		mStacksHud = new UIStacksHud(mDBFacade);
		mEventComponent = new EventComponent(mDBFacade);
		mDBFacade.keyBindings.addChangeListener(onKeyBindingsChanged);
		mSettingsModel = settingsModel;
		mSettingsModel.addChangeListener(onSettingChanged);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"), function(param1:SwfAsset) {
			setupUI(param1, (ASCompat.toInt(settingsModel.getValue("hudStyle")) : UInt));
		});
		mXpBulgeTask = null;
		mProfileBulgeTask = null;
		mBuffs = new Vector<BuffGameObject>();
		mBuffIconButtons = new Vector<UIButton>();
		mBuffCooldowns = new Vector<MovieClipRenderer>();
	}

	static function setButtonLabel(button:UIButton, text:String) {
		if (button == null || button.label == null) {
			return;
		}
		button.label.text = text;
	}

	static function hideControllerIcon(iconData:ControllerIconData) {
		iconData.mIsHidden = true;
		if (iconData.mOwner != null && iconData.mControllerGlyph != null && iconData.mOwner.contains(iconData.mControllerGlyph)) {
			iconData.mOwner.removeChild(iconData.mControllerGlyph);
		}
	}

	static function hideControllerIcons(icons:Vector<ControllerIconData>) {
		var _loc2_:ControllerIconData;
		if (checkNullIteratee(icons))
			for (_tmp_ in icons) {
				_loc2_ = _tmp_;
				hideControllerIcon(_loc2_);
			}
	}

	static function unloadControllerIcons(icons:Vector<ControllerIconData>) {
		var _loc2_:ControllerIconData;
		if (checkNullIteratee(icons))
			for (_tmp_ in icons) {
				_loc2_ = _tmp_;
				hideControllerIcon(_loc2_);
				_loc2_.destroy();
			}
		icons.length = 0;
	}

	public static function isThisAConsumbleChestId(chestId:Int):Bool {
		return chestId == 60005 || chestId == 60006;
	}

	function switchHudEvent(event:UIHudChangeEvent) {
		this.setupUI(mSwfAsset, event.hudType);
		resetBuffButtonPositions();
		if (mAssetsLoaded && mHeroOwner != null) {
			setupStatsForResourceBars();
		}
	}

	@:isVar public var chatLogContainer(get, never):MovieClip;

	public function get_chatLogContainer():MovieClip {
		return ASCompat.coerce((mUIRoot : ASAny).chatLogContainer, flash.display.MovieClip);
	}

	public function offScreenPicChange(playerId:Int, picType:String) {
		if (mOffScreenPlayerManager != null) {
			mOffScreenPlayerManager.handlePicChange(playerId, picType);
		}
	}

	@:isVar public var ownedHero(get, never):HeroGameObjectOwner;

	public function get_ownedHero():HeroGameObjectOwner {
		return mHeroOwner;
	}

	@:isVar public var swfAsset(get, never):SwfAsset;

	public function get_swfAsset():SwfAsset {
		return mSwfAsset;
	}

	function setDooberLocations(hudType:UInt) {
		switch (hudType) {
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

	function setupUI(swfAsset:SwfAsset, hudType:UInt = (0 : UInt)) {
		var cooldownIndex:Int;
		var hudClassName:String;
		var hudClass:Dynamic;
		var i:UInt;
		var tooltipOffsset:Point;
		mHudType = hudType;
		if (mUIRoot != null && mRoot.contains(mUIRoot)) {
			mRoot.removeChild(mUIRoot);
		}
		mPetCarriedAcrossRebuild = ASCompat.coerce(mPetPortrait != null ? mPetPortrait.petNPCGameObject : null, distributedObjects.NPCGameObject);
		if (mHpBar != null) {
			mHpBar.destroy();
		}
		mHpBar = null;
		if (mFlashingHpBar != null) {
			mFlashingHpBar.destroy();
		}
		mFlashingHpBar = null;
		if (mManaBar != null) {
			mManaBar.destroy();
		}
		mManaBar = null;
		if (mBusterBar != null) {
			mBusterBar.destroy();
		}
		mBusterBar = null;
		if (mXpBar != null) {
			mXpBar.destroy();
		}
		mXpBar = null;
		if (mPetPortrait != null) {
			mPetPortrait.destroy();
		}
		mPetPortrait = null;
		if (mBasicCurrencyUI != null) {
			mBasicCurrencyUI.destroy();
		}
		mBasicCurrencyUI = null;
		if (mPremiumCurrencyUI != null) {
			mPremiumCurrencyUI.destroy();
		}
		mPremiumCurrencyUI = null;
		if (mXpObject != null) {
			mXpObject.destroy();
		}
		mXpObject = null;
		if (mCloseButton != null) {
			mCloseButton.destroy();
		}
		mCloseButton = null;
		if (mWeaponZButton != null) {
			mWeaponZButton.destroy();
		}
		mWeaponZButton = null;
		if (mWeaponXButton != null) {
			mWeaponXButton.destroy();
		}
		mWeaponXButton = null;
		if (mWeaponCButton != null) {
			mWeaponCButton.destroy();
		}
		mWeaponCButton = null;
		mWeaponButtons = null;
		if (mConsumable1Button != null) {
			mConsumable1Button.destroy();
		}
		mConsumable1Button = null;
		if (mConsumable2Button != null) {
			mConsumable2Button.destroy();
		}
		mConsumable2Button = null;
		mConsumableWeaponButtons = null;
		if (mDungeonModifer1 != null) {
			mDungeonModifer1.destroy();
		}
		mDungeonModifer1 = null;
		if (mDungeonModifer2 != null) {
			mDungeonModifer2.destroy();
		}
		mDungeonModifer2 = null;
		if (mDungeonModifer3 != null) {
			mDungeonModifer3.destroy();
		}
		mDungeonModifer3 = null;
		if (mDungeonModifer4 != null) {
			mDungeonModifer4.destroy();
		}
		mDungeonModifer4 = null;
		if (mCooldowns != null) {
			cooldownIndex = 0;
			while (cooldownIndex < mCooldowns.length) {
				if (mCooldowns[cooldownIndex] != null) {
					mCooldowns[cooldownIndex].destroy();
				}
				cooldownIndex = cooldownIndex + 1;
			}
			mCooldowns = null;
		}
		if (mConsumableCooldowns != null) {
			cooldownIndex = 0;
			while (cooldownIndex < mConsumableCooldowns.length) {
				if (mConsumableCooldowns[cooldownIndex] != null) {
					mConsumableCooldowns[cooldownIndex].destroy();
				}
				cooldownIndex = cooldownIndex + 1;
			}
			mConsumableCooldowns = null;
		}
		if (mInitControllerIconsLater != null) {
			mInitControllerIconsLater.destroy();
		}
		mInitControllerIconsLater = null;
		destroyTeamLoot();
		mSwfAsset = swfAsset;
		switch (hudType) {
			case 0:
				hudClassName = "ui_hud_old";
				mDBFacade.camera.offset = new Point(0, 45);
				mVerticalYClipping = 0;

			case 1:
				hudClassName = "ui_hud";
				mDBFacade.camera.offset = new Point(0, 0);
				mVerticalYClipping = 90;

			default:
				hudClassName = "ui_hud_old";
				mDBFacade.camera.offset = new Point(0, 45);
				mVerticalYClipping = 0;
				Logger.warn("Unable to determine hud with type: " + hudType);
		}
		setDooberLocations(mHudType);
		mDBFacade.camera.yCilppingFromBottom = mVerticalYClipping;
		mDBFacade.camera.forceRedraw();
		hudClass = swfAsset.getClass(hudClassName);
		mUIRoot = ASCompat.coerce(ASCompat.createInstance(hudClass, []), flash.display.MovieClip);
		mRoot.addChild(mUIRoot);
		mFloaterTextClass = swfAsset.getClass("floater_text");
		mStacksHud.initializeHud(swfAsset.getClass("stacks_hud"));
		if (mUIChatLog != null) {
			mUIChatLog.destroy();
		}
		mUIChatLog = new UIChatLog(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).chatLogContainer, flash.display.MovieClip),
			ASCompat.coerce((mUIRoot : ASAny).UI_chat, flash.display.MovieClip), ASCompat.coerce((mUIRoot : ASAny).UI_chat.log_btn, flash.display.MovieClip),
			ASCompat.coerce((mUIRoot : ASAny).UI_chat.chat_btn, flash.display.MovieClip));
		if (mHudType != 1) {
			mUIChatLog.textSizeModifier = 1.18;
		}
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).close, flash.display.MovieClip));
		mCloseButton.releaseCallback = function() {
			closeButtonReleaseCallback();
		};
		if (mDBFacade.dbConfigManager.getConfigBoolean("want_pets", true)) {
			mWantPets = true;
		}
		mProfileBox = ASCompat.coerce((mUIRoot : ASAny).UI_profile, flash.display.MovieClip);
		mProfileRestScale = mProfileBox.scaleX;
		mHpBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_profile.HP_bar, flash.display.MovieClip),
			ASCompat.coerce((mUIRoot : ASAny).UI_profile.HP_bar_delta, flash.display.MovieClip));
		mHpText = ASCompat.coerce((mUIRoot : ASAny).UI_profile.HP_text, flash.text.TextField);
		mHpText.visible = false;
		mFlashingHpBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_profile.HP_bar_invincible, flash.display.MovieClip));
		mFlashingHpBar.visible = false;
		mFlashingHpBar.root.mouseEnabled = false;
		mManaBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_profile.mana_bar, flash.display.MovieClip),
			ASCompat.coerce((mUIRoot : ASAny).UI_profile.mana_bar_delta, flash.display.MovieClip));
		mManaText = ASCompat.coerce((mUIRoot : ASAny).UI_profile.mana_text, flash.text.TextField);
		mManaText.visible = false;
		mHealthFullClip = ASCompat.coerce((mUIRoot : ASAny).UI_profile.HP_full_text, flash.text.TextField);
		mManaFullClip = ASCompat.coerce((mUIRoot : ASAny).UI_profile.mana_full_text, flash.text.TextField);
		mHealthFullClip.mouseEnabled = false;
		mManaFullClip.mouseEnabled = false;
		mHealthFullClip.visible = false;
		mManaFullClip.visible = false;
		mBusterRoot = ASCompat.coerce((mUIRoot : ASAny).UI_buster, flash.display.MovieClip);
		mBusterBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_buster.buster_bar, flash.display.MovieClip));
		hideBustSign();
		mBasicCurrencyUI = new UIObject(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_currency_coin, flash.display.MovieClip));
		mBasicCurrencyUI.setRootMovieClipAsBitMap();
		mPremiumCurrencyUI = new UIObject(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_currency_cash, flash.display.MovieClip));
		mPremiumCurrencyUI.setRootMovieClipAsBitMap();
		mBasicCurrencyText = ASCompat.coerce((mUIRoot : ASAny).UI_currency_coin.game_currency_text, flash.text.TextField);
		mBasicCurrencyText.mouseEnabled = false;
		mPremiumCurrencyText = ASCompat.coerce((mUIRoot : ASAny).UI_currency_cash.cash_text, flash.text.TextField);
		mPremiumCurrencyText.mouseEnabled = false;
		if (mDBFacade.dbAccountInfo != null) {
			setCurrency((mDBFacade.dbAccountInfo.basicCurrency : Int), (mDBFacade.dbAccountInfo.premiumCurrency : Int));
		}
		mLevelText = ASCompat.coerce((mUIRoot : ASAny).UI_XP.xp_level, flash.text.TextField);
		mXpObject = new UIObject(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_XP, flash.display.MovieClip));
		mXpRestScale = mXpObject.root.scaleX;
		mXpBar = new UIProgressBar(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_XP.xp_bar, flash.display.MovieClip),
			ASCompat.coerce((mUIRoot : ASAny).UI_XP.xp_bar_delta, flash.display.MovieClip));
		ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_bar_delta, "alpha", 0.3);
		mXpText = ASCompat.coerce((mUIRoot : ASAny).UI_XP.xp_points, flash.text.TextField);
		mXpText.visible = false;
		ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", false);
		mXPBonusText = ASCompat.coerce((mUIRoot : ASAny).UI_XP.doublexp_text, flash.text.TextField);
		mCoinBonusText = ASCompat.coerce((mUIRoot : ASAny).UI_currency_coin.doublecoin_text, flash.text.TextField);
		mCoinBonusText.visible = false;
		mWeaponZButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_weapons.weapon_z, flash.display.MovieClip));
		mWeaponXButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_weapons.weapon_x, flash.display.MovieClip));
		mWeaponCButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_weapons.weapon_c, flash.display.MovieClip));
		mWeaponButtons = Vector.ofArray([mWeaponZButton, mWeaponXButton, mWeaponCButton]);
		if (!mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds")) {
			mWeaponZButton.setRootMovieClipAsBitMap();
			mWeaponXButton.setRootMovieClipAsBitMap();
			mWeaponCButton.setRootMovieClipAsBitMap();
		}
		i = (0 : UInt);
		while (i < (mWeaponButtons.length:UInt)) {
			this.createWeaponTooltip(mWeaponButtons[(i : Int)], i);
			i = i + 1;
		}
		mCooldowns = new Vector<MovieClipRenderer>();
		mCooldowns.push(new MovieClipRenderer(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_weapons.weapon_z.cooldown, flash.display.MovieClip)));
		ASCompat.setProperty((mUIRoot : ASAny).UI_weapons.weapon_z.cooldown, "visible", false);
		mCooldowns.push(new MovieClipRenderer(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_weapons.weapon_x.cooldown, flash.display.MovieClip)));
		ASCompat.setProperty((mUIRoot : ASAny).UI_weapons.weapon_x.cooldown, "visible", false);
		mCooldowns.push(new MovieClipRenderer(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_weapons.weapon_c.cooldown, flash.display.MovieClip)));
		ASCompat.setProperty((mUIRoot : ASAny).UI_weapons.weapon_c.cooldown, "visible", false);
		mConsumable1Button = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).consumables_01, flash.display.MovieClip));
		mConsumable2Button = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).consumables_02, flash.display.MovieClip));
		mConsumableWeaponButtons = Vector.ofArray([mConsumable1Button, mConsumable2Button]);
		mConsumable1Button.setRootMovieClipAsBitMap();
		mConsumable2Button.setRootMovieClipAsBitMap();
		refreshKeyboardLabels();
		mConsumableCooldowns = new Vector<MovieClipRenderer>();
		mConsumableCooldowns.push(new MovieClipRenderer(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).consumables_01.cooldown, flash.display.MovieClip)));
		ASCompat.setProperty((mUIRoot : ASAny).consumables_01.cooldown, "visible", false);
		mConsumableCooldowns.push(new MovieClipRenderer(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).consumables_02.cooldown, flash.display.MovieClip)));
		ASCompat.setProperty((mUIRoot : ASAny).consumables_02.cooldown, "visible", false);
		ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", false);
		mPetPortraitRoot = ASCompat.coerce((mUIRoot : ASAny).pet, flash.display.MovieClip);
		if (ASCompat.toBool((mUIRoot : ASAny).pet_none)) {
			mPetPortraitNoneRoot = ASCompat.coerce((mUIRoot : ASAny).pet_none, flash.display.MovieClip);
		}
		mAssetsLoaded = true;
		mFloorLabel = ASCompat.coerce((mUIRoot : ASAny).label_floor, flash.text.TextField);
		mFloorLabel.cacheAsBitmap = true;
		tooltipOffsset = new Point(0, -15);
		mDungeonModifer1 = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).floor_modifier01, flash.display.MovieClip));
		mDungeonModifer1.tooltip = ASCompat.coerce((mUIRoot : ASAny).tooltip_modifier01, flash.display.MovieClip);
		mDungeonModifer1.tooltipPos = tooltipOffsset;
		mDungeonModifer2 = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).floor_modifier02, flash.display.MovieClip));
		mDungeonModifer2.tooltip = ASCompat.coerce((mUIRoot : ASAny).tooltip_modifier02, flash.display.MovieClip);
		mDungeonModifer2.tooltipPos = tooltipOffsset;
		mDungeonModifer3 = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).floor_modifier03, flash.display.MovieClip));
		mDungeonModifer3.tooltip = ASCompat.coerce((mUIRoot : ASAny).tooltip_modifier03, flash.display.MovieClip);
		mDungeonModifer3.tooltipPos = tooltipOffsset;
		mDungeonModifer4 = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).floor_modifier04, flash.display.MovieClip));
		mDungeonModifer4.tooltip = ASCompat.coerce((mUIRoot : ASAny).tooltip_modifier04, flash.display.MovieClip);
		mDungeonModifer4.tooltipPos = tooltipOffsset;
		if (mDBFacade.steamInputManager.wantsControllerPrompts) {
			setAllKeyboardIconsVisibility(false);
		}
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			mInitControllerIconsLater = mLogicalWorkComponent.doLater(mControllerIconLoadDelay, initAllControllerIconsTask);
		}
		if (mHeroOwner != null) {
			this.initializeHud(mHeroOwner);
		}
	}

	function closeButtonReleaseCallback() {
		var xpLoss:UInt;
		var closeCallback:ASFunction = function() {
			var _loc1_:ASObject = {};
			ASCompat.setProperty(_loc1_, "buttonDesc", "UIHud Exit Button Clicked");
			ASCompat.setProperty(_loc1_, "areaType", "Dungeon");
			mDBFacade.metrics.log("ButtonClick", _loc1_);
			mUIChatLog.hideChatLog();
			mInfiniteExitPopup = null;
			mLootLossPopup = null;
			mDBFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
			mDBFacade.dbAccountInfo.dbAccountParams.flushParams();
		};
		if (mHeroOwner.distributedDungeonFloor.isInfiniteDungeon) {
			if (mInfiniteExitPopup == null) {
				mInfiniteExitPopup = new II_UIExitDungeonPopUp(mDBFacade, closeCallback, null, openSettingsPopup);
				MemoryTracker.track(mInfiniteExitPopup, "II_UIExitDungeonPopup - created in UIHud.setupUI()");
			} else {
				mInfiniteExitPopup.destroy();
				mInfiniteExitPopup = null;
			}
		} else if (mLootLossPopup == null) {
			xpLoss = mHeroOwner.distributedDungeonFloor.completionXp;
			mLootLossPopup = new UILootLossPopup(mDBFacade, xpLoss, mHeroOwner.distributedDungeonFloor.treasureCollected, closeCallback, null,
				openSettingsPopup);
			MemoryTracker.track(mLootLossPopup, "UILootLossPopup - created in UIHud.setupUI()");
		} else {
			mLootLossPopup.destroy();
			mLootLossPopup = null;
		}
	}

	function initAllControllerIconsTask(inClock:GameClock) {
		mInitControllerIconsLater = null;
		initAllControllerIcons();
	}

	function initAllControllerIcons() {
		if (!mDBFacade.steamInputManager.isSteamInputReady) {
			Logger.warn("Attempted to display Controller Icons but no controllers are connected. Aborting.");
			return;
		}
		unloadControllerIcons(mHudControllerIcons);
		initControllerIconOn("attack_weapon_1", mWeaponZButton, CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS, CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
		initControllerIconOn("attack_weapon_2", mWeaponXButton, CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS, CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
		initControllerIconOn("attack_weapon_3", mWeaponCButton, CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS, CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
		initControllerIconOn("use_consumable_one", mConsumable1Button, CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS, CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
		initControllerIconOn("use_consumable_two", mConsumable2Button, CONTROLLER_ICON_POSITION_FOR_WEAPON_BUTTONS, CONTROLLER_GLYPH_SCALE_WEAPON_BUTTONS);
		initControllerIconOn("use_dungeon_buster", mDungeonBusterButton, CONTROLLER_ICON_POSITION_FOR_DUNGEON_BUSTER, CONTROLLER_GLYPH_SCALE_DUNGEON_BUSTER);
		initControllerIconOn("toggle_menu", mCloseButton, CONTROLLER_ICON_POSITION_FOR_CLOSE_BUTTON, CONTROLLER_GLYPH_SCALE_CLOSE_BUTTON);
		initControllerIconOn("toggle_chat_log", ASCompat.coerce(mUIChatLog != null ? mUIChatLog.chatLogButton : null, brain.uI.UIButton),
			CONTROLLER_ICON_POSITION_FOR_CHAT_LOG_BUTTON, CONTROLLER_GLYPH_SCALE_CHAT_BUTTONS);
		if (mDBFacade.steamInputManager.usesSteamOnScreenKeyboard) {
			initControllerIconOn("open_chat_keyboard", ASCompat.coerce(mUIChatLog != null ? mUIChatLog.chatSendButton : null, brain.uI.UIButton),
				CONTROLLER_ICON_POSITION_FOR_CHAT_SEND_BUTTON, CONTROLLER_GLYPH_SCALE_CHAT_BUTTONS);
		}
	}

	function onSettingChanged(id:String) {
		if (id != "numbersOnBars") {
			return;
		}
		if (mAssetsLoaded && mHeroOwner != null) {
			setupStatsForResourceBars();
		}
	}

	function onKeyBindingsChanged(action:String) {
		refreshKeyboardLabels();
	}

	function refreshKeyboardLabels() {
		var _loc2_ = ASCompat.coerce(mDBFacade != null ? mDBFacade.keyBindings : null, input.keyBindings.KeyBindings);
		if (_loc2_ == null || mUIRoot == null) {
			return;
		}
		setButtonLabel(mWeaponZButton, _loc2_.displayNameFor("attackWeapon1"));
		setButtonLabel(mWeaponXButton, _loc2_.displayNameFor("attackWeapon2"));
		setButtonLabel(mWeaponCButton, _loc2_.displayNameFor("attackWeapon3"));
		setButtonLabel(mConsumable1Button, _loc2_.displayNameFor("useConsumable1"));
		setButtonLabel(mConsumable2Button, _loc2_.displayNameFor("useConsumable2"));
		if (mDungeonBusterButton == null || mDBFacade.steamInputManager.hasGlyphForAction("use_dungeon_buster")) {
			return;
		}
		var _loc1_ = Locale.getString("PRESS_BUSTER_BUTTON_KEYBOARD") + _loc2_.displayNameFor("useDungeonBuster");
		TextUtil.setText(ASCompat.coerce((mUIRoot : ASAny).UI_buster_active.buster_activated.up.db_pressbutton_text, flash.text.TextField), _loc1_);
		TextUtil.setText(ASCompat.coerce((mUIRoot : ASAny).UI_buster_active.buster_activated.over.mc.db_pressbutton_text, flash.text.TextField), _loc1_);
	}

	function initControllerIconOn(inActionName:String, inButton:UIButton, iconPosition:Vector3D, iconScale:Point) {
		if (inButton == null || inButton.root == null) {
			return;
		}
		addControllerIcon(mHudControllerIcons, inActionName, inButton.root, iconPosition, iconScale);
	}

	function setAllKeyboardIconsVisibility(isVisible:Bool) {
		mWeaponZButton.label.visible = keepsKeyboardLabel(isVisible, "attack_weapon_1");
		mWeaponXButton.label.visible = keepsKeyboardLabel(isVisible, "attack_weapon_2");
		mWeaponCButton.label.visible = keepsKeyboardLabel(isVisible, "attack_weapon_3");
		mConsumable1Button.label.visible = keepsKeyboardLabel(isVisible, "use_consumable_one");
		mConsumable2Button.label.visible = keepsKeyboardLabel(isVisible, "use_consumable_two");
		if (mUIChatLog != null) {
			mUIChatLog.setChatPromptVisible(isVisible);
		}
		setBusterPressText(keepsKeyboardLabel(isVisible, "use_dungeon_buster"));
	}

	function keepsKeyboardLabel(isVisible:Bool, actionName:String):Bool {
		return isVisible || !mDBFacade.steamInputManager.hasGlyphForAction(actionName);
	}

	function setBusterPressText(isKeyboard:Bool) {
		var _loc2_:ASObject = null;
		if (mUIRoot == null || (mUIRoot : ASAny).UI_buster_active == null) {
			return;
		}
		var _loc4_ = ASCompat.coerce((mUIRoot : ASAny).UI_buster_active.buster_activated, flash.display.MovieClip);
		if (_loc4_ == null) {
			return;
		}
		var _loc3_:TextField;
		final __ax4_iter_417:Array<ASAny> = [
			(_loc4_ : ASAny)
			.up.db_pressbutton_text,
			(_loc4_ : ASAny)
			.over.mc.db_pressbutton_text
		];
		if (checkNullIteratee(__ax4_iter_417))
			for (_tmp_ in __ax4_iter_417) {
				_loc3_ = ASCompat.coerce(_tmp_, flash.text.TextField);
				if (_loc3_ != null) {
					_loc2_ = mBusterPressTextOriginals[_loc3_];
					if (_loc2_ == null) {
						_loc2_ = {
							"text": _loc3_.text,
							"x": _loc3_.x
						};
						mBusterPressTextOriginals[_loc3_] = _loc2_;
					}
					if (isKeyboard) {
						_loc3_.x = ASCompat.toNumberField(_loc2_, "x");
						TextUtil.setText(_loc3_, _loc2_.text);
					} else {
						_loc3_.x = ASCompat.toNumber(_loc2_.x + -5);
						Locale.setText(_loc3_, "PRESS_BUSTER_BUTTON_CONTROLLER");
					}
				}
			}
		if (isKeyboard) {
			refreshKeyboardLabels();
		}
	}

	public function initControllerIcon(inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) {
		addControllerIcon(mExternalControllerIcons, inActionName, inOwner, iconPosition, iconScale);
	}

	public function removeControllerIcons(inOwner:MovieClip) {
		var _loc2_ = 0;
		var _loc3_:ControllerIconData = null;
		_loc2_ = mExternalControllerIcons.length - 1;
		while (_loc2_ >= 0) {
			_loc3_ = mExternalControllerIcons[_loc2_];
			if (_loc3_.mOwner == inOwner) {
				hideControllerIcon(_loc3_);
				_loc3_.destroy();
				mExternalControllerIcons.removeAt(_loc2_);
			}
			_loc2_--;
		}
	}

	function addControllerIcon(icons:Vector<ControllerIconData>, inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) {
		if (inOwner == null) {
			return;
		}
		var _loc7_:ControllerIconData = null;
		var _loc6_:ControllerIconData;
		if (checkNullIteratee(icons))
			for (_tmp_ in icons) {
				_loc6_ = _tmp_;
				if (_loc6_.mActionName == inActionName && _loc6_.mOwner == inOwner) {
					_loc7_ = _loc6_;
					break;
				}
			}
		if (_loc7_ == null) {
			_loc7_ = new ControllerIconData(null, inOwner, false);
			_loc7_.mActionName = inActionName;
			icons.push(_loc7_);
		}
		_loc7_.mPosition = iconPosition;
		_loc7_.mScale = iconScale;
		if (!mDBFacade.steamInputManager.isSteamInputReady) {
			_loc7_.mIsHidden = true;
			return;
		}
		showControllerIcon(_loc7_);
	}

	function showControllerIcon(iconData:ControllerIconData) {
		var glyphFilePath:String;
		iconData.mIsHidden = false;
		glyphFilePath = mDBFacade.steamInputManager.getGlyphFilePathForAction(iconData.mActionName);
		if (glyphFilePath == "error1" || glyphFilePath == "") {
			glyphFilePath = null;
		}
		if (glyphFilePath == iconData.mGlyphFilePath) {
			if (iconData.mControllerGlyph != null && !iconData.mOwner.contains(iconData.mControllerGlyph)) {
				iconData.mOwner.addChild(iconData.mControllerGlyph);
			}
			return;
		}
		if (iconData.mControllerGlyph != null && iconData.mOwner.contains(iconData.mControllerGlyph)) {
			iconData.mOwner.removeChild(iconData.mControllerGlyph);
		}
		iconData.mControllerGlyph = null;
		iconData.mGlyphFilePath = glyphFilePath;
		if (glyphFilePath == null) {
			Logger.warnch("Input", "UIHud: no controller glyph for action \'" + iconData.mActionName + "\'");
			return;
		}
		mAssetLoadingComponent.getImageAsset(glyphFilePath, function(param1:brain.assetRepository.ImageAsset) {
			if (iconData.mOwner == null || iconData.mGlyphFilePath != glyphFilePath || iconData.mControllerGlyph != null) {
				return;
			}
			var _loc2_ = new Bitmap(param1.image.bitmapData, param1.image.pixelSnapping, param1.image.smoothing);
			_loc2_.x = iconData.mPosition.x;
			_loc2_.y = iconData.mPosition.y;
			_loc2_.width = iconData.mScale.x;
			_loc2_.height = iconData.mScale.y;
			iconData.mControllerGlyph = _loc2_;
			if (!iconData.mIsHidden) {
				iconData.mOwner.addChild(_loc2_);
			}
		});
	}

	function refreshControllerIcons(icons:Vector<ControllerIconData>) {
		var _loc2_:ControllerIconData;
		if (checkNullIteratee(icons))
			for (_tmp_ in icons) {
				_loc2_ = _tmp_;
				showControllerIcon(_loc2_);
			}
	}

	function hideAndUnloadControllerIcons() {
		unloadControllerIcons(mHudControllerIcons);
		unloadControllerIcons(mExternalControllerIcons);
	}

	function syncControllerPrompts() {
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			initAllControllerIcons();
			refreshControllerIcons(mExternalControllerIcons);
		} else {
			hideControllerIcons(mHudControllerIcons);
			hideControllerIcons(mExternalControllerIcons);
		}
		setAllKeyboardIconsVisibility(!mDBFacade.steamInputManager.wantsControllerPrompts);
	}

	function openSettingsPopup() {
		if (mSettingsPopup != null || mDBFacade == null) {
			return;
		}
		mSettingsPopup = new SettingsPopup(mDBFacade, onSettingsPopupClosed);
		MemoryTracker.track(mSettingsPopup, "SettingsPopup - created in UIHud.openSettingsPopup()");
	}

	function toggleSettingsPopup() {
		if (mSettingsPopup == null) {
			openSettingsPopup();
		} else if (SettingsPopup.isTopMenu(mDBFacade)) {
			mSettingsPopup.destroy();
			mSettingsPopup = null;
		}
	}

	function onSteamInputButtonReleased(event:OnSteamInputButtonReleasedEvent) {
		if (event.actionName == "menu_options" && mSettingsPopup != null) {
			toggleSettingsPopup();
		}
	}

	function onSettingsPopupClosed() {
		mSettingsPopup = null;
		mSuppressNextExitMenuToggle = mDBFacade.inputManager.check(27);
	}

	function mouseOverXpListener(e:Event) {
		ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", false);
		mXpText.visible = true;
	}

	function mouseOutXpListener(e:Event) {
		if (!mDBFacade.featureFlags.getFlagValue("want-numbered-hud")) {
			ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", true);
			mXpText.visible = false;
		}
	}

	public function showHealthFullMessage() {
		if (mHealthFullRevealer != null || mHealthFullFloater != null) {
			return;
		}
		mHealthFullClip.visible = true;
		mHealthFullClip.scaleX = 1;
		mHealthFullClip.scaleY = 1;
		mHealthFullRevealer = new Revealer(mHealthFullClip, mDBFacade, (8 : UInt), function() {
			if (mHealthFullRevealer != null) {
				mHealthFullRevealer = null;
			}
			mHealthFullFloater = new FloatingMessage(mHealthFullClip, mDBFacade, (2 : UInt), (16 : UInt), 1.125, 0, null, function() {
				mHealthFullClip.scaleX = 1;
				mHealthFullClip.scaleY = 1;
				mHealthFullFloater = null;
			}, "DAMAGE_MOVEMENT_TYPE", true);
		}, (1 : UInt));
	}

	public function showManaFullMessage() {
		if (mManaFullRevealer != null || mManaFullFloater != null) {
			return;
		}
		mManaFullClip.visible = true;
		mManaFullClip.scaleX = 1;
		mManaFullClip.scaleY = 1;
		mManaFullRevealer = new Revealer(mManaFullClip, mDBFacade, (8 : UInt), function() {
			if (mManaFullRevealer != null) {
				mManaFullRevealer = null;
			}
			mManaFullFloater = new FloatingMessage(mManaFullClip, mDBFacade, (2 : UInt), (16 : UInt), 1.125, 0, null, function() {
				mManaFullClip.scaleX = 1;
				mManaFullClip.scaleY = 1;
				mManaFullFloater = null;
			}, "DAMAGE_MOVEMENT_TYPE", true);
		}, (1 : UInt));
	}

	public function handleBoosterTimeUp(event:TimerEvent) {
		if (mBoosterTimer != null) {
			mBoosterTimer.stop();
			mBoosterTimer = null;
		}
		showBonusXPEffects(null);
		showBonusCoinEffects(null);
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
		if (_loc2_ >= 0) {
			mBoosterTimer = Timers.create(_loc2_, 0, "UIHud.mBoosterTimer");
			EventListeners.add(mBoosterTimer, "timer", handleBoosterTimeUp);
			mBoosterTimer.start();
		}
	}

	function handleBoostersParsedEvent(event:Event) {
		showBonusXPEffects(event);
		showBonusCoinEffects(event);
	}

	function showBonusXPEffects(event:Event) {
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
		if (mDBFacade.accountBonus.isXPBonusActive) {
			mXPBonusText.visible = true;
			TextUtil.setText(mXPBonusText, mDBFacade.accountBonus.xpBonusText);
		} else if (_loc2_ != null && _loc2_.BuffInfo.Exp > 1) {
			mXPBonusText.visible = true;
			TextUtil.setText(mXPBonusText, _loc2_.BuffInfo.Exp + Locale.getString("BOOSTER_XP"));
		} else {
			mXPBonusText.visible = false;
		}
	}

	function showBonusCoinEffects(event:Event) {
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
		if (mDBFacade.accountBonus.isCoinBonusActive) {
			mCoinBonusText.visible = true;
			TextUtil.setText(mCoinBonusText, mDBFacade.accountBonus.coinBonusText);
		} else if (_loc2_ != null && _loc2_.BuffInfo.Gold > 1) {
			mCoinBonusText.visible = true;
			TextUtil.setText(mCoinBonusText, _loc2_.BuffInfo.Gold + Locale.getString("BOOSTER_GOLD"));
		} else {
			mCoinBonusText.visible = false;
		}
	}

	public function registerPet(petNPC:NPCGameObject) {
		if (mPetPortrait != null) {
			mPetPortrait.destroy();
		}
		if (mWantPets) {
			mPetPortrait = new PetPortraitUI(mDBFacade, mPetPortraitRoot, mPetPortraitNoneRoot, petNPC);
		}
	}

	public function unregisterPet(petNPC:NPCGameObject) {
		if (mPetPortrait != null) {
			if (mPetPortrait.petNPCGameObject == petNPC) {
				mPetPortrait.petDeath();
			}
			if (mPetPortrait.petNPCGameObject == null && petNPC.gmNpc.RespawnT <= 0) {
				mPetPortrait.destroy();
				mPetPortrait = null;
			}
		}
	}

	function createWeaponTooltip(button:UIButton, num:UInt) {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), function(param1:SwfAsset) {
			if (button.root == null) {
				return;
			}
			var _loc2_ = num == 0 ? param1.getClass("DR_weapon_tooltip_z") : param1.getClass("DR_weapon_tooltip");
			var _loc4_ = new UIWeaponTooltip(mDBFacade, _loc2_);
			button.tooltip = _loc4_;
			var _loc3_ = new Point();
			_loc3_.y -= button.root.height * 0.5;
			button.tooltipPos = _loc3_;
			button.tooltipDelay = 0.4;
		});
	}

	function destroyTeamLoot() {
		if (mLootTween != null) {
			mDBFacade.mTween.killTween(mLootTween);
			mLootTween = null;
		}
		if (mLootTask != null) {
			mLootTask.destroy();
			mLootTask = null;
		}
		if (mTeamLootMC != null) {
			mTeamLootMC.clip.visible = false;
			if (mTeamLootMC.clip.parent != null) {
				mTeamLootMC.clip.parent.removeChild(mTeamLootMC.clip);
			}
			mTeamLootMC.destroy();
			mTeamLootMC = null;
		}
	}

	public function openTeamLoot(chestId:UInt) {
		destroyTeamLoot();
		var _loc4_ = "";
		switch (chestId - 60001) {
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
		var _loc3_ = mSwfAsset.getClass(_loc4_);
		var _loc2_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc3_, []), MovieClip);
		mTeamLootMC = new MovieClipRenderController(mDBFacade, _loc2_);
		mUIRoot.addChild(mTeamLootMC.clip);
		mTeamLootMC.clip.scaleX = mTeamLootMC.clip.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		mTeamLootMC.clip.x = -550;
		mTeamLootMC.clip.y = -150;
		if (mLootTween != null) {
			mDBFacade.mTween.killTween(mLootTween);
		}
		mTeamLootMC.play((0 : UInt), true);
		mLootTween = mDBFacade.mTween.tweenMaxTo(mTeamLootMC.clip, 0.5, {"x": -550});
		if (mLootTask != null) {
			mLootTask.destroy();
		}
		mLootTask = mLogicalWorkComponent.doLater(2, closeTeamLoot);
	}

	public function closeTeamLoot(gameClock:GameClock = null) {
		var cleanupFunc:ASFunction;
		if (mTeamLootMC == null) {
			return;
		}
		cleanupFunc = function() {
			if (mTeamLootMC == null) {
				return;
			}
			mTeamLootMC.stop();
			mTeamLootMC.clip.visible = false;
		};
		if (mLootTask != null) {
			mLootTask.destroy();
		}
		mLootTask = null;
		if (mLootTween != null) {
			mDBFacade.mTween.killTween(mLootTween);
		}
		mLootTween = mDBFacade.mTween.tweenMaxTo(mTeamLootMC.clip, 0.5, {
			"x": -250,
			"onComplete": cleanupFunc
		});
	}

	public function detachHero() {
		var _loc1_ = 0;
		hide();
		hideBustSign();
		if (mOffScreenPlayerManager != null) {
			mOffScreenPlayerManager.destroy();
		}
		mOffScreenPlayerManager = null;
		mHeroOwner = null;
		if (mUIChatLog != null) {
			mUIChatLog.heroOwner = null;
		}
		mEventComponent.removeAllListeners();
		EventListeners.remove(ASCompat.coerce((mUIRoot : ASAny).UI_XP, flash.events.IEventDispatcher), "mouseOver", mouseOverXpListener);
		EventListeners.remove(ASCompat.coerce((mUIRoot : ASAny).UI_XP, flash.events.IEventDispatcher), "mouseOut", mouseOutXpListener);
		if (mProfileBox != null) {
			EventListeners.remove(mProfileBox, "mouseOver", mouseOverProfileBox);
			EventListeners.remove(mProfileBox, "mouseOut", mouseOutProfileBox);
		}
		if (mBuffDisplayTask != null) {
			mBuffDisplayTask.destroy();
		}
		mBuffDisplayTask = null;
		if (mBuffs != null) {
			mBuffs.splice(0, (mBuffs.length : UInt));
		}
		if (mBuffIconButtons != null) {
			_loc1_ = 0;
			while (_loc1_ < mBuffIconButtons.length) {
				if (mBuffIconButtons[_loc1_] != null) {
					mBuffIconButtons[_loc1_].destroy();
				}
				_loc1_++;
			}
			mBuffIconButtons.splice(0, (mBuffIconButtons.length : UInt));
		}
		if (mBuffCooldowns != null) {
			_loc1_ = 0;
			while (_loc1_ < mBuffCooldowns.length) {
				if (mBuffCooldowns[_loc1_] != null) {
					mBuffCooldowns[_loc1_].destroy();
				}
				_loc1_++;
			}
			mBuffCooldowns.splice(0, (mBuffCooldowns.length : UInt));
		}
		if (mBoosterTimer != null) {
			mBoosterTimer.stop();
			EventListeners.remove(mBoosterTimer, "timer", handleBoosterTimeUp);
			mBoosterTimer = null;
		}
		if (mDungeonBusterButton != null) {
			mDungeonBusterButton.destroy();
		}
		mDungeonBusterButton = null;
		if (mBusterGlowMc != null) {
			mBusterGlowMc.destroy();
		}
		mBusterGlowMc = null;
		if (mBusterPulseMc != null) {
			mBusterPulseMc.destroy();
		}
		mBusterPulseMc = null;
		if (mLootLossPopup != null) {
			mLootLossPopup.destroy();
		}
		mLootLossPopup = null;
		if (mInfiniteExitPopup != null) {
			mInfiniteExitPopup.destroy();
		}
		mInfiniteExitPopup = null;
		destroyTeamLoot();
	}

	public function initializeHud(heroOwner:HeroGameObjectOwner) {
		var boosterTime:Int;
		var equippedWeapons:Vector<WeaponGameObject>;
		var i:Int;
		var equippedConsumableWeapons:Vector<ConsumableWeaponGameObject>;
		var j:Int;
		var gmSkin:GMSkin;
		var busterConstant:String;
		var busterAttack:GMAttack;
		var busterName:String;
		show();
		mHeroOwner = heroOwner;
		if (mAssetsLoaded && mHeroOwner != null) {
			mUIChatLog.heroOwner = mHeroOwner;
			mUIChatLog.enable();
			hideInvulnerable();
			setHp(mHeroOwner.hitPoints, (ASCompat.floatToInt(mHeroOwner.maxHitPoints) : UInt));
			setMana(mHeroOwner.manaPoints, (ASCompat.floatToInt(mHeroOwner.maxManaPoints) : UInt));
			setXp(mHeroOwner.experiencePoints);
			bulgeXpBar();
			bulgeProfileBox();
			this.addListeners();
			if (mBoosterTimer != null) {
				mBoosterTimer.stop();
				mBoosterTimer.removeEventListener("timer", handleBoosterTimeUp);
				mBoosterTimer = null;
			}
			boosterTime = mDBFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
			if (boosterTime >= 0) {
				mBoosterTimer = Timers.create(boosterTime, 0, "UIHud.mBoosterTimer");
				EventListeners.add(mBoosterTimer, "timer", handleBoosterTimeUp);
				mBoosterTimer.start();
			}
			if (mOffScreenPlayerManager != null) {
				mOffScreenPlayerManager.destroy();
				mOffScreenPlayerManager = null;
			}
			mOffScreenPlayerManager = new UIOffScreenPlayerManager(mDBFacade, mUIRoot, mHeroOwner);
			equippedWeapons = new Vector<WeaponGameObject>();
			i = 0;
			while (i < mHeroOwner.weaponControllers.length) {
				equippedWeapons.push(ASCompat.coerce(mHeroOwner.weaponControllers[i] != null ? mHeroOwner.weaponControllers[i].weapon : null,
					combat.weapon.WeaponGameObject));
				i = i + 1;
			}
			this.setupWeaponUI(equippedWeapons);
			equippedConsumableWeapons = new Vector<ConsumableWeaponGameObject>();
			j = 0;
			while (j < 2) {
				equippedConsumableWeapons.push(ASCompat.coerce(mHeroOwner.consumables[j] != null ? mHeroOwner.consumables[j] : null,
					combat.weapon.ConsumableWeaponGameObject));
				j = j + 1;
			}
			this.setupConsumableWeaponUI(equippedConsumableWeapons);
			gmSkin = mHeroOwner.gmSkin;
			if (gmSkin == null) {
				Logger.error("GMSkin on hero is null.  HeroType: " + mHeroOwner.type + " AccountId: " + mDBFacade.accountId);
			} else {
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath), function(param1:SwfAsset) {
					var _loc3_ = param1.getClass(gmSkin.IconName);
					var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
					if (ASCompat.toBool((mUIRoot : ASAny).UI_profile.avatar)) {
						(mUIRoot : ASAny).UI_profile.avatar.addChild(_loc2_);
					}
					if (ASCompat.toBool((mUIRoot : ASAny).avatar)) {
						(mUIRoot : ASAny).avatar.addChild(_loc2_);
					}
				});
			}
			mStacksHud.setupStacksUI();
			if (mDungeonBusterButton != null) {
				mDungeonBusterButton.destroy();
			}
			mDungeonBusterButton = new UIButton(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_buster_active.buster_activated, flash.display.MovieClip));
			mDungeonBusterButton.releaseCallback = handleBusterBarClickEvent;
			mBusterLabel = ASCompat.coerce((mUIRoot : ASAny).UI_buster_active.buster_activated.up.name_mc.name_label, flash.text.TextField);
			mBusterLabelOver = ASCompat.coerce((mUIRoot : ASAny).UI_buster_active.buster_activated.over.mc.name_label, flash.text.TextField);
			busterConstant = mHeroOwner.gMHero.DBuster1;
			busterAttack = ASCompat.coerce(mDBFacade.gameMaster.attackByConstant.itemFor(busterConstant), gameMasterDictionary.GMAttack);
			busterName = busterAttack != null ? GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME", busterAttack.Constant) : "BUSTER!";
			TextUtil.setText(mBusterLabel, busterName.toUpperCase());
			TextUtil.setText(mBusterLabelOver, busterName.toUpperCase());
			if (mBusterGlowMc != null) {
				mBusterGlowMc.destroy();
			}
			mBusterGlowMc = new MovieClipRenderController(mDBFacade, ASCompat.coerce((mUIRoot : ASAny).UI_buster_glow, flash.display.MovieClip));
			if (mBusterPulseMc != null) {
				mBusterPulseMc.destroy();
			}
			mBusterPulseMc = new MovieClipRenderController(mDBFacade,
				ASCompat.coerce((mUIRoot : ASAny).UI_buster.buster_activated_glow, flash.display.MovieClip));
			if (ASCompat.toBool((mUIRoot : ASAny).UI_buster.buster_activated_glow.visible)) {
				mBusterPulseMc.play((0 : UInt), true);
			}
			TextUtil.setText(ASCompat.coerce((mUIRoot : ASAny).UI_buster_glow.buster_text.buster_text_label.name_label, flash.text.TextField),
				busterName.toUpperCase());
			refreshKeyboardLabels();
			if (mDBFacade.dbAccountInfo != null) {
				setCurrency((mDBFacade.dbAccountInfo.basicCurrency : Int), (mDBFacade.dbAccountInfo.premiumCurrency : Int));
			}
			mMaxBusterPoints = mHeroOwner.maxBusterPoints;
			setBusterPoints(mHeroOwner.dungeonBusterPoints);
			initializePetPortraits();
			setCurrentFloorLabel();
			setDungeonModifiers();
			mUIChatLog.heroOwner = mHeroOwner;
			if (mBuffDisplayTask != null) {
				mBuffDisplayTask.destroy();
			}
			mBuffDisplayTask = mLogicalWorkComponent.doEveryFrame(updateBuffDisplay);
			setupStatsForResourceBars();
		}
	}

	function setCurrentFloorLabel() {
		TextUtil.setText(mFloorLabel, Locale.getString("UI_HUD_FLOOR_LABEL") + Std.string(mHeroOwner.distributedDungeonFloor.getCurrentFloorNum()));
	}

	function setDungeonModifiers() {
		var _loc1_:UIButton = null;
		var _loc2_ = (0 : UInt);
		mDungeonModifer1.visible = false;
		mDungeonModifer2.visible = false;
		mDungeonModifer3.visible = false;
		mDungeonModifer4.visible = false;
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers.length:UInt)) {
			switch (_loc2_) {
				case 0:
					_loc1_ = mDungeonModifer1;

				case 1:
					_loc1_ = mDungeonModifer2;

				case 2:
					_loc1_ = mDungeonModifer3;

				case 3:
					_loc1_ = mDungeonModifer4;
			}
			setupModifiers(_loc1_, mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers[(_loc2_ : Int)]);
			_loc2_++;
		}
	}

	function setupModifiers(dungeonModButton:UIButton, gmDungeonModifier:DungeonModifierHelper) {
		TextUtil.setText(ASCompat.coerce((dungeonModButton.tooltip : ASAny).title_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME", gmDungeonModifier.GMDungeonMod.Constant));
		TextUtil.setText(ASCompat.coerce((dungeonModButton.tooltip : ASAny).description_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION", gmDungeonModifier.GMDungeonMod.Constant));
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmDungeonModifier.GMDungeonMod.IconFilepath), function(param1:SwfAsset) {
			if (dungeonModButton.root == null) {
				return;
			}
			var _loc2_ = param1.getClass(gmDungeonModifier.GMDungeonMod.IconName);
			if (_loc2_ == null) {
				return;
			}
			var _loc3_ = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
			UIObject.scaleToFit(_loc3_, dungeonModButton.root.width);
			_loc3_.x += 10;
			_loc3_.y += 10;
			dungeonModButton.root.removeChildren();
			dungeonModButton.root.addChild(_loc3_);
			dungeonModButton.root.visible = true;
		});
	}

	function initializePetPortraits() {
		var _loc1_:NPCGameObject = null;
		if (mPetPortrait != null) {
			_loc1_ = mPetPortrait.petNPCGameObject;
		} else {
			_loc1_ = mPetCarriedAcrossRebuild;
		}
		mPetCarriedAcrossRebuild = null;
		registerPet(_loc1_);
	}

	public function show() {
		mSceneGraphComponent.addChild(mRoot, (50 : UInt));
		mStacksHud.show();
		mDBFacade.camera.yCilppingFromBottom = mVerticalYClipping;
		initializePetPortraits();
	}

	public function hide() {
		mSceneGraphComponent.removeChild(mRoot);
		mDBFacade.camera.yCilppingFromBottom = 0;
		mDBFacade.camera.forceRedraw();
		if (mSettingsPopup != null) {
			mSettingsPopup.destroy();
			mSettingsPopup = null;
		}
		mStacksHud.hide();
		if (mUIChatLog != null) {
			mUIChatLog.disable();
			mUIChatLog.hideChatLog();
		}
		if (mPetPortrait != null) {
			mPetPortrait.destroy();
		}
		mPetPortrait = null;
		mPetCarriedAcrossRebuild = null;
	}

	public function showStacks() {
		mStacksHud.show();
	}

	public function hideStacks() {
		mStacksHud.hide();
	}

	function resetButtons(buttons:Vector<UIButton>) {
		var _loc3_:DisplayObject = null;
		var _loc2_:UIButton;
		if (checkNullIteratee(buttons))
			for (_tmp_ in buttons) {
				_loc2_ = _tmp_;
				_loc2_.pressCallback = null;
				_loc2_.pressRollOutCallback = null;
				if (_loc2_.tooltip != null) {
					_loc2_.tooltip.visible = false;
				}
				if (ASCompat.toNumberField((_loc2_.root : ASAny).graphic, "numChildren") > 0) {
					(_loc2_.root : ASAny).graphic.removeChildAt(0);
				}
				_loc3_ = _loc2_.root.getChildByName("rarityIcon");
				if (_loc3_ != null) {
					_loc2_.root.removeChild(_loc3_);
				}
				ASCompat.setProperty((_loc2_.root : ASAny).selectionFrame, "visible", false);
				_loc2_.enabled = true;
				_loc2_.root.filters = cast([]);
			}
	}

	function setupWeaponUI(equippedWeapons:Vector<WeaponGameObject>) {
		var weaponGameObject:WeaponGameObject;
		var gmWeapon:GMWeaponItem;
		var gmWeaponAesthetic:GMWeaponAesthetic;
		var weapon:MovieClip;
		var button:UIButton;
		var tooltip:UIWeaponTooltip;
		var i:UInt;
		var makeCallback:ASFunction;
		var slotSize:Float = 56;
		resetButtons(mWeaponButtons);
		i = (0 : UInt);
		while (i < (equippedWeapons.length:UInt)) {
			if (equippedWeapons[(i : Int)] != null) {
				weaponGameObject = equippedWeapons[(i : Int)];
				gmWeapon = weaponGameObject.weaponData;
				gmWeaponAesthetic = weaponGameObject.weaponAesthetic;
				button = mWeaponButtons[(i : Int)];
				ASCompat.setProperty(button.root, "weaponIndex", i);
				tooltip = cast(button.tooltip, UIWeaponTooltip);
				tooltip.setWeaponItemFromWeaponGameObject(weaponGameObject);
				tooltip.visible = true;
				button.pressCallbackThis = function(param1:UIButton) {
					if (mHeroOwner.currentWeaponIndex != ASCompat.toNumberField((param1.root : ASAny), "weaponIndex")) {
						mHeroOwner.currentWeaponIndex = ASCompat.toInt((param1.root : ASAny).weaponIndex);
					} else {
						mHeroOwner.PlayerAttack.addToPotentialWeaponInputQueue((ASCompat.toInt((param1.root : ASAny).weaponIndex) : UInt), true, true);
					}
				};
				button.releaseCallbackThis = function(param1:UIButton) {
					if (mHeroOwner.currentWeaponIndex == ASCompat.toNumberField((param1.root : ASAny), "weaponIndex")) {
						mHeroOwner.PlayerAttack.addToPotentialWeaponInputQueue((ASCompat.toInt((param1.root : ASAny).weaponIndex) : UInt), false, true);
					}
				};
				button.pressRollOutCallback = function() {
					mDBFacade.inputManager.onMouseDown(null);
				};
				makeCallback = function(param1:UIButton, param2:GMWeaponAesthetic, param3:gameMasterDictionary.GMRarity):ASFunction {
					var weaponButton = param1;
					var weaponAesthetic = param2;
					var rarity = param3;
					return function(param1:SwfAsset) {
						var weaponClass:Dynamic;
						var bgColoredExists:Bool;
						var bgSwfPath:String;
						var bgIconName:String;
						var swfAsset = param1;
						if (weaponButton.root == null) {
							return;
						}
						weaponClass = swfAsset.getClass(weaponAesthetic.IconName);
						if (weaponClass == null) {
							return;
						}
						weapon = ASCompat.coerce(ASCompat.createInstance(weaponClass, []), flash.display.MovieClip);
						weapon.name = "weaponIcon";
						weapon.scaleX = weapon.scaleY = 60 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
						(weaponButton.root : ASAny).graphic.addChildAt(weapon, 0);
						bgColoredExists = rarity.HasColoredBackground;
						bgSwfPath = rarity.BackgroundSwf;
						bgIconName = rarity.BackgroundIcon;
						if (bgColoredExists && mDBFacade.featureFlags.getFlagValue("want-dynamic-rarity-backgrounds")) {
							mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath), function(param1:SwfAsset) {
								var _loc3_:MovieClip = null;
								if (weaponButton.root == null) {
									return;
								}
								var _loc2_ = param1.getClass(bgIconName);
								if (_loc2_ != null) {
									_loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
									_loc3_.name = "rarityIcon";
									weaponButton.root.addChildAt(_loc3_, 2);
									_loc3_.scaleX = _loc3_.scaleY = 0.85;
									_loc3_.y -= 6;
								}
							});
						}
					};
				};
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmWeaponAesthetic.IconSwf),
					ASCompat.coerceFunction(makeCallback(button, gmWeaponAesthetic, weaponGameObject.gmRarity)));
			}
			i = i + 1;
		}
	}

	function setupConsumableWeaponUI(equippedConsumableWeapons:Vector<ConsumableWeaponGameObject>) {
		var consumableWeaponGameObject:ConsumableWeaponGameObject;
		var gmWeapon:GMWeaponItem;
		var gmWeaponAesthetic:GMWeaponAesthetic;
		var weapon:MovieClip;
		var button:UIButton;
		var tooltip:MovieClip = null;
		var i:UInt;
		var makeCallback:ASFunction;
		var slotSize:Float = 56;
		resetButtons(mConsumableWeaponButtons);
		ASCompat.setProperty((mUIRoot : ASAny).consumable_tooltip01, "visible", false);
		ASCompat.setProperty((mUIRoot : ASAny).consumable_tooltip02, "visible", false);
		i = (0 : UInt);
		while (i < (equippedConsumableWeapons.length:UInt)) {
			button = mConsumableWeaponButtons[(i : Int)];
			ASCompat.setProperty((button.root : ASAny).quantity, "visible", false);
			ASCompat.setProperty((button.root : ASAny).textx, "visible", false);
			if (equippedConsumableWeapons[(i : Int)] != null) {
				consumableWeaponGameObject = equippedConsumableWeapons[(i : Int)];
				gmWeapon = consumableWeaponGameObject.weaponData;
				ASCompat.setProperty(button.root, "weaponIndex", i);
				ASCompat.setProperty((button.root : ASAny).quantity, "visible", true);
				ASCompat.setProperty((button.root : ASAny).textx, "visible", true);
				TextUtil.setText(ASCompat.coerce((button.root : ASAny).quantity, flash.text.TextField),
					Std.string(consumableWeaponGameObject.getConsumableCount()));
				switch (i) {
					case 0:
						tooltip = ASCompat.coerce((mUIRoot : ASAny).consumable_tooltip01, flash.display.MovieClip);

					case 1:
						tooltip = ASCompat.coerce((mUIRoot : ASAny).consumable_tooltip02, flash.display.MovieClip);
				}
				button.tooltip = tooltip;
				TextUtil.setText(ASCompat.coerce((button.tooltip : ASAny).description_label, flash.text.TextField),
					GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION", consumableWeaponGameObject.getGMStackable().Constant));
				tooltip.visible = true;
				button.setTooltipToBeParentedToStage();
				button.tooltipPos = new Point(button.root.x, button.root.y);
				button.releaseCallbackThis = function(param1:UIButton) {
					mHeroOwner.tryToUseConsumable((ASCompat.toInt((param1.root : ASAny).weaponIndex) : UInt));
				};
				makeCallback = function(param1:UIButton, param2:gameMasterDictionary.GMStackable):ASFunction {
					var weaponButton = param1;
					var gmStackable = param2;
					return function(param1:SwfAsset) {
						if (weaponButton.root == null) {
							return;
						}
						var _loc2_ = param1.getClass(gmStackable.IconName);
						if (_loc2_ == null) {
							return;
						}
						weapon = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
						weapon.name = "weaponIcon";
						weapon.scaleX = weapon.scaleY = 60 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
						(weaponButton.root : ASAny).graphic.addChildAt(weapon, 0);
					};
				};
				mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(consumableWeaponGameObject.getGMStackable().UISwfFilepath),
					ASCompat.coerceFunction(makeCallback(button, consumableWeaponGameObject.getGMStackable())));
			}
			i = i + 1;
		}
	}

	function addListeners() {
		var heroOwnerId:UInt;
		mEventComponent.removeAllListeners();
		heroOwnerId = mHeroOwner.id;
		mEventComponent.addListener("BONUS_XP_CHANGED_EVENT", showBonusXPEffects);
		showBonusXPEffects(new Event("BONUS_XP_CHANGED_EVENT"));
		mEventComponent.addListener("BONUS_COIN_CHANGED_EVENT", showBonusCoinEffects);
		showBonusCoinEffects(new Event("BONUS_COIN_CHANGED_EVENT"));
		mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE", this.handleBoostersParsedEvent);
		mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE", heroOwnerId), function(param1:events.HpEvent) {
			setHp(param1.hp, param1.maxHp);
		});
		mEventComponent.addListener(GameObjectEvent.uniqueEvent("ManaEvent_MANA_UPDATE", heroOwnerId), function(param1:events.ManaEvent) {
			setMana(param1.mana, param1.maxMana);
		});
		mEventComponent.addListener(GameObjectEvent.uniqueEvent("ExperienceEvent_EXPERIENCE_UPDATE", heroOwnerId), function(param1:events.ExperienceEvent) {
			setXp(param1.experience);
		});
		mEventComponent.addListener(GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE", heroOwnerId), handleBusterPointsEvent);
		mEventComponent.addListener("CurrencyUpdatedAccountEvent", function(param1:account.CurrencyUpdatedAccountEvent) {
			setCurrency((param1.basicCurrency : Int), (param1.premiumCurrency : Int));
		});
		mEventComponent.addListener(GameObjectEvent.uniqueEvent(BuffHandler.ACTOR_INVULNERABLE, heroOwnerId), function(param1:events.ActorInvulnerableEvent) {
			if (param1.mIsInvulnerable) {
				showInvulnerable();
			} else {
				hideInvulnerable();
			}
		});
		mEventComponent.addListener("UI_HUD_CHANGE_EVENT", switchHudEvent);
		mEventComponent.addListener("OnSteamInputGlyphsChanged", onSteamInputGlyphsChanged);
		mEventComponent.addListener("ControllerConnectionChangedEvent", onControllerConnectionChanged);
		mEventComponent.addListener("OnSteamInputButtonReleasedEvent", onSteamInputButtonReleased);
		EventListeners.add(mProfileBox, "mouseOver", mouseOverProfileBox);
		EventListeners.add(mProfileBox, "mouseOut", mouseOutProfileBox);
		EventListeners.add(ASCompat.coerce((mUIRoot : ASAny).UI_XP, flash.events.IEventDispatcher), "mouseOver", mouseOverXpListener);
		EventListeners.add(ASCompat.coerce((mUIRoot : ASAny).UI_XP, flash.events.IEventDispatcher), "mouseOut", mouseOutXpListener);
		setAllKeyboardIconsVisibility(!mDBFacade.steamInputManager.wantsControllerPrompts);
		if (mDBFacade.steamInputManager.isSteamInputReady && mInitControllerIconsLater == null) {
			mInitControllerIconsLater = mLogicalWorkComponent.doLater(mControllerIconLoadDelay, initAllControllerIconsTask);
		}
	}

	function onControllerConnectionChanged(inEvent:Event) {
		syncControllerPrompts();
	}

	function mouseOutProfileBox(e:Event) {
		if (!mDBFacade.featureFlags.getFlagValue("want-numbered-hud")) {
			mHpText.visible = false;
			mManaText.visible = false;
		}
	}

	function mouseOverProfileBox(e:Event) {
		mHpText.visible = true;
		mManaText.visible = true;
	}

	function setupStatsForResourceBars() {
		if (mDBFacade.featureFlags.getFlagValue("want-numbered-hud")) {
			mHpText.visible = true;
			mManaText.visible = true;
			mXpText.visible = true;
			ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", false);
		} else {
			mHpText.visible = false;
			mManaText.visible = false;
			mXpText.visible = false;
			ASCompat.setProperty((mUIRoot : ASAny).UI_XP.xp_level_title, "visible", true);
		}
	}

	function handleBusterPointsEvent(event:BusterPointsEvent) {
		mMaxBusterPoints = event.maxBusterPoints;
		setBusterPoints(event.busterPoints);
	}

	function showInvulnerable() {
		mFlashingHpBar.value = mHpBar.value;
		mFlashingHpBar.visible = true;
		mHpBar.visible = false;
	}

	function hideInvulnerable() {
		mFlashingHpBar.visible = false;
		mHpBar.visible = true;
	}

	@:isVar public var floaterTextClass(get, never):Dynamic;

	public function get_floaterTextClass():Dynamic {
		return mFloaterTextClass;
	}

	function floaterCallback(clip:MovieClip):ASFunction {
		return function() {
			mDBFacade.sceneGraphManager.removeChild(clip);
		};
	}

	function spawnFloater(text:String, x:Float, y:Float, color:UInt, scale:Float, holdTime:UInt, fadeTime:UInt, scaleDampening:Float, speed:Float) {
		var _loc10_ = ASCompat.dynamicAs(ASCompat.createInstance(mFloaterTextClass, []), MovieClip);
		ASCompat.setProperty((_loc10_ : ASAny).label, "text", text);
		ASCompat.setProperty((_loc10_ : ASAny).label, "textColor", color);
		_loc10_.x = x;
		_loc10_.y = y;
		_loc10_.scaleX = scale;
		_loc10_.scaleY = scale;
		var _loc11_ = new FloatingMessage(_loc10_, mDBFacade, holdTime, fadeTime, scaleDampening, speed, null, floaterCallback(_loc10_));
		mDBFacade.sceneGraphManager.addChild(_loc10_, 50);
	}

	public function setHp(current:UInt, max:UInt) {
		if (!mAssetsLoaded) {
			return;
		}
		var _loc3_ = current / max;
		mHpBar.value = _loc3_;
		mFlashingHpBar.value = _loc3_;
		TextUtil.setText(mHpText, Std.string(current) + " / " + Std.string(max));
	}

	public function setMana(current:UInt, max:UInt) {
		if (!mAssetsLoaded) {
			return;
		}
		mManaBar.value = current / max;
		TextUtil.setText(mManaText, Std.string(current) + " / " + Std.string(max));
	}

	function spawnBusterFloater(delta:Int, offset:Float) {}

	public function setBusterPoints(current:UInt) {
		if (!mAssetsLoaded) {
			return;
		}
		mBusterBar.value = current / mMaxBusterPoints;
		var _loc2_ = (current - mBusterValue : Int);
		if (_loc2_ > 0) {
			spawnBusterFloater(_loc2_, mBusterBar.value * 75);
		}
		mBusterValue = current;
		if (mBusterValue >= mMaxBusterPoints) {
			this.showBustSign();
		} else {
			this.hideBustSign();
		}
	}

	public function setCurrency(basicCurrency:Int, premiumCurrency:Int) {
		if (!mAssetsLoaded) {
			return;
		}
		TextUtil.setText(mBasicCurrencyText, Std.string(basicCurrency));
		TextUtil.setText(mPremiumCurrencyText, Std.string(premiumCurrency));
	}

	function spawnCoinFloater(delta:Int) {}

	public function setBasicCurrency(basicCurrency:Int) {
		if (!mAssetsLoaded) {
			return;
		}
		var _loc2_ = (basicCurrency - mBasicCurrency : Int);
		if (_loc2_ > 0) {
			spawnCoinFloater(_loc2_);
		}
		TextUtil.setText(mBasicCurrencyText, Std.string(basicCurrency));
		mBasicCurrency = (basicCurrency : UInt);
	}

	function spawnCashFloater(delta:Int) {}

	public function setPremiumCurrency(premiumCurrency:Int) {
		if (!mAssetsLoaded) {
			return;
		}
		var _loc2_ = (premiumCurrency - mPremiumCurrency : Int);
		if (_loc2_ > 0) {
			spawnCashFloater(_loc2_);
		}
		TextUtil.setText(mPremiumCurrencyText, Std.string(premiumCurrency));
		mPremiumCurrency = (premiumCurrency : UInt);
	}

	function spawnXpFloater(delta:Int, offset:Float) {}

	public function setXp(xp:UInt) {
		if (!mAssetsLoaded) {
			return;
		}
		var _loc5_ = mHeroOwner.level;
		var _loc4_ = xp;
		var _loc2_ = (mHeroOwner.gMHero.getLevelIndex(xp, (mHeroOwner.ascensionLevel : Int)) : UInt);
		var _loc7_ = (ASCompat.toInt(_loc2_ > 0 ? mHeroOwner.gMHero.getExpFromIndex(_loc2_ - 1) : 0) : UInt);
		var _loc6_ = mHeroOwner.gMHero.getExpFromIndex(_loc2_);
		TextUtil.setText(mLevelText, Std.string(_loc5_));
		var _loc3_ = ((_loc4_ : Float) - (_loc7_ : Float)) / ((_loc6_ : Float) - (_loc7_ : Float));
		mXpBar.value = _loc3_;
		TextUtil.setText(mXpText, Std.string(_loc4_) + " / " + Std.string(_loc6_));
		spawnXpFloater((xp - mXpValue : Int), _loc3_ * 100);
		mXpValue = xp;
		if (!mXpGotInitialUpdate) {
			mXpGotInitialUpdate = true;
			bulgeXpBar();
		}
	}

	function updateXpBulge(clock:GameClock) {
		var _loc3_ = mXpObject.root;
		var _loc2_ = _loc3_.scaleX - mXpRestScale;
		_loc2_ *= 0.75;
		_loc3_.scaleX = mXpRestScale + _loc2_;
		_loc3_.scaleY = mXpRestScale + _loc2_;
		if (Math.abs(_loc2_) <= 0.01) {
			_loc3_.scaleX = mXpRestScale;
			_loc3_.scaleY = mXpRestScale;
			mXpBulgeTask.destroy();
			mXpBulgeTask = null;
		}
	}

	public function bulgeXpBar() {
		if (!mDBFacade.featureFlags.getFlagValue("want-pickup-ui-pop")) {
			return;
		}
		mXpObject.root.scaleX *= 1.08;
		mXpObject.root.scaleY *= 1.08;
		if (mXpBulgeTask == null) {
			mXpBulgeTask = mLogicalWorkComponent.doEveryFrame(updateXpBulge);
		}
	}

	function updateProfileBulge(clock:GameClock) {
		var _loc2_ = mProfileBox.scaleX - mProfileRestScale;
		_loc2_ *= 0.75;
		mProfileBox.scaleX = mProfileRestScale + _loc2_;
		mProfileBox.scaleY = mProfileRestScale + _loc2_;
		if (Math.abs(_loc2_) <= 0.01) {
			mProfileBox.scaleX = mProfileRestScale;
			mProfileBox.scaleY = mProfileRestScale;
			mProfileBulgeTask.destroy();
			mProfileBulgeTask = null;
		}
	}

	public function bulgeProfileBox() {
		if (!mDBFacade.featureFlags.getFlagValue("want-pickup-ui-pop")) {
			return;
		}
		mProfileBox.scaleX *= 1.08;
		mProfileBox.scaleY *= 1.08;
		if (mProfileBulgeTask == null) {
			mProfileBulgeTask = mLogicalWorkComponent.doEveryFrame(updateProfileBulge);
		}
	}

	public function destroy() {
		var _loc2_ = 0;
		var _loc1_:UIButton = null;
		if (mDBFacade != null && mDBFacade.keyBindings != null) {
			mDBFacade.keyBindings.removeChangeListener(onKeyBindingsChanged);
		}
		if (mSettingsModel != null) {
			mSettingsModel.removeChangeListener(onSettingChanged);
			mSettingsModel = null;
		}
		if (mProfileBox != null) {
			EventListeners.remove(mProfileBox, "mouseOver", mouseOverProfileBox);
			EventListeners.remove(mProfileBox, "mouseOut", mouseOutProfileBox);
		}
		if (mBuffs != null) {
			mBuffs.splice(0, (mBuffs.length : UInt));
			mBuffs = null;
		}
		if (mBuffIconButtons != null) {
			_loc2_ = 0;
			while (_loc2_ < mBuffIconButtons.length) {
				if (mBuffIconButtons[_loc2_] != null) {
					mBuffIconButtons[_loc2_].destroy();
				}
				_loc2_++;
			}
			mBuffIconButtons = null;
		}
		if (mBuffCooldowns != null) {
			_loc2_ = 0;
			while (_loc2_ < mBuffCooldowns.length) {
				if (mBuffCooldowns[_loc2_] != null) {
					mBuffCooldowns[_loc2_].destroy();
				}
				_loc2_++;
			}
			mBuffCooldowns = null;
		}
		if (mBoosterTimer != null) {
			mBoosterTimer.stop();
			mBoosterTimer = null;
		}
		mDBFacade = null;
		if (mSettingsPopup != null) {
			mSettingsPopup.destroy();
			mSettingsPopup = null;
		}
		mStacksHud.destroy();
		mStacksHud = null;
		if (mOffScreenPlayerManager != null) {
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
		if (mInitControllerIconsLater != null) {
			mInitControllerIconsLater.destroy();
		}
		mInitControllerIconsLater = null;
		if (mProfileBulgeTask != null) {
			mProfileBulgeTask.destroy();
		}
		mProfileBulgeTask = null;
		if (mBuffDisplayTask != null) {
			mBuffDisplayTask.destroy();
		}
		mBuffDisplayTask = null;
		if (mHpBar != null) {
			mHpBar.destroy();
		}
		mHpBar = null;
		if (mFlashingHpBar != null) {
			mFlashingHpBar.destroy();
		}
		mFlashingHpBar = null;
		if (mManaBar != null) {
			mManaBar.destroy();
		}
		mManaBar = null;
		if (mBusterBar != null) {
			mBusterBar.destroy();
		}
		mBusterBar = null;
		if (mXpBar != null) {
			mXpBar.destroy();
		}
		mXpBar = null;
		if (mXpBulgeTask != null) {
			mXpBulgeTask.destroy();
		}
		mXpBulgeTask = null;
		if (mLootTask != null) {
			mLootTask.destroy();
		}
		mLootTask = null;
		if (mCloseButton != null) {
			mCloseButton.destroy();
		}
		mCloseButton = null;
		if (mWeaponZButton != null) {
			mWeaponZButton.destroy();
		}
		mWeaponZButton = null;
		if (mWeaponXButton != null) {
			mWeaponXButton.destroy();
		}
		mWeaponXButton = null;
		if (mWeaponCButton != null) {
			mWeaponCButton.destroy();
		}
		mWeaponCButton = null;
		if (mConsumable1Button != null) {
			mConsumable1Button.destroy();
		}
		mConsumable1Button = null;
		if (mConsumable2Button != null) {
			mConsumable2Button.destroy();
		}
		mConsumable2Button = null;
		if (mDungeonBusterButton != null) {
			mDungeonBusterButton.destroy();
		}
		mDungeonBusterButton = null;
		if (mBusterGlowMc != null) {
			mBusterGlowMc.destroy();
		}
		mBusterGlowMc = null;
		if (mBusterPulseMc != null) {
			mBusterPulseMc.destroy();
		}
		mBusterPulseMc = null;
		if (mSettingsPopup != null) {
			mSettingsPopup.destroy();
		}
		mSettingsPopup = null;
		if (mStacksHud != null) {
			mStacksHud.destroy();
		}
		mStacksHud = null;
		if (mUITask != null) {
			mUITask.destroy();
		}
		mUITask = null;
		if (mUIChatLog != null) {
			mUIChatLog.destroy();
		}
		mUIChatLog = null;
		if (mPetPortrait != null) {
			mPetPortrait.destroy();
		}
		mPetPortrait = null;
		final __ax4_iter_418 = mWeaponButtons;
		if (checkNullIteratee(__ax4_iter_418))
			for (_tmp_ in __ax4_iter_418) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
				_loc1_ = null;
			}
		final __ax4_iter_419 = mConsumableWeaponButtons;
		if (checkNullIteratee(__ax4_iter_419))
			for (_tmp_ in __ax4_iter_419) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
				_loc1_ = null;
			}
		hideAndUnloadControllerIcons();
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
		if (mLootLossPopup != null) {
			mLootLossPopup.destroy();
		}
		mLootLossPopup = null;
		if (mInfiniteExitPopup != null) {
			mInfiniteExitPopup.destroy();
		}
		mInfiniteExitPopup = null;
	}

	@:isVar public var offScreenPlayerManager(get, never):UIOffScreenPlayerManager;

	public function get_offScreenPlayerManager():UIOffScreenPlayerManager {
		return mOffScreenPlayerManager;
	}

	public function showBustSign() {
		ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow, "visible", true);
		mBusterGlowMc.play((1 : UInt), false, function() {
			ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow, "visible", false);
			ASCompat.setProperty((mUIRoot : ASAny).UI_buster_active, "visible", true);
			ASCompat.setProperty((mUIRoot : ASAny).UI_buster.buster_activated_glow, "visible", true);
			if (mBusterPulseMc != null && !mBusterPulseMc.isPlaying) {
				mBusterPulseMc.play((0 : UInt), true);
			}
		});
	}

	public function hideBustSign() {
		ASCompat.setProperty((mUIRoot : ASAny).UI_buster_glow, "visible", false);
		ASCompat.setProperty((mUIRoot : ASAny).UI_buster_active, "visible", false);
		ASCompat.setProperty((mUIRoot : ASAny).UI_buster.buster_activated_glow, "visible", false);
		if (mBusterPulseMc != null) {
			mBusterPulseMc.stop();
		}
	}

	public function handleBusterBarClickEvent() {
		if (mHeroOwner != null && mHeroOwner.dungeonBusterPoints >= mHeroOwner.maxBusterPoints) {
			mEventComponent.dispatchEvent(new DungeonBusterControlActivatedEvent());
		}
	}

	public function setWeaponHighlight(currentWeaponIndex:Int) {
		var _loc2_:UIButton;
		final __ax4_iter_420 = mWeaponButtons;
		if (checkNullIteratee(__ax4_iter_420))
			for (_tmp_ in __ax4_iter_420) {
				_loc2_ = _tmp_;
				ASCompat.setProperty((_loc2_.root : ASAny).selectionFrame, "visible", false);
			}
		ASCompat.setProperty((mWeaponButtons[currentWeaponIndex].root : ASAny).selectionFrame, "visible", true);
	}

	public function hideNotEnoughMana() {
		ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", false);
	}

	public function showNotEnoughMana() {
		ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", true);
		Locale.setText(ASCompat.coerce((mUIRoot : ASAny).UI_center_message, flash.text.TextField), "NOT_ENOUGH_MANA");
	}

	@:isVar public var chatLog(get, never):UIChatLog;

	public function get_chatLog():UIChatLog {
		return mUIChatLog;
	}

	public function isInCooldown() {
		showText("IS_IN_COOLDOWN");
	}

	public function startCooldown(currentWeaponIndex:Int, cooldownTime:Float) {
		mCooldowns[currentWeaponIndex].clip.visible = true;
		mCooldowns[currentWeaponIndex].playRate = 1 / cooldownTime * 4.1;
		mCooldowns[currentWeaponIndex].play();
		ASCompat.setProperty((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic, "alpha", 0.5);
	}

	public function stopCooldown(currentWeaponIndex:Int) {
		mCooldowns[currentWeaponIndex].stop();
		mCooldowns[currentWeaponIndex].clip.visible = false;
		ASCompat.setProperty((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic, "alpha", 1);
		mDBFacade.mTween.tweenMaxTo((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic, 0.25, {
			"scaleX": 1.25,
			"scaleY": 1.25,
			"tint": 16777215,
			"onComplete": function() {
				mDBFacade.mTween.tweenMaxTo((mWeaponButtons[currentWeaponIndex].root : ASAny).graphic, 0.25, {
					"scaleX": 1,
					"scaleY": 1,
					"removeTint": true
				});
			}
		});
	}

	public function startConsumableCooldown(currentWeaponIndex:Int, cooldownTime:Float) {
		mConsumableCooldowns[currentWeaponIndex].clip.visible = true;
		mConsumableCooldowns[currentWeaponIndex].playRate = 1 / cooldownTime * 4.1;
		mConsumableCooldowns[currentWeaponIndex].play();
		ASCompat.setProperty((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic, "alpha", 0.5);
	}

	public function stopConsumableCooldown(currentWeaponIndex:Int) {
		mConsumableCooldowns[currentWeaponIndex].stop();
		mConsumableCooldowns[currentWeaponIndex].clip.visible = false;
		ASCompat.setProperty((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic, "alpha", 1);
		mDBFacade.mTween.tweenMaxTo((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic, 0.25, {
			"scaleX": 1.25,
			"scaleY": 1.25,
			"tint": 16777215,
			"onComplete": function() {
				mDBFacade.mTween.tweenMaxTo((mConsumableWeaponButtons[currentWeaponIndex].root : ASAny).graphic, 0.25, {
					"scaleX": 1,
					"scaleY": 1,
					"removeTint": true
				});
			}
		});
	}

	public function decrementConsumableCount(slot:UInt) {
		TextUtil.setText(ASCompat.coerce((mConsumableWeaponButtons[(slot : Int)].root : ASAny).quantity, flash.text.TextField),
			Std.string(ASCompat.toInt((mConsumableWeaponButtons[(slot : Int)].root : ASAny).quantity.text) - 1));
	}

	public function totalConsumableCountReached(slot:UInt) {
		mConsumableWeaponButtons[(slot : Int)].enabled = false;
		mConsumableWeaponButtons[(slot : Int)].root.filters = cast([
			new ColorMatrixFilter(cast([
				0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0.3086, 0.6094, 0.082, 0, 0, 0, 0, 0, 1, 0
			]))
		]);
	}

	public function showText(localeTextName:String) {
		if ((mUIRoot : ASAny).UI_center_message.visible == false) {
			ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", true);
			Locale.setText(ASCompat.coerce((mUIRoot : ASAny).UI_center_message, flash.text.TextField), localeTextName);
			mLogicalWorkComponent.doLater(0.35, function() {
				ASCompat.setProperty((mUIRoot : ASAny).UI_center_message, "visible", false);
			});
		} else {
			Locale.setText(ASCompat.coerce((mUIRoot : ASAny).UI_center_message, flash.text.TextField), localeTextName);
		}
	}

	@:isVar public var teamLootDestination(get, never):Vector3D;

	public function get_teamLootDestination():Vector3D {
		return mTeamLootDestination;
	}

	@:isVar public var profileDestination(get, never):Vector3D;

	public function get_profileDestination():Vector3D {
		return mProfileDestination;
	}

	@:isVar public var coinsDestination(get, never):Vector3D;

	public function get_coinsDestination():Vector3D {
		return mCoinsDestination;
	}

	@:isVar public var cashDestination(get, never):Vector3D;

	public function get_cashDestination():Vector3D {
		return mCashDestination;
	}

	@:isVar public var expDestination(get, never):Vector3D;

	public function get_expDestination():Vector3D {
		return mExpDestination;
	}

	@:isVar public var crowdDestination(get, never):Vector3D;

	public function get_crowdDestination():Vector3D {
		return mCrowdDestination;
	}

	public function showBuffDisplay(buffGO:BuffGameObject) {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(buffGO.buffData.IconSwf), function(param1:SwfAsset) {
			if (buffGO.isDestroyed) {
				return;
			}
			var _loc6_ = param1.getClass(buffGO.buffData.IconName);
			var _loc5_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc6_, []), MovieClip);
			var _loc2_ = mSwfAsset.getClass("buff_cooldown_icon");
			var _loc4_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
			var _loc7_ = new MovieClipRenderer(mDBFacade, ASCompat.coerce((_loc4_ : ASAny).cooldown, flash.display.MovieClip));
			_loc5_.alpha = 0.75;
			_loc5_.scaleX = _loc5_.scaleY = 0.75;
			(_loc4_ : ASAny).graphic.addChild(_loc5_);
			mRoot.addChild(_loc4_);
			var _loc3_ = new UIButton(mDBFacade, _loc4_);
			_loc3_.tooltip = ASCompat.coerce((_loc4_ : ASAny).tooltip, flash.display.MovieClip);
			TextUtil.setText(ASCompat.coerce((_loc4_ : ASAny).tooltip.title_label, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("BUFF_NAME", buffGO.buffData.Constant));
			TextUtil.setText(ASCompat.coerce((_loc4_ : ASAny).tooltip.description_label, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",
					buffGO.buffData.Constant) + buffGO.buffData.getStacksDescription((buffGO.instanceCount : Int)));
			mBuffIconButtons.push(_loc3_);
			mBuffs.push(buffGO);
			mBuffCooldowns.push(_loc7_);
			TextUtil.setText(ASCompat.coerce((_loc4_ : ASAny).quantity, flash.text.TextField), Std.string(buffGO.instanceCount));
			resetBuffButtonPositions();
			startBuffCooldown(mBuffIconButtons.length - 1, buffGO.buffData.Duration);
		});
	}

	public function startBuffCooldown(currentBuffIndex:Int, cooldownTime:Float) {
		mBuffCooldowns[currentBuffIndex].playRate = 1 / cooldownTime * 4.1;
		mBuffCooldowns[currentBuffIndex].play();
	}

	public function updateBuffDisplay(gameClock:GameClock) {
		var _loc3_ = 0;
		var _loc2_:BuffGameObject = null;
		_loc3_ = 0;
		while (_loc3_ < mBuffs.length) {
			_loc2_ = mBuffs[_loc3_];
			if (_loc2_.isDestroyed) {
				mRoot.removeChild(mBuffIconButtons[_loc3_].root);
				mBuffIconButtons[_loc3_].destroy();
				mBuffCooldowns[_loc3_].destroy();
				mBuffs.splice(_loc3_, (1 : UInt));
				mBuffIconButtons.splice(_loc3_, (1 : UInt));
				mBuffCooldowns.splice(_loc3_, (1 : UInt));
			}
			_loc3_++;
		}
	}

	public function updateBuffInstance(updatedBuffGO:BuffGameObject) {
		var _loc2_:BuffGameObject = null;
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ < mBuffs.length) {
			_loc2_ = mBuffs[_loc3_];
			if (_loc2_ == updatedBuffGO) {
				TextUtil.setText(ASCompat.coerce((mBuffIconButtons[_loc3_].root : ASAny).quantity, flash.text.TextField), Std.string(_loc2_.instanceCount));
				TextUtil.setText(ASCompat.coerce((mBuffIconButtons[_loc3_].root : ASAny).tooltip.description_label, flash.text.TextField),
					GameMasterLocale.getGameMasterSubString("BUFF_DESCRIPTION",
						_loc2_.buffData.Constant) + _loc2_.buffData.getStacksDescription((_loc2_.instanceCount : Int)));
				startBuffCooldown(_loc3_, _loc2_.buffData.Duration);
				return;
			}
			_loc3_++;
		}
	}

	public function resetBuffButtonPositions() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mBuffs.length) {
			if (mHudType == 1) {
				mBuffIconButtons[_loc1_].root.x = 455 + _loc1_ * 63;
				mBuffIconButtons[_loc1_].root.y = 865;
			} else {
				mBuffIconButtons[_loc1_].root.x = 424 + _loc1_ * 63;
				mBuffIconButtons[_loc1_].root.y = 980;
			}
			_loc1_++;
		}
	}

	public function refreshHUD() {
		this.setupUI(mSwfAsset, mHudType);
	}

	function onSteamInputGlyphsChanged(event:Event) {
		if (mDBFacade.steamInputManager.isSteamInputReady) {
			syncControllerPrompts();
		}
	}

	public function handleMenuButtonPressed(index:UInt) {
		if (index == 0) {
			if (mSuppressNextExitMenuToggle) {
				mSuppressNextExitMenuToggle = false;
				return;
			}
			if (mSettingsPopup != null) {
				return;
			}
			closeButtonReleaseCallback();
		} else if (index == 1) {
			toggleSettingsPopup();
		} else if (index == 2) {
			mUIChatLog.tryToggleChatLog();
		} else if (index == 3) {
			if (mDBFacade.steamInputManager.usesSteamOnScreenKeyboard) {
				mUIChatLog.focusChatInput();
			}
		}
	}

	public function clearExitMenu() {
		mLootLossPopup = null;
		mInfiniteExitPopup = null;
	}

	public function suppressNextExitMenuToggle() {
		mSuppressNextExitMenuToggle = mDBFacade.inputManager.check(27) || mDBFacade.steamInputManager.pressedAction("menu_cancel");
	}
}
