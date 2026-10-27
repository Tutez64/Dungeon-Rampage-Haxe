package networkCode.transport;

import flash.events.Event;
import flash.utils.ByteArray;

class GameTransportEvent extends Event {
	public static inline final CONNECTED = "gameTransportConnected";

	public static inline final DATA = "gameTransportData";

	public static inline final CLOSED = "gameTransportClosed";

	public static inline final FAILED = "gameTransportFailed";

	public static inline final TEXT = "gameTransportText";

	public static inline final RECONNECTING = "gameTransportReconnecting";

	public static inline final RECONNECT_ATTEMPT = "gameTransportReconnectAttempt";

	public static inline final RESUMED = "gameTransportResumed";

	public static inline final INITIATOR_SERVER = "server";

	public static inline final INITIATOR_CLIENT = "client";

	public static inline final INITIATOR_TRANSPORT = "transport";

	public static inline final INITIATOR_UNKNOWN = "unknown";

	public static inline final CLOSE_CLIENT_ABANDONED = 4000;

	public static inline final SOCKET_ERROR_CLOSED = (601 : UInt);

	public static inline final SOCKET_ERROR_IO = (602 : UInt);

	public static inline final SOCKET_ERROR_SECURITY = (603 : UInt);

	public var bytes:ByteArray;

	public var code:Int = 0;

	public var reason:String = "";

	public var initiator:String = "unknown";

	public var errorCode:UInt = (0 : UInt);

	public var text:String = "";

	public var certificateStatus:String = "";

	public var certificateDetail:String = "";

	public var attempts:Int = 0;

	public var elapsedMilliseconds:Int = 0;

	public var graceMilliseconds:Int = 0;

	public var gaveUp:Bool = false;

	public var terminal:Bool = false;

	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false) {
		super(type, bubbles, cancelable);
	}

	public static function connectedEvent():GameTransportEvent {
		return new GameTransportEvent("gameTransportConnected");
	}

	public static function dataEvent(bytes:ByteArray):GameTransportEvent {
		var _loc2_ = new GameTransportEvent("gameTransportData");
		_loc2_.bytes = bytes;
		return _loc2_;
	}

	public static function closedEvent(code:Int, reason:String, initiator:String):GameTransportEvent {
		var _loc4_ = new GameTransportEvent("gameTransportClosed");
		_loc4_.code = code;
		_loc4_.reason = reason == null ? "" : reason;
		_loc4_.initiator = initiator == null ? "unknown" : initiator;
		return _loc4_;
	}

	public static function failedEvent(errorCode:UInt, text:String, certificateStatus:String = "", certificateDetail:String = ""):GameTransportEvent {
		var _loc5_ = new GameTransportEvent("gameTransportFailed");
		_loc5_.errorCode = errorCode;
		_loc5_.text = text == null ? "" : text;
		_loc5_.certificateStatus = certificateStatus == null ? "" : certificateStatus;
		_loc5_.certificateDetail = certificateDetail == null ? "" : certificateDetail;
		return _loc5_;
	}

	public static function textEvent(text:String):GameTransportEvent {
		var _loc2_ = new GameTransportEvent("gameTransportText");
		_loc2_.text = text == null ? "" : text;
		return _loc2_;
	}

	public static function reconnectingEvent(code:Int, reason:String, elapsedMilliseconds:Int):GameTransportEvent {
		var _loc4_ = new GameTransportEvent("gameTransportReconnecting");
		_loc4_.code = code;
		_loc4_.reason = reason == null ? "" : reason;
		_loc4_.initiator = "server";
		_loc4_.elapsedMilliseconds = elapsedMilliseconds;
		return _loc4_;
	}

	public static function reconnectAttemptEvent(attempts:Int, elapsedMilliseconds:Int, graceMilliseconds:Int):GameTransportEvent {
		var _loc4_ = new GameTransportEvent("gameTransportReconnectAttempt");
		_loc4_.attempts = attempts;
		_loc4_.elapsedMilliseconds = elapsedMilliseconds;
		_loc4_.graceMilliseconds = graceMilliseconds;
		return _loc4_;
	}

	public static function resumedEvent(attempts:Int, elapsedMilliseconds:Int):GameTransportEvent {
		var _loc3_ = new GameTransportEvent("gameTransportResumed");
		_loc3_.attempts = attempts;
		_loc3_.elapsedMilliseconds = elapsedMilliseconds;
		return _loc3_;
	}

	override public function toString():String {
		return formatToString("GameTransportEvent", "type", "code", "reason", "initiator", "errorCode", "text", "certificateStatus", "certificateDetail",
			"attempts", "elapsedMilliseconds", "graceMilliseconds");
	}
}
