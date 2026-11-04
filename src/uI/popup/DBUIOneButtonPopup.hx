package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.uI.UIButton;
import brain.uI.UIObject;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;

class DBUIOneButtonPopup extends DBUIPopup {
	var mCenterButton:UIButton;

	var mCenterCallback:ASFunction;

	var mCenterText:String;

	var mClassOverride:String;

	var mSwfOverride:String;

	public function new(dbFacade:DBFacade, uiLayerName:String, titleText:String, content:ASAny, centerText:String, centerCallback:ASFunction,
			allowClose:Bool = true, closeCallback:ASFunction = null, classOverride:String = null, swfOverride:String = null, scalePopup:Bool = true) {
		mClassOverride = classOverride;
		mSwfOverride = swfOverride;
		mCenterText = centerText;
		mCenterCallback = centerCallback;
		super(dbFacade, uiLayerName, titleText, content, allowClose, true, closeCallback, true, scalePopup);
	}

	override public function destroy() {
		if (mCenterButton != null) {
			mCenterButton.destroy();
			mCenterButton = null;
		}
		mCenterCallback = null;
		super.destroy();
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		if (ASCompat.stringAsBool(mCenterText)) {
			ASCompat.setProperty((mPopup : ASAny).center_button, "visible", true);
			mCenterButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).center_button, flash.display.MovieClip));
			TextUtil.setText(mCenterButton.label, mCenterText);
			mCenterButton.releaseCallback = this.centerButtonCallback;
			mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
		} else if (ASCompat.toBool((mPopup : ASAny).center_button)) {
			ASCompat.setProperty((mPopup : ASAny).center_button, "visible", false);
		}
	}

	function centerButtonCallback() {
		this.close(mCenterCallback);
	}

	override function getClassName():String {
		if (ASCompat.stringAsBool(mClassOverride)) {
			return mClassOverride;
		}
		return "popup";
	}

	override function getSwfPath():String {
		if (ASCompat.stringAsBool(mSwfOverride)) {
			return mSwfOverride;
		}
		return super.getSwfPath();
	}

	override function setupMenuNavigation() {
		if (mCloseButton != null && mCenterButton != null) {
			mCloseButton.isAbove(mCenterButton);
			mCenterButton.isToTheLeftOf(mCloseButton);
		}
	}

	override function getDefaultNavigationObject():UIObject {
		return mCenterButton != null ? mCenterButton : mCloseButton;
	}
}
