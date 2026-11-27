package account;

import account.iI.II_AvatarMapNodeScore;
import account.iI.II_AvatarsScoresInfo;
import account.iI.II_FriendChampionsboardInfo;
import brain.event.EventComponent;
import facade.DBFacade;
import facade.GameMasterLocale;
import flash.events.Event;
import flash.events.EventDispatcher;

class FriendInfo extends EventDispatcher {
	public static inline final PORTRAIT_CHANGED = "FriendPortraitChanged";

	public static var FRIEND_SCORES_PARSED:String = "FRIEND_SCORES_PARSED";

	var mSkinId:UInt = (151 : UInt);

	var mPortraitUrl:String;

	var mAccountId:UInt = 0;

	var mSteamAvatarUrl:String;

	var mFriendName:String;

	var mTrophies:UInt = 0;

	var mAscensionLevel:UInt = 0;

	var mDBFacade:DBFacade;

	var mResponseCallback:ASFunction;

	var mIILeaderboardInfo:II_FriendChampionsboardInfo;

	var mIIAvatarScoresInfo:II_AvatarsScoresInfo;

	var mEventComponent:EventComponent;

	public function new(dbFacade:DBFacade, friendJson:ASObject, responseCallback:ASFunction = null) {
		super();
		mResponseCallback = responseCallback;
		mDBFacade = dbFacade;
		mEventComponent = new EventComponent(mDBFacade);
		parseFriendJson(friendJson);
	}

	public function parseFriendJson(friendJson:ASObject) {
		var _loc4_:AvatarInfo = null;
		if (friendJson == null) {
			return;
		}
		mAccountId = ASCompat.asUint(friendJson.account_id);
		mFriendName = ASCompat.asString(friendJson.name);
		mTrophies = ASCompat.asUint(friendJson.trophies);
		mAscensionLevel = (friendJson.hasOwnProperty("ascension_level") ? (ASCompat.toInt(friendJson.ascension_level) : UInt) : (0 : UInt):UInt);
		mSteamAvatarUrl = ASCompat.asString(friendJson.steam_avatar_url);
		var _loc3_ = mSkinId;
		var _loc2_ = mPortraitUrl;
		if (friendJson.hasOwnProperty("active_skin")) {
			mSkinId = (ASCompat.toInt(friendJson.active_skin) : UInt);
		} else if (mAccountId == mDBFacade.accountId) {
			_loc4_ = mDBFacade.dbAccountInfo.activeAvatarInfo;
			mSkinId = _loc4_ != null ? _loc4_.skinId : (151 : UInt);
		} else {
			mSkinId = (151 : UInt);
		}
		mPortraitUrl = mSteamAvatarUrl;
		if (_loc3_ != mSkinId || _loc2_ != mPortraitUrl) {
			dispatchEvent(new Event("FriendPortraitChanged"));
		}
		if (mResponseCallback != null) {
			mResponseCallback();
		}
	}

	public function parseChampionsboardData(friendChampionsBoardInfo:II_FriendChampionsboardInfo) {
		mIILeaderboardInfo = friendChampionsBoardInfo;
	}

	public function parseIIAvatarScoresData(avatarScoresJson:ASObject) {
		mIIAvatarScoresInfo = new II_AvatarsScoresInfo(avatarScoresJson);
		mEventComponent.dispatchEvent(new Event(FRIEND_SCORES_PARSED));
	}

	public function refreshOwnPortrait() {
		if (mAccountId != mDBFacade.accountId) {
			return;
		}
		var _loc2_ = mDBFacade.dbAccountInfo.activeAvatarInfo;
		var _loc1_ = _loc2_ != null ? _loc2_.skinId : (151 : UInt);
		if (_loc1_ == mSkinId) {
			return;
		}
		mSkinId = _loc1_;
		dispatchEvent(new Event("FriendPortraitChanged"));
	}

	@:isVar public var skinId(get, never):UInt;

	public function get_skinId():UInt {
		return mSkinId;
	}

	@:isVar public var id(get, never):UInt;

	public function get_id():UInt {
		return mAccountId;
	}

	@:isVar public var steamAvatarUrl(get, never):String;

	public function get_steamAvatarUrl():String {
		return mSteamAvatarUrl;
	}

	@:isVar public var trophies(get, set):UInt;

	public function get_trophies():UInt {
		return mTrophies;
	}

	function set_trophies(value:UInt):UInt {
		return mTrophies = value;
	}

	@:isVar public var ascensionLevel(get, set):UInt;

	public function get_ascensionLevel():UInt {
		return mAscensionLevel;
	}

	function set_ascensionLevel(value:UInt):UInt {
		return mAscensionLevel = value;
	}

	@:isVar public var lastMapNode(get, never):UInt;

	public function get_lastMapNode():UInt {
		if (mDBFacade.mDistributedObjectManager != null && mDBFacade.mDistributedObjectManager.mPresenceManager != null) {
			return mDBFacade.mDistributedObjectManager.mPresenceManager.InDungeonId(mAccountId);
		}
		return (0 : UInt);
	}

	@:isVar public var dungeonName(get, never):String;

	public function get_dungeonName():String {
		var _loc1_ = mDBFacade.gameMaster != null ? mDBFacade.gameMaster.getMapNode(lastMapNode) : null;
		if (_loc1_ == null) {
			return null;
		}
		return GameMasterLocale.getGameMasterSubString("DUNGEON_NAME", _loc1_.Constant);
	}

	public function isOnline():Bool {
		if (mAccountId == mDBFacade.dbAccountInfo.id) {
			return true;
		}
		if (mDBFacade.mDistributedObjectManager != null && mDBFacade.mDistributedObjectManager.mPresenceManager != null) {
			return mDBFacade.mDistributedObjectManager.mPresenceManager.isOnline(mAccountId);
		}
		return false;
	}

	public function isInDungeon():Bool {
		if (mDBFacade.mDistributedObjectManager != null && mDBFacade.mDistributedObjectManager.mPresenceManager != null) {
			return mDBFacade.mDistributedObjectManager.mPresenceManager.isInDungeon(mAccountId);
		}
		return false;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return mFriendName;
	}

	@:isVar public var excludeId(get, never):String;

	public function get_excludeId():String {
		return Std.string(this.id);
	}

	public function getWeaponsUsedForNode(nodeId:UInt):Array<Dynamic> {
		if (mIILeaderboardInfo != null) {
			return mIILeaderboardInfo.getWeaponsForNodeId(nodeId);
		}
		return new Array<Dynamic>();
	}

	public function getIILeaderboardScoreForNode(nodeId:Int):Int {
		if (mIILeaderboardInfo != null && mIILeaderboardInfo.nodeIdToScore.hasKey(nodeId)) {
			return ASCompat.toInt(mIILeaderboardInfo.nodeIdToScore.itemFor(nodeId));
		}
		return 0;
	}

	public function getIILeaderboardAvatarSkinForNode(nodeId:Int):Int {
		if (mIILeaderboardInfo != null && mIILeaderboardInfo.nodeIdToActiveSkin.hasKey(nodeId)) {
			return ASCompat.toInt(mIILeaderboardInfo.nodeIdToActiveSkin.itemFor(nodeId));
		}
		return 151;
	}

	public function getIIAvatarScoreForNode(avatarId:Int, nodeId:Int):Int {
		var _loc3_ = 0;
		if (mIIAvatarScoresInfo == null) {
			return 0;
		}
		var _loc4_ = ASCompat.coerce(mIIAvatarScoresInfo.avatarIdToAvatarScore.itemFor(avatarId), account.iI.II_AvatarMapNodeScore);
		if (_loc4_ != null) {
			_loc3_ = ASCompat.toInt(_loc4_.nodeIdToScore.itemFor(nodeId));
			if (_loc3_ != 0) {
				return _loc3_;
			}
		}
		return 0;
	}
}
