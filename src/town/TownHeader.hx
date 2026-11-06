package town;

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
import brain.utils.TextUtil;
import brain.workLoop.LogicalWorkComponent;
import dBGlobals.DBGlobal;
import events.BoostersParsedEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import uI.CountdownTextTimer;
import uI.popup.UIExitPopup;
import uI.UITownTweens;
import flash.display.MovieClip;
import flash.filters.DropShadowFilter;
import flash.text.TextField;

class TownHeader {
	static inline final TOWN_HEADER_CLASS_NAME = "UI_header";

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

	var mTeamBonusUI:UIObject;

	var mCoinBoosterUI:UIObject;

	var mXPBoosterUI:UIObject;

	var mGemIcon:MovieClip;

	var mAddCashSaleButton:UIButton;

	var mSaleEfx:MovieClip;

	var mAddCoinButton:UIButton;

	var mAddCashButton:UIButton;

	var mCloseButton:UIButton;

	var mCashLabel:TextField;

	var mCoinLabel:TextField;

	var mShowCloseButton:Bool = true;

	var mJumpToMapState:Bool = false;

	var mInHomeState:Bool = false;

	var mTownSwf:SwfAsset;

	var mBoosterXP:BoosterInfo;

	var mBoosterGold:BoosterInfo;

	var mCountDownTextXP:CountdownTextTimer;

	var mCountDownTextGold:CountdownTextTimer;

	public function new(dbFacade:DBFacade, defaultCloseCallback:ASFunction, mapStateCallback:ASFunction = null) {
		MemoryTracker.track(this, "TownHeader - created in TownHeader()", "default");
		mDBFacade = dbFacade;
		mDefaultCloseCallback = defaultCloseCallback;
		mMapStateCallback = mapStateCallback;
		mTitle = Locale.getString("TOWN_HEADER");
		mEventComponent = new EventComponent(mDBFacade);
		mEventComponent.addListener("CurrencyUpdatedAccountEvent", this.currencyUpdated);
		mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade, "TownHeader");
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "TownHeader");
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), swfLoaded);
	}

	public function destroy() {
		if (mCountDownTextXP != null) {
			mCountDownTextXP.destroy();
		}
		if (mCountDownTextGold != null) {
			mCountDownTextGold.destroy();
		}
		if (mTeamBonusUI != null) {
			mTeamBonusUI.destroy();
		}
		if (mCoinBoosterUI != null) {
			mCoinBoosterUI.destroy();
		}
		if (mXPBoosterUI != null) {
			mXPBoosterUI.destroy();
		}
		mCashUI.destroy();
		mCoinUI.destroy();
		mAddCoinButton.destroy();
		mAddCashButton.destroy();
		mCloseButton.destroy();
		mGemIcon = null;
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

	function swfLoaded(swfAsset:SwfAsset) {
		mTownSwf = swfAsset;
		var _loc2_ = mTownSwf.getClass("UI_header");
		mRoot = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
		mRoot.filters = cast([new DropShadowFilter(6, 90, (0 : UInt), 0.5, 6, 6, 1)]);
		setupUI();
		show();
	}

	@:isVar public var rootMovieClip(get, never):MovieClip;

	public function get_rootMovieClip():MovieClip {
		return mRoot;
	}

	function setupUI() {
		var acctInfo:DBAccountInfo;
		mRoot.x = mDBFacade.viewWidth * 0.5;
		mRoot.y = 0;
		mCashUI = new UIObject(mDBFacade, ASCompat.coerce((mRoot : ASAny).currency.cash, flash.display.MovieClip));
		mCoinUI = new UIObject(mDBFacade, ASCompat.coerce((mRoot : ASAny).currency.coin, flash.display.MovieClip));
		mTeamBonusUI = new UIObject(mDBFacade, ASCompat.coerce((mRoot : ASAny).currency.crewbonus, flash.display.MovieClip));
		Locale.setText(ASCompat.coerce((mTeamBonusUI.tooltip : ASAny).title_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_TITLE");
		Locale.setText(ASCompat.coerce((mTeamBonusUI.tooltip : ASAny).description_label, flash.text.TextField), "TEAM_BONUS_TOOLTIP_DESCRIPTION");
		Locale.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_txt1, flash.text.TextField), "TEAM_BONUS_TITLE_CREW", null, 0.82);
		Locale.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_txt2, flash.text.TextField), "TEAM_BONUS_TITLE_BONUS", null, 0.82);
		TextUtil.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_number, flash.text.TextField),
			Std.string((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 1), 0.73);
		(mTeamBonusUI.root : ASAny).header_crew_bonus_anim.stop();
		mCoinBoosterUI = new UIObject(mDBFacade, ASCompat.coerce((mRoot : ASAny).currency.boosterCoin, flash.display.MovieClip));
		mXPBoosterUI = new UIObject(mDBFacade, ASCompat.coerce((mRoot : ASAny).currency.boosterXP, flash.display.MovieClip));
		mAddCashButton = new UIButton(mDBFacade, ASCompat.coerce((mCashUI.root : ASAny).add_cash, flash.display.MovieClip));
		Locale.setText(mAddCashButton.label, "HOW");
		mGemIcon = ASCompat.coerce((mCashUI.root : ASAny).gem_icon, flash.display.MovieClip);
		mSaleEfx = ASCompat.coerce((mCashUI.root : ASAny).lable_sale_efx, flash.display.MovieClip);
		mSaleEfx.visible = false;
		mAddCashSaleButton = new UIButton(mDBFacade, ASCompat.coerce((mCashUI.root : ASAny).add_cash_sale, flash.display.MovieClip));
		mAddCashSaleButton.visible = false;
		Locale.setText(mAddCashSaleButton.label, "HOW");
		mAddCashSaleButton.rolloverFilter = mAddCashButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mAddCashSaleButton.releaseCallback = mAddCashButton.releaseCallback = function() {
			mDBFacade.metrics.log("TownHeaderAddCash");
			StoreServicesController.showCashPage(mDBFacade, "TownHeaderAddCash");
		};
		mGemIcon.filters = cast([]);
		mAddCoinButton = new UIButton(mDBFacade, ASCompat.coerce((mCoinUI.root : ASAny).add_coin, flash.display.MovieClip));
		mAddCoinButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mAddCoinButton.releaseCallback = function() {
			StoreServicesController.showCoinPage(mDBFacade);
		};
		Locale.setText(mAddCoinButton.label, "HOW");
		mCoinLabel = ASCompat.dynamicAs((mCoinUI.root : ASAny).coin, TextField);
		mCoinLabel.mouseEnabled = false;
		mCashLabel = ASCompat.dynamicAs((mCashUI.root : ASAny).cash, TextField);
		mCashLabel.mouseEnabled = false;
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).UI_town_home_button_instance, flash.display.MovieClip));
		mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mCloseButton.releaseCallback = determineCallback;
		title = mTitle;
		showCloseButton(mShowCloseButton);
		acctInfo = mDBFacade.dbAccountInfo;
		setCurrency(acctInfo.basicCurrency, acctInfo.premiumCurrency);
		setBoosters();
		mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE", this.handleBoostersParsedEvent);
	}

	public function updateTeamBonusUI() {
		TextUtil.setText(ASCompat.coerce((mTeamBonusUI.root : ASAny).header_crew_bonus_number, flash.text.TextField),
			Std.string((mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() : Float) - 1), 0.73);
	}

	public function animateHeader() {
		UITownTweens.headerTweenSequence(mRoot, mDBFacade);
	}

	public function show() {
		if (mRoot != null && !mSceneGraphComponent.contains(mRoot, (105 : UInt))) {
			mSceneGraphComponent.addChild(mRoot, (75 : UInt));
		}
	}

	public function hide() {
		if (mRoot != null) {
			mSceneGraphComponent.removeChild(mRoot);
		}
	}

	public function showCloseButton(value:Bool) {
		mShowCloseButton = value;
		if (mCloseButton != null) {
			mCloseButton.visible = mShowCloseButton;
		}
	}

	@:isVar public var jumpToMapState(never, set):Bool;

	public function set_jumpToMapState(value:Bool):Bool {
		return mJumpToMapState = value;
	}

	@:isVar public var inHomeState(never, set):Bool;

	public function set_inHomeState(value:Bool):Bool {
		return mInHomeState = value;
	}

	function showExitPopup() {
		var _loc1_ = new UIExitPopup(mDBFacade);
		MemoryTracker.track(_loc1_, "UIExitPopup - created in TownHeader.showExitPopup()");
	}

	public function determineCallback() {
		if (mInHomeState) {
			showExitPopup();
			return;
		}
		if (mJumpToMapState && mMapStateCallback != null) {
			mMapStateCallback();
		} else {
			mDefaultCloseCallback();
		}
		mJumpToMapState = false;
	}

	function setCurrency(basicCurrency:UInt, premiumCurrency:UInt) {
		if (mRoot != null) {
			TextUtil.setText(mCoinLabel, Std.string(basicCurrency));
			TextUtil.setText(mCashLabel, Std.string(premiumCurrency));
		}
	}

	function currencyUpdated(event:CurrencyUpdatedAccountEvent) {
		this.setCurrency(event.basicCurrency, event.premiumCurrency);
	}

	function handleBoostersParsedEvent(event:BoostersParsedEvent) {
		resetBoosters();
	}

	function resetBoosters() {
		setBoosters();
	}

	function setBoosters() {
		var _loc1_ = mDBFacade.dbAccountInfo.inventoryInfo;
		mXPBoosterUI.visible = false;
		mCoinBoosterUI.visible = false;
		mBoosterXP = _loc1_.findHighestBoosterXP();
		mBoosterGold = _loc1_.findHighestBoosterGold();
		if (mCountDownTextXP != null) {
			mCountDownTextXP.destroy();
		}
		if (mCountDownTextGold != null) {
			mCountDownTextGold.destroy();
		}
		if (mBoosterXP != null) {
			TextUtil.setText(ASCompat.coerce((mRoot : ASAny).currency.boosterXP.label, flash.text.TextField), mBoosterXP.BuffInfo.Exp + "X");
			TextUtil.setText(ASCompat.coerce((mXPBoosterUI.tooltip : ASAny).title_label, flash.text.TextField), mBoosterXP.StackInfo.Name);
			mXPBoosterUI.visible = true;
			mCountDownTextXP = new CountdownTextTimer(ASCompat.coerce((mXPBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),
				mBoosterXP.getEndDate(), GameClock.getWebServerDate, setBoosters, Locale.getString("BOOSTER_REMAINING"), "", Locale.getString("EXPIRED"));
			mCountDownTextXP.start();
		}
		if (mBoosterGold != null) {
			TextUtil.setText(ASCompat.coerce((mRoot : ASAny).currency.boosterCoin.label, flash.text.TextField), mBoosterGold.BuffInfo.Gold + "X");
			TextUtil.setText(ASCompat.coerce((mCoinBoosterUI.tooltip : ASAny).title_label, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("STACKABLE_NAME", mBoosterGold.StackInfo.Constant));
			mCoinBoosterUI.visible = true;
			mCountDownTextGold = new CountdownTextTimer(ASCompat.coerce((mCoinBoosterUI.tooltip : ASAny).time_label, flash.text.TextField),
				mBoosterGold.getEndDate(), GameClock.getWebServerDate, setBoosters, Locale.getString("BOOSTER_REMAINING"), "", Locale.getString("EXPIRED"));
			mCountDownTextGold.start();
		}
	}

	@:isVar public var title(never, set):String;

	public function set_title(value:String):String {
		mTitle = value;
		if (mRoot != null) {
			TextUtil.setText(ASCompat.coerce((mRoot : ASAny).page_title, flash.text.TextField), mTitle);
			ASCompat.setProperty((mRoot : ASAny).page_title, "mouseEnabled", false);
		}
		return value;
	}

	@:isVar public var addCoinButton(get, never):UIButton;

	public function get_addCoinButton():UIButton {
		return mAddCoinButton;
	}

	@:isVar public var addGemButton(get, never):UIButton;

	public function get_addGemButton():UIButton {
		return mAddCashButton;
	}

	@:isVar public var closeButton(get, never):UIButton;

	public function get_closeButton():UIButton {
		return mCloseButton;
	}

	public function setupButtonLinks() {
		mAddCoinButton.clearNavigationAndInteractions();
		mAddCashButton.clearNavigationAndInteractions();
		mCloseButton.clearNavigationAndInteractions();
		mAddCoinButton.isToTheLeftOf(mAddCashButton);
		if (mShowCloseButton) {
			mAddCashButton.isToTheLeftOf(mCloseButton);
		}
	}

	public function resetButtonLinks() {
		mAddCoinButton.clearNavigationAndInteractions();
		mAddCashButton.clearNavigationAndInteractions();
		mCloseButton.clearNavigationAndInteractions();
		mAddCoinButton.setFocused(false);
		mAddCashButton.setFocused(false);
		mCloseButton.setFocused(false);
	}
}
