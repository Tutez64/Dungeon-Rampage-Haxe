package starling.assets;

import flash.net.URLLoader;
import flash.net.URLRequest;
import starling.utils.Execute;

class DataLoader {
	static inline final HTTP_RESPONSE_STATUS = "httpResponseStatus";

	static inline final CERTIFICATE_ERROR = "certificateError";

	var _urlLoaders:ASDictionary<ASAny, ASAny>;

	public function new() {
		_urlLoaders = new ASDictionary<ASAny, ASAny>(true);
	}

	static function getHttpHeader(headers:Array<ASAny>, headerName:String):String {
		var _loc3_:ASObject;
		if (headers != null) {
			if (checkNullIteratee(headers))
				for (_tmp_ in headers) {
					_loc3_ = _tmp_;
					if (_loc3_.name == headerName) {
						return _loc3_.value;
					}
				}
		}
		return null;
	}

	public function load(url:String, onComplete:ASFunction, onError:ASFunction, onProgress:ASFunction = null) {
		var cleanup:() -> Void = null;
		var mimeType:String;
		var httpStatus:Int;
		var request:URLRequest = null;
		var loader:URLLoader = null;
		var message:String;
		var onHttpResponseStatus = function(param1:flash.events.HTTPStatusEvent) {
			httpStatus = param1.status;
			mimeType = getHttpHeader(ASCompat.coerce((param1 : ASAny)["responseHeaders"], Array), "Content-Type");
		};
		var onLoadError = function(param1:flash.events.ErrorEvent) {
			cleanup();
			message = param1.type + " - " + param1.text;
			Execute.execute(onError, message);
		};
		var onLoadProgress = function(param1:flash.events.ProgressEvent) {
			if (onProgress != null && param1.bytesTotal > 0) {
				onProgress(param1.bytesLoaded / param1.bytesTotal);
			}
		};
		var onLoadComplete = function(param1:ASObject) {
			cleanup();
			if (httpStatus < 400) {
				Execute.execute(onComplete, loader.data, mimeType);
			} else {
				Execute.execute(onError, "Unexpected HTTP status \'" + httpStatus + "\'. URL: " + request.url, httpStatus);
			}
		};
		cleanup = function() {
			loader.removeEventListener("ioError", onLoadError);
			loader.removeEventListener("securityError", onLoadError);
			loader.removeEventListener("certificateError", onLoadError);
			loader.removeEventListener("httpResponseStatus", onHttpResponseStatus);
			loader.removeEventListener("progress", onLoadProgress);
			loader.removeEventListener("complete", onLoadComplete);
			_urlLoaders.remove(loader);
		};
		mimeType = null;
		httpStatus = 0;
		request = new URLRequest(url);
		loader = new URLLoader();
		loader.dataFormat = "binary";
		loader.addEventListener("ioError", onLoadError);
		loader.addEventListener("securityError", onLoadError);
		loader.addEventListener("certificateError", onLoadError);
		loader.addEventListener("httpResponseStatus", onHttpResponseStatus);
		loader.addEventListener("progress", onLoadProgress);
		loader.addEventListener("complete", onLoadComplete);
		loader.load(request);
		_urlLoaders[loader] = true;
	}

	public function close() {
		var _loc1_:ASAny;
		final __ax4_iter_364 = _urlLoaders;
		if (checkNullIteratee(__ax4_iter_364))
			for (_tmp_ in __ax4_iter_364.keys()) {
				_loc1_ = _tmp_;
				try {
					_loc1_.close();
				} catch (e:Dynamic) {}
			}
		_urlLoaders = new ASDictionary<ASAny, ASAny>(true);
	}
}
