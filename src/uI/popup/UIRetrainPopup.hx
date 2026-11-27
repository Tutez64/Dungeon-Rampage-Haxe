package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;

class UIRetrainPopup extends DBUITwoButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final POPUP_CLASS_NAME = "popup_retrain";

	var mPrice:UInt = 0;

	public function new(dbFacade:DBFacade, leftCallback:ASFunction, price:UInt) {
		mPrice = price;
		super(dbFacade, "RETRAIN_POPUP", Locale.getString("RETRAIN_POPUP_TITLE"), Locale.getString("RETRAIN_POPUP_MESSAGE"), Locale.getString("RETRAIN_BUY"),
			leftCallback, Locale.getString("CANCEL"), null);
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		TextUtil.setText(mLeftButton.label, Std.string(mPrice));
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_town.swf";
	}

	override function getClassName():String {
		return "popup_retrain";
	}

	override function setupMenuNavigation() {
		mCloseButton.clearNavigationAndInteractions();
		mLeftButton.clearNavigationAndInteractions();
		mRightButton.clearNavigationAndInteractions();
		mRightButton.isToTheLeftOf(mLeftButton);
		mCloseButton.isAbove(mRightButton);
		mLeftButton.upNavigation = mCloseButton;
	}
}
