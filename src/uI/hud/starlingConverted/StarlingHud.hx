package uI.hud.starlingConverted;

import account.CurrencyUpdatedAccountEvent;
import actor.buffs.BuffGameObject;
import actor.buffs.BuffHandler;
import actor.player.input.DungeonBusterControlActivatedEvent;
import brain.assetRepository.AssetLoadingComponent;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.render.tweens.TweenHandle;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedImage;
import brain.starling.swfConverter.BakedPages;
import brain.utils.TextUtil;
import brain.utils.Timers;
import brain.workLoop.LayerWorkComponent;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import distributedObjects.HeroGameObjectOwner;
import distributedObjects.NPCGameObject;
import events.ActorInvulnerableEvent;
import events.BusterPointsEvent;
import events.ExperienceEvent;
import events.GameObjectEvent;
import events.HpEvent;
import events.ManaEvent;
import events.UIHudChangeEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import dr_floor.DungeonModifierHelper;
import gameMasterDictionary.GMAttack;
import gameMasterDictionary.GMSkin;
import settings.SettingsPopup;
import steamInput.OnSteamInputButtonReleasedEvent;
import steamInput.SteamInputGlyphsChangedEvent;
import uI.infiniteIsland.II_UIExitDungeonPopUp;
import uI.popup.UILootLossPopup;
import uI.UIChatLog;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.TimerEvent;
import flash.geom.Point;
import flash.geom.Vector3D;
import flash.utils.Timer;
import starling.core.Starling;
import starling.display.DisplayObject;
import starling.display.DisplayObjectContainer;
import starling.display.Image;
import starling.display.Sprite;
import starling.textures.Texture;

class StarlingHud implements IGameHud {
	static var sCurrent:StarlingHud;

	static var sErrorCount:UInt = (0 : UInt);

	static var sFirstError:String;

	static var sFirstErrorStack:String;

	static var sLastError:String;

	var mFacade:DBFacade;

	var mHeroOwner:HeroGameObjectOwner;

	var mRoot:Sprite;

	var mView:ArtView;

	var mSettingsPopup:SettingsPopup;

	var mInput:StarlingInput;

	var mCut:StarlingWorldCut;

	var mTicker:HudTicker;

	var mWork:LogicalWorkComponent;

	var mFadeWork:LayerWorkComponent;

	var mEvents:EventComponent;

	var mAssets:AssetLoadingComponent;

	var mChatHolder:flash.display.Sprite;

	var mChat:UIChatLog;

	var mChatClip:MovieClip;

	var mChatContainer:MovieClip;

	var mChatPrompt:StarlingChatPrompt;

	var mChatPromptFailed:Bool = false;

	var mTooltips:Vector<StarlingTooltip> = new Vector((0 : UInt));

	var mHp:StarlingBar;

	var mInvulnerable:StarlingBar;

	var mMana:StarlingBar;

	var mXp:StarlingBar;

	var mHealthFull:StarlingFullMessage;

	var mManaFull:StarlingFullMessage;

	var mProfile:DisplayObject;

	var mXpRoot:DisplayObject;

	var mCenterMessage:ArtDisplay;

	var mProfileRest:Float = Math.NaN;

	var mXpRest:Float = Math.NaN;

	var mProfileBulging:Bool = false;

	var mXpBulging:Bool = false;

	var mXpInitial:Bool = false;

	var mShown:Bool = false;

	var mDestroyed:Bool = false;

	var mGeneration:UInt = 0;

	var mHudType:UInt = 0;

	var mBuiltHudType:Int = -1;

	var mWeapons:Vector<StarlingHudSlot> = new Vector((0 : UInt));

	var mHighlightIndex:Int = -1;

	var mConsumables:Vector<StarlingHudSlot> = new Vector((0 : UInt));

	var mCooldownStarts:Vector<Float> = Vector.ofArray(([0, 0, 0, 0, 0] : Array<Float>));

	var mCooldownDurations:Vector<Float> = Vector.ofArray(([0, 0, 0, 0, 0] : Array<Float>));

	var mBoosterTimer:Timer;

	var mGlyphs:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mGlyphGeneration:UInt = 0;

	var mGlyphTextures:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mStarlingGlyphs:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mGlyphPaths:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mGlyphPixels:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mGrayGlyphPixels:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var mGlyphTask:Task;

	var mPortrait:BakedImage;

	var mPortraitArt:ArtNode;

	var mPortraitKey:String;

	var mPortraitSource:MovieClip;

	var mPortraitRetry:ASFunction;

	var mLootLossPopup:UILootLossPopup;

	var mInfiniteExitPopup:II_UIExitDungeonPopUp;

	var mSuppressNextExitMenuToggle:Bool = false;

	var mPet:NPCGameObject;

	var mBuffs:Vector<BuffGameObject> = new Vector((0 : UInt));

	var mDestinations:Vector<Vector3D>;

	var mBuster:StarlingBar;

	var mBusterButton:StarlingButton;

	var mBusterBanner:TimelineView;

	var mBusterPulse:TimelineView;

	var mBusterMax:UInt = (ASCompat.floatToInt(4294967295) : UInt);

	var mBusterReady:Bool = false;

	var mStacks:ArtView;

	var mStacksShown:Bool = true;

	var mStackButtons:Vector<StarlingButton> = new Vector((0 : UInt));

	var mTeamLoot:ArtView;

	var mLootTask:Task;

	var mLootTween:TweenHandle;

	var mLootGeneration:UInt = 0;

	var mLootMoving:Bool = false;

	var mPetPortrait:StarlingPetPortrait;

	var mPetModel:MovieClip;

	var mOffScreen:StarlingOffScreenManager;

	var mBuffViews:Vector<StarlingBuff> = new Vector((0 : UInt));

	var mModifierButtons:Vector<StarlingButton> = new Vector((0 : UInt));

	var mModifierModels:Vector<MovieClip> = new Vector((0 : UInt));

	var mModifierIcons:Vector<StarlingHudIcon> = new Vector((0 : UInt));

	var mModifierWidths:Vector<Float> = new Vector((0 : UInt));

	var mBusterPromptOffset:Float = Math.NaN;

	var mUiHidden:Bool = false;

	var mUiHideEvents:EventComponent;

	public function new(facade:DBFacade) {
		try {
			mFacade = facade;
			sCurrent = this;
			mRoot = new StarlingHudRoot();
			mRoot.visible = false;
			mRoot.touchable = false;
			HudTransform.sync(facade, mRoot);
			mTicker = new HudTicker(facade.gameClock);
			mTicker.onError = failed;
			mWork = new LogicalWorkComponent(facade, "StarlingHud");
			mEvents = new EventComponent(facade);
			mUiHideEvents = new EventComponent(facade);
			mUiHideEvents.addListener("UI_HIDE_TOGGLE_CHANGED", uiHideChanged);
			mUiHidden = facade.uiHideToggle != null && facade.uiHideToggle.hidden;
			if (facade.keyBindings != null) {
				facade.keyBindings.addChangeListener(keyBindingsChanged);
			}
			if (facade.settingsModel != null) {
				facade.settingsModel.addChangeListener(settingChanged);
			}
			mAssets = new AssetLoadingComponent(facade);
			mHudType = (ASCompat.toInt(facade.settingsModel.getValue("hudStyle")) == 1 ? (1 : UInt) : (0 : UInt):UInt);
			setDestinations();
			mWork.doEveryFrame(update);
			mFadeWork = new LayerWorkComponent(facade, "StarlingHud.fade");
			mFadeWork.doEveryFrame(syncFade);
			HudArt.onRebaked(rebuild);
			HudArt.onReady(artReady);
		} catch (error:ASAny) {
			HudArt.fatal("HUD construction failed: " + ASCompat.toString(error), true);
		}
	}

	static function drawn(display:DisplayObject):Bool {
		while (display != null) {
			if (!display.visible || display.alpha <= 0) {
				return false;
			}
			display = display.parent;
		}
		return true;
	}

	@:allow(uI.hud.starlingConverted) static function giveUp() {
		if (sCurrent != null) {
			sCurrent.hide();
		}
	}

	public static function reportError(error:Error) {
		if (Std.isOfType(error, HudFatalError)) {
			HudArt.fatal(error.message);
		}
		sErrorCount = sErrorCount + 1;
		sLastError = error.errorID + " " + Std.string(error.message);
		if (sFirstError == null) {
			sFirstError = sLastError;
			sFirstErrorStack = error.getStackTrace();
		}
	}

	@:isVar public static var errorCount(get, never):UInt;

	static public function get_errorCount():UInt {
		return sErrorCount;
	}

	@:isVar public static var firstError(get, never):String;

	static public function get_firstError():String {
		return sFirstError;
	}

	@:isVar public static var firstErrorStack(get, never):String;

	static public function get_firstErrorStack():String {
		return sFirstErrorStack;
	}

	@:isVar public static var lastError(get, never):String;

	static public function get_lastError():String {
		return sLastError;
	}

	@:allow(uI.hud.starlingConverted) static function disposeResource(resource:ASObject, method:String = "dispose") {
		try {
			if (resource != null) {
				resource[method]();
			}
		} catch (error:Dynamic) {
			reportError(error);
		}
	}

	static function placeGlyph(bitmap:Bitmap, owner:MovieClip, position:Vector3D, scale:Point) {
		bitmap.x = position.x;
		bitmap.y = position.y;
		bitmap.width = scale.x;
		bitmap.height = scale.y;
		owner.addChild(bitmap);
	}

	function artReady() {
		if (!mDestroyed) {
			refreshHUD();
		}
	}

	public function refreshHUD() {
		mHighlightIndex = -1;
		rebuild();
	}

	function rebuild() {
		var generation:UInt;
		var type:UInt;
		try {
			if (mDestroyed || !HudArt.ready) {
				return;
			}
			generation = ++mGeneration;
			type = mHudType;
			HudArt.convertLayout(type, function(param1:ArtNode) {
				try {
					if (mDestroyed || generation != mGeneration) {
						return;
					}
					build(param1);
				} catch (error:ASAny) {
					HudArt.fatal("HUD build failed: " + ASCompat.toString(error), true);
				}
			});
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function build(art:ArtNode) {
		var _loc3_:String = null;
		var _loc9_:StarlingButton = null;
		var _loc10_:StarlingBuff = null;
		var _loc2_:BuffGameObject = null;
		var _loc4_ = 0;
		HudTransform.sync(mFacade, mRoot);
		if (art == null) {
			throw new Error("HUD layout unavailable");
		}
		var _loc5_ = (mBuiltHudType : UInt) != mHudType;
		var _loc6_ = ArtView.build(art, mTicker);
		mBuiltHudType = mHudType;
		disposeView();
		mView = _loc6_;
		visible("UI_XP.xp_points", false);
		visible("UI_XP.xp_level_title", false);
		cast(mView.root, ArtDisplay).advanceHiddenTimelines(true);
		mRoot.addChild(mView.root);
		mFacade.starlingLayerManager.hudLayer.addChild(mRoot);
		mRoot.visible = mShown && !mUiHidden;
		mTicker.attachStage(ASCompat.coerce(mRoot.visible ? mFacade.stageRef : null, flash.display.Stage));
		mProfile = node("UI_profile");
		mXpRoot = node("UI_XP");
		mCenterMessage = ASCompat.reinterpretAs(node("UI_center_message"), ArtDisplay);
		mProfileRest = mProfile != null ? mProfile.scaleX : 1;
		mXpRest = mXpRoot != null ? mXpRoot.scaleX : 1;
		mHp = new StarlingBar(node("UI_profile.HP_bar"), node("UI_profile.HP_bar_delta"), mTicker);
		mInvulnerable = new StarlingBar(node("UI_profile.HP_bar_invincible"), null, mTicker);
		mMana = new StarlingBar(node("UI_profile.mana_bar"), node("UI_profile.mana_bar_delta"), mTicker);
		mXp = new StarlingBar(node("UI_XP.xp_bar"), node("UI_XP.xp_bar_delta"), mTicker);
		visible("UI_XP.xp_bar_delta", true);
		var _loc7_ = node("UI_XP.xp_bar_delta");
		if (_loc7_ != null) {
			_loc7_.alpha = 0.3;
		}
		mHealthFull = new StarlingFullMessage(mFacade, node("UI_profile.HP_full_text"), mTicker);
		mManaFull = new StarlingFullMessage(mFacade, node("UI_profile.mana_full_text"), mTicker);
		mHealthFull.changed = mManaFull.changed = invalidateBounds;
		mInput = new StarlingInput(mFacade);
		mInput.onError = failed;
		var _loc8_ = new StarlingButton(mView, "close", mRoot);
		_loc8_.releaseCallback = closeButtonReleased;
		mInput.add(_loc8_);
		buildSlots();
		mBuster = new StarlingBar(node("UI_buster.buster_bar"), null, mTicker);
		mBusterButton = new StarlingButton(mView, "UI_buster_active.buster_activated", mRoot);
		mBusterButton.releaseCallback = handleBusterBarClickEvent;
		mInput.add(mBusterButton);
		mBusterBanner = ASCompat.reinterpretAs(node("UI_buster_glow"), TimelineView);
		mBusterPulse = ASCompat.reinterpretAs(node("UI_buster.buster_activated_glow"), TimelineView);
		if (mBusterBanner != null) {
			mBusterBanner.stop();
			mBusterBanner.stageRate = false;
		}
		if (mBusterPulse != null) {
			mBusterPulse.stop();
		}
		mStacks = ArtView.build(HudArt.art("stacks_hud"), mTicker);
		mStacks.root.x = 480;
		mStacks.root.y = 55;
		mRoot.addChild(mStacks.root);
		final __ax4_iter_190 = Vector.ofArray(["potion_slot_A", "potion_slot_B", "potion_slot_C"]);
		if (checkNullIteratee(__ax4_iter_190))
			for (_tmp_ in __ax4_iter_190) {
				_loc3_ = _tmp_;
				_loc9_ = new StarlingButton(mStacks, _loc3_, mRoot);
				_loc9_.enabled = false;
				mStackButtons.push(_loc9_);
			}
		addHover("UI_profile", profileOver, profileOut);
		addHover("UI_XP", xpOver, xpOut);
		buildFlashParts(_loc8_);
		hideDeferredParts();
		hideBuster();
		updateStacks();
		_loc4_ = 0;
		while (_loc4_ < mBuffViews.length) {
			_loc10_ = mBuffViews[_loc4_];
			if (_loc10_.art != HudArt.art("buff_cooldown_icon")) {
				mBuffViews[_loc4_] = _loc10_.rebuild(mFacade, mTicker, mInput, mRoot);
			} else {
				_loc10_.rebindInput(mInput);
			}
			_loc4_++;
		}
		final __ax4_iter_191 = mBuffs;
		if (checkNullIteratee(__ax4_iter_191))
			for (_tmp_ in __ax4_iter_191) {
				_loc2_ = _tmp_;
				if (buffView(_loc2_) == null) {
					createBuff(_loc2_);
				}
			}
		if (_loc5_) {
			resetBuffButtonPositions();
		}
		profileOut();
		xpOut();
		visible("UI_profile.HP_bar_invincible", false);
		mCut = new StarlingWorldCut(mFacade.sceneGraphManager.worldLayerGroup, mFacade.scalingRoot, mRoot, mFacade.sceneGraphManager.getLayer(42));
		bindBounds(mRoot);
		mInput.boundsChanged = invalidateBounds;
		applyCamera();
		setDestinations();
		setCurrency((mFacade.dbAccountInfo.basicCurrency : Int), (mFacade.dbAccountInfo.premiumCurrency : Int));
		if (mHeroOwner != null) {
			populateHero();
		}
		restoreSlotCooldowns();
		if (mShown) {
			show();
		} else {
			hide();
		}
	}

	function buildFlashParts(close:StarlingButton) {
		var _loc2_ = HudArt.swfClass(mHudType == 1 ? "ui_hud" : "ui_hud_old");
		var _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
		mChatHolder = new flash.display.Sprite();
		mChatHolder.name = "StarlingHud.chat";
		mChatHolder.transform.matrix = _loc3_.transform.matrix;
		mChatClip = ASCompat.coerce((_loc3_ : ASAny).UI_chat, flash.display.MovieClip);
		mChatContainer = ASCompat.coerce((_loc3_ : ASAny).chatLogContainer, flash.display.MovieClip);
		mChatHolder.addChild(mChatContainer);
		mChatHolder.addChild(mChatClip);
		mChat = new UIChatLog(mFacade, mChatContainer, mChatClip, ASCompat.coerce((mChatClip : ASAny).log_btn, flash.display.MovieClip),
			ASCompat.coerce((mChatClip : ASAny).chat_btn, flash.display.MovieClip));
		if (mHudType != 1) {
			mChat.textSizeModifier = 1.18;
		}
		mChat.disable();
		mConsumables[0].consumableTooltip = ASCompat.coerce((_loc3_ : ASAny).consumable_tooltip01, flash.display.MovieClip);
		mConsumables[1].consumableTooltip = ASCompat.coerce((_loc3_ : ASAny).consumable_tooltip02, flash.display.MovieClip);
		mPetModel = new MovieClip();
		ASCompat.setProperty(mPetModel, "pet", (_loc3_ : ASAny).pet);
		ASCompat.setProperty(mPetModel, "pet_none", (_loc3_ : ASAny).hasOwnProperty("pet_none") ? (_loc3_ : ASAny).pet_none : null);
		buildModifiers(_loc3_);
		visible("UI_currency_coin.coin.add_coin_button", false);
		visible("UI_currency_cash.cash.add_cash_button", false);
		buttonTooltip(ASCompat.coerce((_loc3_ : ASAny).close, flash.display.MovieClip), close, mView, "close");
		HudArtConverter.stopTree(_loc3_);
		_loc3_.removeChildren();
		visible("UI_chat", false);
		visible("chatLogContainer", false);
		setAllKeyboardIconsVisibility(!mFacade.steamInputManager.wantsControllerPrompts);
		if (mFacade.steamInputManager.isSteamInputReady) {
			mGlyphTask = mWork.doLater(1, delayedControllerIcons);
		}
		syncChatPrompt();
	}

	function syncChatPrompt() {
		var _loc1_ = mChat != null && mFacade.featureFlags.getFlagValue("starling-chat-prompt");
		if (_loc1_ == (mChatPrompt != null)) {
			return;
		}
		if (_loc1_) {
			if (mChatPromptFailed) {
				return;
			}
			try {
				mChatPrompt = new StarlingChatPrompt(mFacade, mTicker, mRoot, mInput, mChatHolder, mChatClip,
					HudArt.swfClass(mHudType == 1 ? "ui_hud" : "ui_hud_old"), mChat, Locale.getString("DEFAULT_CHAT_PROMPT"), mChat.promptColor, mHudType,
					invalidateBounds, chatButtonsReady);
			} catch (error:Dynamic) {
				mChatPromptFailed = true;
				failed(error);
				return;
			}
			mChat.starlingPrompt = mChatPrompt.show;
			if (mChatPrompt.logButton != null) {
				chatButtonsReady();
			}
		} else {
			if (mChat != null) {
				mChat.starlingPrompt = null;
			}
			disposeResource(mChatPrompt);
			mChatPrompt = null;
			invalidateBounds();
			chatButtonsReady();
		}
	}

	function chatButtonsReady() {
		try {
			if (mGlyphTask == null && mFacade.steamInputManager.isSteamInputReady) {
				updateControllerIcons();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function buildSlots() {
		var _loc2_ = 0;
		var _loc3_:StarlingHudSlot = null;
		var _loc1_ = Vector.ofArray([
			"UI_weapons.weapon_z",
			"UI_weapons.weapon_x",
			"UI_weapons.weapon_c",
			"consumables_01",
			"consumables_02"
		]);
		_loc2_ = 0;
		while (_loc2_ < _loc1_.length) {
			_loc3_ = new StarlingHudSlot(mFacade, mTicker, mView, _loc1_[_loc2_], mRoot, _loc2_ < 3 ? _loc2_ : _loc2_ - 3, invalidateBounds);
			if (_loc2_ < 3) {
				mWeapons.push(_loc3_);
			} else {
				mConsumables.push(_loc3_);
			}
			mInput.add(_loc3_.button);
			_loc2_++;
		}
		visible("consumable_tooltip01", false);
		visible("consumable_tooltip02", false);
	}

	function buttonTooltip(model:MovieClip, button:StarlingButton, view:ArtView, path:String = "") {
		if (!(model : ASAny).hasOwnProperty("tooltip") || !Std.isOfType((model : ASAny).tooltip, MovieClip)) {
			return;
		}
		var _loc7_ = ASCompat.coerce((model : ASAny).tooltip, flash.display.MovieClip);
		HudArtConverter.stopTree(_loc7_);
		var _loc6_ = new StarlingTooltip(mFacade, button.root, mRoot, _loc7_);
		mTooltips.push(_loc6_);
		button.rollOverCallback = _loc6_.rollOver;
		button.rollOutCallback = _loc6_.hide;
		var _loc5_ = ASCompat.reinterpretAs(view.node(path.length > 0 ? path + ".tooltip" : "tooltip"), ArtDisplay);
		if (_loc5_ != null) {
			_loc5_.setHudVisibility(false);
		}
	}

	function addHover(path:String, over:ASFunction, out:ASFunction) {
		var _loc4_ = new StarlingButton(mView, path, mRoot);
		_loc4_.rollOverCallback = over;
		_loc4_.rollOutCallback = out;
		mInput.add(_loc4_, false, true);
	}

	function hideDeferredParts() {
		var _loc1_:String = null;
		var _loc2_ = Vector.ofArray([
			"UI_buster_active",
			"UI_buster_glow",
			"UI_buster_pulse",
			"UI_team_loot",
			"pet",
			"pet_none",
			"floor_modifier01",
			"floor_modifier02",
			"floor_modifier03",
			"floor_modifier04",
			"tooltip_modifier01",
			"tooltip_modifier02",
			"tooltip_modifier03",
			"tooltip_modifier04",
			"UI_center_message",
			"UI_weapons.weapon_z.cooldown",
			"UI_weapons.weapon_x.cooldown",
			"UI_weapons.weapon_c.cooldown",
			"UI_weapons.weapon_z.selectionFrame",
			"UI_weapons.weapon_x.selectionFrame",
			"UI_weapons.weapon_c.selectionFrame",
			"consumables_01.cooldown",
			"consumables_02.cooldown"
		]);
		if (checkNullIteratee(_loc2_))
			for (_tmp_ in _loc2_) {
				_loc1_ = _tmp_;
				visible(_loc1_, false);
			}
	}

	function node(path:String):DisplayObject {
		return ASCompat.coerce(mView != null ? mView.node(path) : null, starling.display.DisplayObject);
	}

	function visible(path:String, value:Bool) {
		var _loc3_ = node(path);
		if (_loc3_ == null) {
			return;
		}
		var _loc4_ = _loc3_.visible != value;
		if (Std.isOfType(_loc3_, ArtDisplay)) {
			cast(_loc3_, ArtDisplay).setHudVisibility(value);
		}
		if (_loc3_.visible != value) {
			_loc3_.visible = value;
		}
		if (_loc4_) {
			invalidateBounds();
		}
	}

	function text(path:String, value:String, baked:Bool = false) {
		var _loc4_ = ASCompat.reinterpretAs(node(path), StarlingText);
		if (_loc4_ == null) {
			return;
		}
		if (_loc4_.text == value && (!baked || _loc4_.mode == "baked")) {
			return;
		}
		try {
			_loc4_.setContent(value, baked ? "baked" : "glyphs");
		} catch (error:Dynamic) {
			failed(error);
		}
		if (drawn(_loc4_)) {
			invalidateBounds();
		}
	}

	function profileOver() {
		visible("UI_profile.HP_text", true);
		visible("UI_profile.mana_text", true);
	}

	function profileOut() {
		var _loc1_ = mFacade.featureFlags.getFlagValue("want-numbered-hud");
		visible("UI_profile.HP_text", _loc1_);
		visible("UI_profile.mana_text", _loc1_);
	}

	function xpOver() {
		visible("UI_XP.xp_points", true);
		visible("UI_XP.xp_level_title", false);
	}

	function xpOut() {
		var _loc1_ = mFacade.featureFlags.getFlagValue("want-numbered-hud");
		visible("UI_XP.xp_points", _loc1_);
		visible("UI_XP.xp_level_title", !_loc1_);
	}

	public function initializeHud(heroOwner:HeroGameObjectOwner) {
		try {
			if (mDestroyed) {
				return;
			}
			if (HudTransform.sync(mFacade, mRoot)) {
				invalidateBounds();
			}
			cancelPortrait();
			if (mHeroOwner != heroOwner) {
				clearCooldowns();
			}
			mHeroOwner = heroOwner;
			addListeners();
			show();
			mHighlightIndex = -1;
			if (mView != null && heroOwner != null) {
				populateHero();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function populateHero() {
		if (mChat != null) {
			mChat.heroOwner = mHeroOwner;
			if (mShown) {
				mChat.enable();
			}
		}
		visible("UI_profile.HP_bar_invincible", false);
		visible("UI_profile.HP_bar", true);
		setHp(mHeroOwner.hitPoints, (ASCompat.floatToInt(mHeroOwner.maxHitPoints) : UInt));
		setMana(mHeroOwner.manaPoints, (ASCompat.floatToInt(mHeroOwner.maxManaPoints) : UInt));
		setXp(mHeroOwner.experiencePoints);
		bulgeXpBar();
		bulgeProfileBox();
		profileOut();
		xpOut();
		refreshBonuses();
		scheduleBooster();
		text("label_floor", Locale.getString("UI_HUD_FLOOR_LABEL") + Std.string(mHeroOwner.distributedDungeonFloor.getCurrentFloorNum()), true);
		loadPortrait();
		initializeBuster();
		refreshKeyboardLabels();
		updatePet();
		updateOffScreen();
		setDungeonModifiers();
		updateWeapons();
		updateConsumables();
		var _loc2_ = mHeroOwner.currentWeaponIndex;
		var _loc1_ = _loc2_ >= 0
			&& _loc2_ < mHeroOwner.weaponControllers.length
			&& mHeroOwner.weaponControllers[_loc2_] != null
			&& mHeroOwner.weaponControllers[_loc2_].weapon != null;
		setWeaponHighlight(mHighlightIndex >= 0 ? mHighlightIndex : (_loc1_ ? _loc2_ : -1));
	}

	function addListeners() {
		mEvents.removeAllListeners();
		if (mHeroOwner == null) {
			return;
		}
		var _loc1_ = mHeroOwner.id;
		mEvents.addListener(GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE", _loc1_), busterChanged);
		mEvents.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE", _loc1_), hpChanged);
		mEvents.addListener(GameObjectEvent.uniqueEvent("ManaEvent_MANA_UPDATE", _loc1_), manaChanged);
		mEvents.addListener(GameObjectEvent.uniqueEvent("ExperienceEvent_EXPERIENCE_UPDATE", _loc1_), xpChanged);
		mEvents.addListener(GameObjectEvent.uniqueEvent(BuffHandler.ACTOR_INVULNERABLE, _loc1_), invulnerabilityChanged);
		mEvents.addListener("CurrencyUpdatedAccountEvent", currencyChanged);
		mEvents.addListener("BONUS_XP_CHANGED_EVENT", bonusChanged);
		mEvents.addListener("BONUS_COIN_CHANGED_EVENT", bonusChanged);
		mEvents.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE", bonusChanged);
		mEvents.addListener("UI_HUD_CHANGE_EVENT", layoutChanged);
		mEvents.addListener("OnSteamInputGlyphsChanged", controllerChanged);
		mEvents.addListener("ControllerConnectionChangedEvent", controllerChanged);
		mEvents.addListener("OnSteamInputButtonReleasedEvent", steamButtonReleased);
		setAllKeyboardIconsVisibility(!mFacade.steamInputManager.wantsControllerPrompts);
		if (mFacade.steamInputManager.isSteamInputReady && mGlyphTask == null && mView != null) {
			mGlyphTask = mWork.doLater(1, delayedControllerIcons);
		}
	}

	function keyBindingsChanged(action:String) {
		try {
			if (!mDestroyed && !HudArt.fatalFailure) {
				refreshKeyboardLabels();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function settingChanged(id:String) {
		try {
			if (mDestroyed || HudArt.fatalFailure || id != "numbersOnBars" || mView == null || mHeroOwner == null) {
				return;
			}
			profileOut();
			xpOut();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function refreshKeyboardLabels() {
		var _loc1_ = mFacade.keyBindings;
		if (_loc1_ == null || mView == null) {
			return;
		}
		text("UI_weapons.weapon_z.label", _loc1_.displayNameFor("attackWeapon1"), true);
		text("UI_weapons.weapon_x.label", _loc1_.displayNameFor("attackWeapon2"), true);
		text("UI_weapons.weapon_c.label", _loc1_.displayNameFor("attackWeapon3"), true);
		text("consumables_01.label", _loc1_.displayNameFor("useConsumable1"), true);
		text("consumables_02.label", _loc1_.displayNameFor("useConsumable2"), true);
		if (mHeroOwner != null) {
			syncBusterPrompt();
		}
	}

	function hpChanged(event:HpEvent) {
		try {
			setHp(event.hp, event.maxHp);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function manaChanged(event:ManaEvent) {
		try {
			setMana(event.mana, event.maxMana);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function xpChanged(event:ExperienceEvent) {
		try {
			setXp(event.experience);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function currencyChanged(event:CurrencyUpdatedAccountEvent) {
		try {
			setCurrency((event.basicCurrency : Int), (event.premiumCurrency : Int));
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function bonusChanged(event:Event) {
		try {
			refreshBonuses();
			scheduleBooster();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function controllerChanged(event:Event) {
		try {
			if (Std.isOfType(event, SteamInputGlyphsChangedEvent) && !mFacade.steamInputManager.isSteamInputReady) {
				return;
			}
			updateControllerIcons();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function layoutChanged(event:UIHudChangeEvent) {
		try {
			mHudType = (event.hudType == 1 ? (1 : UInt) : (0 : UInt):UInt);
			refreshHUD();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function invulnerabilityChanged(event:ActorInvulnerableEvent) {
		try {
			if (mHp == null) {
				return;
			}
			if (event.mIsInvulnerable) {
				mInvulnerable.value = mHp.value;
			}
			visible("UI_profile.HP_bar_invincible", event.mIsInvulnerable);
			visible("UI_profile.HP_bar", !event.mIsInvulnerable);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setHp(current:UInt, max:UInt) {
		try {
			if (mHp == null) {
				return;
			}
			mHp.value = mInvulnerable.value = max > 0 ? current / max : 0;
			text("UI_profile.HP_text", Std.string(current) + " / " + Std.string(max));
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setMana(current:UInt, max:UInt) {
		try {
			if (mMana == null) {
				return;
			}
			mMana.value = max > 0 ? current / max : 0;
			text("UI_profile.mana_text", Std.string(current) + " / " + Std.string(max));
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setXp(xp:UInt) {
		var _loc4_ = (0 : UInt);
		var _loc2_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		try {
			if (mXp == null || mHeroOwner == null) {
				return;
			}
			_loc4_ = (mHeroOwner.gMHero.getLevelIndex(xp, (mHeroOwner.ascensionLevel : Int)) : UInt);
			_loc2_ = (ASCompat.toInt(_loc4_ > 0 ? mHeroOwner.gMHero.getExpFromIndex(_loc4_ - 1) : 0) : UInt);
			_loc3_ = mHeroOwner.gMHero.getExpFromIndex(_loc4_);
			mXp.value = _loc3_ > _loc2_ ? ((xp : Float) - (_loc2_ : Float)) / ((_loc3_ : Float) - (_loc2_ : Float)) : 0;
			text("UI_XP.xp_level", Std.string(mHeroOwner.level));
			text("UI_XP.xp_points", Std.string(xp) + " / " + Std.string(_loc3_));
			if (!mXpInitial) {
				mXpInitial = true;
				bulgeXpBar();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setCurrency(basicCurrency:Int, premiumCurrency:Int) {
		try {
			setBasicCurrency(basicCurrency);
			setPremiumCurrency(premiumCurrency);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setBasicCurrency(basicCurrency:Int) {
		try {
			text("UI_currency_coin.game_currency_text", Std.string(basicCurrency));
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setPremiumCurrency(premiumCurrency:Int) {
		try {
			text("UI_currency_cash.cash_text", Std.string(premiumCurrency));
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function refreshBonuses() {
		if (mView == null) {
			return;
		}
		var _loc3_ = mFacade.dbAccountInfo.inventoryInfo.findHighestBoosterXP();
		var _loc4_ = mFacade.dbAccountInfo.inventoryInfo.findHighestBoosterGold();
		var _loc1_ = mFacade.accountBonus.isXPBonusActive;
		var _loc2_ = mFacade.accountBonus.isCoinBonusActive;
		visible("UI_XP.doublexp_text", _loc1_ || _loc3_ != null && _loc3_.BuffInfo.Exp > 1);
		visible("UI_currency_coin.doublecoin_text", _loc2_ || _loc4_ != null && _loc4_.BuffInfo.Gold > 1);
		if (_loc1_) {
			text("UI_XP.doublexp_text", mFacade.accountBonus.xpBonusText, true);
		} else if (_loc3_ != null && _loc3_.BuffInfo.Exp > 1) {
			text("UI_XP.doublexp_text", _loc3_.BuffInfo.Exp + Locale.getString("BOOSTER_XP"), true);
		}
		if (_loc2_) {
			text("UI_currency_coin.doublecoin_text", mFacade.accountBonus.coinBonusText, true);
		} else if (_loc4_ != null && _loc4_.BuffInfo.Gold > 1) {
			text("UI_currency_coin.doublecoin_text", _loc4_.BuffInfo.Gold + Locale.getString("BOOSTER_GOLD"), true);
		}
	}

	function stopBooster() {
		if (mBoosterTimer == null) {
			return;
		}
		mBoosterTimer.stop();
		mBoosterTimer.removeEventListener("timer", boosterExpired);
		mBoosterTimer = null;
	}

	function scheduleBooster() {
		stopBooster();
		var _loc1_ = mFacade.dbAccountInfo.inventoryInfo.timeTillNextBoosterExpire();
		if (_loc1_ >= 0 && mHeroOwner != null) {
			mBoosterTimer = Timers.create(_loc1_, 0, "StarlingHud.mBoosterTimer");
			mBoosterTimer.addEventListener("timer", boosterExpired);
			mBoosterTimer.start();
		}
	}

	function boosterExpired(event:TimerEvent) {
		try {
			refreshBonuses();
			scheduleBooster();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function loadPortrait() {
		var skin:GMSkin;
		var avatar:DisplayObjectContainer;
		var portraitPath:String;
		var pixelScale:Float;
		var key:String;
		var known:ArtNode;
		var generation:UInt;
		var hero:HeroGameObjectOwner;
		cancelPortrait();
		if (mPortrait != null) {
			mPortrait.removeFromParent(true);
		}
		mPortrait = null;
		skin = mHeroOwner.gmSkin;
		if (skin == null) {
			return;
		}
		avatar = ASCompat.reinterpretAs(ASCompat.thisOrDefault(node("avatar"), node("UI_profile.avatar")), DisplayObjectContainer);
		if (avatar == null) {
			return;
		}
		portraitPath = node("avatar") != null ? "avatar" : "UI_profile.avatar";
		pixelScale = BakeScale.forArt(mView.artNode(""), portraitPath) * HudArt.pixelScale;
		key = skin.UISwfFilepath + "|" + skin.IconName + "|" + BakedPages.scaleKey(pixelScale);
		mPortraitKey = key;
		known = HudArt.content("hudStarlingPortrait|" + key);
		if (known != null) {
			mPortraitArt = known;
			known.retainView();
			attachPortrait(known.cell);
			return;
		}
		generation = mGeneration;
		hero = mHeroOwner;
		HudArt.loadRuntimeSwf(mAssets, skin.UISwfFilepath, skin.IconName, function(param1:brain.assetRepository.SwfAsset) {
			var definition:Dynamic;
			var asset = param1;
			if (mDestroyed || generation != mGeneration || hero != mHeroOwner || key != mPortraitKey) {
				return;
			}
			definition = HudIconBake.symbol(asset, skin.UISwfFilepath, skin.IconName);
			mPortraitSource = ASCompat.dynamicAs(ASCompat.createInstance(definition, []), MovieClip);
			if (mPortraitSource == null) {
				HudArt.fatal("Required HUD portrait is not a MovieClip: " + skin.UISwfFilepath + " " + skin.IconName);
			}
			HudArtConverter.stopTree(mPortraitSource);
			attachPortrait(null);
			mPortraitRetry = function():Bool {
				var _loc7_:Bool;
				var _loc1_:BakedCell = null;
				try {
					if (mPortraitSource == null) {
						return true;
					}
					if (Starling.current == null || !Starling.current.contextValid) {
						return false;
					}
					_loc1_ = HudArt.bakeContent("hudStarlingPortrait|" + key, mPortraitSource, pixelScale);
					if (_loc1_ == null) {
						return false;
					}
					mPortraitArt = new ArtNode();
					mPortraitArt.cell = mPortraitArt.hold(_loc1_, HudArt.pages);
					HudArt.storeContent("hudStarlingPortrait|" + key, mPortraitArt);
					mPortraitArt.retainView();
					mPortraitSource = null;
					if (mPortrait != null) {
						mPortrait.cell = _loc1_;
					}
					invalidateBounds();
					return true;
				} catch (error:Dynamic) {
					failed(error);
					_loc7_ = true;
				}
				return _loc7_;
			};
			if (!ASCompat.toBool(mPortraitRetry())) {
				mTicker.deferBake(mPortraitRetry);
			}
		});
	}

	function attachPortrait(cell:BakedCell) {
		var _loc2_ = ASCompat.reinterpretAs(ASCompat.thisOrDefault(node("avatar"), node("UI_profile.avatar")), DisplayObjectContainer);
		if (_loc2_ == null) {
			return;
		}
		mPortrait = new BakedImage(cell);
		_loc2_.addChild(mPortrait);
		invalidateBounds();
	}

	function cancelPortrait() {
		if (mPortraitArt != null) {
			mPortraitArt.releaseView();
		}
		mPortraitArt = null;
		if (mPortraitRetry != null) {
			mTicker.cancelBake(mPortraitRetry);
		}
		mPortraitRetry = null;
		mPortraitSource = null;
		mPortraitKey = null;
	}

	public function bulgeXpBar() {
		try {
			if (mXpRoot == null || !mFacade.featureFlags.getFlagValue("want-pickup-ui-pop")) {
				return;
			}
			mXpRoot.scaleX *= 1.08;
			mXpRoot.scaleY *= 1.08;
			mXpBulging = true;
			invalidateBounds();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function bulgeProfileBox() {
		try {
			if (mProfile == null || !mFacade.featureFlags.getFlagValue("want-pickup-ui-pop")) {
				return;
			}
			mProfile.scaleX *= 1.08;
			mProfile.scaleY *= 1.08;
			mProfileBulging = true;
			invalidateBounds();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function decayBulge(root:DisplayObject, rest:Float):Bool {
		var _loc3_ = (root.scaleX - rest) * 0.75;
		if (Math.abs(_loc3_) <= 0.01) {
			_loc3_ = 0;
		}
		root.scaleX = root.scaleY = rest + _loc3_;
		invalidateBounds();
		return _loc3_ != 0;
	}

	function update(clock:GameClock) {
		try {
			if (!mDestroyed && HudTransform.sync(mFacade, mRoot)) {
				invalidateBounds();
			}
		} catch (transformError:Dynamic) {
			failed(transformError);
		}
		if (HudArtConverter.busy) {
			return;
		}
		try {
			if (mDestroyed) {
				return;
			}
			if (!mShown || mUiHidden || mView == null) {
				return;
			}
			mTicker.tick(clock.tickLength);
			if (mChatPrompt != null != mFacade.featureFlags.getFlagValue("starling-chat-prompt")) {
				syncChatPrompt();
			}
			if (mProfileBulging) {
				mProfileBulging = decayBulge(mProfile, mProfileRest);
			}
			if (mXpBulging) {
				mXpBulging = decayBulge(mXpRoot, mXpRest);
			}
			updateBuffs();
			if (mOffScreen != null) {
				mOffScreen.update();
			}
			if (mLootMoving) {
				invalidateBounds();
			}
			if (mCut != null) {
				mCut.update();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function syncFade(clock:GameClock) {
		var _loc3_ = Math.NaN;
		var _loc2_ = (0 : UInt);
		try {
			if (mCut != null) {
				_loc3_ = mFacade.camera != null ? mFacade.camera.backgroundFadeAlpha : 0;
				_loc2_ = (ASCompat.toInt(mFacade.camera != null ? mFacade.camera.backgroundFadeColor : 0) : UInt);
				mCut.syncChatOverlay(_loc3_, _loc2_);
				mCut.fade(_loc3_, _loc2_);
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function failed(error:Error) {
		reportError(error);
	}

	function invalidateBounds() {
		if (mCut != null) {
			mCut.invalidate();
		}
	}

	function invalidateArrowBounds() {
		if (mCut != null) {
			mCut.invalidateDynamic();
		}
	}

	function cleanupCall(callback:ASFunction) {
		try {
			callback();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function bindBounds(display:DisplayObject) {
		var _loc3_ = 0;
		if (Std.isOfType(display, ArtDisplay)) {
			cast(display, ArtDisplay).contentBoundsChanged = invalidateBounds;
		}
		var _loc2_ = ASCompat.reinterpretAs(display, DisplayObjectContainer);
		if (_loc2_ != null) {
			_loc3_ = 0;
			while (_loc3_ < _loc2_.numChildren) {
				bindBounds(_loc2_.getChildAt(_loc3_));
				_loc3_++;
			}
		}
	}

	function applyCamera() {
		mFacade.camera.offset = new Point(0, mHudType == 1 ? 0 : 45);
		mFacade.camera.yCilppingFromBottom = mHudType == 1 ? 90 : 0;
		mFacade.camera.forceRedraw();
	}

	function openSettingsPopup() {
		if (mSettingsPopup != null || mDestroyed) {
			return;
		}
		mSettingsPopup = new SettingsPopup(mFacade, onSettingsPopupClosed);
	}

	function onSettingsPopupClosed() {
		mSettingsPopup = null;
		try {
			mSuppressNextExitMenuToggle = mFacade.inputManager.check(27);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function closeSettingsPopup() {
		var _loc1_ = mSettingsPopup;
		mSettingsPopup = null;
		if (_loc1_ != null) {
			disposeResource(_loc1_, "destroy");
		}
	}

	function toggleSettingsPopup() {
		if (mSettingsPopup == null) {
			openSettingsPopup();
		} else if (SettingsPopup.isTopMenu(mFacade)) {
			closeSettingsPopup();
		}
	}

	function steamButtonReleased(event:OnSteamInputButtonReleasedEvent) {
		try {
			if (event.actionName == "menu_options" && mSettingsPopup != null) {
				toggleSettingsPopup();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function setDestinations() {
		mDestinations = mHudType == 1 ? Vector.ofArray([
			new Vector3D(45, 150),
			new Vector3D(1550, 980),
			new Vector3D(60, 980),
			new Vector3D(53, 1031),
			new Vector3D(54, 915),
			new Vector3D(1555, 920)
		]) : Vector.ofArray([
			new Vector3D(45, 150),
			new Vector3D(112, 95),
			new Vector3D(813, 57),
			new Vector3D(1032, 57),
			new Vector3D(1584, 78),
			new Vector3D(1869, 1041)
		]);
	}

	public function show() {
		try {
			if (mDestroyed || HudArt.fatalFailure) {
				return;
			}
			mShown = true;
			mStacksShown = true;
			if (mView == null) {
				return;
			}
			mRoot.visible = !mUiHidden;
			mTicker.attachStage(ASCompat.coerce(mUiHidden ? null : mFacade.stageRef, flash.display.Stage));
			if (mChatHolder != null) {
				mFacade.sceneGraphManager.addChild(mChatHolder, 50);
				mChatHolder.visible = !mUiHidden;
			}
			if (mChat != null) {
				mChat.enable();
			}
			if (!mUiHidden) {
				mInput.attach();
			}
			updateStacks();
			if (mPetPortrait == null) {
				updatePet();
			}
			if (mCut != null) {
				mCut.invalidate();
				mCut.enabled = !mUiHidden;
			}
			mFacade.camera.yCilppingFromBottom = mHudType == 1 ? 90 : 0;
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function hide() {
		var __ax4_iter_192:Vector<StarlingBuff>;
		var __ax4_iter_193:Vector<StarlingTooltip>;
		var __ax4_iter_194:Vector<StarlingHudSlot>;
		var __ax4_iter_195:Vector<StarlingHudSlot>;
		var _loc3_:StarlingBuff = null;
		var _loc1_:StarlingTooltip = null;
		var _loc2_:StarlingHudSlot = null;
		try {
			mShown = false;
			mRoot.visible = false;
			mTicker.attachStage(null);
			if (mInput != null) {
				mInput.detach();
			}
			if (mPetPortrait != null) {
				mPetPortrait.dispose();
				mPetPortrait = null;
			}
			mPet = null;
			__ax4_iter_192 = mBuffViews;
			if (checkNullIteratee(__ax4_iter_192))
				for (_tmp_ in __ax4_iter_192) {
					_loc3_ = _tmp_;
					_loc3_.hideTooltip();
				}
			if (mStacks != null) {
				mStacks.root.visible = false;
			}
			__ax4_iter_193 = mTooltips;
			if (checkNullIteratee(__ax4_iter_193))
				for (_tmp_ in __ax4_iter_193) {
					_loc1_ = _tmp_;
					_loc1_.hide();
				}
			__ax4_iter_194 = mWeapons;
			if (checkNullIteratee(__ax4_iter_194))
				for (_tmp_ in __ax4_iter_194) {
					_loc2_ = _tmp_;
					_loc2_.hideTooltip();
				}
			__ax4_iter_195 = mConsumables;
			if (checkNullIteratee(__ax4_iter_195))
				for (_tmp_ in __ax4_iter_195) {
					_loc2_ = _tmp_;
					_loc2_.hideTooltip();
				}
			if (mCut != null) {
				mCut.enabled = false;
			}
			if (mChatHolder != null && mChatHolder.parent != null) {
				mChatHolder.parent.removeChild(mChatHolder);
			}
			if (mChat != null) {
				mChat.disable();
				mChat.hideChatLog();
			}
			closeSettingsPopup();
			mFacade.camera.yCilppingFromBottom = 0;
			mFacade.camera.forceRedraw();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function detachHero() {
		var __ax4_iter_196:Vector<StarlingBuff>;
		var __ax4_iter_197:Vector<StarlingHudSlot>;
		var __ax4_iter_198:Vector<StarlingHudSlot>;
		var _loc2_:StarlingBuff = null;
		var _loc1_:StarlingHudSlot = null;
		try {
			hide();
			cleanupCall(hideBuster);
			cleanupCall(destroyTeamLoot);
			disposeResource(mOffScreen, "dispose");
			mOffScreen = null;
			__ax4_iter_196 = mBuffViews;
			if (checkNullIteratee(__ax4_iter_196))
				for (_tmp_ in __ax4_iter_196) {
					_loc2_ = _tmp_;
					disposeResource(_loc2_, "dispose");
				}
			mBuffViews.length = 0;
			disposeResource(mEvents, "removeAllListeners");
			cleanupCall(stopBooster);
			cleanupCall(cancelPortrait);
			cleanupCall(destroyExitMenus);
			disposeResource(mHealthFull, "stop");
			disposeResource(mManaFull, "stop");
			try {
				if (mPortrait != null) {
					mPortrait.removeFromParent(true);
				}
			} catch (portraitError:Dynamic) {
				failed(portraitError);
			}
			mPortrait = null;
			mHeroOwner = null;
			clearCooldowns();
			mPet = null;
			mBuffs.length = 0;
			__ax4_iter_197 = mWeapons;
			if (checkNullIteratee(__ax4_iter_197))
				for (_tmp_ in __ax4_iter_197) {
					_loc1_ = _tmp_;
					disposeResource(_loc1_, "reset");
				}
			__ax4_iter_198 = mConsumables;
			if (checkNullIteratee(__ax4_iter_198))
				for (_tmp_ in __ax4_iter_198) {
					_loc1_ = _tmp_;
					disposeResource(_loc1_, "reset");
				}
			if (mChat != null) {
				mChat.heroOwner = null;
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function disposeView() {
		var _loc5_:StarlingBuff = null;
		var _loc2_:StarlingHudIcon = null;
		var _loc1_:StarlingButton = null;
		var _loc4_:StarlingHudSlot = null;
		var _loc3_:StarlingTooltip = null;
		final __ax4_iter_199 = mBuffViews;
		if (checkNullIteratee(__ax4_iter_199))
			for (_tmp_ in __ax4_iter_199) {
				_loc5_ = _tmp_;
				disposeResource(_loc5_, "detachInput");
			}
		cleanupCall(destroyTeamLoot);
		if (mPetPortrait != null) {
			disposeResource(mPetPortrait);
			mPetPortrait = null;
		}
		disposeResource(mOffScreen, "dispose");
		mOffScreen = null;
		disposeResource(mBuster, "dispose");
		disposeResource(mBusterButton, "dispose");
		mBuster = null;
		mBusterButton = null;
		mBusterBanner = mBusterPulse = null;
		mBusterPromptOffset = 0;
		final __ax4_iter_200 = mModifierIcons;
		if (checkNullIteratee(__ax4_iter_200))
			for (_tmp_ in __ax4_iter_200) {
				_loc2_ = _tmp_;
				disposeResource(_loc2_);
			}
		final __ax4_iter_201 = mModifierButtons;
		if (checkNullIteratee(__ax4_iter_201))
			for (_tmp_ in __ax4_iter_201) {
				_loc1_ = _tmp_;
				disposeResource(_loc1_);
			}
		final __ax4_iter_202 = mStackButtons;
		if (checkNullIteratee(__ax4_iter_202))
			for (_tmp_ in __ax4_iter_202) {
				_loc1_ = _tmp_;
				disposeResource(_loc1_);
			}
		mModifierIcons.length = mModifierButtons.length = mModifierModels.length = mModifierWidths.length = mStackButtons.length = 0;
		disposeResource(mStacks, "dispose");
		mStacks = null;
		mPetModel = null;
		cleanupCall(cancelPortrait);
		mPortrait = null;
		mProfileBulging = mXpBulging = false;
		final __ax4_iter_203 = mWeapons;
		if (checkNullIteratee(__ax4_iter_203))
			for (_tmp_ in __ax4_iter_203) {
				_loc4_ = _tmp_;
				disposeResource(_loc4_);
			}
		final __ax4_iter_204 = mConsumables;
		if (checkNullIteratee(__ax4_iter_204))
			for (_tmp_ in __ax4_iter_204) {
				_loc4_ = _tmp_;
				disposeResource(_loc4_);
			}
		mWeapons.length = mConsumables.length = 0;
		disposeResource(mInput);
		mInput = null;
		disposeResource(mCut, "dispose");
		mCut = null;
		final __ax4_iter_205 = mTooltips;
		if (checkNullIteratee(__ax4_iter_205))
			for (_tmp_ in __ax4_iter_205) {
				_loc3_ = _tmp_;
				disposeResource(_loc3_);
			}
		mTooltips.length = 0;
		disposeResource(mChatPrompt);
		mChatPrompt = null;
		mChatPromptFailed = false;
		disposeResource(mChat, "destroy");
		mChat = null;
		if (mChatHolder != null && mChatHolder.parent != null) {
			mChatHolder.parent.removeChild(mChatHolder);
		}
		mChatHolder = null;
		mChatClip = mChatContainer = null;
		disposeResource(mGlyphTask, "destroy");
		mGlyphTask = null;
		cleanupCall(clearGlyphs);
		disposeResource(mHealthFull, "dispose");
		disposeResource(mManaFull, "dispose");
		mHealthFull = mManaFull = null;
		disposeResource(mHp, "dispose");
		disposeResource(mInvulnerable, "dispose");
		disposeResource(mMana, "dispose");
		disposeResource(mXp, "dispose");
		mHp = mInvulnerable = mMana = mXp = null;
		disposeResource(mView, "dispose");
		mView = null;
		mProfile = mXpRoot = null;
		mCenterMessage = null;
	}

	public function destroy() {
		try {
			if (mDestroyed) {
				return;
			}
			detachHero();
			mDestroyed = true;
			mGeneration = mGeneration + 1;
			HudArt.removeReady(artReady);
			HudArt.removeRebaked(rebuild);
			disposeView();
			closeSettingsPopup();
			mTicker.dispose();
			mWork.destroy();
			mFadeWork.destroy();
			mEvents.destroy();
			mUiHideEvents.destroy();
			if (mFacade.keyBindings != null) {
				mFacade.keyBindings.removeChangeListener(keyBindingsChanged);
			}
			if (mFacade.settingsModel != null) {
				mFacade.settingsModel.removeChangeListener(settingChanged);
			}
			mAssets.destroy();
			mRoot.removeFromParent(true);
			if (sCurrent == this) {
				sCurrent = null;
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function uiHideChanged(event:Event) {
		try {
			mUiHidden = mFacade.uiHideToggle != null && mFacade.uiHideToggle.hidden;
			if (mDestroyed || !mShown || mView == null) {
				return;
			}
			mRoot.visible = !mUiHidden;
			if (mChatHolder != null) {
				mChatHolder.visible = !mUiHidden;
			}
			if (mCut != null) {
				mCut.enabled = !mUiHidden;
				mCut.invalidate();
			}
			if (mInput != null) {
				if (mUiHidden) {
					mInput.detach();
				} else {
					mInput.attach();
				}
			}
			mTicker.attachStage(ASCompat.coerce(mUiHidden ? null : mFacade.stageRef, flash.display.Stage));
			if (!mUiHidden) {
				restoreSlotCooldowns();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function showHealthFullMessage() {
		try {
			if (mHealthFull != null) {
				mHealthFull.show();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function showManaFullMessage() {
		try {
			if (mManaFull != null) {
				mManaFull.show();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function showText(localeTextName:String) {
		var _loc2_:DisplayObject = null;
		try {
			_loc2_ = node("UI_center_message");
			if (_loc2_ == null) {
				return;
			}
			if (!_loc2_.visible) {
				visible("UI_center_message", true);
				mWork.doLater(0.35, hideCenterMessage);
			}
			text("UI_center_message", Locale.getString(localeTextName), true);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function isInCooldown() {
		showText("IS_IN_COOLDOWN");
	}

	function hideCenterMessage(clock:GameClock) {
		try {
			if (mCenterMessage != null) {
				mCenterMessage.setHudVisibility(false);
				invalidateBounds();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function showNotEnoughMana() {
		try {
			visible("UI_center_message", true);
			text("UI_center_message", Locale.getString("NOT_ENOUGH_MANA"), true);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function hideNotEnoughMana() {
		try {
			visible("UI_center_message", false);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function closeButtonReleased() {
		if (mHeroOwner == null) {
			return;
		}
		if (mHeroOwner.distributedDungeonFloor.isInfiniteDungeon) {
			if (mInfiniteExitPopup == null) {
				mInfiniteExitPopup = new II_UIExitDungeonPopUp(mFacade, confirmExit, null, openSettingsPopup);
			} else {
				mInfiniteExitPopup.destroy();
				mInfiniteExitPopup = null;
			}
		} else if (mLootLossPopup == null) {
			mLootLossPopup = new UILootLossPopup(mFacade, mHeroOwner.distributedDungeonFloor.completionXp,
				mHeroOwner.distributedDungeonFloor.treasureCollected, confirmExit, null, openSettingsPopup);
		} else {
			mLootLossPopup.destroy();
			mLootLossPopup = null;
		}
	}

	function confirmExit() {
		try {
			mFacade.metrics.log("ButtonClick", {
				"buttonDesc": "UIHud Exit Button Clicked",
				"areaType": "Dungeon"
			});
			if (mChat != null) {
				mChat.hideChatLog();
			}
			clearExitMenu();
			mFacade.mDistributedObjectManager.mMatchMaker.RequestExit();
			mFacade.dbAccountInfo.dbAccountParams.flushParams();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function destroyExitMenus() {
		disposeResource(mLootLossPopup, "destroy");
		disposeResource(mInfiniteExitPopup, "destroy");
		clearExitMenu();
	}

	public function clearExitMenu() {
		mLootLossPopup = null;
		mInfiniteExitPopup = null;
	}

	public function suppressNextExitMenuToggle() {
		try {
			mSuppressNextExitMenuToggle = mFacade.inputManager.check(27) || mFacade.steamInputManager.pressedAction("menu_cancel");
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function handleMenuButtonPressed(index:UInt) {
		try {
			if (index == 0) {
				if (mSuppressNextExitMenuToggle) {
					mSuppressNextExitMenuToggle = false;
					return;
				}
				if (mSettingsPopup != null) {
					return;
				}
				closeButtonReleased();
			} else if (index == 1) {
				toggleSettingsPopup();
			} else if (index == 2 && mChat != null) {
				mChat.tryToggleChatLog();
			} else if (index == 3 && mChat != null && mFacade.steamInputManager.usesSteamOnScreenKeyboard) {
				mChat.focusChatInput();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function initControllerIcon(inActionName:String, inOwner:MovieClip, iconPosition:Vector3D, iconScale:Point) {
		var path:String;
		var ownerGlyphs:ASObject;
		var stored:Bitmap;
		var generation:UInt;
		try {
			if (mDestroyed || inOwner == null || !mFacade.steamInputManager.isSteamInputReady) {
				return;
			}
			path = mFacade.steamInputManager.getGlyphFilePathForAction(inActionName);
			if (path == null || path.length == 0 || path == "error1") {
				return;
			}
			ownerGlyphs = mGlyphs[inOwner];
			if (ownerGlyphs == null) {
				ownerGlyphs = {};
				mGlyphs[inOwner] = ownerGlyphs;
			}
			stored = ASCompat.dynamicAs(ownerGlyphs[inActionName], Bitmap);
			if (stored != null && stored.parent != null && stored.parent != inOwner) {
				stored = null;
			}
			if (stored != null) {
				placeGlyph(stored, inOwner, iconPosition, iconScale);
				return;
			}
			generation = mGlyphGeneration;
			mAssets.getImageAsset(path, function(param1:brain.assetRepository.ImageAsset) {
				var _loc2_:Bitmap = null;
				var _loc3_:Bitmap = null;
				try {
					if (mDestroyed || generation != mGlyphGeneration || mGlyphs[inOwner] != ownerGlyphs) {
						return;
					}
					_loc2_ = ASCompat.dynamicAs(ownerGlyphs[inActionName], Bitmap);
					if (_loc2_ != null && _loc2_.parent == inOwner) {
						inOwner.removeChild(_loc2_);
					}
					_loc3_ = new Bitmap(param1.image.bitmapData, param1.image.pixelSnapping, param1.image.smoothing);
					ownerGlyphs[inActionName] = _loc3_;
					placeGlyph(_loc3_, inOwner, iconPosition, iconScale);
				} catch (error:Dynamic) {
					failed(error);
				}
			});
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function removeControllerIcons(inOwner:MovieClip) {
		var _loc3_:ASObject = null;
		var _loc2_:Bitmap = null;
		try {
			_loc3_ = mGlyphs[inOwner];
			if (_loc3_ == null) {
				return;
			}
			if (checkNullIteratee(_loc3_))
				for (_tmp_ in iterateDynamicValues(_loc3_)) {
					_loc2_ = ASCompat.coerce(_tmp_, flash.display.Bitmap);
					if (_loc2_.parent == inOwner) {
						inOwner.removeChild(_loc2_);
					}
				}
			mGlyphs.remove(inOwner);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function clearGlyphs() {
		var _loc4_:Bitmap = null;
		var _loc5_:ASObject = null;
		var _loc1_:Image = null;
		var _loc3_:Texture = null;
		var _loc2_:BitmapData = null;
		mGlyphGeneration = mGlyphGeneration + 1;
		final __ax4_iter_206 = mGlyphs;
		if (checkNullIteratee(__ax4_iter_206))
			for (_tmp_ in __ax4_iter_206) {
				_loc5_ = _tmp_;
				if (checkNullIteratee(_loc5_))
					for (_tmp_ in iterateDynamicValues(_loc5_)) {
						_loc4_ = ASCompat.coerce(_tmp_, flash.display.Bitmap);
						if (_loc4_.parent != null) {
							_loc4_.parent.removeChild(_loc4_);
						}
					}
			}
		mGlyphs = new ASDictionary<ASAny, ASAny>();
		final __ax4_iter_207 = mStarlingGlyphs;
		if (checkNullIteratee(__ax4_iter_207))
			for (_tmp_ in __ax4_iter_207) {
				_loc1_ = ASCompat.coerce(_tmp_, starling.display.Image);
				_loc1_.removeFromParent(true);
			}
		final __ax4_iter_208 = mGlyphTextures;
		if (checkNullIteratee(__ax4_iter_208))
			for (_tmp_ in __ax4_iter_208) {
				_loc3_ = ASCompat.coerce(_tmp_, starling.textures.Texture);
				_loc3_.dispose();
			}
		final __ax4_iter_209 = mGrayGlyphPixels;
		if (checkNullIteratee(__ax4_iter_209))
			for (_tmp_ in __ax4_iter_209) {
				_loc2_ = ASCompat.coerce(_tmp_, flash.display.BitmapData);
				_loc2_.dispose();
			}
		mStarlingGlyphs = new ASDictionary<ASAny, ASAny>();
		mGlyphTextures = new ASDictionary<ASAny, ASAny>();
		mGlyphPaths = new ASDictionary<ASAny, ASAny>();
		mGlyphPixels = new ASDictionary<ASAny, ASAny>();
		mGrayGlyphPixels = new ASDictionary<ASAny, ASAny>();
	}

	function delayedControllerIcons(clock:GameClock) {
		try {
			mGlyphTask = null;
			updateControllerIcons();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function updateControllerIcons() {
		clearGlyphs();
		if (mHeroOwner != null) {
			syncBusterPrompt();
		}
		if (mChat == null) {
			return;
		}
		var _loc1_ = mFacade.steamInputManager.isSteamInputReady;
		setAllKeyboardIconsVisibility(!mFacade.steamInputManager.wantsControllerPrompts);
		if (!_loc1_) {
			return;
		}
		var _loc2_ = mChatPrompt != null && mChatPrompt.logButton != null;
		if (_loc2_) {
			initStarlingGlyph("toggle_chat_log", mChatPrompt.logButton.root, 25, -10, 20);
		} else {
			initControllerIcon("toggle_chat_log", ASCompat.coerce((mChatClip : ASAny).log_btn, flash.display.MovieClip), new Vector3D(25, -10),
				new Point(20, 20));
		}
		if (mFacade.steamInputManager.usesSteamOnScreenKeyboard) {
			if (_loc2_) {
				initStarlingGlyph("open_chat_keyboard", mChatPrompt.sendButton.root, 32, -10, 20);
			} else {
				initControllerIcon("open_chat_keyboard", ASCompat.coerce((mChatClip : ASAny).chat_btn, flash.display.MovieClip), new Vector3D(32, -10),
					new Point(20, 20));
			}
		}
		initStarlingControllerIcons();
		HudReviveBridge.refresh(mFacade, this, mHeroOwner);
	}

	function setAllKeyboardIconsVisibility(value:Bool) {
		visible("UI_weapons.weapon_z.label", keepsKeyboardLabel(value, "attack_weapon_1"));
		visible("UI_weapons.weapon_x.label", keepsKeyboardLabel(value, "attack_weapon_2"));
		visible("UI_weapons.weapon_c.label", keepsKeyboardLabel(value, "attack_weapon_3"));
		visible("consumables_01.label", keepsKeyboardLabel(value, "use_consumable_one"));
		visible("consumables_02.label", keepsKeyboardLabel(value, "use_consumable_two"));
		if (mChat != null) {
			mChat.setChatPromptVisible(value);
		}
	}

	function keepsKeyboardLabel(value:Bool, action:String):Bool {
		return value || !mFacade.steamInputManager.hasGlyphForAction(action);
	}

	function initStarlingControllerIcons() {
		var _loc1_ = 0;
		var _loc2_ = Vector.ofArray(["attack_weapon_1", "attack_weapon_2", "attack_weapon_3"]);
		_loc1_ = 0;
		while (_loc1_ < mWeapons.length) {
			initStarlingGlyph(_loc2_[_loc1_], mWeapons[_loc1_].button.root, 13, -50);
			_loc1_++;
		}
		if (mConsumables.length > 0) {
			initStarlingGlyph("use_consumable_one", mConsumables[0].button.root, 13, -50);
		}
		if (mConsumables.length > 1) {
			initStarlingGlyph("use_consumable_two", mConsumables[1].button.root, 13, -50);
		}
		initStarlingGlyph("toggle_menu", node("close"), -5, -27);
		initStarlingGlyph("use_dungeon_buster", node("UI_buster_active.buster_activated"), 8, -8);
	}

	function initStarlingGlyph(action:String, owner:DisplayObject, x:Float, y:Float, size:Float = 25) {
		var path:String;
		var generation:UInt;
		var container = ASCompat.reinterpretAs(owner, DisplayObjectContainer);
		if (container == null) {
			return;
		}
		path = mFacade.steamInputManager.getGlyphFilePathForAction(action);
		if (path == null || path.length == 0 || path == "error1") {
			return;
		}
		generation = mGlyphGeneration;
		mAssets.getImageAsset(path, function(param1:brain.assetRepository.ImageAsset) {
			var _loc4_:Texture = null;
			var _loc3_:Image = null;
			var _loc2_:Image = null;
			try {
				if (mDestroyed || generation != mGlyphGeneration) {
					return;
				}
				_loc4_ = ASCompat.dynamicAs(mGlyphTextures[path], Texture);
				if (_loc4_ == null) {
					_loc4_ = Texture.fromBitmapData(param1.image.bitmapData);
					mGlyphTextures[path] = _loc4_;
				}
				mGlyphPixels[path] = param1.image.bitmapData;
				mGlyphPaths[action] = path;
				_loc3_ = ASCompat.dynamicAs(mStarlingGlyphs[action], Image);
				if (_loc3_ != null) {
					_loc3_.removeFromParent(true);
				}
				_loc2_ = new Image(_loc4_);
				_loc2_.touchable = false;
				_loc2_.x = x;
				_loc2_.y = y;
				_loc2_.width = _loc2_.height = size;
				container.addChild(_loc2_);
				mStarlingGlyphs[action] = _loc2_;
				if (action == "use_consumable_one" && mConsumables.length > 0 && !mConsumables[0].button.enabled || action == "use_consumable_two"
					&& mConsumables.length > 1 && !mConsumables[1].button.enabled) {
					grayscaleGlyph(action);
				}
				invalidateBounds();
			} catch (error:Dynamic) {
				failed(error);
			}
		});
	}

	function grayscaleGlyph(action:String) {
		var _loc4_:BitmapData = null;
		var _loc3_ = ASCompat.dynamicAs(mStarlingGlyphs[action], Image);
		var _loc2_:String = mGlyphPaths[action];
		var _loc6_ = ASCompat.dynamicAs(mGlyphPixels[_loc2_], BitmapData);
		if (_loc3_ == null || _loc6_ == null) {
			return;
		}
		var _loc7_ = _loc2_ + "|gray";
		var _loc5_ = ASCompat.dynamicAs(mGlyphTextures[_loc7_], Texture);
		if (_loc5_ == null) {
			_loc4_ = _loc6_.clone();
			_loc4_.applyFilter(_loc4_, _loc4_.rect, new Point(), HudArtConverter.grayscaleFilter());
			_loc5_ = Texture.fromBitmapData(_loc4_);
			mGlyphTextures[_loc7_] = _loc5_;
			mGrayGlyphPixels[_loc7_] = _loc4_;
		}
		_loc3_.texture = _loc5_;
	}

	@:isVar public var ownedHero(get, never):HeroGameObjectOwner;

	public function get_ownedHero():HeroGameObjectOwner {
		return mHeroOwner;
	}

	@:isVar public var chatLog(get, never):UIChatLog;

	public function get_chatLog():UIChatLog {
		return mChat;
	}

	@:isVar public var floaterTextClass(get, never):Dynamic;

	public function get_floaterTextClass():Dynamic {
		var _loc3_:ASAny;
		try {
			return (HudArt.ready || HudArt.fatalFailure ? HudArt.swfClass("floater_text") : null:Dynamic);
		} catch (error:Dynamic) {
			failed(error);
			_loc3_ = null;
		}
		return (_loc3_ : Dynamic);
	}

	@:isVar public var teamLootDestination(get, never):Vector3D;

	public function get_teamLootDestination():Vector3D {
		return mDestinations[0];
	}

	@:isVar public var profileDestination(get, never):Vector3D;

	public function get_profileDestination():Vector3D {
		return mDestinations[1];
	}

	@:isVar public var coinsDestination(get, never):Vector3D;

	public function get_coinsDestination():Vector3D {
		return mDestinations[2];
	}

	@:isVar public var expDestination(get, never):Vector3D;

	public function get_expDestination():Vector3D {
		return mDestinations[4];
	}

	@:isVar public var crowdDestination(get, never):Vector3D;

	public function get_crowdDestination():Vector3D {
		return mDestinations[5];
	}

	public function hideBustSign() {
		try {
			hideBuster();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setWeaponHighlight(currentWeaponIndex:Int) {
		var _loc2_ = 0;
		try {
			mHighlightIndex = currentWeaponIndex;
			_loc2_ = 0;
			while (_loc2_ < mWeapons.length) {
				mWeapons[_loc2_].highlight(_loc2_ == currentWeaponIndex);
				_loc2_++;
			}
			invalidateBounds();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function startCooldown(currentWeaponIndex:Int, cooldownTime:Float) {
		try {
			if (currentWeaponIndex < 0 || currentWeaponIndex >= 3) {
				return;
			}
			recordCooldown(currentWeaponIndex, cooldownTime);
			if (currentWeaponIndex < mWeapons.length) {
				mWeapons[currentWeaponIndex].startCooldown(cooldownTime);
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function stopCooldown(currentWeaponIndex:Int) {
		try {
			if (currentWeaponIndex < 0 || currentWeaponIndex >= 3) {
				return;
			}
			mCooldownDurations[currentWeaponIndex] = 0;
			if (currentWeaponIndex < mWeapons.length) {
				mWeapons[currentWeaponIndex].stopCooldown();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function startConsumableCooldown(currentWeaponIndex:Int, cooldownTime:Float) {
		try {
			if (currentWeaponIndex < 0 || currentWeaponIndex >= 2) {
				return;
			}
			recordCooldown(currentWeaponIndex + 3, cooldownTime);
			if (currentWeaponIndex < mConsumables.length) {
				mConsumables[currentWeaponIndex].startCooldown(cooldownTime);
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function stopConsumableCooldown(currentWeaponIndex:Int) {
		try {
			if (currentWeaponIndex < 0 || currentWeaponIndex >= 2) {
				return;
			}
			mCooldownDurations[currentWeaponIndex + 3] = 0;
			if (currentWeaponIndex < mConsumables.length) {
				mConsumables[currentWeaponIndex].stopCooldown();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function recordCooldown(slot:Int, seconds:Float) {
		mCooldownStarts[slot] = mFacade.gameClock.gameTime;
		mCooldownDurations[slot] = seconds;
	}

	function clearCooldowns() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mCooldownDurations.length) {
			mCooldownDurations[_loc1_] = 0;
			_loc1_++;
		}
	}

	function restoreSlotCooldowns() {
		var _loc3_ = 0;
		var _loc1_ = Math.NaN;
		var _loc2_ = Math.NaN;
		var _loc4_:StarlingHudSlot = null;
		_loc3_ = 0;
		while (_loc3_ < mCooldownDurations.length) {
			_loc2_ = mCooldownDurations[_loc3_];
			if (_loc2_ > 0) {
				_loc1_ = Math.max(0, (mFacade.gameClock.gameTime - mCooldownStarts[_loc3_]) / 1000);
				if (_loc1_ >= _loc2_) {
					mCooldownDurations[_loc3_] = 0;
				} else {
					_loc4_ = ASCompat.coerce(_loc3_ < 3 ? ASCompat.coerce(_loc3_ < mWeapons.length ? mWeapons[_loc3_] : null,
						uI.hud.starlingConverted.StarlingHudSlot) : ASCompat.coerce(_loc3_ - 3 < mConsumables.length ? mConsumables[_loc3_ - 3] : null,
							uI.hud.starlingConverted.StarlingHudSlot),
						uI.hud.starlingConverted.StarlingHudSlot);
					if (_loc4_ != null) {
						_loc4_.startCooldown(_loc2_, _loc1_);
					}
				}
			}
			_loc3_++;
		}
	}

	public function decrementConsumableCount(slot:UInt) {
		try {
			if (slot < (mConsumables.length:UInt)) {
				mConsumables[(slot : Int)].decrement();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function totalConsumableCountReached(slot:UInt) {
		try {
			if (slot >= (mConsumables.length : UInt)) {
				return;
			}
			mConsumables[(slot : Int)].exhaust();
			grayscaleGlyph(slot == 0 ? "use_consumable_one" : "use_consumable_two");
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function openTeamLoot(chestId:UInt) {
		var symbol:String;
		var generation:UInt;
		try {
			destroyTeamLoot();
			if (mView == null) {
				return;
			}
			switch (chestId - 60001) {
				case 0:
					symbol = "UI_teamloot_basic";

				case 1:
					symbol = "UI_teamloot_uncommon";

				case 2:
					symbol = "UI_teamloot_rare";

				case 3:
					symbol = "UI_teamloot_legendary";

				case 4:
					symbol = "UI_teamloot_box_small";

				case 5:
					symbol = "UI_teamloot_box_royal";

				default:
					return;
			}
			generation = mLootGeneration;
			HudArt.convertSymbol(symbol, function(param1:ArtNode) {
				try {
					if (mDestroyed || generation != mLootGeneration || param1 == null || mView == null) {
						return;
					}
					mTeamLoot = ArtView.build(param1, mTicker);
					cast(mView.root, DisplayObjectContainer).addChild(mTeamLoot.root);
					mTeamLoot.root.scaleX = mTeamLoot.root.scaleY = 1.8;
					mTeamLoot.root.x = -550;
					mTeamLoot.root.y = -150;
					cast(mTeamLoot.root, TimelineView).stageRate = false;
					cast(mTeamLoot.root, TimelineView).play(0, true);
					bindBounds(mTeamLoot.root);
					mLootMoving = true;
					mLootTween = mFacade.mTween.tweenMaxTo(mTeamLoot.root, 0.5, {
						"x": -550,
						"onComplete": lootOpened
					});
					mLootTask = mWork.doLater(2, closeTeamLoot);
					invalidateBounds();
				} catch (error:Dynamic) {
					failed(error);
				}
			});
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function lootOpened() {
		mLootTween = null;
		mLootMoving = false;
		invalidateBounds();
	}

	function closeTeamLoot(clock:GameClock) {
		try {
			mLootTask = null;
			if (mTeamLoot == null) {
				return;
			}
			if (mLootTween != null) {
				mFacade.mTween.killTween(mLootTween);
			}
			mLootMoving = true;
			mLootTween = mFacade.mTween.tweenMaxTo(mTeamLoot.root, 0.5, {
				"x": -250,
				"onComplete": lootClosed
			});
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function lootClosed() {
		try {
			mLootMoving = false;
			mLootTween = null;
			if (mTeamLoot != null) {
				cast(mTeamLoot.root, TimelineView).stop();
				mTeamLoot.root.visible = false;
			}
			invalidateBounds();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function destroyTeamLoot() {
		mLootGeneration = mLootGeneration + 1;
		if (mLootTween != null) {
			mFacade.mTween.killTween(mLootTween);
		}
		if (mLootTask != null) {
			mLootTask.destroy();
		}
		mLootTask = null;
		mLootTween = null;
		mLootMoving = false;
		if (mTeamLoot != null) {
			mTeamLoot.dispose();
		}
		mTeamLoot = null;
		invalidateBounds();
	}

	public function showStacks() {
		try {
			mStacksShown = true;
			updateStacks();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function hideStacks() {
		try {
			mStacksShown = false;
			updateStacks();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function offScreenPicChange(playerId:Int, picType:String) {
		try {
			if (mOffScreen != null) {
				mOffScreen.handlePicChange(playerId, picType);
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function showBuffDisplay(buffGO:BuffGameObject) {
		try {
			if (buffGO == null || buffGO.isDestroyed || mBuffs.indexOf(buffGO) >= 0) {
				return;
			}
			mBuffs.push(buffGO);
			if (mView != null) {
				createBuff(buffGO);
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function updateBuffInstance(updatedBuffGO:BuffGameObject) {
		var _loc2_:StarlingBuff = null;
		try {
			_loc2_ = buffView(updatedBuffGO);
			if (_loc2_ != null) {
				_loc2_.updateInstance();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function registerPet(petNPC:NPCGameObject) {
		try {
			mPet = petNPC;
			updatePet();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function unregisterPet(petNPC:NPCGameObject) {
		try {
			if (petNPC == null || mPet != petNPC) {
				return;
			}
			mPet = null;
			if (mPetPortrait != null) {
				mPetPortrait.petDeath();
				if (petNPC.gmNpc.RespawnT <= 0) {
					mPetPortrait.dispose();
					mPetPortrait = null;
				}
			}
			invalidateBounds();
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function syncBusterPrompt() {
		var _loc1_:String = null;
		var _loc3_:StarlingText = null;
		var _loc2_ = mFacade.steamInputManager.hasGlyphForAction("use_dungeon_buster");
		mBusterPromptOffset = _loc2_ ? -5 : 0;
		final __ax4_iter_210 = Vector.ofArray([
			"UI_buster_active.buster_activated.up.db_pressbutton_text",
			"UI_buster_active.buster_activated.over.mc.db_pressbutton_text"
		]);
		if (checkNullIteratee(__ax4_iter_210))
			for (_tmp_ in __ax4_iter_210) {
				_loc1_ = _tmp_;
				if (Std.isOfType(node(_loc1_), ArtDisplay)) {
					cast(node(_loc1_), ArtDisplay).setHudOffset(mBusterPromptOffset, 0);
				}
				if (_loc2_) {
					text(_loc1_, Locale.getString("PRESS_BUSTER_BUTTON_CONTROLLER"), true);
				} else if (mFacade.keyBindings != null) {
					text(_loc1_, Locale.getString("PRESS_BUSTER_BUTTON_KEYBOARD") + mFacade.keyBindings.displayNameFor("useDungeonBuster"), true);
				} else {
					_loc3_ = ASCompat.reinterpretAs(node(_loc1_), StarlingText);
					if (_loc3_ != null) {
						_loc3_.mode = "baked";
						_loc3_.setText(_loc3_.art.initialText);
					}
				}
			}
	}

	function initializeBuster() {
		hideBuster();
		mBusterButton.setHover(false);
		mBusterButton.setPressed(false);
		var _loc1_ = ASCompat.coerce(mFacade.gameMaster.attackByConstant.itemFor(mHeroOwner.gMHero.DBuster1), gameMasterDictionary.GMAttack);
		var _loc2_ = _loc1_ != null ? GameMasterLocale.getGameMasterSubString("ATTACK_BUSTER_NAME", _loc1_.Constant).toUpperCase() : "BUSTER!";
		text("UI_buster_active.buster_activated.up.name_mc.name_label", _loc2_, true);
		text("UI_buster_active.buster_activated.over.mc.name_label", _loc2_, true);
		text("UI_buster_glow.buster_text.buster_text_label.name_label", _loc2_, true);
		syncBusterPrompt();
		mBusterMax = mHeroOwner.maxBusterPoints;
		applyBusterPulse();
		setBusterPoints(mHeroOwner.dungeonBusterPoints);
	}

	function busterChanged(event:BusterPointsEvent) {
		var _loc2_ = (0 : UInt);
		try {
			mBusterMax = event.maxBusterPoints;
			_loc2_ = event.busterPoints;
			setBusterPoints(_loc2_);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function setBusterPoints(current:UInt) {
		try {
			if (mBuster == null) {
				return;
			}
			mBuster.value = mBusterMax > 0 ? current / mBusterMax : 0;
			if (current >= mBusterMax) {
				showBustSign();
			} else {
				hideBuster();
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	public function showBustSign() {
		try {
			mBusterReady = true;
			if (mBusterBanner == null) {
				busterReady();
				return;
			}
			visible("UI_buster_glow", true);
			mBusterBanner.stageRate = false;
			mBusterBanner.play(1, false, busterReady);
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function busterReady() {
		try {
			if (!mBusterReady) {
				return;
			}
			visible("UI_buster_glow", false);
			visible("UI_buster_active", true);
			visible("UI_buster_active.buster_activated", true);
			if (mBusterButton != null) {
				mBusterButton.restartState();
			}
			visible("UI_buster.buster_activated_glow", true);
			if (mBusterPulse != null && !mBusterPulse.isPlaying) {
				mBusterPulse.play(0, true);
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function applyBusterPulse() {
		if (mBusterPulse == null) {
			return;
		}
		mBusterPulse.stageRate = false;
		pulseHiddenTiming(mBusterPulse);
		if (mBusterPulse.visible) {
			mBusterPulse.play(0, true);
		}
	}

	function pulseHiddenTiming(display:DisplayObject) {
		var _loc3_ = 0;
		if (Std.isOfType(display, TimelineView)) {
			cast(display, TimelineView).advanceWhileHidden = false;
		}
		var _loc2_ = ASCompat.reinterpretAs(display, DisplayObjectContainer);
		if (_loc2_ != null) {
			_loc3_ = 0;
			while (_loc3_ < _loc2_.numChildren) {
				pulseHiddenTiming(_loc2_.getChildAt(_loc3_));
				_loc3_++;
			}
		}
	}

	function hideBuster() {
		mBusterReady = false;
		if (mBusterBanner != null) {
			mBusterBanner.stop();
		}
		visible("UI_buster_glow", false);
		visible("UI_buster_active", false);
		visible("UI_buster.buster_activated_glow", false);
		if (mBusterPulse != null) {
			mBusterPulse.stop();
		}
	}

	public function handleBusterBarClickEvent() {
		try {
			if (mHeroOwner != null && mHeroOwner.dungeonBusterPoints >= mHeroOwner.maxBusterPoints) {
				mEvents.dispatchEvent(new DungeonBusterControlActivatedEvent());
			}
		} catch (error:Dynamic) {
			failed(error);
		}
	}

	function updateWeapons() {
		var _loc1_ = 0;
		if (mHeroOwner == null) {
			return;
		}
		_loc1_ = 0;
		while (_loc1_ < mWeapons.length) {
			mWeapons[_loc1_].equipWeapon(mHeroOwner,
				ASCompat.coerce(_loc1_ < mHeroOwner.weaponControllers.length
					&& mHeroOwner.weaponControllers[_loc1_] != null ? mHeroOwner.weaponControllers[_loc1_].weapon : null,
					combat.weapon.WeaponGameObject));
			_loc1_++;
		}
	}

	function updateConsumables() {
		var _loc1_ = 0;
		if (mHeroOwner == null) {
			return;
		}
		_loc1_ = 0;
		while (_loc1_ < mConsumables.length) {
			mConsumables[_loc1_].equipConsumable(mHeroOwner,
				ASCompat.coerce(_loc1_ < mHeroOwner.consumables.length ? mHeroOwner.consumables[_loc1_] : null, combat.weapon.ConsumableWeaponGameObject));
			_loc1_++;
		}
		restoreGlyph("use_consumable_one");
		restoreGlyph("use_consumable_two");
	}

	function restoreGlyph(action:String) {
		if (action == "use_consumable_one" && mConsumables.length > 0 && !mConsumables[0].button.enabled || action == "use_consumable_two"
			&& mConsumables.length > 1 && !mConsumables[1].button.enabled) {
			grayscaleGlyph(action);
			return;
		}
		var _loc2_ = ASCompat.dynamicAs(mStarlingGlyphs[action], Image);
		var _loc3_ = ASCompat.dynamicAs(mGlyphTextures[mGlyphPaths[action]], Texture);
		if (_loc2_ != null && _loc3_ != null) {
			_loc2_.texture = _loc3_;
		}
	}

	function updateStacks() {
		if (mStacks != null) {
			mStacks.root.visible = mShown && mStacksShown;
		}
		invalidateBounds();
	}

	function updateOffScreen() {
		if (mOffScreen != null) {
			mOffScreen.dispose();
		}
		mOffScreen = ASCompat.coerce(mView != null
			&& mHeroOwner != null ? new StarlingOffScreenManager(mFacade, mTicker, ASCompat.reinterpretAs(mView.root, DisplayObjectContainer), mHeroOwner,
				invalidateArrowBounds, mCut) : null,
			uI.hud.starlingConverted.StarlingOffScreenManager);
		if (mOffScreen != null) {
			bindBounds(mRoot);
		}
	}

	function buffView(buffGO:BuffGameObject):StarlingBuff {
		var _loc2_:StarlingBuff = null;
		final __ax4_iter_211 = mBuffViews;
		if (checkNullIteratee(__ax4_iter_211))
			for (_tmp_ in __ax4_iter_211) {
				_loc2_ = _tmp_;
				if (_loc2_.buff == buffGO) {
					return _loc2_;
				}
			}
		return null;
	}

	function createBuff(buffGO:BuffGameObject) {
		if (buffGO == null || buffGO.isDestroyed) {
			return;
		}
		var _loc2_ = new StarlingBuff(mFacade, mTicker, mInput, mRoot, buffGO, invalidateBounds);
		mBuffViews.push(_loc2_);
		bindBounds(_loc2_.root);
		resetBuffButtonPositions();
	}

	function resetBuffButtonPositions() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mBuffViews.length) {
			mBuffViews[_loc1_].position(_loc1_, mHudType == 1);
			_loc1_++;
		}
	}

	function updateBuffs() {
		var _loc1_ = 0;
		var _loc2_ = 0;
		_loc1_ = 0;
		while (_loc1_ < mBuffViews.length) {
			if (mBuffViews[_loc1_].buff.isDestroyed) {
				_loc2_ = mBuffs.indexOf(mBuffViews[_loc1_].buff);
				if (_loc2_ >= 0) {
					mBuffs.removeAt(_loc2_);
				}
				mBuffViews[_loc1_].dispose();
				mBuffViews.removeAt(_loc1_--);
			}
			_loc1_++;
		}
	}

	function updatePet() {
		if (mPetPortrait != null) {
			mPetPortrait.dispose();
			mPetPortrait = null;
		}
		if (mView == null || !mShown || mPetModel == null || !mFacade.dbConfigManager.getConfigBoolean("want_pets", true)) {
			return;
		}
		mPetPortrait = new StarlingPetPortrait(mFacade, mView, mTicker, mInput, mRoot, mPetModel, mPet, invalidateBounds);
	}

	function buildModifiers(model:MovieClip) {
		var _loc5_ = 0;
		var _loc3_:String = null;
		var _loc2_:StarlingButton = null;
		var _loc6_:MovieClip = null;
		var _loc4_:StarlingTooltip = null;
		_loc5_ = 1;
		while (_loc5_ <= 4) {
			_loc3_ = "floor_modifier0" + _loc5_;
			_loc2_ = new StarlingButton(mView, _loc3_, mRoot);
			mModifierButtons.push(_loc2_);
			mModifierWidths.push(_loc2_.root.width);
			_loc2_.clearStateArt();
			_loc6_ = ASCompat.coerce((model : ASAny)["tooltip_modifier0" + _loc5_], flash.display.MovieClip);
			mModifierModels.push(_loc6_);
			_loc4_ = new StarlingTooltip(mFacade, _loc2_.root, mRoot, _loc6_, 0, new Point(0, -15));
			mTooltips.push(_loc4_);
			_loc2_.rollOverCallback = _loc4_.rollOver;
			_loc2_.rollOutCallback = _loc4_.hide;
			mInput.add(_loc2_, false);
			_loc5_++;
		}
	}

	function setDungeonModifiers() {
		var _loc2_ = 0;
		var _loc1_:StarlingHudIcon = null;
		final __ax4_iter_212 = mModifierIcons;
		if (checkNullIteratee(__ax4_iter_212))
			for (_tmp_ in __ax4_iter_212) {
				_loc1_ = _tmp_;
				_loc1_.dispose();
			}
		mModifierIcons.length = 0;
		_loc2_ = 0;
		while (_loc2_ < mModifierButtons.length) {
			visible("floor_modifier0" + (_loc2_ + 1), false);
			_loc2_++;
		}
		var _loc3_ = mHeroOwner.distributedDungeonFloor.activeGMDungeonModifiers;
		_loc2_ = 0;
		while (_loc2_ < _loc3_.length && _loc2_ < mModifierButtons.length) {
			setupModifier(_loc2_, _loc3_[_loc2_]);
			_loc2_++;
		}
	}

	function setupModifier(index:Int, modifier:DungeonModifierHelper) {
		var root:DisplayObjectContainer;
		var child:DisplayObject;
		var i:Int;
		var icon:StarlingHudIcon;
		var button = mModifierButtons[index];
		var tooltip = mModifierModels[index];
		TextUtil.setText(ASCompat.coerce((tooltip : ASAny).title_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_NAME", modifier.GMDungeonMod.Constant));
		TextUtil.setText(ASCompat.coerce((tooltip : ASAny).description_label, flash.text.TextField),
			GameMasterLocale.getGameMasterSubString("DUNGEON_MODIFIER_DESCRIPTION", modifier.GMDungeonMod.Constant));
		root = ASCompat.reinterpretAs(button.root, DisplayObjectContainer);
		i = 0;
		while (i < root.numChildren) {
			child = root.getChildAt(i);
			if (Std.isOfType(child, ArtDisplay)) {
				cast(child, ArtDisplay).setHudVisibility(false);
			} else {
				child.visible = false;
			}
			i = i + 1;
		}
		icon = new StarlingHudIcon(mFacade, mTicker, root, function() {
			try {
				visible("floor_modifier0" + (index + 1), true);
			} catch (error:Dynamic) {
				failed(error);
			}
		});
		mModifierIcons.push(icon);
		icon.load(modifier.GMDungeonMod.IconFilepath, modifier.GMDungeonMod.IconName, 1, 1, mModifierWidths[index]);
	}

	public function petPortraitState():ASObject {
		var _loc4_:ASAny;
		var _loc1_:NPCGameObject = null;
		try {
			_loc1_ = ASCompat.coerce(mPetPortrait != null ? mPetPortrait.petNPCGameObject : null, distributedObjects.NPCGameObject);
			return {
				"present": mPetPortrait != null,
				"hasPet": _loc1_ != null,
				"npcId": (_loc1_ != null ? _loc1_.id : 0),
				"isDead": mPetPortrait != null && mPetPortrait.isDead};
		} catch (error:Dynamic) {
			failed(error);
			_loc4_ = null;
		}
		return _loc4_;
	}
}
