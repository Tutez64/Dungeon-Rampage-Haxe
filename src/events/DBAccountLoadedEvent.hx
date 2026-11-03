package events;

import account.DBAccountInfo;
import flash.events.Event;

class DBAccountLoadedEvent extends Event {
	public static inline final EVENT_NAME = "DB_ACCOUNT_INFO_LOADED";

	var mDBAccountInfo:DBAccountInfo;

	public function new(dbAccountInfo:DBAccountInfo, bubbles:Bool = false, cancelable:Bool = false) {
		super("DB_ACCOUNT_INFO_LOADED", bubbles, cancelable);
		mDBAccountInfo = dbAccountInfo;
	}

	@:isVar public var dbAccountInfo(get, never):DBAccountInfo;

	public function get_dbAccountInfo():DBAccountInfo {
		return mDBAccountInfo;
	}
}
