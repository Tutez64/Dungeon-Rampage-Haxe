package uI.shop;

import account.StoreServicesController;
import facade.DBFacade;
import facade.GameMasterLocale;

class UIShopBundleOffer extends UIShopOffer {
	public function new(dbFacade:DBFacade, templateClass:Dynamic, buyCallback:ASFunction = null, useIconScaling:Bool = true, wantNewRollOverScale:Bool = true) {
		super(dbFacade, templateClass, buyCallback, useIconScaling, wantNewRollOverScale);
	}

	override function get_offerDescription():String {
		return GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_DESCRIPTION", Std.string(this.offer.Id));
	}

	override function get_offerIconName():String {
		return this.offer.BundleIcon;
	}

	override function get_offerSwfPath():String {
		return this.offer.BundleSwfFilepath;
	}

	override function hasRequirements():Bool {
		return false;
	}

	override function requirementsMetForPurchase():Bool {
		return !StoreServicesController.alreadyOwns(mDBFacade, this.offer);
	}
}
