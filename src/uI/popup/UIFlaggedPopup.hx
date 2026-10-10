package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import facade.DBFacade;
import facade.Locale;
import flash.net.URLRequest;
import flash.text.TextFormat;

class UIFlaggedPopup extends DBUITwoButtonPopup {
	public function new(dbFacade:DBFacade, isFlaggedDueToFamilySharingOwnerIsFlag:Bool, isFlaggedDueToFamilySharingOwnerName:String,
			isFlaggedUntilAfterDate:String) {
		var _loc7_:String = null;
		var _loc9_:String = null;
		var _loc5_:String = null;
		var _loc8_:ASFunction = null;
		var _loc10_:String = null;
		var _loc6_:ASFunction = null;
		if (isFlaggedDueToFamilySharingOwnerIsFlag) {
			_loc7_ = Locale.getString("FLAGGED_POPUP_TITLE");
			_loc9_ = Locale.getString("FLAGGED_POPUP_MESSAGE_FAMILY_SHARING_OWNER") + "" + isFlaggedDueToFamilySharingOwnerName;
			_loc5_ = Locale.getString("OK");
			_loc8_ = closePopupAction;
			_loc10_ = Locale.getString("FLAGGED_READ_RULES");
			_loc6_ = readGameRules;
		} else if (isFlaggedUntilAfterDate != "" && isFlaggedUntilAfterDate != null) {
			_loc7_ = Locale.getString("FLAGGED_POPUP_TITLE");
			_loc9_ = Locale.getString("FLAGGED_POPUP_MESSAGE_UNTIL_DATE") + "\n" + isFlaggedUntilAfterDate;
			_loc5_ = Locale.getString("OK");
			_loc8_ = closePopupAction;
			_loc10_ = Locale.getString("FLAGGED_READ_RULES");
			_loc6_ = readGameRules;
		} else {
			_loc7_ = Locale.getString("FLAGGED_POPUP_TITLE");
			_loc9_ = Locale.getString("FLAGGED_POPUP_MESSAGE_NORMAL");
			_loc5_ = Locale.getString("OK");
			_loc8_ = closePopupAction;
			_loc10_ = Locale.getString("FLAGGED_READ_RULES");
			_loc6_ = readGameRules;
		}
		super(dbFacade, _loc7_, _loc9_, _loc5_, _loc8_, _loc10_, _loc6_, true, null);
	}

	function readGameRules() {
		var _loc2_:URLRequest = null;
		var _loc1_ = mDBFacade.mSteamworks.isOverlayEnabled();
		var _loc3_ = mDBFacade.stageRef.displayState == "fullScreenInteractive";
		if (_loc1_ && _loc3_) {
			Logger.debug("Using activateGameOverlayToStore to open steam page");
			mDBFacade.mSteamworks.activateGameOverlayToWebPage("https://steamcommunity.com/app/3053950/discussions/0/792200576013303398/");
		} else {
			Logger.debug("Using navigateToURL to open steam page because isOverlayEnabled:" + _loc1_ + " isFullscreen:" + _loc3_);
			_loc2_ = new URLRequest("https://steamcommunity.com/app/3053950/discussions/0/792200576013303398/");
			flash.Lib.getURL(_loc2_, "_blank");
		}
	}

	function closePopupAction() {
		this.destroy();
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		var _loc6_:TextFormat = null;
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		if (mMessage != null) {
			_loc6_ = mMessage.getTextFormat();
			_loc6_.size = ASCompat.toInt(_loc6_.size) - 2;
			mMessage.setTextFormat(_loc6_);
		}
	}
}
