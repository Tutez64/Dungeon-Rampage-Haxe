package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMOffer;
import gameMasterDictionary.GMSkin;
import flash.display.MovieClip;
import flash.text.TextField;

class DBUIConfirmChestPurchasePopup extends DBUIPopup {
	static inline final TOWN_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final POPUP_CLASS_NAME = "chest_shop_popup";

	var mChestOffer:GMOffer;

	var mSelectedHeroSkin:GMSkin;

	var mCancelButton:UIButton;

	var mBuyButton:UIButton;

	var mTitleLabel:TextField;

	var mHeroLabel:TextField;

	var mTextContentLabel:TextField;

	var mItemIcon:MovieClip;

	var mAvatarIcon:MovieClip;

	var mBuyCallback:ASFunction;

	public function new(dbFacade:DBFacade, buyCallback:ASFunction, cancelCallback:ASFunction, chestOffer:GMOffer, forHeroSkin:UInt, allowClose:Bool = true,
			closeCallback:ASFunction = null) {
		mChestOffer = chestOffer;
		mBuyCallback = buyCallback;
		mSelectedHeroSkin = ASCompat.dynamicAs(dbFacade.gameMaster.skinsById.itemFor(forHeroSkin), GMSkin);
		if (mSelectedHeroSkin == null) {
			Logger.error("Unable to find GMSkin for skin id: " + forHeroSkin);
		}
		super(dbFacade, "CONFIRM_CHEST_PURCHASE_POPUP", "", null, allowClose, true, cancelCallback, false, false);
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_town.swf";
	}

	override function getClassName():String {
		return "chest_shop_popup";
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		mSwfAsset = swfAsset;
		var popupClass = swfAsset.getClass("chest_shop_popup");
		mPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), MovieClip);
		mRoot.addChild(mPopup);
		mCloseButton = new UIButton(mFacade, ASCompat.coerce((mPopup : ASAny).close, flash.display.MovieClip));
		mCloseButton.releaseCallback = handleInputCalledClosed;
		mCancelButton = new UIButton(mFacade, ASCompat.coerce((mPopup : ASAny).button_cancel, flash.display.MovieClip));
		mCancelButton.releaseCallback = handleInputCalledClosed;
		Locale.setText(mCancelButton.label, "CANCEL");
		mBuyButton = new UIButton(mFacade, ASCompat.coerce((mPopup : ASAny).buy_button_gems, flash.display.MovieClip));
		mBuyButton.releaseCallback = mBuyCallback;
		TextUtil.setText(mBuyButton.label, Std.string(mChestOffer.Price));
		ASCompat.setProperty((mBuyButton.root : ASAny).original_price, "visible", false);
		ASCompat.setProperty((mBuyButton.root : ASAny).icons_bundle.coin, "visible", false);
		ASCompat.setProperty((mBuyButton.root : ASAny).icons_bundle.gift_icon, "visible", false);
		ASCompat.setProperty((mBuyButton.root : ASAny).strike, "visible", false);
		mTitleLabel = ASCompat.coerce((mPopup : ASAny).label, flash.text.TextField);
		Locale.setText(mTitleLabel, "CONFIRM_SHOP_CHEST_PURCHASE");
		mItemIcon = ASCompat.coerce((mPopup : ASAny).icon_slot, flash.display.MovieClip);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mChestOffer.BundleSwfFilepath), function(param1:SwfAsset) {
			var _loc3_ = param1.getClass(mChestOffer.BundleIcon);
			var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
			mItemIcon.addChild(_loc2_);
		});
		mHeroLabel = ASCompat.coerce((mPopup : ASAny).hero_label, flash.text.TextField);
		Locale.setText(mHeroLabel, "OPENING_WITH");
		mTextContentLabel = ASCompat.coerce((mPopup : ASAny).text, flash.text.TextField);
		Locale.setText(mTextContentLabel, "PURCHASE_AND_OPEN_CHEST_TEXT_CONTENT");
		mAvatarIcon = ASCompat.coerce((mPopup : ASAny).avatar, flash.display.MovieClip);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mSelectedHeroSkin.IconSwfFilepath), function(param1:SwfAsset) {
			var _loc2_ = param1.getClass(mSelectedHeroSkin.IconName);
			var _loc3_ = ASCompat.coerce(ASCompat.createInstance(_loc2_, []), flash.display.MovieClip);
			mAvatarIcon.addChild(_loc3_);
		});
		mPopup.x = mFacade.viewWidth * 0.5;
		mPopup.y = mFacade.viewHeight * 0.5 - 50;
	}

	override function setupMenuNavigation() {
		mBuyButton.isToTheLeftOf(mCancelButton);
		mCloseButton.isAbove(mBuyButton);
	}

	override function getDefaultNavigationObject():UIObject {
		return mCloseButton;
	}

	override function getInitialFocusedNavigationObject():UIObject {
		return mBuyButton;
	}

	override public function destroy() {
		if (mDBFacade == null) {
			return;
		}
		if (mCloseButton != null) {
			mCloseButton.destroy();
			mCloseButton = null;
		}
		if (mCancelButton != null) {
			mCancelButton.destroy();
			mCancelButton = null;
		}
		if (mBuyButton != null) {
			mBuyButton.destroy();
			mBuyButton = null;
		}
		super.destroy();
	}
}
