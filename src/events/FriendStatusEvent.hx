package events;

import flash.events.Event;

class FriendStatusEvent extends Event {
	public static inline final FRIEND_ONLINE_STATUS = "FRIEND_STATUS_EVENT";

	public static inline final FRIEND_DUNGEON_STATUS = "FRIEND_DUNGEON_STATUS_EVENT";

	var mFriendId:UInt = 0;

	var mStatus:Bool = false;

	public function new(type:String, friendId:UInt, status:Bool, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
		mFriendId = friendId;
		mStatus = status;
	}

	@:isVar public var friendId(get, never):UInt;

	public function get_friendId():UInt {
		return mFriendId;
	}

	@:isVar public var status(get, never):Bool;

	public function get_status():Bool {
		return mStatus;
	}
}
