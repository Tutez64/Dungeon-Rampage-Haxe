package networkCode.transport;

class TransportCandidate {
	public var kind:String;

	public var host:String;

	public var port:Int = 0;

	public var url:String;

	public function new(kind:String, host:String = "", port:Int = 0, url:String = "") {
		this.kind = kind;
		this.host = host;
		this.port = port;
		this.url = url;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return kind + " " + (url != "" ? url : host + ":" + port);
	}
}
