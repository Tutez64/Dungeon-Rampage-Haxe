package com.facebook.graph.data;

import com.facebook.graph.core.FacebookLimits;

class Batch {
	var _requests:Array<ASAny>;

	public function new() {
		this._requests = [];
	}

	@:isVar public var requests(get, never):Array<ASAny>;

	public function get_requests():Array<ASAny> {
		return this._requests;
	}

	public function add(relativeURL:String, callback:ASFunction = null, params:ASAny = null, requestMethod:String = "GET") {
		if ((this._requests.length : UInt) == FacebookLimits.BATCH_REQUESTS) {
			throw new Error("Facebook limits you to " + FacebookLimits.BATCH_REQUESTS + " requests in a single batch.");
		}
		this._requests.push(new BatchItem(relativeURL, callback, params, requestMethod));
	}
}
