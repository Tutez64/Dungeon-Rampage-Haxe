package uI.inventory;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.GameMasterLocale;
import facade.Locale;
import gameMasterDictionary.GMHero;
import gameMasterDictionary.GMNpc;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMOfferDetail;
import gameMasterDictionary.GMSkin;
import gameMasterDictionary.GMWeaponAesthetic;
import gameMasterDictionary.GMWeaponItem;
import uI.popup.DBUITwoButtonPopup;
import flash.display.MovieClip;

class UIPurchaseOfferPopup extends DBUITwoButtonPopup {
	var mPopupClassName:String;

	var mGMOffer:GMOffer;

	public function new(dbFacade:DBFacade, uiLayerName:String, popupClassName:String, titleText:String, offer:GMOffer, leftText:String,
			leftCallback:ASFunction, rightText:String, rightCallback:ASFunction, allowClose:Bool = true, closeCallback:ASFunction = null) {
		mGMOffer = offer;
		mPopupClassName = popupClassName;
		super(dbFacade, uiLayerName, titleText, null, leftText, leftCallback, rightText, rightCallback, allowClose, closeCallback);
	}

	override public function destroy() {
		super.destroy();
	}

	override function getClassName():String {
		return mPopupClassName;
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var swfPath:String = null;
		var iconName:String = null;
		var offerName:String;
		var offerDetail:GMOfferDetail;
		var weaponItem:GMWeaponItem;
		var weaponAesthetic:GMWeaponAesthetic;
		var hero:GMHero;
		var defaultSkin:GMSkin;
		var pet:GMNpc;
		var skin:GMSkin;
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		offerName = "";
		ASCompat.setProperty((mPopup : ASAny).power, "visible", false);
		if (mGMOffer.IsBundle) {
			offerName = mGMOffer.BundleName;
			swfPath = mGMOffer.BundleSwfFilepath;
			iconName = mGMOffer.BundleIcon;
		} else {
			offerDetail = mGMOffer.Details[0];
			if (offerDetail.WeaponId != 0) {
				weaponItem = ASCompat.coerce(mDBFacade.gameMaster.weaponItemById.itemFor(offerDetail.WeaponId), gameMasterDictionary.GMWeaponItem);
				weaponAesthetic = weaponItem.getWeaponAesthetic(offerDetail.Level);
				offerName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME", weaponAesthetic.Constant);
				swfPath = weaponAesthetic.IconSwf;
				iconName = weaponAesthetic.IconName;
				ASCompat.setProperty((mPopup : ASAny).power, "visible", true);
				TextUtil.setText(ASCompat.coerce((mPopup : ASAny).power.label, flash.text.TextField), Std.string(offerDetail.WeaponPower));
				Locale.setText(ASCompat.coerce((mPopup : ASAny).power.attack_label, flash.text.TextField), "POWER");
			} else if (offerDetail.HeroId != 0) {
				hero = ASCompat.coerce(mDBFacade.gameMaster.heroById.itemFor(offerDetail.HeroId), gameMasterDictionary.GMHero);
				defaultSkin = mDBFacade.gameMaster.getSkinByConstant(hero.DefaultSkin);
				if (defaultSkin != null) {
					offerName = GameMasterLocale.getGameMasterSubString("SKIN_NAME", defaultSkin.Constant);
					swfPath = defaultSkin.UISwfFilepath;
					iconName = defaultSkin.IconName;
				}
			} else if (offerDetail.PetId != 0) {
				pet = ASCompat.coerce(mDBFacade.gameMaster.npcById.itemFor(offerDetail.PetId), gameMasterDictionary.GMNpc);
				offerName = GameMasterLocale.getGameMasterSubString("PET_NAME", pet.Constant);
				swfPath = pet.IconSwfFilepath;
				iconName = pet.IconName;
			} else if (offerDetail.SkinId != 0) {
				skin = mDBFacade.gameMaster.getSkinByType(offerDetail.SkinId);
				offerName = GameMasterLocale.getGameMasterSubString("SKIN_NAME", skin.Constant);
				swfPath = skin.UISwfFilepath;
				iconName = skin.IconName;
			}
		}
		if (ASCompat.stringAsBool(swfPath) && ASCompat.stringAsBool(iconName)) {
			mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath), function(param1:SwfAsset) {
				var _loc3_ = param1.getClass(iconName);
				if (_loc3_ == null) {
					Logger.error("Unable to get iconClass for iconName: " + iconName);
					return;
				}
				var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
				_loc2_.scaleX = _loc2_.scaleY = 70 / DBGlobal.WEAPON_ICON_NATIVE_SIZE;
				(mPopup : ASAny).item_icon.addChild(_loc2_);
			});
		}
		if ((mPopup : ASAny).message_label != null) {
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).message_label, flash.text.TextField), offerName);
		}
		ASCompat.setProperty((mPopup : ASAny).cash, "visible", mGMOffer.Price > 0 && mGMOffer.CurrencyType == GMOffer.PREMIUM_CURRENCY);
		ASCompat.setProperty((mPopup : ASAny).coin, "visible", mGMOffer.Price > 0 && mGMOffer.CurrencyType == GMOffer.BASIC_CURRENCY);
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).price, flash.text.TextField),
			mGMOffer.Price > 0 ? Std.string(mGMOffer.Price) : Locale.getString("SHOP_FREE"));
	}
}
