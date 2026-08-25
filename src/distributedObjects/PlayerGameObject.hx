package distributedObjects;

import brain.gameObject.GameObject;
import events.ChatEvent;
import events.ChatLogEvent;
import events.FriendStatusEvent;
import events.PlayerExitEvent;
import events.PlayerIsTypingEvent;
import facade.DBFacade;
import generatedCode.IPlayerGameObject;
import generatedCode.PlayerGameObjectNetworkComponent;
import uI.UIChatLog;
import account.FriendInfo;
import events.FacebookIdReceivedEvent;
import facade.DBFacade;

class PlayerGameObject extends GameObject implements IPlayerGameObject {
	var mName:String;

	var mFacebookHelper:FacebookHelper;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, remoteId:UInt = (0 : UInt)) {
		super(dbFacade, remoteId);
		mDBFacade = dbFacade;
		mFacebookHelper = new FacebookHelper(dbFacade, remoteId);
		mFacade.eventManager.dispatchEvent(new FriendStatusEvent("FRIEND_DUNGEON_STATUS_EVENT", this.id, true));
	}

	public function setNetworkComponentPlayerGameObject(iface:PlayerGameObjectNetworkComponent) {}

	public function postGenerate() {}

	@:isVar public var screenName(get, set):String;

	public function set_screenName(val:String):String {
		return mName = val;
	}

	function get_screenName():String {
		return mName;
	}

	@:isVar public var facebookId(get, never):String;

	public function get_facebookId():String {
		if (mFacebookHelper != null) {
			return mFacebookHelper.facebookId;
		}
		return "";
	}

	@:isVar public var isFriend(get, never):Bool;

	public function get_isFriend():Bool {
		return mFacebookHelper.isFriend;
	}

	public function Chat(text:String) {
		mFacade.eventManager.dispatchEvent(new ChatEvent("ChatEvent_INCOMING_CHAT_UPDATE", id, text));
		mFacade.eventManager.dispatchEvent(new ChatLogEvent("CHAT_LOG_EVENT", text, UIChatLog.CHAT_TYPE, mName));
	}

	public function ShowPlayerIsTyping(value:UInt) {
		if (value != 0) {
			mFacade.eventManager.dispatchEvent(new PlayerIsTypingEvent("PLAYER_IS_TYPING", id, "CHAT_BOX_FOCUS_IN"));
		} else {
			mFacade.eventManager.dispatchEvent(new PlayerIsTypingEvent("PLAYER_IS_TYPING", id, "CHAT_BOX_FOCUS_OUT"));
		}
	}

	override public function destroy() {
		mFacade.eventManager.dispatchEvent(new FriendStatusEvent("FRIEND_DUNGEON_STATUS_EVENT", this.id, false));
		mFacade.eventManager.dispatchEvent(new PlayerExitEvent(id));
		if (mFacebookHelper != null) {
			mFacebookHelper.destroy();
		}
		mFacebookHelper = null;
		mDBFacade = null;
		super.destroy();
	}

	@:isVar public var basicCurrency(get, set):UInt;

	public function get_basicCurrency():UInt {
		return mDBFacade.dbAccountInfo.basicCurrency;
	}

	function set_basicCurrency(value:UInt):UInt {
		return value;
	}
}

private class FacebookHelper {
	var mFacebookId:String;

	var mIsFriend:Bool = false;

	var mPlayerId:UInt = 0;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, id:UInt) {
		mDBFacade = dbFacade;
		mPlayerId = id;
		getFacebookId();
	}

	function getFacebookId() {
		var friend:FriendInfo;
		if (mDBFacade.dbAccountInfo.id == mPlayerId) {
			mFacebookId = mDBFacade.facebookPlayerId;
		} else if (mDBFacade.dbAccountInfo.friendInfos.hasKey(mPlayerId)) {
			mIsFriend = true;
			friend = ASCompat.dynamicAs(mDBFacade.dbAccountInfo.friendInfos.itemFor(mPlayerId), account.FriendInfo);
			if (friend != null) {
				mFacebookId = friend.facebookId;
			}
		} else {
			mDBFacade.dbAccountInfo.getFacebookIdRPC(mPlayerId, function(param1:String) {
				if (param1 != "") {
					mDBFacade.eventManager.dispatchEvent(new FacebookIdReceivedEvent("FACEBOOK_ID_RECEIVED_EVENT", mPlayerId, param1));
				}
				mFacebookId = param1;
			});
		}
	}

	@:isVar public var facebookId(get, never):String;

	public function get_facebookId():String {
		return mFacebookId;
	}

	@:isVar public var isFriend(get, never):Bool;

	public function get_isFriend():Bool {
		return mIsFriend;
	}

	public function destroy() {
		mDBFacade = null;
	}
}
