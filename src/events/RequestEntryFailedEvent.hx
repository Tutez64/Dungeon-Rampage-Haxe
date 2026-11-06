package events;

import flash.events.Event;

class RequestEntryFailedEvent extends Event {
	public static inline final EVENT_NAME = "REQUEST_ENTRY_FAILED";

	var mErrorCode:UInt = 0;

	public function new(errorCode:UInt, bubbles:Bool = false, cancelable:Bool = false) {
		super("REQUEST_ENTRY_FAILED", bubbles, cancelable);
		mErrorCode = errorCode;
	}

	@:isVar public var errorCode(get, never):UInt;

	public function get_errorCode():UInt {
		return mErrorCode;
	}
}
