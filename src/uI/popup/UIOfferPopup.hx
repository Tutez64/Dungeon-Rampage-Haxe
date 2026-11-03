package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import gameMasterDictionary.GMOffer;
import uI.shop.UIShopBundleOffer;
import uI.shop.UIShopOffer;
import flash.display.MovieClip;

class UIOfferPopup extends DBUIPopup {
	static inline final TEMPLATE_CLASSNAME = "shop_offer_template";

	static inline final PREMIUM_TEMPLATE_CLASSNAME = "shop_offer_premium_template";

	static inline final DLC_TEMPLATE_CLASSNAME = "shop_offer_dlc_template";

	static inline final POPUP_CLASS_NAME = "coin_purchase_popup";

	var mOfferIds:Vector<UInt>;

	var mBuyCallback:ASFunction;

	var mOfferTemplateClass:Dynamic;

	var mPremiumOfferTemplateClass:Dynamic;

	var mDLCOfferTemplateClass:Dynamic;

	var mUIOffers:Vector<UIShopOffer> = new Vector();

	var mEmptyOffers:Vector<MovieClip> = new Vector();

	var mUseIconScaling:Bool = false;

	var mWantNewRollOverScale:Bool = false;

	public function new(dbFacade:DBFacade, titleText:String, offerIds:Vector<UInt>, buyCallback:ASFunction, closeCallback:ASFunction,
			useIconScaling:Bool = true, wantNewRollOverScale:Bool = true, navigationLayerName:String = "POPUP_OFFER") {
		mOfferIds = offerIds;
		mBuyCallback = buyCallback;
		mUseIconScaling = useIconScaling;
		mWantNewRollOverScale = wantNewRollOverScale;
		super(dbFacade, navigationLayerName, titleText, null, true, true, closeCallback, false);
	}

	override public function destroy() {
		mBuyCallback = null;
		mUIOffers = null;
		mEmptyOffers = null;
		mOfferTemplateClass = null;
		super.destroy();
	}

	override function getClassName():String {
		return "coin_purchase_popup";
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var offerId:UInt;
		var emptyOffer:MovieClip;
		var gmOffer:GMOffer;
		var uiShopOffer:UIShopBundleOffer;
		var offerClass:Dynamic;
		var i:UInt;
		var callback:GMOffer->Void;
		var popupClass = swfAsset.getClass(this.getClassName());
		mPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
		mRoot.addChild(mPopup);
		mPopup.scaleY = mPopup.scaleX = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		centerPopup();
		mTitle = ASCompat.coerce((mPopup : ASAny).title_label, flash.text.TextField);
		TextUtil.setText(mTitle, titleText);
		mEmptyOffers.push(ASCompat.coerce((mPopup : ASAny).coin_shop_empty_slot_1, flash.display.MovieClip));
		mEmptyOffers.push(ASCompat.coerce((mPopup : ASAny).coin_shop_empty_slot_2, flash.display.MovieClip));
		mEmptyOffers.push(ASCompat.coerce((mPopup : ASAny).coin_shop_empty_slot_3, flash.display.MovieClip));
		mOfferTemplateClass = swfAsset.getClass("shop_offer_template");
		mPremiumOfferTemplateClass = swfAsset.getClass("shop_offer_premium_template");
		mDLCOfferTemplateClass = swfAsset.getClass("shop_offer_dlc_template");
		i = (0 : UInt);
		while (i < (mOfferIds.length:UInt)) {
			callback = function(param1:GMOffer) {
				close(mBuyCallback, param1);
			};
			offerId = mOfferIds[(i : Int)];
			gmOffer = ASCompat.coerce(mDBFacade.gameMaster.offerById.itemFor(offerId), gameMasterDictionary.GMOffer);
			offerClass = gmOffer.CurrencyType == GMOffer.PREMIUM_CURRENCY
				&& ASCompat.floatAsBool(gmOffer.Price) ? mPremiumOfferTemplateClass : mOfferTemplateClass;
			uiShopOffer = new UIShopBundleOffer(mDBFacade, offerClass, callback, mUseIconScaling, mWantNewRollOverScale);
			emptyOffer = mEmptyOffers[(i : Int)];
			emptyOffer.parent.addChild(uiShopOffer.root);
			uiShopOffer.root.x = emptyOffer.x;
			uiShopOffer.root.y = emptyOffer.y;
			mUIOffers[(i : Int)] = uiShopOffer;
			uiShopOffer.showOffer(gmOffer, null);
			uiShopOffer.root.visible = true;
			mEmptyOffers[(i : Int)].visible = false;
			i = i + 1;
		}
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).close, flash.display.MovieClip));
		mCloseButton.releaseCallback = function() {
			close(closeCallback);
		};
		animatedEntrance();
	}

	override function setupMenuNavigation() {
		var _loc2_ = (0 : UInt);
		var _loc1_ = getNavigationButtons();
		var _loc3_:UIButton;
		if (checkNullIteratee(_loc1_))
			for (_tmp_ in _loc1_) {
				_loc3_ = _tmp_;
				_loc3_.clearNavigationAndInteractions();
			}
		mCloseButton.clearNavigationAndInteractions();
		_loc2_ = (0 : UInt);
		while (_loc2_ < (_loc1_.length:UInt)) {
			_loc1_[(_loc2_ : Int)].upNavigation = mCloseButton;
			if (_loc2_ > 0) {
				_loc1_[(_loc2_ - 1 : Int)].isToTheLeftOf(_loc1_[(_loc2_ : Int)]);
			}
			_loc2_++;
		}
		if (_loc1_.length > 0) {
			mCloseButton.downNavigation = _loc1_[0];
		}
	}

	override function getInitialFocusedNavigationObject():UIObject {
		var _loc1_ = getNavigationButtons();
		return _loc1_.length > 0 ? _loc1_[0] : mCloseButton;
	}

	function getNavigationButtons():Vector<UIButton> {
		var _loc1_ = new Vector<UIButton>();
		var _loc2_:UIShopOffer;
		final __ax4_iter_32 = mUIOffers;
		if (checkNullIteratee(__ax4_iter_32))
			for (_tmp_ in __ax4_iter_32) {
				_loc2_ = _tmp_;
				if (_loc2_.navigationButton != null) {
					_loc1_.push(_loc2_.navigationButton);
				}
			}
		return _loc1_;
	}
}
