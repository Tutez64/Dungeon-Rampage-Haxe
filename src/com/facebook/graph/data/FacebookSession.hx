package com.facebook.graph.data;

class FacebookSession {
	public var uid:String;

	public var user:ASObject;

	public var sessionKey:String;

	public var expireDate:Date;

	public var accessToken:String;

	public var secret:String;

	public var sig:String;

	public var availablePermissions:Array<ASAny>;

	public function new() {}

	public function fromJSON(result:ASObject) {
		if (result != null) {
			this.sessionKey = result.session_key;
			this.expireDate = Date.fromTime(result.expires);
			this.accessToken = result.access_token;
			this.secret = result.secret;
			this.sig = result.sig;
			this.uid = result.uid;
		}
	}

	public function toString():String {
		return "[userId:" + this.uid + "]";
	}
}
