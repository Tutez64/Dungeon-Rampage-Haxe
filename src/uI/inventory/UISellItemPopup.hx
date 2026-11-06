package uI.inventory;

import account.InventoryBaseInfo;
import account.ItemInfo;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import facade.DBFacade;
import facade.Locale;
import uI.popup.DBUITwoButtonPopup;
import flash.display.MovieClip;

class UISellItemPopup extends DBUITwoButtonPopup {
	static inline final POPUP_CLASS_NAME = "item_popup";

	var mInfo:InventoryBaseInfo;

	public function new(dbFacade:DBFacade, titleText:String, info:InventoryBaseInfo, leftText:String, leftCallback:ASFunction, rightText:String,
			rightCallback:ASFunction, allowClose:Bool = true, closeCallback:ASFunction = null) {
		mInfo = info;
		super(dbFacade, "SELL_ITEM_POPUP", titleText, null, leftText, leftCallback, rightText, rightCallback, allowClose, closeCallback);
	}

	override public function destroy() {
		super.destroy();
	}

	override function getClassName():String {
		return "item_popup";
	}

	override function setupMenuNavigation() {
		if (mRightButton == null || mLeftButton == null) {
			super.setupMenuNavigation();
			return;
		}
		if (mCloseButton != null) {
			mCloseButton.isAbove(mRightButton);
		}
		mRightButton.isAbove(mLeftButton);
	}

	override function getInitialFocusedNavigationObject():UIObject {
		return mRightButton;
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var itemInfo:ItemInfo;
		var swfPath:String;
		var iconName:String;
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		itemInfo = ASCompat.reinterpretAs(mInfo, ItemInfo);
		ASCompat.setProperty((mPopup : ASAny).power, "visible", itemInfo != null);
		if (itemInfo != null) {
			Locale.setText(ASCompat.coerce((mPopup : ASAny).power.attack_label, flash.text.TextField), "POWER");
			TextUtil.setText(ASCompat.coerce((mPopup : ASAny).power.label, flash.text.TextField), Std.string(itemInfo.power));
		}
		swfPath = mInfo.uiSwfFilepath;
		iconName = mInfo.iconName;
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath), function(param1:SwfAsset) {
			var _loc3_ = param1.getClass(iconName);
			if (_loc3_ == null) {
				Logger.error("Unable to get iconClass for iconName: " + iconName);
				return;
			}
			var _loc2_ = ASCompat.coerce(ASCompat.createInstance(_loc3_, []), flash.display.MovieClip);
			_loc2_.scaleX = _loc2_.scaleY = 70 / mInfo.iconScale;
			(mPopup : ASAny).item_icon.addChild(_loc2_);
		});
		ASCompat.setProperty((mPopup : ASAny).coin, "visible", true);
		ASCompat.setProperty((mPopup : ASAny).coin, "mouseEnabled", false);
		ASCompat.setProperty((mPopup : ASAny).coin, "mouseChildren", false);
		TextUtil.setText(ASCompat.coerce((mPopup : ASAny).price, flash.text.TextField), Std.string(mInfo.sellCoins));
		ASCompat.setProperty((mPopup : ASAny).price, "mouseEnabled", false);
	}
}
