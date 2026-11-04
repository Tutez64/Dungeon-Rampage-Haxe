package uI.inventory;

import account.DBInventoryInfo;
import account.StackableInfo;
import account.StoreServicesController;
import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.clock.GameClock;
import brain.event.EventComponent;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import events.BoostersParsedEvent;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMBuff;
import uI.CountdownTextTimer;
import flash.display.MovieClip;
import flash.text.TextField;

class BoosterInfoCard extends UIObject {
	public static inline final UI_ICON_SWF_PATH = "Resources/Art2D/Icons/Items/db_icons_items.swf";

	public static inline final UI_BOOSTER_SWF_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	var mCountdownTextTimer:CountdownTextTimer;

	var mDBFacade:DBFacade;

	var mInfo:StackableInfo;

	var mIcon:MovieClip;

	var mBoostIcon:MovieClip;

	var mActivateButton:UIButton;

	var mActivateAnotherButton:UIButton;

	var mActivatedCallback:ASFunction;

	var mActivationPending:Bool = false;

	var mUpdatingInfo:Bool = false;

	var mSparkleController:MovieClipRenderController;

	var mEventComponent:EventComponent;

	var mFlagIcon:Bool = false;

	var mFlagBooster:Bool = false;

	var mAssetLoadingComponent:AssetLoadingComponent;

	public function new(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent, root:MovieClip, activatedCallback:ASFunction = null) {
		super(dbFacade, root);
		mDBFacade = dbFacade;
		mActivatedCallback = activatedCallback;
		setupBoosterCardUI();
		hide();
	}

	override public function destroy() {
		if (mCountdownTextTimer != null) {
			mCountdownTextTimer.destroy();
			mCountdownTextTimer = null;
		}
		if (mEventComponent != null) {
			mEventComponent.destroy();
			mEventComponent = null;
		}
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
			mAssetLoadingComponent = null;
		}
		mActivatedCallback = null;
		super.destroy();
	}

	function setupBoosterCardUI() {
		mEventComponent = new EventComponent(mDBFacade);
		mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE", this.handleBoostersParsedEvent);
	}

	@:isVar public var info(never, set):StackableInfo;

	public function set_info(info:StackableInfo):StackableInfo {
		var invInfo:DBInventoryInfo;
		mUpdatingInfo = true;
		mInfo = info;
		if (mInfo == null) {
			mRoot.visible = false;
			hide();
		} else {
			if (mIcon != null) {
				(mRoot : ASAny).booster_icon.removeChild(mIcon);
				mIcon = null;
			}
			if (mBoostIcon != null) {
				(mRoot : ASAny).booster_activated.removeChild(mBoostIcon);
				mBoostIcon = null;
			}
			invInfo = mDBFacade.dbAccountInfo.inventoryInfo;
			if (mAssetLoadingComponent == null) {
				mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
			}
			setupBoosterInfoUI(mInfo);
			TextUtil.setText(ASCompat.coerce((mRoot : ASAny).label, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("STACKABLE_NAME", mInfo.gmStackable.Constant));
			TextUtil.setText(ASCompat.coerce((mRoot : ASAny).description, flash.text.TextField),
				GameMasterLocale.getGameMasterSubString("STACKABLE_DESCRIPTION", mInfo.gmStackable.Constant));
			Locale.setText(ASCompat.coerce((mRoot : ASAny).button_activate.label, flash.text.TextField), "BOOSTER_CARD_ACTIVATE");
			ASCompat.setProperty((mRoot : ASAny).booster_activated, "visible", false);
			TextUtil.setText(ASCompat.coerce((mRoot : ASAny).booster_activated.label_time, flash.text.TextField), "00:00:00");
			mActivateButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).button_activate, flash.display.MovieClip));
			mActivateButton.releaseCallback = function() {
				activateBooster();
			};
			mActivateAnotherButton = new UIButton(mDBFacade, ASCompat.coerce((mRoot : ASAny).booster_activated.activate_another, flash.display.MovieClip));
			mActivateAnotherButton.releaseCallback = function() {
				activateBooster();
			};
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Items/db_icons_items.swf"), iconsLoaded);
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), boostersLoaded);
			setupTimer();
		}
		mUpdatingInfo = false;
		completePendingActivationIfReady();
		return info;
	}

	function setupTimer() {
		ASCompat.setProperty((mRoot : ASAny).button_activate, "visible", false);
		ASCompat.setProperty((mRoot : ASAny).booster_activated, "visible", true);
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo;
		var _loc1_ = _loc2_.dateBooster((mInfo.gmId : Int));
		if (mCountdownTextTimer != null) {
			mCountdownTextTimer.destroy();
			mCountdownTextTimer = null;
		}
		if (_loc1_ == null) {
			timeUp();
		} else {
			mCountdownTextTimer = new CountdownTextTimer(ASCompat.coerce((mRoot : ASAny).booster_activated.label_time, flash.text.TextField), _loc1_,
				GameClock.getWebServerDate, timeUp, Locale.getString("BOOSTER_REMAINING"), "", Locale.getString("EXPIRED"));
			mCountdownTextTimer.start();
		}
	}

	function timeUp() {
		ASCompat.setProperty((mRoot : ASAny).button_activate, "visible", true);
		ASCompat.setProperty((mRoot : ASAny).booster_activated, "visible", false);
		if (mCountdownTextTimer != null) {
			mCountdownTextTimer.destroy();
			mCountdownTextTimer = null;
		}
	}

	function handleBoostersParsedEvent(event:BoostersParsedEvent) {
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo;
		if (mCountdownTextTimer != null) {
			mCountdownTextTimer.destroy();
			mCountdownTextTimer = null;
		}
		if (mInfo != null) {
			this.info = _loc2_.getStackableByStackId((mInfo.gmId : Int));
			if (getTimeLeft() > 0) {
				setupTimer();
			}
		}
		if (mInfo == null && mRoot != null) {
			hide();
		}
		completePendingActivationIfReady();
	}

	function iconsLoaded(swfAsset:SwfAsset) {
		if (mDBFacade == null) {
			return;
		}
		var _loc2_ = swfAsset.getClass(mInfo.iconName);
		mIcon = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
		(mRoot : ASAny).booster_icon.addChild(mIcon);
		mFlagIcon = true;
		if (mFlagIcon && mFlagBooster) {
			mRoot.visible = true;
			show();
			completePendingActivationIfReady();
		}
	}

	function boostersLoaded(swfAsset:SwfAsset) {
		if (mDBFacade == null) {
			return;
		}
		var _loc3_ = ASCompat.coerce(mDBFacade.gameMaster.buffByConstant.itemFor(mInfo.gmStackable.Buff), gameMasterDictionary.GMBuff);
		var _loc4_ = "inv_itemCard_boosterXP";
		var _loc2_ = _loc3_.Exp + "X";
		if (_loc3_.Exp < _loc3_.Gold) {
			_loc4_ = "inv_itemCard_boosterCoin";
			_loc2_ = _loc3_.Gold + "X";
		}
		var _loc5_ = swfAsset.getClass(_loc4_);
		mBoostIcon = ASCompat.coerce(ASCompat.createInstance(_loc5_, []), flash.display.MovieClip);
		var _loc6_ = ASCompat.coerce((mRoot : ASAny).booster_activated.booster_icon_text, flash.text.TextField);
		if (mSparkleController == null) {
			mSparkleController = new MovieClipRenderController(mDBFacade,
				ASCompat.coerce((mRoot : ASAny).booster_activated.booster_icon_anim, flash.display.MovieClip));
			mSparkleController.play();
			mSparkleController.loop = true;
		}
		(mRoot : ASAny).booster_activated.addChild(mBoostIcon);
		mBoostIcon.x = ASCompat.toNumberField((mRoot : ASAny).booster_activated.booster_icon, "x");
		mBoostIcon.y = ASCompat.toNumberField((mRoot : ASAny).booster_activated.booster_icon, "y");
		ASCompat.setProperty((mRoot : ASAny).booster_activated.booster_icon, "visible", false);
		(mRoot : ASAny).booster_activated.removeChild(_loc6_);
		(mRoot : ASAny).booster_activated.addChild(_loc6_);
		TextUtil.setText(ASCompat.coerce((mRoot : ASAny).booster_activated.booster_icon_text, flash.text.TextField), _loc2_);
		mFlagBooster = true;
		if (mFlagIcon && mFlagBooster) {
			mRoot.visible = true;
			show();
			completePendingActivationIfReady();
		}
	}

	public function getTimeLeft():Float {
		if (mInfo == null) {
			return 0;
		}
		var _loc2_ = mDBFacade.dbAccountInfo.inventoryInfo;
		var _loc1_ = _loc2_.dateBooster((mInfo.gmId : Int));
		if (_loc1_ == null) {
			return 0;
		}
		return _loc1_.getTime() - GameClock.getWebServerTime();
	}

	function activateBooster() {
		var _loc1_ = mInfo;
		mActivationPending = true;
		StoreServicesController.useAccountBooster(mDBFacade, _loc1_);
	}

	function completePendingActivationIfReady() {
		if (!mActivationPending || mUpdatingInfo || mInfo != null && !isShowing()) {
			return;
		}
		mActivationPending = false;
		if (mActivatedCallback != null) {
			mActivatedCallback();
		}
	}

	function setupBoosterInfoUI(info:StackableInfo) {}

	public function hide() {
		this.visible = false;
	}

	public function show() {
		this.visible = true;
	}

	public function isShowing():Bool {
		return this.visible;
	}

	@:isVar public var visibleActivationButton(get, never):UIButton;

	public function get_visibleActivationButton():UIButton {
		if (ASCompat.toBool((mRoot : ASAny).button_activate.visible)) {
			return mActivateButton;
		}
		if (ASCompat.toBool((mRoot : ASAny).booster_activated.visible)) {
			return mActivateAnotherButton;
		}
		return null;
	}
}
