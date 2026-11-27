package uI.inventory;

import facade.DBFacade;
import facade.Locale;
import uI.popup.DBUITwoButtonPopup;

class UIAbandonChestPopup extends DBUITwoButtonPopup {
	var mCancelCallback:ASFunction;

	public function new(dbFacade:DBFacade, cancelCallback:ASFunction, confirmCallback:ASFunction) {
		super(dbFacade, "ABANDON_CHEST_POPUP", Locale.getString("ABANDON_CHEST_POPUP_TITLE"), Locale.getString("ABANDON_CHEST_POPUP_DESC"),
			Locale.getString("ABANDON_CHEST_POPUP_CANCEL"), cancelCallback, Locale.getString("ABANDON_CHEST_POPUP_CONFIRM"), confirmCallback, false,
			cancelCallback);
		mCancelCallback = cancelCallback;
	}

	override public function destroy() {
		mCancelCallback = null;
		super.destroy();
	}

	override function handleInputCalledClosed() {
		close(mCancelCallback);
	}
}
