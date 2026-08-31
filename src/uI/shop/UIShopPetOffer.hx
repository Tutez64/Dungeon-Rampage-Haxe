package uI.shop;

import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMOfferDetail;

class UIShopPetOffer extends UIShopOffer {
	var mGMOfferDetail:GMOfferDetail;

	var mGMOfferPet:GMNpc;

	public function new(dbFacade:DBFacade, templateClass:Dynamic, buyCallback:ASFunction = null) {
		super(dbFacade, templateClass, buyCallback);
	}

	override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) {
		this.offer = gmOffer;
		mGMOfferDetail = this.offer.Details[0];
		mGMOfferPet = ASCompat.dynamicAs(mDBFacade.gameMaster.npcById.itemFor(mGMOfferDetail.PetId), gameMasterDictionary.GMNpc);
		super.showOffer(gmOffer, gmHero);
	}

	override function get_nativeIconSize():Float {
		return 68;
	}

	override function get_offerDescription():String {
		return mGMOfferPet != null ? GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION", mGMOfferPet.Constant) : "";
	}

	override function get_offerIconName():String {
		return mGMOfferPet != null ? mGMOfferPet.IconName : "";
	}

	override function get_offerSwfPath():String {
		return mGMOfferPet != null ? mGMOfferPet.IconSwfFilepath : "";
	}

	override function hasRequirements():Bool {
		return false;
	}

	override function requirementsMetForPurchase():Bool {
		return true;
	}
}
