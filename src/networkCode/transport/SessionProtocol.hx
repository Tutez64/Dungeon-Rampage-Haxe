package networkCode.transport;

final class SessionProtocol {
	public static inline final CODE_UNKNOWN_SESSION = 4004;

	static inline final MAX_SAFE_COUNT:Float = 9007199254740991;

	static inline final MAX_POD_ORDINAL = 99999;

	static inline final MAX_CONTROL_FRAME_CHARACTERS = 4096;

	static final UNRECOVERABLE_CODES:Array<ASAny> = [4001, 4002, 4003, 4005, 4006, 4007, 4008, 4011];

	static final CLOSE_REASONS:ASObject = {
		"4001": "session buffer full",
		"4002": "bad control message",
		"4003": "session expired",
		"4004": "unknown session",
		"4005": "replay window exceeded",
		"4006": "superseded",
		"4007": "upstream ended",
		"4008": "unauthenticated",
		"4011": "attached idle"
	};

	public function new() {}

	public static function helloMessageFor(credential:SessionCredential):String {
		return "{\"t\":\"hello\",\"v\":1" + fieldsOf(credential) + "}";
	}

	public static function ackMessage(received:Float):String {
		return "{\"t\":\"ack\",\"recv\":" + formatCount(received) + "}";
	}

	public static function resumeMessageFor(token:String, received:Float, why:String, credential:SessionCredential):String {
		return "{\"t\":\"resume\",\"session\":\""
			+ token
			+ "\",\"recv\":"
			+ formatCount(received)
			+ whyField(why)
			+ fieldsOf(credential)
			+ "}";
	}

	public static function parseControl(text:String):ASObject {
		var _loc6_:ASAny;
		var _loc2_:ASObject = null;
		if (text == null || text.length == 0 || text.length > 4096) {
			return null;
		}
		try {
			_loc2_ = haxe.Json.parse(text);
			if (_loc2_ == null || _loc2_.t == null) {
				return null;
			}
			return _loc2_;
		} catch (error:Dynamic) {
			_loc6_ = null;
		}
		return _loc6_;
	}

	public static function isPlausibleToken(token:String):Bool {
		return token != null && new compat.RegExp("^[A-Za-z0-9_\\-]{16,128}$").test(token);
	}

	public static function isWholeCount(value:Float):Bool {
		return !Math.isNaN(value) && value >= 0 && value == Math.ffloor(value) && value <= 9007199254740991;
	}

	public static function isPlausiblePod(pod:Float):Bool {
		return !Math.isNaN(pod) && pod >= 0 && pod <= 99999 && pod == Math.ffloor(pod);
	}

	public static function isUnrecoverable(code:Int):Bool {
		return UNRECOVERABLE_CODES.indexOf(code) >= 0;
	}

	public static function closeReasonFor(code:Int):String {
		return ASCompat.toString(CLOSE_REASONS[Std.string(code)]);
	}

	static function whyField(why:String):String {
		return why == null || why == "" ? "" : ",\"why\":\"" + why + "\"";
	}

	static function fieldsOf(credential:SessionCredential):String {
		return credential?.jsonFields;
	}

	static function formatCount(value:Float):String {
		return ASCompat.toFixed(value, (0 : UInt));
	}
}
