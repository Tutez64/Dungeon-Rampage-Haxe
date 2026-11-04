package uI.shop;

import account.AvatarInfo;
import account.StoreServicesController;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import gameMasterDictionary.GMChest;
import uI.inventory.chests.ChestRevealPopUp;
import uI.popup.DBUIConfirmChestPurchasePopup;

class UIChestOffer extends UIShopBundleOffer {
	var mConfirmPurchaseChestPopup:DBUIConfirmChestPurchasePopup;

	var mGMChest:GMChest;

	var mSelectedAvatarInfo:AvatarInfo;

	public function new(dbFacade:DBFacade, templateClass:Dynamic, selectedAvatarInfo:AvatarInfo, buySuccessCallback:ASFunction = null) {
		super(dbFacade, templateClass, buySuccessCallback);
		mSelectedAvatarInfo = selectedAvatarInfo;
	}

	override function buyButtonCallback() {
		mGMChest = ASCompat.coerce(mDBFacade.gameMaster.chestsById.itemFor(this.offer.Details[0].ChestId), gameMasterDictionary.GMChest);
		if (mGMChest == null) {
			Logger.error("Unable to find GMChest for chestId: " + this.offer.Details[0].ChestId);
		}
		mConfirmPurchaseChestPopup = new DBUIConfirmChestPurchasePopup(mDBFacade, purchaseChest, close, offer, mSelectedAvatarInfo.skinId, true, null);
		MemoryTracker.track(mConfirmPurchaseChestPopup, "DBUIConfirmChestPurchasePopup - created in UIChestOffer.buyButtonCallback()");
	}

	function purchaseChest() {
		StoreServicesController.tryBuyOffer(mDBFacade, this.offer, workAroundForOfferBeingDestroyed(mDBFacade, mGMChest), mSelectedAvatarInfo.id);
	}

	function workAroundForOfferBeingDestroyed(dbFacade:DBFacade, gmChest:GMChest):ASFunction {
		return function(param1:ASAny) {
			var selfManagedPopup:ChestRevealPopUp = null;
			var details:ASAny = param1;
			selfManagedPopup = new ChestRevealPopUp(dbFacade, gmChest, function() {
				selfManagedPopup.destroy();
			}, null);
			selfManagedPopup.updateRevealLoot(details);
		};
	}

	function close() {
		mConfirmPurchaseChestPopup.destroy();
	}

	override public function destroy() {
		if (mConfirmPurchaseChestPopup != null) {
			mConfirmPurchaseChestPopup.destroy();
		}
		super.destroy();
	}
}
