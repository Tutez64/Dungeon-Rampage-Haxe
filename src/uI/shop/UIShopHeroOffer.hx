package uI.shop;

import brain.uI.UIButton;
import brain.utils.MemoryTracker;
import facade.DBFacade;
import facade.GameMasterLocale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMOfferDetail;
import gameMasterDictionary.GMSkin;
import town.TownHeader;
import uI.*;
import uI.popup.UIHeroUpsellPopup;

class UIShopHeroOffer extends UIShopOffer {
	var mGMOfferDetail:GMOfferDetail;

	var mGMOfferHero:GMHero;

	var mInfoButton:UIButton;

	var mTownHeader:TownHeader;

	public function new(townHeader:TownHeader, dbFacade:DBFacade, templateClass:Dynamic, buyCallback:ASFunction = null) {
		super(dbFacade, templateClass, buyCallback);
		mInfoButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mRoot : ASAny).icon, flash.display.MovieClip));
		mInfoButton.releaseCallback = this.showInfo;
		mTownHeader = townHeader;
	}

	function showInfo() {
		var _loc1_:UIHeroUpsellPopup = null;
		if (this.requirementsMetForPurchase()) {
			_loc1_ = new UIHeroUpsellPopup(mTownHeader, mDBFacade, this.offer, null);
			MemoryTracker.track(_loc1_, "UIHeroUpsellPopup - created in UIShopHeroOffer.showInfo()");
		}
	}

	override public function destroy() {
		if (mInfoButton != null) {
			mInfoButton.destroy();
			mInfoButton = null;
		}
	}

	override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) {
		this.offer = gmOffer;
		mGMOfferDetail = this.offer.Details[0];
		mGMOfferHero = ASCompat.dynamicAs(mDBFacade.gameMaster.heroById.itemFor(mGMOfferDetail.HeroId), gameMasterDictionary.GMHero);
		super.showOffer(gmOffer, gmHero);
	}

	override function IsCashPageExclusiveOffer():Bool {
		return mGMOfferHero.IsExclusive;
	}

	override function get_nativeIconSize():Float {
		return 72;
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
