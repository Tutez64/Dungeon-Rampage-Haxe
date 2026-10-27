package config;

import brain.logger.Logger;
import flash.events.*;
import flash.net.*;

class ServiceDiscoveryLoader {
	var mOnComplete:ASFunction;

	var mLoader:URLLoader;

	var mHttpStatus:Int = 0;

	var mUrl:String;

	public function new(serviceDiscoveryUrl:String, onComplete:ASFunction) {
		mOnComplete = onComplete;
		mUrl = serviceDiscoveryUrl + "/game-status/service-discovery";
		mLoader = new URLLoader();
		mLoader.addEventListener("httpResponseStatus", onResponseStatus);
		mLoader.addEventListener("complete", onCompleted);
		mLoader.addEventListener("ioError", onError);
		mLoader.addEventListener("securityError", onError);
		mLoader.addEventListener("certificateError", onError);
		mLoader.load(new URLRequest(mUrl));
	}

	public static function maintenanceMessage(result:ASObject):String {
		var _loc2_:String = ASCompat.toBool(result) ? ASCompat.asString(result.maintenanceMessage) : null;
		return ASCompat.stringAsBool(_loc2_) && new compat.RegExp("\\S").test(_loc2_) ? _loc2_ : null;
	}

	function onResponseStatus(event:HTTPStatusEvent) {
		mHttpStatus = event.status;
	}

	function onCompleted(event:Event) {
		var _loc3_:ASObject = null;
		var _loc2_:String = ASCompat.toBool(event.target)
			&& ASCompat.toBool(ASCompat.dynamicAs(event.target, URLLoader).data) ? ASCompat.asString(ASCompat.dynamicAs(event.target, URLLoader).data) : null;
		Logger.debugch("HTTP", "Service discovery response (HTTP " + mHttpStatus + ") from " + mUrl + ": " + _loc2_);
		if (mHttpStatus < 100 || mHttpStatus >= 400) {
			Logger.warn("Service discovery returned HTTP " + mHttpStatus + " from " + mUrl);
			complete(null, 1500, Std.string(mHttpStatus));
			return;
		}
		var _loc4_ = false;
		try {
			_loc3_ = haxe.Json.parse(_loc2_);
			_loc4_ = ASCompat.toBool(_loc3_)
				&& ASCompat.toBool(_loc3_.webServicesUrl)
				&& ASCompat.toBool(_loc3_.gameSocketAddress)
				&& ASCompat.toBool(_loc3_.gameSocketPort);
		} catch (e:Dynamic) {
			Logger.fatal("Service discovery returned unparseable response from " + mUrl + ": " + Std.string(e.message));
			complete(null, 1503, "Invalid service discovery JSON: " + Std.string(e.message));
			return;
		}
		if (_loc4_) {
			Logger.info("Service discovery resolved from " + mUrl);
			complete(_loc3_, 0, "");
			return;
		}
		Logger.fatal("Service discovery response missing required fields from " + mUrl + ": " + _loc2_);
		complete(null, 1503, "Service discovery response missing required fields");
	}

	function onError(event:Event) {
		Logger.warn("Service discovery request failed (HTTP " + mHttpStatus + ") from " + mUrl);
		complete(null, 1503, "");
	}

	function complete(result:ASObject, errorCode:Int, diagnostic:String) {
		var _loc4_ = mOnComplete;
		mOnComplete = null;
		cleanup();
		if (_loc4_ != null) {
			_loc4_(result, errorCode, diagnostic);
		}
	}

	function cleanup() {
		if (mLoader == null) {
			return;
		}
		mLoader.removeEventListener("httpResponseStatus", onResponseStatus);
		mLoader.removeEventListener("complete", onCompleted);
		mLoader.removeEventListener("ioError", onError);
		mLoader.removeEventListener("securityError", onError);
		mLoader.removeEventListener("certificateError", onError);
		mLoader = null;
	}
}
