package town;

import account.AvatarInfo;
import account.StoreServicesController;
import brain.assetRepository.AssetLoadingComponent;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.render.MovieClipRenderController;
import brain.uI.UIButton;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import brain.jsonRPC.JSONRPCService;
import dBGlobals.DBGlobal;
import events.XPBonusEvent;
import facade.DBFacade;
import facade.Locale;
import facade.TrickleCacheLoader;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMSkin;
import settings.SettingsPopup;
import steamInput.OnSteamInputButtonReleasedEvent;
import uI.dailyRewards.UIDailyRewards;
import uI.gifting.UIGift;
import uI.leaderboard.UILeaderboard;
import uI.popup.DBUIMoviePopup;
import uI.popup.DBUIOneButtonPopup;
import uI.popup.DBUIPopup;
import uI.popup.UIDragonKnightUpsellPopup;
import uI.popup.UIFlaggedPopup;
import uI.popup.UIWhatsNewPopup;
import uI.UILevelUpPostController;
import uI.UIPagingPanel;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.geom.Point;
import flash.net.URLRequest;

class HomeState extends TownSubState {
	public static inline final NAME = "HomeState";

	public static inline final ACTIVE_AVATAR_CHANGED_EVENT = "ACTIVE_AVATAR_CHANGED_EVENT";

	static inline final POPUP_DELAY_TIME:Float = 0.5;

	static inline final COLISEUM_UNLOCK_LEVEL = (100 : UInt);

	public static var mHasPonderedMOD:Bool = false;

	var mBattleButton:UIButton;

	var mTavernButton:UIButton;

	var mInventoryButton:UIButton;

	var mSkillsButton:UIButton;

	var mSkillsButtonLocked:UIButton;

	var mTrainButton:UIButton;

	var mShopButton:UIButton;

	var mGiftButton:UIButton;

	var mRewardButton:UIButton;

	var mNewsButton:UIButton;

	var mCreditsButton:UIButton;

	var mOptionsButton:UIButton;

	var mSettingsPopup:SettingsPopup;

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

	var mOptionsKeyTask:Task;

	var mUILeaderboard:UILeaderboard;

	var mNewsStories:Vector<MessageOfTheDay>;

	var mNewsPagination:UIPagingPanel;

	var mNewsCurrentPage:UInt = 0;

	var mNewsTotalPages:UInt = 0;

	var mNewsPopUp:DBUIPopup;

	public function new(dbFacade:DBFacade, townStateMachine:TownStateMachine) {
		super(dbFacade, townStateMachine, "HomeState");
		mEventComponent = new EventComponent(mDBFacade);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "HomeState");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		var _loc3_ = mDBFacade.settingsModel;
		mNewsStories = new Vector<MessageOfTheDay>();
	}

	function toggleSettingsPopup() {
		if (mSettingsPopup != null) {
			mSettingsPopup.destroy();
			mSettingsPopup = null;
			return;
		}
		mSettingsPopup = new SettingsPopup(mDBFacade, onSettingsPopupClosed);
		MemoryTracker.track(mSettingsPopup, "SettingsPopup - created in HomeState.toggleSettingsPopup()");
	}

	function onSettingsPopupClosed() {
		mSettingsPopup = null;
	}

	function checkOptionsKey(gameClock:GameClock) {
		if (mDBFacade.keyBindings.wasReleased("openOptionsMenu")) {
			toggleSettingsFromShortcut();
		}
	}

	function onSteamInputButtonReleased(event:OnSteamInputButtonReleasedEvent) {
		if (event.actionName == "menu_options") {
			toggleSettingsFromShortcut();
		}
	}

	function toggleSettingsFromShortcut() {
		var _loc1_ = mSettingsPopup != null ? SettingsPopup.isTopMenu(mDBFacade) : mDBFacade.menuNavigationController.getTopUILayer() == "TOWN_MENU";
		if (_loc1_) {
			toggleSettingsPopup();
		}
	}

	override public function destroy() {
		EventListeners.remove(mDBFacade.stageRef, "keyDown", openDaily);
		if (mDailyRewardsPopup != null) {
			mDailyRewardsPopup.destroy();
			mDailyRewardsPopup = null;
		}
		mRenderer.destroy();
		mBattleButton.destroy();
		mTavernButton.destroy();
		mInventoryButton.destroy();
		if (mSkillsButtonLocked != null) {
			mSkillsButtonLocked.destroy();
			mSkillsButtonLocked = null;
		}
		mTrainButton.destroy();
		mShopButton.destroy();
		mGiftButton.destroy();
		mCreditsButton.destroy();
		mOptionsButton.destroy();
		if (mEventComponent != null) {
			mEventComponent.destroy();
		}
		mEventComponent = null;
		if (mLogicalWorkComponent != null) {
			mLogicalWorkComponent.destroy();
		}
		mLogicalWorkComponent = null;
		if (mUILeaderboard != null) {
			mUILeaderboard = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
		}
		mAssetLoadingComponent = null;
		if (mSettingsPopup != null) {
			mSettingsPopup.destroy();
			mSettingsPopup = null;
		}
		mDBFacade.menuNavigationController.popLayer("TOWN_MENU");
		super.destroy();
	}

	override function setupState() {
		super.setupState();
		mBattleButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_button_battle_instance, flash.display.MovieClip));
		mBattleButton.releaseCallback = mTownStateMachine.enterMapState;
		mInventoryButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_inventory_button_instance, flash.display.MovieClip));
		mInventoryButton.releaseCallback = mTownStateMachine.enterInventoryState;
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_inventory_button_instance.up.label, flash.text.TextField), "INVENTORY_BUILDING");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_inventory_button_instance.over.label, flash.text.TextField), "INVENTORY_BUILDING");
		mInventoryAlertUp = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_inventory_button_instance.up.alert_icon, flash.display.MovieClip);
		mInventoryAlertOver = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_inventory_button_instance.over.alert_icon, flash.display.MovieClip);
		mInventoryAlertUp.visible = false;
		mInventoryAlertOver.visible = false;
		mTavernButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance, flash.display.MovieClip));
		mTavernButton.releaseCallback = mTownStateMachine.enterTavernState;
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance.up.label, flash.text.TextField), "TAVERN_BUILDING");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance.over.label, flash.text.TextField), "TAVERN_BUILDING");
		mTavernAlertUp = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance.up.alert_icon, flash.display.MovieClip);
		mTavernAlertOver = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance.over.alert_icon, flash.display.MovieClip);
		mTavernAlertUp.visible = false;
		mTavernAlertOver.visible = false;
		mTrainButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_train_button_instance, flash.display.MovieClip));
		mTrainButton.releaseCallback = mTownStateMachine.enterTrainState;
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_train_button_instance.up.label, flash.text.TextField), "TRAINING_BUILDING");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_train_button_instance.over.label, flash.text.TextField), "TRAINING_BUILDING");
		mTrainAlertUp = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_train_button_instance.up.alert_icon, flash.display.MovieClip);
		mTrainAlertOver = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_train_button_instance.over.alert_icon, flash.display.MovieClip);
		mTrainAlertUp.visible = false;
		mTrainAlertOver.visible = false;
		mCreditsButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).news, flash.display.MovieClip));
		mCreditsButton.releaseCallback = mTownStateMachine.enterCreditState;
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).news.up.credit_mc.label, flash.text.TextField), "CREDITS_BUILDING");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).news.over.credit_mc.label, flash.text.TextField), "CREDITS_BUILDING");
		mSkillsButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_skills_button_instance, flash.display.MovieClip));
		mSkillsButton.releaseCallback = mTownStateMachine.enterSkillsState;
		mSkillsAlertUp = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_skills_button_instance.up.alert_icon, flash.display.MovieClip);
		mSkillsAlertOver = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_skills_button_instance.over.alert_icon, flash.display.MovieClip);
		mSkillsAlertUp.visible = false;
		mSkillsAlertOver.visible = false;
		mSkillsButtonLocked = new UIButton(mDBFacade,
			ASCompat.coerce((mRootMovieClip : ASAny).townScreen_coliseumClosed_button_instance, flash.display.MovieClip));
		mSkillsButtonLocked.releaseCallback = showColiseumClosedPopup;
		mSkillsButtonLocked.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_sale_instance, "visible", false);
		mShopButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance, flash.display.MovieClip));
		mShopButton.releaseCallback = mTownStateMachine.enterShopState;
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance.up.label, flash.text.TextField), "SHOP_BUILDING");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance.over.label, flash.text.TextField), "SHOP_BUILDING");
		mShopAlertUp = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance.up.alert_icon, flash.display.MovieClip);
		mShopAlertOver = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance.over.alert_icon, flash.display.MovieClip);
		mShopAlertUp.visible = false;
		mShopAlertOver.visible = false;
		mShopNewUp = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance.up.new_icon, flash.display.MovieClip);
		mShopNewOver = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_instance.over.new_icon, flash.display.MovieClip);
		mGiftButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).gift, flash.display.MovieClip));
		mGiftButton.releaseCallback = function() {
			mGiftPopup = new UIGift(mDBFacade, mRootMovieClip, giftPopupCloseCallback, giftCallbackToFriendManager);
			mGiftButton.enabled = false;
		};
		EventListeners.add(mDBFacade.stageRef, "keyDown", openDaily);
		if (!mDBFacade.mCheckedDailyReward) {
			mDBFacade.mCheckedDailyReward = true;
			mDailyRewardsPopup = new UIDailyRewards(mDBFacade, rewardPopupCloseCallback, false);
		}
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).gift.up.label, flash.text.TextField), "GIFT_BUILDING");
		Locale.setText(ASCompat.coerce((mRootMovieClip : ASAny).gift.over.label, flash.text.TextField), "GIFT_BUILDING");
		mGiftAlertUp = ASCompat.coerce((mRootMovieClip : ASAny).gift.up.alert_icon, flash.display.MovieClip);
		mGiftAlertOver = ASCompat.coerce((mRootMovieClip : ASAny).gift.over.alert_icon, flash.display.MovieClip);
		mGiftAlertUp.visible = false;
		mGiftAlertOver.visible = false;
		mOptionsButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).options_button, flash.display.MovieClip));
		mOptionsButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mOptionsButton.releaseCallback = toggleSettingsPopup;
		mRenderer = new MovieClipRenderController(mDBFacade, mRootMovieClip);
		loadActiveAvatarIcon(new Event("ACTIVE_AVATAR_CHANGED_EVENT"));
		mEventComponent.addListener("ACTIVE_AVATAR_CHANGED_EVENT", loadActiveAvatarIcon);
		this.refreshAlerts();
		mTavernButton.isToTheLeftOf(mBattleButton);
		mTavernButton.isAbove(mGiftButton);
		mBattleButton.isToTheLeftOf(mInventoryButton);
		mBattleButton.isAbove(mShopButton);
		mInventoryButton.isAbove(mCreditsButton);
		mInventoryButton.rightNavigation = mOptionsButton;
		mOptionsButton.downNavigation = mCreditsButton;
		mCreditsButton.rightNavigation = mOptionsButton;
		mGiftButton.isToTheLeftOf(mTrainButton);
		mTrainButton.isToTheLeftOf(mShopButton);
		mTavernButton.leftNavigation = mGiftButton;
		mTrainButton.upNavigation = mTavernButton;
		mSkillsButton.upNavigation = mInventoryButton;
		mSkillsButtonLocked.upNavigation = mInventoryButton;
		refreshColiseumLock();
		setupHeaderLinks();
		mDBFacade.menuNavigationController.pushNewLayer("TOWN_MENU", mTownStateMachine.townHeader.determineCallback, mBattleButton, mBattleButton,
			focusPreviousLeaderboardFriend, focusNextLeaderboardFriend);
		mEventComponent.addListener("LEADERBOARD_INITIALIZED_EVENT", setupFriendLinks);
		setupFriendLinks();
	}

	public function setupFriendLinks(event:Event = null) {
		if (mUILeaderboard == null) {
			mUILeaderboard = mTownStateMachine.leaderboard;
		}
		if (mUILeaderboard == null) {
			return;
		}
		if (!mUILeaderboard.initialized) {
			return;
		}
		mEventComponent.removeListener("LEADERBOARD_INITIALIZED_EVENT");
		mUILeaderboard.setupNavigationlinks();
		linkTownButtonsToLeaderboard();
		mGiftButton.clearDownNavigation();
		mGiftButton.downNavigation = mUILeaderboard.getManageFriendsButton;
	}

	function linkTownButtonsToLeaderboard() {
		if (mUILeaderboard == null || !mUILeaderboard.initialized) {
			return;
		}
		mUILeaderboard.linkTownButtons([mTrainButton, mShopButton, coliseumButton]);
	}

	@:isVar var coliseumButton(get, never):UIButton;

	function get_coliseumButton():UIButton {
		return mSkillsButton.enabled ? mSkillsButton : mSkillsButtonLocked;
	}

	function focusPreviousLeaderboardFriend() {
		if (mUILeaderboard != null) {
			mUILeaderboard.focusPreviousFriendSlot();
		}
	}

	function focusNextLeaderboardFriend() {
		if (mUILeaderboard != null) {
			mUILeaderboard.focusNextFriendSlot();
		}
	}

	override function setupHeaderLinks() {
		super.resetHeaderLinks();
		super.setupHeaderLinks();
		mTownStateMachine.townHeader.addCoinButton.isAbove(mTavernButton);
		mTownStateMachine.townHeader.addGemButton.isAbove(mBattleButton);
		mTownStateMachine.townHeader.closeButton.isAbove(mInventoryButton);
		mTownStateMachine.townHeader.closeButton.isToTheLeftOf(mOptionsButton);
	}

	function refreshHeaderNavigationLinks() {
		super.resetHeaderLinks();
		super.setupHeaderLinks();
		mTownStateMachine.townHeader.addCoinButton.downNavigation = mTavernButton;
		mTownStateMachine.townHeader.addGemButton.downNavigation = mBattleButton;
		mTownStateMachine.townHeader.closeButton.downNavigation = mInventoryButton;
		mTownStateMachine.townHeader.closeButton.rightNavigation = mOptionsButton;
	}

	function openDaily(event:KeyboardEvent) {
		if (event.keyCode == 36 && mDBFacade != null) {
			mDailyRewardsPopup = new UIDailyRewards(mDBFacade, rewardPopupCloseCallback, true);
			EventListeners.remove(mDBFacade.stageRef, "keyDown", openDaily);
		}
	}

	public function animateEntry() {
		if (mTownStateMachine.townHeader.rootMovieClip != null) {
			if (mDBFacade.featureFlags.getFlagValue("want-town-animations")) {
				mTownStateMachine.townHeader.rootMovieClip.visible = false;
				mLogicalWorkComponent.doLater(0.20833333333333334, function(param1:GameClock) {
					mTownStateMachine.townHeader.animateHeader();
				});
			}
		}
	}

	function refreshColiseumLock() {
		if (mSkillsButton == null || mSkillsButtonLocked == null) {
			return;
		}
		var _loc1_ = tryUnlockColiseum();
		mSkillsButton.visible = _loc1_;
		mSkillsButton.enabled = _loc1_;
		mSkillsButtonLocked.visible = !_loc1_;
		mSkillsButtonLocked.enabled = !_loc1_;
		mShopButton.clearRightNavigation();
		mCreditsButton.clearLeftNavigation();
		mCreditsButton.clearDownNavigation();
		mShopButton.isToTheLeftOf(coliseumButton);
		coliseumButton.isToTheLeftOf(mCreditsButton);
		mCreditsButton.downNavigation = coliseumButton;
		linkTownButtonsToLeaderboard();
	}

	function tryUnlockColiseum():Bool {
		if (mDBFacade.dbAccountInfo.hasAttribute("hasReachedLevel100")) {
			return true;
		}
		if (!hasHeroAtColiseumUnlockLevel()) {
			return false;
		}
		mDBFacade.dbAccountInfo.alterAttribute("hasReachedLevel100", "1");
		return true;
	}

	function hasHeroAtColiseumUnlockLevel():Bool {
		var _loc2_:AvatarInfo = null;
		var _loc4_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars;
		if (_loc4_ == null) {
			return false;
		}
		var _loc1_ = _loc4_.keysToArray();
		var _loc3_:ASAny;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc3_ = _tmp_;
				_loc2_ = ASCompat.dynamicAs(_loc4_.itemFor(_loc3_), AvatarInfo);
				if (_loc2_ != null && _loc2_.cloutLevel >= 100) {
					return true;
				}
			}
		return false;
	}

	function showColiseumClosedPopup() {
		var _loc1_ = new DBUIOneButtonPopup(mDBFacade, "COLISEUM_CLOSED_POPUP", Locale.getString("COLISEUM_CLOSED_TITLE"),
			Locale.getString("COLISEUM_CLOSED_MESSAGE"), Locale.getString("OK"), null);
		MemoryTracker.track(_loc1_, "DBUIOneButtonPopup - created in HomeState.showColiseumClosedPopup()");
	}

	function refreshAlerts() {
		var _loc2_ = false;
		var _loc1_ = false;
		if (mRootMovieClip != null) {
			mTavernAlertUp.visible = mTavernAlertOver.visible = this.tavernNeedsAttention;
			mTrainAlertUp.visible = mTrainAlertOver.visible = this.trainingNeedsAttention;
			mSkillsAlertUp.visible = mSkillsAlertOver.visible = this.skillsNeedsAttention;
			mShopAlertUp.visible = mShopAlertOver.visible = this.shopNeedsAttention;
			mInventoryAlertUp.visible = mInventoryAlertOver.visible = this.inventoryNeedsAttention;
			checkGiftAlert();
			_loc2_ = mDBFacade.gameMaster.storeHasSaleNow();
			if (_loc2_) {
				ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_sale_instance, "visible", true);
				ASCompat.setProperty((mRootMovieClip : ASAny).townScreen_shop_button_instance, "visible", false);
				mShopButton = new UIButton(mDBFacade, ASCompat.coerce((mRootMovieClip : ASAny).townScreen_shop_button_sale_instance, flash.display.MovieClip));
				mShopButton.releaseCallback = mTownStateMachine.enterShopState;
			}
			_loc1_ = mDBFacade.gameMaster.storeHasNewOffers();
			mShopNewUp.visible = _loc1_;
			mShopNewOver.visible = _loc1_;
		}
	}

	function tryShowBetaRewardsPopup():Bool {
		if (mDBFacade.dbAccountInfo.dbAccountParams.hasBetaPlayerParam()) {
			if (mDBFacade.dbAccountInfo.dbAccountParams.hasBetaRewardsParam()) {
				return false;
			}
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
				function(param1:brain.assetRepository.SwfAsset) {
					var swfAsset = param1;
					var popup = new DBUIOneButtonPopup(mDBFacade, "BETA_REWARDS_POPUP", Locale.getString("BETA_REWARDS_POPUP_TITLE"),
						Locale.getString("BETA_REWARDS_POPUP_MESSAGE"), Locale.getString("BETA_REWARDS_POPUP_BUTTON"), function() {}, true, null,
						"popup_beta_thanks");
					MemoryTracker.track(popup, "DBUIOneButtonPopup - created in HomeState.tryShowBetaRewardsPopup()");
				});
			mDBFacade.dbAccountInfo.dbAccountParams.setBetaRewardsParam();
			return true;
		}
		return false;
	}

	function tryShowWhatsNewPopup(callback:ASFunction) {
		this.getWhatsNewRPC(callback);
	}

	function getWhatsNewCallback(gameAction:String):ASFunction {
		var callback:ASFunction;
		switch (gameAction) {
			case "STORE" | "SHOP":
				callback = function() {
					mTownStateMachine.enterShopState();
				};

			case "BATTLE" | "MAP":
				callback = function() {
					mTownStateMachine.enterMapState();
				};

			case "INVENTORY":
				callback = function() {
					mTownStateMachine.enterInventoryState();
				};

			case "TRAINING":
				callback = function() {
					mTownStateMachine.enterTrainState();
				};

			case "GEMS":
				callback = function() {
					StoreServicesController.showCashPage(mDBFacade, "whatsNewPopup");
				};

			case "TAVERN":
				callback = function() {
					mTownStateMachine.enterTavernState();
				};

			case "CLOSE" | "":
				callback = null;

			default:
				Logger.warn("Ignoring MOD game_action: action not recognized: " + gameAction);
				callback = null;
		}
		return callback;
	}

	function getWhatsNewRPC(callback:ASFunction = null, skipPonder:Bool = false) {
		var platformParameter:UInt;
		var rpcFunc:ASFunction;
		var parseResults:ASFunction;
		var firstLoginConfig = mDBFacade.dbConfigManager.getConfigBoolean("FirstLoginToday", true);
		if (!skipPonder) {
			if (mHasPonderedMOD || !firstLoginConfig) {
				return;
			}
		}
		mHasPonderedMOD = true;
		platformParameter = (ASCompat.floatToInt(mDBFacade.dbConfigManager.networkId) : UInt);
		rpcFunc = JSONRPCService.getFunction("getmod", mDBFacade.rpcRoot + "modrpc");
		parseResults = function(param1:ASAny) {
			var _loc5_:ASObject;
			var _loc4_:String = null;
			var _loc2_:String = null;
			var _loc3_:MessageOfTheDay = null;
			if (mDBFacade == null) {
				return;
			}
			if (Std.isOfType(param1, Array) && ASCompat.toNumberField(param1, "length") > 0) {
				if (checkNullIteratee(param1))
					for (_tmp_ in param1) {
						_loc5_ = _tmp_;
						_loc4_ = ASCompat.toString(_loc5_.game_action).toUpperCase();
						_loc2_ = Locale.getString("WHATS_NEW_" + _loc4_);
						_loc3_ = new MessageOfTheDay(_loc5_.layout_type, _loc5_.headline, _loc5_.body, _loc5_.image_url, _loc2_, getWhatsNewCallback(_loc4_),
							_loc5_.web_link_name, _loc5_.web_link_url);
						mNewsStories.push(_loc3_);
					}
				if (mNewsStories.length > 0) {
					displayNews((0 : UInt));
				}
				if (callback != null) {
					callback(true);
				}
			} else if (callback != null) {
				callback(false);
			}
			mNewsTotalPages = (mNewsStories.length : UInt);
		};
		rpcFunc(platformParameter, parseResults);
	}

	function createNewsUI() {
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var _loc2_ = param1.getClass("pagination_fm");
				mNewsPagination = new UIPagingPanel(mDBFacade, mNewsTotalPages, ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip),
					param1.getClass("pagination_button"), setCurrentNewsPage);
				MemoryTracker.track(mNewsPagination, "UIPagingPanel - created in HomeState.showNewsStories()");
				if (mNewsStories.length > 0) {
					displayNews((0 : UInt), true);
				}
			});
	}

	function displayNews(newsNum:UInt, showPagination:Bool = false) {
		var paginationEmptyMC:MovieClip;
		var parentPos:Point;
		var layoutClassName:String;
		if (mNewsStories[(newsNum : Int)].imageType == 2) {
			mNewsPopUp = new DBUIMoviePopup(mDBFacade, "whatsnew_popup_movie", mNewsStories[(newsNum : Int)].title, mNewsStories[(newsNum : Int)].message,
				mNewsStories[(newsNum : Int)].imageURL + "?version=3&rel=0", mNewsStories[(newsNum : Int)].mainText, function() {
					if (mNewsStories[(newsNum : Int)].mainCallback != null) {
						mNewsStories[(newsNum : Int)].mainCallback();
					}
					if (showPagination) {
						mNewsPagination.destroy();
						mNewsPagination = null;
					}
			}, 426, 240, showPagination);
			MemoryTracker.track(mNewsPopUp, "DBUIMoviePopup - created in HomeState.displayNews()");
			if (showPagination) {
				paginationEmptyMC = mNewsPopUp.getPagination();
				paginationEmptyMC.addChild(mNewsPagination.root);
			}
		} else {
			layoutClassName = mNewsStories[(newsNum : Int)].imageType == 0 ? "whatsnew_popup" : "whatsnew_popup_landscape";
			mNewsPopUp = new UIWhatsNewPopup(mDBFacade, layoutClassName, mNewsStories[(newsNum : Int)].title, mNewsStories[(newsNum : Int)].message,
				mNewsStories[(newsNum : Int)].imageURL, mNewsStories[(newsNum : Int)].mainText, function() {
					if (mNewsStories[(newsNum : Int)].mainCallback != null) {
						mNewsStories[(newsNum : Int)].mainCallback();
					}
					if (showPagination) {
						mNewsPagination.destroy();
						mNewsPagination = null;
					}
			}, mNewsStories[(newsNum : Int)].webText,
				mNewsStories[(newsNum : Int)].webURL, showPagination);
			MemoryTracker.track(mNewsPopUp, "UIWhatsNewPopup - created in HomeState.displayNews()");
			if (showPagination) {
				paginationEmptyMC = mNewsPopUp.getPagination();
				paginationEmptyMC.addChild(mNewsPagination.root);
			}
		}
	}

	function refreshPagination(page:UInt) {
		mNewsPagination.currentPage = (ASCompat.floatToInt(mNewsTotalPages != 0 ? (ASCompat.floatToInt(Math.min((mNewsTotalPages : Float) - 1,
			page)) : UInt) : (0 : UInt)) : UInt);
		mNewsPagination.numPages = mNewsTotalPages;
		mNewsPagination.visible = true;
	}

	function setCurrentNewsPage(page:UInt) {
		mNewsCurrentPage = page;
		refreshPagination(page);
		if (mNewsPopUp != null) {
			mNewsPopUp.destroy();
			mNewsPopUp = null;
		}
		displayNews(page, true);
	}

	function tryShowRewardPopup(rewardOfferId:UInt) {
		var offer:GMOffer;
		mDBFacade.mainStateMachine.showedRewardPopup = true;
		offer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(rewardOfferId), gameMasterDictionary.GMOffer);
		if (offer == null) {
			return;
		}
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var centerCloseButton:UIButton;
				var topCloseButton:UIButton;
				var curtain:Sprite = null;
				var swfAsset = param1;
				var rewardPopupClass = swfAsset.getClass("rewards_popup");
				var rewardPopup = ASCompat.coerce(ASCompat.createInstance(rewardPopupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((rewardPopup : ASAny).title_label, flash.text.TextField), "REWARD_POPUP_TITLE");
				Locale.setText(ASCompat.coerce((rewardPopup : ASAny).header_label, flash.text.TextField), "REWARD_POPUP_HEADER");
				TextUtil.setText(ASCompat.coerce((rewardPopup : ASAny).description_label, flash.text.TextField), offer.getDisplayName(mDBFacade.gameMaster));
				centerCloseButton = new UIButton(mDBFacade, ASCompat.coerce((rewardPopup : ASAny).close_button, flash.display.MovieClip));
				topCloseButton = new UIButton(mDBFacade, ASCompat.coerce((rewardPopup : ASAny).close, flash.display.MovieClip));
				Locale.setText(centerCloseButton.label, "REWARD_POPUP_BUTTON");
				centerCloseButton.releaseCallback = topCloseButton.releaseCallback = function() {
					UILevelUpPostController.removeCurtain(curtain, mSceneGraphComponent);
					mSceneGraphComponent.removeChild(rewardPopup);
					rewardPopup = null;
				};
				if (ASCompat.stringAsBool(offer.BundleSwfFilepath) && ASCompat.stringAsBool(offer.BundleIcon)) {
					mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer.BundleSwfFilepath),
						function(param1:brain.assetRepository.SwfAsset) {
							var _loc3_ = param1.getClass(offer.BundleIcon);
							var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
							_loc2_.scaleX = _loc2_.scaleY = 0.66;
							(rewardPopup : ASAny).icon.addChild(_loc2_);
						});
				}
				curtain = UILevelUpPostController.makeCurtain(mDBFacade, mSceneGraphComponent);
				mSceneGraphComponent.addChild(rewardPopup, (105 : UInt));
			});
	}

	function tryShowRewardErrorPopup(rewardErrorCode:String) {
		var rewardErrorDescription:String;
		mDBFacade.mainStateMachine.showedRewardPopup = true;
		rewardErrorDescription = Locale.getError(ASCompat.toInt(rewardErrorCode));
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),
			function(param1:brain.assetRepository.SwfAsset) {
				var closeButton:UIButton;
				var closeButton2:UIButton;
				var curtain:Sprite = null;
				var helpURL:String;
				var helpButton:UIButton;
				var swfAsset = param1;
				var errorPopupClass = swfAsset.getClass("reward_errors_popup");
				var errorPopup = ASCompat.coerce(ASCompat.createInstance(errorPopupClass, []), flash.display.MovieClip);
				Locale.setText(ASCompat.coerce((errorPopup : ASAny).title_label, flash.text.TextField), "REWARD_ERROR_POPUP_TITLE_" + rewardErrorCode);
				TextUtil.setText(ASCompat.coerce((errorPopup : ASAny).message_label, flash.text.TextField), rewardErrorDescription);
				Locale.setText(ASCompat.coerce((errorPopup : ASAny).question_label, flash.text.TextField), "REWARD_ERROR_POPUP_HELP");
				closeButton = new UIButton(mDBFacade, ASCompat.coerce((errorPopup : ASAny).button, flash.display.MovieClip));
				closeButton2 = new UIButton(mDBFacade, ASCompat.coerce((errorPopup : ASAny).close, flash.display.MovieClip));
				Locale.setText(closeButton.label, "REWARD_ERROR_POPUP_CLOSE");
				closeButton2.releaseCallback = closeButton.releaseCallback = function() {
					UILevelUpPostController.removeCurtain(curtain, mSceneGraphComponent);
					mSceneGraphComponent.removeChild(errorPopup);
					errorPopup = null;
				};
				helpURL = "http://help.dungeonrampage.com/";
				helpButton = new UIButton(mDBFacade, ASCompat.coerce((errorPopup : ASAny).help, flash.display.MovieClip));
				helpButton.releaseCallback = function() {
					var _loc1_ = new URLRequest(helpURL);
					flash.Lib.getURL(_loc1_, "_blank");
				};
				curtain = UILevelUpPostController.makeCurtain(mDBFacade, mSceneGraphComponent);
				mSceneGraphComponent.addChild(errorPopup, (105 : UInt));
			});
	}

	function setUpHacksToRecalculateWeaponPowers() {
		EventListeners.add(mDBFacade.stageRef, "keyDown", hackToHandleKeyPressToRecalculateWeaponPowers);
	}

	function tearDownHacksToRecalculateWeaponPowers() {
		EventListeners.remove(mDBFacade.stageRef, "keyDown", hackToHandleKeyPressToRecalculateWeaponPowers);
	}

	function hackToHandleKeyPressToRecalculateWeaponPowers(e:KeyboardEvent) {}

	function TryShowDragonKnightPopup():Bool {
		return UIDragonKnightUpsellPopup.ShouldDisplayDragonKnightUpsell(mDBFacade);
	}

	override public function enterState() {
		super.enterState();
		if (mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_RECALCULATE_WEAPON_POWERS", false)) {
			setUpHacksToRecalculateWeaponPowers();
		}
		TrickleCacheLoader.queueCommonStarlingAtlases(mDBFacade);
		mRenderer.play((0 : UInt), true);
		mUILeaderboard = mTownStateMachine.leaderboard;
		if (mUILeaderboard != null) {
			mUILeaderboard.setRootMovieClip(mRootMovieClip);
			mUILeaderboard.currentStateName = "HomeState";
			mUILeaderboard.hidePopup();
		}
		mTownStateMachine.townHeader.title = Locale.getString("TOWN_HEADER");
		mTownStateMachine.townHeader.inHomeState = true;
		mTownStateMachine.townHeader.showCloseButton(true);
		mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE", function(param1:events.DBAccountResponseEvent) {
			refreshAlerts();
		});
		this.refreshAlerts();
		this.refreshColiseumLock();
		mEventComponent.dispatchEvent(new XPBonusEvent("XP_BONUS_EVENT", false));
		animateEntry();
		if (mDBFacade != null && mDBFacade.hud != null && mDBFacade.hud.chatLog != null) {
			mDBFacade.hud.chatLog.hideChatLog();
		}
		if (mPopupDelayTask != null) {
			mPopupDelayTask.destroy();
		}
		mPopupDelayTask = mLogicalWorkComponent.doLater(0.5, showPopups);
		refreshHeaderNavigationLinks();
		if (mOptionsKeyTask != null) {
			mOptionsKeyTask.destroy();
		}
		mOptionsKeyTask = mLogicalWorkComponent.doEveryFrame(checkOptionsKey);
		mEventComponent.addListener("OnSteamInputButtonReleasedEvent", onSteamInputButtonReleased);
	}

	function showPopups(gameClock:GameClock = null) {
		var flaggedPopupClass:UIFlaggedPopup;
		var dkPopupClass:UIDragonKnightUpsellPopup;
		var rewardOfferId = (ASCompat.toInt(mDBFacade.dbConfigManager.getConfigString("RewardOfferId", "0")) : UInt);
		var rewardErrorCode = mDBFacade.dbConfigManager.getConfigString("RewardErrorMessage", "");
		if (mDBFacade.mSteamIsFlagged && !mDBFacade.mSeenFlaggedPopup) {
			mDBFacade.mSeenFlaggedPopup = true;
			flaggedPopupClass = new UIFlaggedPopup(mDBFacade, mDBFacade.mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged,
				mDBFacade.mSteamIsFlaggedDueToFamilySharingOwnerName, mDBFacade.mSteamFlaggedUntilAfterDateString);
			MemoryTracker.track(flaggedPopupClass, "UIFlaggedPopup - created in HomeState.showPopups()");
		}
		if (rewardOfferId != 0 && !mDBFacade.mainStateMachine.showedRewardPopup) {
			this.tryShowRewardPopup(rewardOfferId);
		} else if (rewardErrorCode != "" && !mDBFacade.mainStateMachine.showedRewardPopup) {
			this.tryShowRewardErrorPopup(rewardErrorCode);
		} else if (TryShowDragonKnightPopup()) {
			dkPopupClass = new UIDragonKnightUpsellPopup(mDBFacade);
			MemoryTracker.track(dkPopupClass, "UIDragonKnightUpsellPopup - created in HomeState.showPopups()");
		} else {
			this.tryShowWhatsNewPopup(function(param1:Bool) {
				if (!param1 && mDBFacade != null) {
					tryShowBetaRewardsPopup();
				}
			});
		}
	}

	public function loadActiveAvatarIcon(event:Event) {
		var gmSkin:GMSkin;
		var mActiveAvatar = mDBFacade.dbAccountInfo.activeAvatarInfo;
		if (mActiveAvatar == null) {
			return;
		}
		gmSkin = mDBFacade.gameMaster.getSkinByType(mActiveAvatar.skinId);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath), function(param1:brain.assetRepository.SwfAsset) {
			var _loc4_ = param1.getClass(gmSkin.IconName);
			var _loc5_ = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance.up.avatar, flash.display.MovieClip);
			var _loc2_ = ASCompat.coerce((mRootMovieClip : ASAny).townScreen_tavern_button_instance.over.avatar, flash.display.MovieClip);
			var _loc3_ = _loc5_.getChildByName("avatarPic");
			if (_loc3_ != null) {
				_loc5_.removeChild(_loc3_);
			}
			_loc3_ = _loc2_.getChildByName("avatarPic");
			if (_loc3_ != null) {
				_loc2_.removeChild(_loc3_);
			}
			if (_loc4_ != null) {
				_loc3_ = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.DisplayObject);
				_loc3_.name = "avatarPic";
				_loc5_.addChild(_loc3_);
				_loc3_ = ASCompat.coerce(ASCompat.createInstance(_loc4_, []), flash.display.DisplayObject);
				_loc3_.name = "avatarPic";
				_loc2_.addChild(_loc3_);
			}
		});
	}

	override public function exitState() {
		mTownStateMachine.townHeader.inHomeState = false;
		if (mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_RECALCULATE_WEAPON_POWERS", false)) {
			tearDownHacksToRecalculateWeaponPowers();
		}
		if (mPopupDelayTask != null) {
			mPopupDelayTask.destroy();
			mPopupDelayTask = null;
		}
		if (mOptionsKeyTask != null) {
			mOptionsKeyTask.destroy();
			mOptionsKeyTask = null;
		}
		mRenderer.stop();
		mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
		mEventComponent.removeListener("OnSteamInputButtonReleasedEvent");
		super.exitState();
	}

	@:isVar public var leaderboard(get, never):UILeaderboard;

	public function get_leaderboard():UILeaderboard {
		return mUILeaderboard;
	}

	@:isVar var tavernNeedsAttention(get, never):Bool;

	function get_tavernNeedsAttention():Bool {
		return false;
	}

	@:isVar var trainingNeedsAttention(get, never):Bool;

	function get_trainingNeedsAttention():Bool {
		var _loc1_ = mDBFacade.dbAccountInfo.activeAvatarInfo;
		return _loc1_ != null && _loc1_.skillPointsAvailable > 0;
	}

	@:isVar var skillsNeedsAttention(get, never):Bool;

	function get_skillsNeedsAttention():Bool {
		var _loc2_:AvatarInfo = null;
		var _loc4_ = mDBFacade.dbAccountInfo.inventoryInfo.avatars;
		if (_loc4_ == null) {
			return false;
		}
		var _loc1_ = _loc4_.keysToArray();
		var _loc3_:ASAny;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc3_ = _tmp_;
				_loc2_ = ASCompat.dynamicAs(_loc4_.itemFor(_loc3_), AvatarInfo);
				if (_loc2_ != null && _loc2_.canAscend) {
					return true;
				}
			}
		return false;
	}

	@:isVar var inventoryNeedsAttention(get, never):Bool;

	function get_inventoryNeedsAttention():Bool {
		return mDBFacade.dbAccountInfo.inventoryInfo.hasNewEquippableItems;
	}

	@:isVar var shopNeedsAttention(get, never):Bool;

	function get_shopNeedsAttention():Bool {
		return false;
	}

	public function getGifts() {
		mDBFacade.dbAccountInfo.getGiftData(checkGiftAlert);
	}

	@:isVar var giftNeedsAttention(get, never):Bool;

	function get_giftNeedsAttention():Bool {
		if (mDBFacade.dbAccountInfo.gifts.size > 0) {
			return true;
		}
		return false;
	}

	function checkGiftAlert() {
		if (mDBFacade == null) {
			return;
		}
		mGiftAlertUp.visible = mGiftAlertOver.visible = this.giftNeedsAttention;
	}

	function giftPopupCloseCallback() {
		mGiftButton.enabled = true;
		checkGiftAlert();
		mGiftPopup = null;
	}

	function checkRewardAlert() {
		if (mDBFacade == null) {
			return;
		}
	}

	function rewardPopupCloseCallback() {
		if (mRewardButton != null) {
			mRewardButton.enabled = true;
		}
		EventListeners.add(mDBFacade.stageRef, "keyDown", openDaily);
		checkRewardAlert();
		mDailyRewardsPopup = null;
	}

	function giftCallbackToFriendManager() {
		mGiftPopup.destroy();
		mGiftPopup = null;
		mTownStateMachine.setFriendManagementTabCategory((1 : UInt));
		mTownStateMachine.enterFriendManagementState();
	}
}
