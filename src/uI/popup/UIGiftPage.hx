package uI.popup;

import account.StoreServicesController;
import brain.assetRepository.SwfAsset;
import facade.DBFacade;
import facade.Locale;

class UIGiftPage extends UIOfferPopup {
	public function new(dbFacade:DBFacade, buyCallback:ASFunction, closeCallback:ASFunction) {
		super(dbFacade, Locale.getString("SHOP_GIFT_PAGE_TITLE"), StoreServicesController.GIFT_OFFERS, buyCallback, closeCallback, false, false);
		if (mBuyCallback == null) {
			mBuyCallback = function() {
				close(null);
			};
		}
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
	}
}
