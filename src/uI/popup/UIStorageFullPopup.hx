package uI.popup;

import brain.assetRepository.SwfAsset;
import facade.DBFacade;
import facade.Locale;

class UIStorageFullPopup extends DBUITwoButtonPopup {
	public static inline final STORAGE_POPUP_CLASS_NAME = "popup_add_storage";

	public function new(dbFacade:DBFacade, titleText:String, content:ASAny, leftText:String, leftCallback:ASFunction, rightText:String,
			rightCallback:ASFunction, allowClose:Bool = true, closeCallback:ASFunction = null) {
		super(dbFacade, titleText, content, leftText, leftCallback, rightText, rightCallback, allowClose, closeCallback);
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		ASCompat.setProperty((mPopup : ASAny).title_label, "text", Locale.getString("STORAGE_FULL_TITLE"));
		ASCompat.setProperty((mPopup : ASAny).message_label, "text", Locale.getString("STORAGE_FULL_DESCRIPTION"));
	}

	override function getClassName():String {
		return "popup_add_storage";
	}
}
