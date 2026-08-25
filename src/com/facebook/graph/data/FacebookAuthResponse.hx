package com.facebook.graph.data;

class FacebookAuthResponse {
	public var uid:String;

	public var expireDate:Date;

	public var accessToken:String;

	public var signedRequest:String;

	public function new() {}

	public function fromJSON(result:ASObject) {
		if (result != null) {
			this.expireDate = Date.now();
			ASCompat.ASDate.setTime(this.expireDate, this.expireDate.getTime() + ASCompat.toNumberField(result, "expiresIn") * 1000);
			this.accessToken = if (ASCompat.toBool(result.access_token)) result.access_token else result.accessToken;
			this.signedRequest = result.signedRequest;
			this.uid = result.userID;
		}
	}

	public function toString():String {
		return "[userId:" + this.uid + "]";
	}
}
