package events;

import account.DBAccountInfo;
import flash.events.Event;

class DBAccountResponseEvent extends Event {
	public static inline final EVENT_NAME = "DB_ACCOUNT_INFO_RESPONSE";

	var mDBAccountInfo:DBAccountInfo;

	public function new(dbAccountInfo:DBAccountInfo, bubbles:Bool = false, cancelable:Bool = false) {
		super("DB_ACCOUNT_INFO_RESPONSE", bubbles, cancelable);
		mDBAccountInfo = dbAccountInfo;
		if (dbAccountInfo.inventoryInfo.canShowInfiniteIsland()) {
			dbAccountInfo.getAllMapnodeScoresRPC(mDBAccountInfo.id);
		}
	}

	@:isVar public var dbAccountInfo(get, never):DBAccountInfo;

	public function get_dbAccountInfo():DBAccountInfo {
		return mDBAccountInfo;
	}
}
