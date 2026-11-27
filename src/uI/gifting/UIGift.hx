package uI.gifting;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.event.EventListeners;
import brain.sceneGraph.SceneGraphComponent;
import brain.sceneGraph.SceneGraphManager;
import brain.uI.UIButton;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import flash.display.MovieClip;
import flash.events.KeyboardEvent;
import flash.text.TextField;

class UIGift {
	public static inline final GIFT_POPUP_CLASS_NAME = "gift_popup";

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mSceneGraphComponent:SceneGraphComponent;

	var mTownRoot:MovieClip;

	var mGiftPopup:MovieClip;

	var mCurtainActive:Bool = false;

	var mCloseCallback:ASFunction;

	var mStoreCallback:ASFunction;

	var mCloseButton:UIButton;

	var mAcceptAllGiftsButton:UIButton;

	var mSendGiftButton:UIButton;

	var mScrollUpButton:UIButton;

	var mScrollDownButton:UIButton;

	var mScrollIndex:Int = 0;

	var mGiftsVector:Vector<UIGiftMessage>;

	var mInfoMessageTF:TextField;

	public function new(dbFacade:DBFacade, townRoot:MovieClip, closeCallback:ASFunction, callbackToStore:ASFunction) {
		mDBFacade = dbFacade;
		mTownRoot = townRoot;
		mCloseCallback = closeCallback;
		mStoreCallback = callbackToStore;
		mGiftsVector = new Vector<UIGiftMessage>();
		mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
		mSceneGraphComponent = new SceneGraphComponent(mDBFacade, "UIGift");
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"), giftPopupLoaded);
		EventListeners.add(mDBFacade.stageRef, "keyDown", handleKeyDown);
	}

	function giftPopupLoaded(swfAsset:SwfAsset) {
		var popupClass = swfAsset.getClass("gift_popup");
		mGiftPopup = ASCompat.coerce(ASCompat.createInstance(popupClass, []), flash.display.MovieClip);
		Locale.setText(ASCompat.coerce((mGiftPopup : ASAny).title_label, flash.text.TextField), "GIFT_POPUP_TITLE");
		mGiftPopup.scaleY = mGiftPopup.scaleX = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
		mGiftPopup.x = 300;
		mSendGiftButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).left_button, flash.display.MovieClip));
		Locale.setText(mSendGiftButton.label, "GIFT_POPUP_SEND_GIFT");
		mSendGiftButton.releaseCallback = function() {
			if (mStoreCallback != null) {
				mStoreCallback();
			}
		};
		mAcceptAllGiftsButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).right_button, flash.display.MovieClip));
		Locale.setText(mAcceptAllGiftsButton.label, "GIFT_POPUP_ACCEPT_ALL");
		if (mDBFacade.dbAccountInfo.gifts.size > 0) {
			mAcceptAllGiftsButton.releaseCallback = function() {
				mDBFacade.dbAccountInfo.acceptAllGifts(refresh);
			};
		} else {
			mAcceptAllGiftsButton.enabled = false;
			SceneGraphManager.setGrayScaleSaturation(mAcceptAllGiftsButton.root, 10);
		}
		mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).close, flash.display.MovieClip));
		mCloseButton.releaseCallback = this.destroy;
		mGiftsVector.push(new UIGiftMessage(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).message_1, flash.display.MovieClip), this));
		mGiftsVector.push(new UIGiftMessage(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).message_2, flash.display.MovieClip), this));
		mGiftsVector.push(new UIGiftMessage(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).message_3, flash.display.MovieClip), this));
		mGiftsVector.push(new UIGiftMessage(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).message_4, flash.display.MovieClip), this));
		mGiftsVector.push(new UIGiftMessage(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).message_5, flash.display.MovieClip), this));
		mScrollUpButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).up, flash.display.MovieClip));
		mScrollDownButton = new UIButton(mDBFacade, ASCompat.coerce((mGiftPopup : ASAny).down, flash.display.MovieClip));
		if (mDBFacade.dbAccountInfo.gifts.size < (mGiftsVector.length:UInt)) {
			mScrollDownButton.visible = false;
			mScrollUpButton.visible = false;
		}
		mScrollUpButton.releaseCallback = function() {
			scrollIndex = -1;
		};
		mScrollDownButton.releaseCallback = function() {
			scrollIndex = 1;
		};
		mScrollIndex = 0;
		mSceneGraphComponent.addChild(mGiftPopup, (105 : UInt));
		showCurtain();
		scrollIndex = 0;
		mInfoMessageTF = ASCompat.coerce((mGiftPopup : ASAny).message_label, flash.text.TextField);
		Locale.setText(mInfoMessageTF, "GIFT_POPUP_INFO_MESSAGE", null, 1.55);
		TextUtil.fitToField(mInfoMessageTF);
		setupMenuNavigation();
	}

	function setupMenuNavigation() {
		var _loc3_ = (0 : UInt);
		var _loc2_:UIGiftMessage = null;
		mDBFacade.menuNavigationController.pushNewLayer("RECEIVED_GIFTS_POPUP", destroy, mCloseButton);
		_loc3_ = (0 : UInt);
		while (_loc3_ < (mGiftsVector.length:UInt)) {
			_loc2_ = mGiftsVector[(_loc3_ : Int)];
			_loc2_.acceptAndSendButton.isToTheLeftOf(_loc2_.declineButton);
			if (_loc3_ + 1 < (mGiftsVector.length : UInt)) {
				_loc2_.acceptAndSendButton.isAbove(mGiftsVector[(_loc3_ + 1 : Int)].acceptAndSendButton);
				_loc2_.declineButton.isAbove(mGiftsVector[(_loc3_ + 1 : Int)].declineButton);
			}
			_loc3_++;
		}
		var _loc4_ = mGiftsVector[0];
		var _loc1_ = mGiftsVector[mGiftsVector.length - 1];
		mScrollUpButton.isAbove(_loc4_.acceptAndSendButton);
		_loc4_.declineButton.upNavigation = mScrollUpButton;
		_loc1_.acceptAndSendButton.isAbove(mScrollDownButton);
		_loc1_.declineButton.downNavigation = mScrollDownButton;
		mScrollUpButton.isToTheLeftOf(mCloseButton);
		mCloseButton.downNavigation = mScrollUpButton;
		mAcceptAllGiftsButton.isToTheLeftOf(mScrollDownButton);
		mScrollDownButton.isToTheLeftOf(mSendGiftButton);
		mAcceptAllGiftsButton.upNavigation = _loc1_.declineButton;
		mSendGiftButton.upNavigation = _loc1_.acceptAndSendButton;
		mScrollUpButton.upNavigation = mCloseButton;
		mScrollDownButton.downNavigation = mAcceptAllGiftsButton;
	}

	function showCurtain() {
		if (!mCurtainActive) {
			mCurtainActive = true;
			mSceneGraphComponent.showPopupCurtain();
		}
	}

	function removeCurtain() {
		if (mCurtainActive) {
			mCurtainActive = false;
			mSceneGraphComponent.removePopupCurtain();
		}
	}

	function populateGiftMessages() {
		var _loc2_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		var _loc1_ = mDBFacade.dbAccountInfo.gifts.keysToArray();
		if (_loc1_.length < mGiftsVector.length) {
			hideGiftMessages();
		}
		_loc2_ = (0 : UInt);
		while (_loc2_ < (mGiftsVector.length:UInt)) {
			_loc3_ = _loc2_ + mScrollIndex;
			if (_loc3_ >= (_loc1_.length : UInt)) {
				break;
			}
			mGiftsVector[(_loc2_ : Int)].visible = true;
			mGiftsVector[(_loc2_ : Int)].populateGiftMessage(ASCompat.coerce(mDBFacade.dbAccountInfo.gifts.itemFor(_loc1_[(_loc3_ : Int)]), account.GiftInfo));
			_loc2_++;
		}
	}

	@:isVar public var scrollIndex(never, set):Int;

	public function set_scrollIndex(value:Int):Int {
		mScrollIndex += value;
		var _loc2_ = (0 : UInt);
		if (mDBFacade.dbAccountInfo.gifts.size > (mGiftsVector.length : UInt)) {
			_loc2_ = mDBFacade.dbAccountInfo.gifts.size - mGiftsVector.length;
		}
		if (mScrollIndex <= 0) {
			mScrollIndex = 0;
		}
		if ((mScrollIndex : UInt) >= _loc2_) {
			mScrollIndex = (_loc2_ : Int);
		}
		if (mScrollIndex == 0) {
			mScrollUpButton.enabled = false;
		} else {
			mScrollUpButton.enabled = true;
		}
		if ((mScrollIndex : UInt) == _loc2_) {
			mScrollDownButton.enabled = false;
		} else {
			mScrollDownButton.enabled = true;
		}
		populateGiftMessages();
		return value;
	}

	function hideGiftMessages() {
		var _loc1_ = (0 : UInt);
		_loc1_ = (0 : UInt);
		while (_loc1_ < (mGiftsVector.length:UInt)) {
			mGiftsVector[(_loc1_ : Int)].visible = false;
			_loc1_++;
		}
	}

	public function refresh() {
		populateGiftMessages();
		if (mDBFacade.dbAccountInfo.gifts.size == 0) {
			destroy();
		}
	}

	function handleKeyDown(event:KeyboardEvent) {
		if (event.keyCode == 27) {
			this.destroy();
		}
	}

	public function destroy() {
		if (mDBFacade == null) {
			return;
		}
		EventListeners.remove(mDBFacade.stageRef, "keyDown", handleKeyDown);
		mDBFacade.menuNavigationController.popLayer("RECEIVED_GIFTS_POPUP");
		mDBFacade = null;
		if (mGiftPopup != null) {
			mSceneGraphComponent.removeChild(mGiftPopup);
		}
		removeCurtain();
		mGiftPopup = null;
		mTownRoot = null;
		mStoreCallback = null;
		if (mCloseButton != null) {
			mCloseButton.destroy();
		}
		mCloseButton = null;
		if (mAcceptAllGiftsButton != null) {
			mAcceptAllGiftsButton.root.filters = cast([]);
			mAcceptAllGiftsButton.destroy();
		}
		mAcceptAllGiftsButton = null;
		if (mSendGiftButton != null) {
			mSendGiftButton.destroy();
		}
		mSendGiftButton = null;
		var _loc1_:UIGiftMessage;
		final __ax4_iter_1 = mGiftsVector;
		if (checkNullIteratee(__ax4_iter_1))
			for (_tmp_ in __ax4_iter_1) {
				_loc1_ = _tmp_;
				_loc1_.destroy();
				_loc1_ = null;
			}
		mGiftsVector.splice(0, (mGiftsVector.length : UInt));
		if (mAssetLoadingComponent != null) {
			mAssetLoadingComponent.destroy();
		}
		mAssetLoadingComponent = null;
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
			mSceneGraphComponent = null;
		}
		if (mCloseCallback != null) {
			mCloseCallback();
		}
		mCloseCallback = null;
	}
}
