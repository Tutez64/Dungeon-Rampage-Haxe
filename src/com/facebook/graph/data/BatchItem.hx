package com.facebook.graph.data;

class BatchItem {
	public var relativeURL:String;

	public var callback:ASFunction;

	public var params:ASAny;

	public var requestMethod:String;

	public function new(relativeURL:String, callback:ASFunction = null, params:ASAny = null, requestMethod:String = "GET") {
		this.relativeURL = relativeURL;
		this.callback = callback;
		this.params = params;
		this.requestMethod = requestMethod;
	}
}
