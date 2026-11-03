package networkCode.transport;

class GameEndpoints {
	public var address:String;

	public var port:Int = 0;

	public var wssPath:String;

	public var enforceServerCertificate:Bool = false;

	public var tlsOffered:Bool = false;

	public function new(address:String, port:Int, wssPath:String = "", enforceServerCertificate:Bool = true, tlsOffered:Bool = true) {
		this.address = address;
		this.port = port;
		this.wssPath = normalizePath(wssPath);
		this.enforceServerCertificate = enforceServerCertificate;
		this.tlsOffered = tlsOffered;
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
		return wssPath == "" ? "" : "wss://" + authority + wssPath;
	}

	@:isVar public var authority(get, never):String;

	public function get_authority():String {
		return port == 443 ? address : address + ":" + port;
	}

	public function toString():String {
		return "GameEndpoints(" + address + ":" + port + " tlsSocket=" + (tlsOffered ? "offered" : "not offered") + " wssPath=" + describePath(wssPath)
			+ " enforceCert=" + enforceServerCertificate + ")";
	}
}
