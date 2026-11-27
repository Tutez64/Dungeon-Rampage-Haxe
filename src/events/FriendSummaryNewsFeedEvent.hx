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

	public var hasPortrait:Bool = false;

	public var skinId:UInt = 0;

	public var steamAvatarUrl:String;

	public function new(friendSummaryNewsFeedEventType:String, message:String, picMC:MovieClip, friendName:String, isFriendNameInFront:Bool = false,
			bubbles:Bool = false, cancelable:Bool = false) {
		mFriendName = friendName;
		mIsFriendNameInFront = isFriendNameInFront;
		mMessage = message;
		mPic = picMC;
		super(friendSummaryNewsFeedEventType, bubbles, cancelable);
	}

	public static function forPortrait(message:String, skinId:UInt, friendName:String, steamUrl:String = null):FriendSummaryNewsFeedEvent {
		var _loc5_ = new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT", message, null, friendName);
		_loc5_.hasPortrait = true;
		_loc5_.skinId = skinId;
		_loc5_.steamAvatarUrl = steamUrl;
		return _loc5_;
	}

	override public function clone():Event {
		var _loc1_ = new FriendSummaryNewsFeedEvent(type, mMessage, mPic, mFriendName, mIsFriendNameInFront, bubbles, cancelable);
		_loc1_.hasPortrait = hasPortrait;
		_loc1_.skinId = skinId;
		_loc1_.steamAvatarUrl = steamAvatarUrl;
		return _loc1_;
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
