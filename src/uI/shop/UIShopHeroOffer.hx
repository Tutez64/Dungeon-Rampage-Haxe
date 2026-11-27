package uI.shop;

import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMOfferDetail;
import gameMasterDictionary.GMSkin;

class UIShopHeroOffer extends UIShopOffer {
	var mGMOfferDetail:GMOfferDetail;

	var mGMOfferHero:GMHero;

	public function new(dbFacade:DBFacade, templateClass:Dynamic, buyCallback:ASFunction = null) {
		super(dbFacade, templateClass, buyCallback);
	}

	override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) {
		this.offer = gmOffer;
		mGMOfferDetail = this.offer.Details[0];
		mGMOfferHero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(mGMOfferDetail.HeroId), gameMasterDictionary.GMHero);
		super.showOffer(gmOffer, gmHero);
	}

	override function IsCashPageExclusiveOffer():Bool {
		return mGMOfferHero.IsExclusive;
	}

	override function get_nativeIconSize():Float {
		return DBGlobal.HERO_ICON_NATIVE_SIZE;
	}

	override function get_offerDescription():String {
		return mGMOfferHero != null ? GameMasterLocale.getGameMasterSubString("SKIN_STORE_DESCRIPTION", mGMOfferHero.Constant) : "";
	}

	override function get_offerIconName():String {
		return mGMOfferHero != null ? mGMOfferHero.IconName : "";
	}

	override function get_offerSwfPath():String {
		var _loc2_:GMSkin = null;
		var _loc1_ = "";
		if (mGMOfferHero != null) {
			_loc2_ = mDBFacade.gameMaster.getSkinByConstant(mGMOfferHero.DefaultSkin);
			_loc1_ = _loc2_.UISwfFilepath;
		}
		return _loc1_;
	}

	override function hasRequirements():Bool {
		return false;
	}

	override function requirementsMetForPurchase():Bool {
		return !mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMOfferDetail.HeroId);
	}
}
