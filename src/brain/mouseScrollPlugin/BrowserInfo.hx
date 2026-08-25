package brain.mouseScrollPlugin;

class BrowserInfo {
	public static inline final WIN_PLATFORM = "win";

	public static inline final MAC_PLATFORM = "mac";

	public static inline final SAFARI_AGENT = "safari";

	public static inline final OPERA_AGENT = "opera";

	public static inline final IE_AGENT = "msie";

	public static inline final MOZILLA_AGENT = "mozilla";

	public static inline final CHROME_AGENT = "chrome";

	var _platform:String = "undefined";

	var _browser:String = "undefined";

	var _version:String = "undefined";

	public function new(browserInfoObj:ASObject, platformObj:ASObject, agent:String) {
		if (!ASCompat.toBool(browserInfoObj) || !ASCompat.toBool(platformObj) || !ASCompat.stringAsBool(agent)) {
			return;
		}
		_version = browserInfoObj.version;
		var _loc5_:String;
		if (checkNullIteratee(browserInfoObj))
			for (_tmp_ in browserInfoObj.___keys()) {
				_loc5_ = _tmp_;
				if (_loc5_ != "version") {
					if (browserInfoObj[_loc5_] == true) {
						_browser = _loc5_;
						break;
					}
				}
			}
		var _loc4_:String;
		if (checkNullIteratee(platformObj))
			for (_tmp_ in platformObj.___keys()) {
				_loc4_ = _tmp_;
				if (platformObj[_loc4_] == true) {
					_platform = _loc4_;
				}
			}
	}

	@:isVar public var platform(get, never):String;

	public function get_platform():String {
		return _platform;
	}

	@:isVar public var browser(get, never):String;

	public function get_browser():String {
		return _browser;
	}

	@:isVar public var version(get, never):String;

	public function get_version():String {
		return _version;
	}
}
