package networkCode.transport;

class GameEndpoints {
	public var address:String;

	public var port:Int = 0;

	public var wssPath:String;

	public var enforceServerCertificate:Bool = false;

	public var tlsOffered:Bool = false;

	public var fallbackPort:Int = 0;

	public function new(address:String, port:Int, wssPath:String = "", enforceServerCertificate:Bool = true, tlsOffered:Bool = true, fallbackPort:Int = 0) {
		this.address = address;
		this.port = port;
		this.wssPath = normalizePath(wssPath);
		this.enforceServerCertificate = enforceServerCertificate;
		this.tlsOffered = tlsOffered;
		this.fallbackPort = fallbackPort;
	}

	static function describePath(path:String):String {
		return path == "" ? "(not offered)" : path;
	}

	static function normalizePath(path:String):String {
		if (path == null || path == "") {
			return "";
		}
		return path.charAt(0) == "/" ? path : "/" + path;
	}

	@:isVar public var wssUrl(get, never):String;

	public function get_wssUrl():String {
		return wssUrlForPort(port);
	}

	public function wssUrlForPort(port:Int):String {
		var _loc2_ = port == 443 ? address : address + ":" + port;
		return wssPath == "" ? "" : "wss://" + _loc2_ + wssPath;
	}

	@:isVar public var authority(get, never):String;

	public function get_authority():String {
		return port == 443 ? address : address + ":" + port;
	}

	public function toString():String {
		return "GameEndpoints(" + address + ":" + port + " tlsSocket=" + (tlsOffered ? "offered" : "not offered") + " fallbackPort=" + fallbackPort
			+ " wssPath=" + describePath(wssPath) + " enforceCert=" + enforceServerCertificate + ")";
	}
}
