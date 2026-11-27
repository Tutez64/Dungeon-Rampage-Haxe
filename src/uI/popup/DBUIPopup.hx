package uI.popup;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.event.EventListeners;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import facade.Locale;
import gameMasterDictionary.GMOffer;
import flash.display.MovieClip;
import flash.display.Sprite;
import flash.events.KeyboardEvent;
import flash.text.TextField;
import flash.text.TextFormat;

class DBUIPopup extends UIObject {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_town.swf";

	static inline final POPUP_CLASS_NAME = "popup";

	static inline final EMPTY_POPUP_CLASS_NAME = "UI_loading_popup";

	static inline final CURTAIN_ALPHA:Float = 0.75;

	var mUseOriginalPopUp:Bool = false;

	var mDBFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mWantCurtain:Bool = false;

	var mCurtainActive:Bool = false;

	var mTitle:TextField;

	var mMessage:TextField;

	var mContent:Sprite;

	var mCloseButton:UIButton;

	var mCloseCallback:ASFunction;

	var mPopup:MovieClip;

	var mSwfAsset:SwfAsset;

	var mScalePopup:Bool = false;

	var mUILayerName:String;

	public function new(dbFacade:DBFacade, uiLayerName:String, titleText:String = "", content:ASAny = null, allowClose:Bool = true, wantCurtain:Bool = true,
			closeCallback:ASFunction = null, useOriginalPopUp:Bool = false, scalePopup:Bool = true) {
		mDBFacade = dbFacade;
		super(dbFacade, new MovieClip());
		mUseOriginalPopUp = useOriginalPopUp;
		mScalePopup = scalePopup;
		mWantCurtain = wantCurtain;
		makeCurtain();
		if (waitsOnPlayer() && mDBFacade.uiHideToggle != null) {
			mDBFacade.uiHideToggle.reveal();
		}
		if (allowClose) {
			mCloseCallback = closeCallback;
			EventListeners.add(mDBFacade.stageRef, "keyDown", handleKeyDown);
		}
		mUILayerName = uiLayerName;
		mDBFacade.sceneGraphManager.addChild(mRoot, 105);
		mAssetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(getSwfPath()), function(param1:SwfAsset) {
			setupUI(param1, titleText, content, allowClose, closeCallback);
			completeMenuNavigationSetup();
		});
	}

	public function getPagination():MovieClip {
		Logger.error("Pagination for UIPopup shouldn\'t be available here.");
		return null;
	}

	function useCurtain():Bool {
		return true;
	}

	function waitsOnPlayer():Bool {
		return true;
	}

	function makeCurtain() {
		if (!mCurtainActive) {
			mFacade.sceneGraphManager.showPopupCurtain();
			mCurtainActive = true;
		}
	}

	function removeCurtain() {
		if (mCurtainActive) {
			mCurtainActive = false;
			mFacade.sceneGraphManager.removePopupCurtain();
		}
	}

	function animatedEntrance() {
		makeCurtain();
	}

	override public function destroy() {
		if (mDBFacade == null) {
			return;
		}
		if (ASCompat.stringAsBool(mUILayerName)) {
			removeMenuNavigationLayer();
		}
		mDBFacade.mTween.killTweensOf(mRoot);
		mDBFacade.sceneGraphManager.removeChild(mRoot);
		removeCurtain();
		EventListeners.remove(mDBFacade.stageRef, "keyDown", handleKeyDown);
		mDBFacade = null;
		mCloseCallback = null;
		if (mCloseButton != null) {
			mCloseButton.destroy();
		}
		mAssetLoadingComponent.destroy();
		mPopup = null;
		super.destroy();
	}

	function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_town.swf";
	}

	function getClassName():String {
		return mUseOriginalPopUp ? "popup" : "UI_loading_popup";
	}

	public function colorizeMessage(tf:TextFormat, start:Int, end:Int) {
		mMessage.setTextFormat(tf, start, end);
	}

	function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		mSwfAsset = swfAsset;
		var popupClass = swfAsset.getClass(this.getClassName());
		mPopup = ASCompat.dynamicAs(ASCompat.createInstance(popupClass, []), MovieClip);
		mRoot.addChild(mPopup);
		if (ASCompat.toBool((mPopup : ASAny).message_label)) {
			ASCompat.setProperty((mPopup : ASAny).message_label, "mouseEnabled", false);
		}
		if (ASCompat.toBool((mPopup : ASAny).left_button)) {
			ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
		}
		if (ASCompat.toBool((mPopup : ASAny).center_button)) {
			ASCompat.setProperty((mPopup : ASAny).center_button, "visible", false);
		}
		if (ASCompat.toBool((mPopup : ASAny).right_button)) {
			ASCompat.setProperty((mPopup : ASAny).right_button, "visible", false);
		}
		if (ASCompat.toBool((mPopup : ASAny).title_label)) {
			mTitle = ASCompat.coerce((mPopup : ASAny).title_label, flash.text.TextField);
			TextUtil.setText(mTitle, titleText);
		}
		if (ASCompat.toBool((mPopup : ASAny).message_label)) {
			mMessage = ASCompat.coerce((mPopup : ASAny).message_label, flash.text.TextField);
			mMessage.text = "";
		}
		if (Std.isOfType(content, MovieClip)) {
			mContent = ASCompat.coerce((mPopup : ASAny).content, flash.display.Sprite);
			mContent.addChild(ASCompat.coerce(content, flash.display.DisplayObject));
		} else if (Std.isOfType(content, String)) {
			setMessageText(content);
		}
		if (ASCompat.toBool((mPopup : ASAny).close)) {
			if (allowClose) {
				mCloseButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).close, flash.display.MovieClip));
				mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
				mCloseButton.releaseCallback = function() {
					close(closeCallback);
				};
			} else {
				ASCompat.setProperty((mPopup : ASAny).close, "visible", false);
			}
		}
		if (mScalePopup) {
			scalePopup();
			centerPopup();
		}
		if (mWantCurtain) {
			animatedEntrance();
		}
	}

	function setMessageText(text:String) {
		TextUtil.setText(mMessage, text, 1.55);
		if (mMessage.bottomScrollV < mMessage.numLines) {
			TextUtil.setText(mMessage, text);
		}
	}

	function handleKeyDown(event:KeyboardEvent) {}

	function handleInputCalledClosed() {
		this.close(mCloseCallback);
	}

	function close(callback:ASFunction, offer:GMOffer = null) {
		if (callback != null) {
			if (offer == null) {
				callback();
			} else {
				callback(offer.getDisplayName(mDBFacade.gameMaster, Locale.getString("GIFT_UNKNOWN_NAME")), offer.Id);
			}
		}
		this.destroy();
	}

	function scalePopup() {
		mPopup.scaleX = mPopup.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
	}

	function centerPopup() {
		var _loc1_ = mPopup.getBounds(mDBFacade.scalingRoot);
		mPopup.x = mDBFacade.viewWidth / 2 - _loc1_.width / 2 - _loc1_.x;
		mPopup.y = mDBFacade.viewHeight / 2 - _loc1_.height / 2 - _loc1_.y;
	}

	function initializeMenuNavigationLayer() {
		mDBFacade.menuNavigationController.pushNewLayer(mUILayerName, getNavigationExitCallback(), getDefaultNavigationObject(),
			getInitialFocusedNavigationObject());
	}

	function getNavigationExitCallback():ASFunction {
		return handleInputCalledClosed;
	}

	function getDefaultNavigationObject():UIObject {
		return mCloseButton;
	}

	function getInitialFocusedNavigationObject():UIObject {
		return null;
	}

	function completeMenuNavigationSetup() {
		setupMenuNavigation();
		if (ASCompat.stringAsBool(mUILayerName)) {
			initializeMenuNavigationLayer();
		}
	}

	function removeMenuNavigationLayer() {
		mDBFacade.menuNavigationController.removeLayer(mUILayerName);
	}

	function setupMenuNavigation() {}
}
