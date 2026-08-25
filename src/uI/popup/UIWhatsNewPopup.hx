package uI.popup;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import brain.uI.UIButton;
import brain.utils.MemoryTracker;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import flash.display.MovieClip;
import flash.net.URLRequest;

class UIWhatsNewPopup extends DBUITwoButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	var mPopUpClassName:String = "whatsnew_popup";

	var mImageURL:String;

	var mImageLocator:MovieClip;

	var massetLoadingComponent:AssetLoadingComponent;

	var mLoadingPopUp:DBUIPopup;

	var mImageRetreived:Bool = false;

	var mUseCurtain:Bool = true;

	public function new(dbFacade:DBFacade, popupClassName:String, titleText:String, messageText:String, imageURL:String, mainText:String,
			mainCallback:ASFunction, webText:String, webURL:String, showPagination:Bool) {
		var webCallback:ASFunction = null;
		massetLoadingComponent = new AssetLoadingComponent(dbFacade);
		mImageURL = imageURL;
		mPopUpClassName = popupClassName;
		if (ASCompat.stringAsBool(webURL)) {
			webCallback = function() {
				var _loc1_ = new URLRequest(webURL);
				flash.Lib.getURL(_loc1_, "_blank");
			};
		}
		mUseCurtain = !showPagination;
		super(dbFacade, titleText, messageText, mainText, mainCallback, webText, webCallback);
		if (!mImageRetreived) {
			mLoadingPopUp = new DBUIPopup(mDBFacade, "LOADING");
			MemoryTracker.track(mLoadingPopUp, "DBUIPopup - created in UIWhatsNewPopup.UIWhatsNewPopup()");
		}
		if (!showPagination) {
			ASCompat.setProperty((mPopup : ASAny).left_button_news, "visible", false);
			ASCompat.setProperty((mPopup : ASAny).pagination, "visible", false);
		} else {
			ASCompat.setProperty((mPopup : ASAny).left_button, "visible", false);
			mLeftButton = new UIButton(mDBFacade, ASCompat.dynamicAs((mPopup : ASAny).left_button_news, flash.display.MovieClip));
			mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			mLeftButton.label.text = mLeftText;
			mLeftButton.releaseCallback = function() {
				close(mLeftCallback);
			};
		}
	}

	override function animatedEntrance() {
		if (mUseCurtain) {
			super.animatedEntrance();
		}
	}

	override public function getPagination():MovieClip {
		return ASCompat.dynamicAs((mPopup : ASAny).pagination, flash.display.MovieClip);
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_screens.swf";
	}

	override function getClassName():String {
		return mPopUpClassName;
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText.toUpperCase(), content, allowClose, closeCallback);
		Logger.debug("MOD: mPopup: " + mPopup);
		mImageLocator = ASCompat.dynamicAs((mPopup : ASAny).whatsnew_image, flash.display.MovieClip);
		Logger.debug("MOD: ImageLocator: " + mImageLocator);
		massetLoadingComponent.getImageAsset(mImageURL, function(param1:brain.assetRepository.ImageAsset) {
			if (mLoadingPopUp != null) {
				mLoadingPopUp.destroy();
				mLoadingPopUp = null;
			}
			Logger.debug("MOD: ImageAsset: " + param1);
			mImageLocator.addChild(param1.image);
			param1.image.x = param1.image.width * -0.5;
			param1.image.y = param1.image.height * -0.5;
			mImageRetreived = true;
		}, function() {
			if (mLoadingPopUp != null) {
				mLoadingPopUp.destroy();
				mLoadingPopUp = null;
			}
		});
	}

	override public function destroy() {
		if (massetLoadingComponent != null) {
			massetLoadingComponent.destroy();
			massetLoadingComponent = null;
		}
		super.destroy();
		mImageLocator = null;
	}
}
