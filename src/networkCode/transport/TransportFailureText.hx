package networkCode.transport;

final class TransportFailureText {
	public static inline final NO_SERVER_TEXT = "NotSet";

	public static inline final NOTHING_KNOWN = "the connection closed without a code or a reason";

	static inline final MAX_WIRE_CHARACTERS = 160;

	static inline final MAX_RUNTIME_CHARACTERS = 512;

	static inline final ELLIPSIS = "...";

	public static inline final CODE_SUPERSEDED = 4006;

	public static inline final SUPERSEDED_TEXT = "this account connected from elsewhere";

	public static inline final CODE_UNAUTHENTICATED = 4008;

	public static inline final UNAUTHENTICATED_TEXT = "This login was not accepted.";

	public static inline final CODE_ATTACHED_IDLE = 4011;

	public static inline final ATTACHED_IDLE_TEXT = "the connection sent nothing for too long";

	public function new() {
		throw new Error("TransportFailureText is a set of functions, not a thing to build.");
	}

	public static function forClose(event:GameTransportEvent):String {
		if (event.code == 4006) {
			return "this account connected from elsewhere (" + event.code + ")";
		}
		if (event.code == 4008) {
			return "This login was not accepted. (" + event.code + ")";
		}
		if (event.code == 4011) {
			return "the connection sent nothing for too long (" + event.code + ")";
		}
		var _loc2_ = tidy(event.reason, 160);
		if (event.code != 0 && _loc2_ != "") {
			return _loc2_ + " (" + event.code + ")";
		}
		if (event.code != 0) {
			return "closed (" + event.code + ")";
		}
		return _loc2_;
	}

	public static function forFailure(event:GameTransportEvent):String {
		var _loc2_ = tidy(event.text, 512);
		return _loc2_ == "" ? "the connection failed without a reason" : _loc2_;
	}

	public static function forGiveUp(event:GameTransportEvent):String {
		var _loc2_ = Math.round(event.elapsedMilliseconds / 1000);
		var _loc3_ = forClose(event);
		return "could not reconnect after " + _loc2_ + " s" + (_loc3_ == "" ? "" : ": " + _loc3_);
	}

	public static function withServerText(serverText:String, detail:String):String {
		var _loc3_ = tidy(serverText, 512);
		if (_loc3_ == "NotSet") {
			_loc3_ = "";
		}
		if (_loc3_ == "") {
			return detail == null || detail == "" ? "the connection closed without a code or a reason" : detail;
		}
		return detail == null || detail == "" ? _loc3_ : _loc3_ + "\n" + detail;
	}

	public static function tidy(text:String, maxCharacters:Int):String {
		if (text == null) {
			return "";
		}
		var _loc5_ = new compat.RegExp("^\\s+|\\s+$", "g").replace(new compat.RegExp("[\\x00-\\x1f\\x7f\\x85  ]+", "g").replace(text, " "), "");
		if (_loc5_.length <= maxCharacters) {
			return _loc5_;
		}
		var _loc3_ = _loc5_.substr(0, maxCharacters - "...".length);
		var _loc4_:Float = _loc3_.charCodeAt(_loc3_.length - 1);
		if (_loc4_ >= 55296 && _loc4_ <= 56319) {
			_loc3_ = _loc3_.substr(0, _loc3_.length - 1);
		}
		return _loc3_ + "...";
	}
}
