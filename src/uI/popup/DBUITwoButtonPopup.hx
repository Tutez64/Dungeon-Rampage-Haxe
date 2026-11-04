package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;

class DBUITwoButtonPopup extends DBUIPopup {
	var mLeftButton:UIButton;

	var mLeftCallback:ASFunction;

	var mLeftText:String;

	var mRightButton:UIButton;

	var mRightCallback:ASFunction;

	var mRightText:String;

	public function new(dbFacade:DBFacade, uiLayerName:String, titleText:String, content:ASAny, leftText:String, leftCallback:ASFunction, rightText:String,
			rightCallback:ASFunction, allowClose:Bool = true, closeCallback:ASFunction = null, useOriginalPopup:Bool = true, scalePopup:Bool = true) {
		mLeftText = leftText;
		mLeftCallback = leftCallback;
		mRightText = rightText;
		mRightCallback = rightCallback;
		super(dbFacade, uiLayerName, titleText, content, allowClose, useCurtain(), closeCallback, useOriginalPopup, scalePopup);
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
			mLeftButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).left_button, flash.display.MovieClip));
			mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			TextUtil.setText(mLeftButton.label, mLeftText);
			mLeftButton.releaseCallback = function() {
				close(mLeftCallback);
			};
		} else {
			ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
		}
		if (ASCompat.stringAsBool(mRightText)) {
			ASCompat.setProperty((mPopup : ASAny).right_button, "visible", true);
			mRightButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).right_button, flash.display.MovieClip));
			mRightButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			TextUtil.setText(mRightButton.label, mRightText);
			mRightButton.releaseCallback = function() {
				close(mRightCallback);
			};
		} else {
			ASCompat.setProperty((mPopup : ASAny).right_button, "visible", false);
		}
	}

	override function getClassName():String {
		return "popup";
	}

	override function setupMenuNavigation() {
		var _loc1_ = ASCompat.stringAsBool(mLeftText) && mLeftButton != null;
		var _loc2_ = ASCompat.stringAsBool(mRightText) && mRightButton != null;
		if (_loc1_ && _loc2_) {
			mRightButton.isToTheLeftOf(mLeftButton);
		}
		if (mCloseButton != null) {
			if (_loc2_) {
				mCloseButton.isAbove(mRightButton);
			}
			if (_loc1_) {
				mLeftButton.upNavigation = mCloseButton;
			}
		}
		if (chooseFocusTarget(_loc1_, _loc2_) == null) {
			Logger.debugch("UI", "DBUITwoButtonPopup: setupMenuNavigation: No buttons found to set focused on");
		}
	}

	function chooseFocusTarget(hasLeft:Bool, hasRight:Bool):UIButton {
		if (hasRight) {
			return mRightButton;
		}
		if (hasLeft) {
			return mLeftButton;
		}
		Logger.debugch("UI", "DBUITwoButtonPopup: setupMenuNavigation: No left or right buttons found to setup navigation for");
		return mCloseButton;
	}

	override function getDefaultNavigationObject():UIObject {
		return chooseFocusTarget(ASCompat.stringAsBool(mLeftText) && mLeftButton != null, ASCompat.stringAsBool(mRightText) && mRightButton != null);
	}
}
