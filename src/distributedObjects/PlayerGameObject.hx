package distributedObjects;

import brain.gameObject.GameObject;
import events.ChatEvent;
import events.ChatLogEvent;
import events.FriendStatusEvent;
import events.PlayerExitEvent;
import events.PlayerIsTypingEvent;
import facade.DBFacade;
import facade.LoadingPrewarm;
import facade.TrickleCacheLoader;
import generatedCode.HeroPreloadLook;
import generatedCode.IPlayerGameObject;
import generatedCode.PlayerGameObjectNetworkComponent;
import stateMachine.mainStateMachine.LoadingScreenState;
import uI.UIChatLog;
import account.FriendInfo;
import events.SteamAvatarUrlReceivedEvent;
import facade.DBFacade;

class PlayerGameObject extends GameObject implements IPlayerGameObject {
	var mName:String;

	var mHeroPreloadLook:HeroPreloadLook;

	var mSteamHelper:SteamHelper;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, remoteId:UInt = (0 : UInt)) {
		super(dbFacade, remoteId);
		mDBFacade = dbFacade;
		mSteamHelper = new SteamHelper(dbFacade, remoteId);
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

	@:isVar public var heroPreloadLook(get, set):HeroPreloadLook;

	public function set_heroPreloadLook(val:HeroPreloadLook):HeroPreloadLook {
		mHeroPreloadLook = val;
		if (val != null && id != mDBFacade.dbAccountInfo.id) {
			TrickleCacheLoader.queueHeroLookAtlases(mDBFacade, val, !Std.isOfType(mDBFacade.mainStateMachine.currentState, LoadingScreenState));
			LoadingPrewarm.heroJoined(mDBFacade, val);
		}
		return val;
	}

	function get_heroPreloadLook():HeroPreloadLook {
		return mHeroPreloadLook;
	}

	@:isVar public var steamAvatarUrl(get, never):String;

	public function get_steamAvatarUrl():String {
		if (mSteamHelper != null) {
			return mSteamHelper.steamAvatarUrl;
		}
		return "";
	}

	@:isVar public var isFriend(get, never):Bool;

	public function get_isFriend():Bool {
		return mSteamHelper.isFriend;
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
		if (mSteamHelper != null) {
			mSteamHelper.destroy();
		}
		mSteamHelper = null;
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

private class SteamHelper {
	var mSteamAvatarUrl:String;

	var mIsFriend:Bool = false;

	var mPlayerId:UInt = 0;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, id:UInt) {
		mDBFacade = dbFacade;
		mPlayerId = id;
		getSteamAvatar();
	}

	function getSteamAvatar() {
		var friend:FriendInfo;
		if (mDBFacade.dbAccountInfo.id == mPlayerId) {
			mSteamAvatarUrl = mDBFacade.mSteamAvatarUrl;
		} else if (mDBFacade.dbAccountInfo.friendInfos.hasKey(mPlayerId)) {
			mIsFriend = true;
			friend = ASCompat.coerce(mDBFacade.dbAccountInfo.friendInfos.itemFor(mPlayerId), account.FriendInfo);
			if (friend != null) {
				mSteamAvatarUrl = friend.steamAvatarUrl;
			}
		} else {
			mDBFacade.dbAccountInfo.getSteamAvatarUrlRPC(mPlayerId, function(param1:String) {
				if (param1 != "" && mDBFacade != null) {
					mDBFacade.eventManager.dispatchEvent(new SteamAvatarUrlReceivedEvent("STEAM_AVATAR_URL_RECEIVED_EVENT", mPlayerId, param1));
				}
				mSteamAvatarUrl = param1;
			});
		}
	}

	@:isVar public var steamAvatarUrl(get, never):String;

	public function get_steamAvatarUrl():String {
		return mSteamAvatarUrl;
	}

	@:isVar public var isFriend(get, never):Bool;

	public function get_isFriend():Bool {
		return mIsFriend;
	}

	public function destroy() {
		mDBFacade = null;
	}
}
