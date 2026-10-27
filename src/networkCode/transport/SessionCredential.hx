package networkCode.transport;

final class SessionCredential {
	static final ACCOUNT:compat.RegExp = new compat.RegExp("^[1-9][0-9]{0,19}$");

	static final TOKEN:compat.RegExp = new compat.RegExp("^[0-9]{1,20}:[0-9a-f]{64}$");

	static final TRACE:compat.RegExp = new compat.RegExp("^00-[0-9a-f]{32}-[0-9a-f]{16}-[0-9a-f]{2}$");

	var mAccount:String;

	var mToken:String;

	var mTrace:String;

	public function new(account:String, token:String, trace:String) {
		mAccount = account;
		mToken = token;
		mTrace = trace;
	}

	static function field(name:String, value:String, shape:compat.RegExp):String {
		return shape.test(value) ? ",\"" + name + "\":\"" + value + "\"" : "";
	}

	@:isVar public var jsonFields(get, never):String;

	public function get_jsonFields():String {
		return field("account", mAccount, ACCOUNT) + field("token", mToken, TOKEN) + field("trace", mTrace, TRACE);
	}

	@:isVar public var omittedFields(get, never):String;

	public function get_omittedFields():String {
		var _loc1_:Array<ASAny> = [];
		if (!ACCOUNT.test(mAccount)) {
			_loc1_.push("account");
		}
		if (!TOKEN.test(mToken)) {
			_loc1_.push("token");
		}
		if (mTrace != null && !TRACE.test(mTrace)) {
			_loc1_.push("trace");
		}
		return _loc1_.join(", ");
	}
}
