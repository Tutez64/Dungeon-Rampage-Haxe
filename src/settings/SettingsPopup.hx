package settings;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.uI.UIRadioButton;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import settings.model.SettingsModel;
import settings.view.SettingsCategoryTabs;
import settings.view.SettingsList;
import uI.popup.DBUIPopup;
import uI.popup.DBUITwoButtonPopup;
import flash.display.MovieClip;
import flash.text.TextField;

class SettingsPopup extends DBUIPopup {
	public static inline final SETTINGS_SWF_PATH = "Resources/Art2D/UI/db_UI_settings.swf";

	public static inline final POPUP_LINKAGE_NAME = "settings_popup";

	static inline final RESET_BUTTON_NAME = "reset_button";

	static inline final RESET_LABEL_NAME = "reset_label";

	var mModel:SettingsModel;

	var mTabs:SettingsCategoryTabs;

	var mList:SettingsList;

	var mResetButton:UIButton;

	var mConfirmResetPopup:DBUITwoButtonPopup;

	var mNavigationReady:Bool = false;

	public function new(dbFacade:DBFacade, closeCallback:ASFunction = null) {
		mModel = dbFacade.settingsModel;
		super(dbFacade, "SETTINGS_MENU", Locale.getString("SETTINGS_TITLE"), null, true, true, closeCallback, false, false);
	}

	public static function isTopMenu(dbFacade:DBFacade):Bool {
		return dbFacade.menuNavigationController.getTopUILayer() == "SETTINGS_MENU";
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_settings.swf";
	}

	override function getClassName():String {
		return "settings_popup";
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		centerPopup();
		mDBFacade.displayTimingSettings.refreshMonitors();
		mTabs = new SettingsCategoryTabs(mDBFacade, mPopup, onCategorySelected);
		mList = new SettingsList(mDBFacade, mPopup, swfAsset, mModel);
		setupResetButton();
		mTabs.selectFirst();
	}

	override function setupMenuNavigation() {
		rebuildNavigation();
	}

	override function initializeMenuNavigationLayer() {
		mDBFacade.menuNavigationController.pushNewLayer(mUILayerName, getNavigationExitCallback(), getDefaultNavigationObject(),
			getInitialFocusedNavigationObject(), mTabs != null ? mTabs.selectPrevious : null, mTabs != null ? mTabs.selectNext : null);
	}

	override function getInitialFocusedNavigationObject():UIObject {
		if (mList != null && mList.firstRow != null) {
			return mList.firstRow;
		}
		if (mTabs != null) {
			return mTabs.selectedButton;
		}
		return null;
	}

	override function completeMenuNavigationSetup() {
		super.completeMenuNavigationSetup();
		mNavigationReady = mUILayerName != null && mUILayerName.length > 0;
	}

	override public function destroy() {
		if (mDBFacade == null) {
			return;
		}
		if (mConfirmResetPopup != null) {
			mConfirmResetPopup.destroy();
			mConfirmResetPopup = null;
		}
		if (mModel != null) {
			mModel.apply();
		}
		mModel = null;
		if (mList != null) {
			mList.destroy();
			mList = null;
		}
		if (mTabs != null) {
			mTabs.destroy();
			mTabs = null;
		}
		if (mResetButton != null) {
			mResetButton.destroy();
			mResetButton = null;
		}
		super.destroy();
	}

	function setupResetButton() {
		var _loc1_ = findResetButtonClip();
		if (_loc1_ == null) {
			Logger.warn("Settings popup art has no reset button");
			return;
		}
		mResetButton = new UIButton(mDBFacade, _loc1_);
		mResetButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		mResetButton.releaseCallback = confirmResetAll;
		labelResetButton(_loc1_, Locale.getString("SETTINGS_RESET_ALL"));
	}

	function findResetButtonClip():MovieClip {
		var _loc1_ = 0;
		var _loc2_:MovieClip = null;
		if ((mPopup : ASAny).hasOwnProperty("reset_button")) {
			return ASCompat.dynamicAs((mPopup : ASAny)["reset_button"], MovieClip);
		}
		_loc1_ = 0;
		while (_loc1_ < mPopup.numChildren) {
			_loc2_ = ASCompat.reinterpretAs(mPopup.getChildAt(_loc1_), MovieClip);
			if (_loc2_ != null && Std.isOfType(_loc2_.getChildByName("reset_label"), TextField)) {
				return _loc2_;
			}
			_loc1_++;
		}
		return null;
	}

	function labelResetButton(clip:MovieClip, text:String) {
		var _loc3_ = mResetButton.label;
		if (_loc3_ == null) {
			_loc3_ = ASCompat.reinterpretAs(clip.getChildByName("reset_label"), TextField);
		}
		if (_loc3_ == null) {
			_loc3_ = ASCompat.reinterpretAs(mPopup.getChildByName("reset_label"), TextField);
		}
		if (_loc3_ == null) {
			return;
		}
		_loc3_.text = text;
		_loc3_.mouseEnabled = false;
	}

	function onCategorySelected(category:String) {
		mList.showCategory(category);
		rebuildNavigation();
		if (!mNavigationReady) {
			return;
		}
		if (isRailObject(mDBFacade.menuNavigationController.focusedUiObject)) {
			return;
		}
		var _loc2_ = getInitialFocusedNavigationObject();
		if (_loc2_ != null) {
			mDBFacade.menuNavigationController.setFocusedUiObject(_loc2_);
		}
	}

	function rebuildNavigation() {
		var _loc4_ = 0;
		if (mTabs == null || mTabs.buttons.length == 0) {
			return;
		}
		var _loc3_ = mTabs.buttons;
		var _loc1_ = mList != null ? mList.firstRow : null;
		var _loc2_ = mList != null ? mList.lastRow : null;
		_loc4_ = 0;
		while (_loc4_ < _loc3_.length) {
			_loc3_[_loc4_].clearNavigationAndInteractions();
			_loc4_++;
		}
		if (mResetButton != null) {
			mResetButton.clearNavigationAndInteractions();
		}
		if (mCloseButton != null) {
			mCloseButton.clearDownNavigation();
		}
		if (mCloseButton != null) {
			mCloseButton.isAbove(_loc3_[0]);
		}
		_loc4_ = 0;
		while (_loc4_ < _loc3_.length - 1) {
			_loc3_[_loc4_].isAbove(_loc3_[_loc4_ + 1]);
			_loc4_++;
		}
		if (mResetButton != null) {
			_loc3_[_loc3_.length - 1].isAbove(mResetButton);
		}
		if (_loc1_ != null) {
			_loc4_ = 0;
			while (_loc4_ < _loc3_.length) {
				_loc3_[_loc4_].rightNavigation = _loc1_;
				_loc4_++;
			}
			if (mResetButton != null) {
				mResetButton.rightNavigation = _loc1_;
			}
			_loc1_.upNavigation = mTabs.selectedButton;
		}
		if (_loc2_ != null && mResetButton != null) {
			_loc2_.downNavigation = mResetButton;
		}
	}

	function isRailObject(uiObject:UIObject):Bool {
		if (uiObject == null) {
			return false;
		}
		if (uiObject == mCloseButton || uiObject == mResetButton) {
			return true;
		}
		var _loc2_:UIRadioButton;
		final __ax4_iter_367 = mTabs.buttons;
		if (checkNullIteratee(__ax4_iter_367))
			for (_tmp_ in __ax4_iter_367) {
				_loc2_ = _tmp_;
				if (_loc2_ == uiObject) {
					return true;
				}
			}
		return false;
	}

	function confirmResetAll() {
		if (mConfirmResetPopup != null) {
			return;
		}
		mConfirmResetPopup = new DBUITwoButtonPopup(mDBFacade, "SETTINGS_RESET_CONFIRM_POPUP", Locale.getString("SETTINGS_RESET_ALL"),
			Locale.getString("SETTINGS_RESET_ALL_CONFIRM"), Locale.getString("SETTINGS_RESET_CONFIRM_YES"), onResetConfirmed,
			Locale.getString("SETTINGS_RESET_CONFIRM_NO"), onResetDismissed, true, onResetDismissed);
	}

	function onResetConfirmed() {
		mConfirmResetPopup = null;
		mModel.resetAll();
	}

	function onResetDismissed() {
		mConfirmResetPopup = null;
	}
}
