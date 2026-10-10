package events;

import flash.display.MovieClip;
import flash.events.Event;

class FriendSummaryNewsFeedEvent extends Event {
	public static inline final NAME = "FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT";

	public static var FRIEND_NAME_HIGHLIGHT_COLOR:UInt = (65280 : UInt);

	var mFriendName:String;

	var mIsFriendNameInFront:Bool = false;

	var mMessage:String;

	var mPic:MovieClip;

	public function new(type:String, message:String, picMC:MovieClip, friendName:String, isFriendNameInFront:Bool = false, bubbles:Bool = false,
			cancelable:Bool = false) {
		mFriendName = friendName;
		mIsFriendNameInFront = isFriendNameInFront;
		mMessage = message;
		mPic = picMC;
		super(type, bubbles, cancelable);
	}

	@:isVar public var friendName(get, never):String;

	public function get_friendName():String {
		return mFriendName;
	}

	@:isVar public var message(get, never):String;

	public function get_message():String {
		return mMessage;
	}

	@:isVar public var isFriendNameInFront(get, never):Bool;

	public function get_isFriendNameInFront():Bool {
		return mIsFriendNameInFront;
	}

	@:isVar public var pic(get, never):MovieClip;

	public function get_pic():MovieClip {
		return mPic;
	}
}
