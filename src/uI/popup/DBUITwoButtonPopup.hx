package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import uI.*;

class DBUITwoButtonPopup extends DBUIPopup {
	var mLeftButton:UIButton;

	var mLeftCallback:ASFunction;

	var mLeftText:String;

	var mRightButton:UIButton;

	var mRightCallback:ASFunction;

	var mRightText:String;

	public function new(dbFacade:DBFacade, titleText:String, content:ASAny, leftText:String, leftCallback:ASFunction, rightText:String,
			rightCallback:ASFunction, allowClose:Bool = true, closeCallback:ASFunction = null, useOriginalPopup:Bool = true, scalePopup:Bool = true,
			UILayerName:String = "") {
		mLeftText = leftText;
		mLeftCallback = leftCallback;
		mRightText = rightText;
		mRightCallback = rightCallback;
		super(dbFacade, titleText, content, allowClose, useCurtain(), closeCallback, useOriginalPopup, scalePopup, UILayerName);
	}

	override public function destroy() {
		if (mLeftButton != null) {
			mLeftButton.destroy();
			mLeftButton = null;
		}
		if (mRightButton != null) {
			mRightButton.destroy();
			mRightButton = null;
		}
		mLeftCallback = null;
		mRightCallback = null;
		super.destroy();
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		if (ASCompat.stringAsBool(mLeftText)) {
			ASCompat.setProperty((mPopup : ASAny).left_button, "visible", true);
			mLeftButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mPopup : ASAny).left_button, flash.display.MovieClip));
			mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			mLeftButton.label.text = mLeftText;
			mLeftButton.releaseCallback = function() {
				close(mLeftCallback);
			};
		} else {
			ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
		}
		if (ASCompat.stringAsBool(mRightText)) {
			ASCompat.setProperty((mPopup : ASAny).right_button, "visible", true);
			mRightButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mPopup : ASAny).right_button, flash.display.MovieClip));
			mRightButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			mRightButton.label.text = mRightText;
			mRightButton.releaseCallback = function() {
				close(mRightCallback);
			};
		} else {
			ASCompat.setProperty((mPopup : ASAny).right_button, "visible", false);
		}
		setupMenuNavigation();
	}

	override function getClassName():String {
		return "popup";
	}

	override function setupMenuNavigation() {
		if (ASCompat.stringAsBool(mLeftText) && ASCompat.stringAsBool(mRightText)) {
			mRightButton.isToTheLeftOf(mLeftButton);
			if (mCloseButton != null) {
				mCloseButton.isAbove(mLeftButton);
			}
		}
		if (ASCompat.stringAsBool(mUILayerName)) {
			if (mCloseButton != null) {
				mDBFacade.menuNavigationController.pushNewLayer(mUILayerName, mCloseCallback, mCloseButton);
			} else {
				mDBFacade.menuNavigationController.pushNewLayer(mUILayerName, mCloseCallback, mLeftButton);
			}
		}
	}

	override function initializeMenuNavigationLayer() {}
}
