package stateMachine.mainStateMachine;

import account.DBAccountInfo;
import flash.events.Event;

class LoadingFinishedEvent extends Event {
	public static inline final EVENT_NAME = "LoadingFinishedEvent";

	var mDBAccountInfo:DBAccountInfo;

	public function new(dbAccountInfo:DBAccountInfo, bubbles:Bool = false, cancelable:Bool = false) {
		super("LoadingFinishedEvent", bubbles, cancelable);
		mDBAccountInfo = dbAccountInfo;
	}

	@:isVar public var dbAccountInfo(get, never):DBAccountInfo;

	public function get_dbAccountInfo():DBAccountInfo {
		return mDBAccountInfo;
	}
}
