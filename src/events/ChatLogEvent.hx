package events;

import flash.events.Event;

class ChatLogEvent extends Event {
	public static inline final NAME = "CHAT_LOG_EVENT";

	var mMessage:String;

	var mChatLogType:String;

	var mPlayerName:String;

	public function new(eventName:String, message:String, chatLogType:String, playerName:String = "", bubbles:Bool = false, cancelable:Bool = false) {
		super(eventName, bubbles, cancelable);
		mMessage = message;
		mChatLogType = chatLogType;
		mPlayerName = playerName;
	}

	@:isVar public var chat(get, never):String;

	public function get_chat():String {
		return mMessage;
	}

	@:isVar public var chatLogType(get, never):String;

	public function get_chatLogType():String {
		return mChatLogType;
	}

	@:isVar public var playerName(get, never):String;

	public function get_playerName():String {
		return mPlayerName;
	}
}
