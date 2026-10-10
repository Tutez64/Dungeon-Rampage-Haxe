package events;

import flash.events.Event;

class GenericNewsFeedEvent extends Event {
	public static inline final NAME = "GENERIC_NEWS_FEED_MESSAGE_EVENT";

	var mMessage:String;

	var mPicSwfLocation:String;

	var mPicSwfClassName:String;

	public function new(type:String, message:String, picSwfLocation:String = "", picSwfClassName:String = "", bubbles:Bool = false, cancelable:Bool = false) {
		mMessage = message;
		mPicSwfLocation = picSwfLocation;
		mPicSwfClassName = picSwfClassName;
		super(type, bubbles, cancelable);
	}

	@:isVar public var message(get, never):String;

	public function get_message():String {
		return mMessage;
	}

	@:isVar public var picLocation(get, never):String;

	public function get_picLocation():String {
		return mPicSwfLocation;
	}

	@:isVar public var picClassName(get, never):String;

	public function get_picClassName():String {
		return mPicSwfClassName;
	}
}
