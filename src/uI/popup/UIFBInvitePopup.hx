package uI.popup;

import brain.assetRepository.SwfAsset;
import brain.logger.Logger;
import facade.DBFacade;
import facade.Locale;
import flash.display.Sprite;

class UIFBInvitePopup extends DBUIOneButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	static inline final POPUP_CLASS_NAME = "invite_popup";

	public function new(dbFacade:DBFacade, centerCallback:ASFunction) {
		super(dbFacade, Locale.getString("INVITE_POPUP_TITLE"), Locale.getString("INVITE_POPUP_MESSAGE"), Locale.getString("INVITE_POPUP_BUTTON"),
			centerCallback, true, null);
		mDBFacade.metrics.log("InvitePopupPresented");
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_screens.swf";
	}

	override function getClassName():String {
		return "invite_popup";
	}

	override function centerButtonCallback() {
		mDBFacade.metrics.log("InvitePopupContinue");
		super.centerButtonCallback();
	}

	override function setupUI(swfAsset:SwfAsset, titleText:String, content:ASAny, allowClose:Bool, closeCallback:ASFunction) {
		super.setupUI(swfAsset, titleText, content, allowClose, closeCallback);
		ASCompat.setProperty((mPopup : ASAny).player_name_label, "text", mDBFacade.dbAccountInfo.name);
		ASCompat.setProperty((mPopup : ASAny).chatBalloon.chatMessage, "text", Locale.getString("INVITE_POPUP_CHAT"));
		ASCompat.setProperty((mPopup : ASAny).nametag_1, "visible", false);
		ASCompat.setProperty((mPopup : ASAny).nametag_2, "visible", false);
		ASCompat.setProperty((mPopup : ASAny).nametag_3, "visible", false);
		mDBFacade.facebookAccountInfo.loadFriends(this.loadedFriends);
	}

	function loadedFriends(friends:Array<ASAny>) {
		var _loc2_ = 0;
		var _loc4_ = 0;
		var _loc3_ = 0;
		if (friends.length >= 3) {
			Logger.debug("UIInvitePopup showing friends");
			ASCompat.setProperty((mPopup : ASAny).nametag_1, "visible", true);
			ASCompat.setProperty((mPopup : ASAny).nametag_2, "visible", true);
			ASCompat.setProperty((mPopup : ASAny).nametag_3, "visible", true);
			_loc2_ = Std.int(Math.ffloor(Math.random() * friends.length));
			_loc4_ = Std.int(Math.ffloor(Math.random() * friends.length));
			while (_loc4_ == _loc2_) {
				_loc4_ = Std.int(Math.ffloor(Math.random() * friends.length));
			}
			_loc3_ = Std.int(Math.ffloor(Math.random() * friends.length));
			while (_loc3_ == _loc4_ || _loc3_ == _loc2_) {
				_loc3_ = Std.int(Math.ffloor(Math.random() * friends.length));
			}
			ASCompat.setProperty((mPopup : ASAny).nametag_1.name_label, "text", friends[_loc2_].name);
			ASCompat.setProperty((mPopup : ASAny).nametag_2.name_label, "text", friends[_loc4_].name);
			ASCompat.setProperty((mPopup : ASAny).nametag_3.name_label, "text", friends[_loc3_].name);
			cast((mPopup : ASAny).nametag_1.pic_bg, Sprite).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(friends[_loc2_].id));
			cast((mPopup : ASAny).nametag_2.pic_bg, Sprite).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(friends[_loc4_].id));
			cast((mPopup : ASAny).nametag_3.pic_bg, Sprite).addChild(mDBFacade.facebookAccountInfo.loadFriendProfilePic(friends[_loc3_].id));
		} else {
			Logger.debug("UIInvitePopup: not enough friends to show");
		}
	}
}
