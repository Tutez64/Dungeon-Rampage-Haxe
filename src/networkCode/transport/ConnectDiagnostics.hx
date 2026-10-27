package networkCode.transport;

import brain.logger.Logger;
import brain.logger.Logger;
import networkCode.transport.TransportSettings;
import flash.events.ErrorEvent;
import flash.events.Event;
import flash.events.HTTPStatusEvent;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.dns.AAAARecord;
import flash.net.dns.ARecord;
import flash.net.dns.DNSResolver;
import flash.net.dns.ResourceRecord;

final class ConnectDiagnostics {
	static inline final MAX_TEXT = 160;

	static inline final STALL_MIN_MS = 4000;

	public function new() {
		throw new Error("ConnectDiagnostics is a set of functions, not a thing to build.");
	}

	public static function summarize(attempts:Array<ASAny>):String {
		var _loc4_ = 0;
		var _loc2_ = ASCompat.toInt(attempts?.length);
		var _loc3_:Array<ASAny> = [];
		_loc4_ = 0;
		while (_loc4_ < _loc2_) {
			_loc3_.push(describeAttempt(attempts[_loc4_]));
			_loc4_++;
		}
		return "no transport connected after " + _loc2_ + " attempt(s): " + _loc3_.join("; ");
	}

	public static function describeAttempt(attempt:ASObject):String {
		var _loc2_ = Std.string(attempt.name) + " " + ASCompat.toInt(attempt.elapsedMs) + "ms ";
		_loc2_ += ASCompat.toBool(attempt.closed) ? "closed " + Std.string(attempt.code) : ASCompat.toString(attempt.code);
		var _loc4_ = TransportFailureText.tidy(attempt.text, 160);
		if (_loc4_ != "") {
			_loc2_ += " " + _loc4_;
		}
		var _loc3_ = describeCertificate(attempt.cert);
		if (_loc3_ != "") {
			_loc2_ += " " + _loc3_;
		}
		var _loc5_ = TransportFailureText.tidy(attempt.certDetail, 160);
		if (_loc5_ != "") {
			_loc2_ += " [" + _loc5_ + "]";
		}
		return _loc2_;
	}

	public static function describeCertificate(status:String):String {
		if (status == null || status == "") {
			return "";
		}
		if (status == "invalid") {
			return "cert=invalid (no certificate)";
		}
		if (status == "unknown") {
			return "cert=unknown (not validated)";
		}
		return "cert=" + status + " (certificate received)";
	}

	public static function looksLikeStall(attempts:Array<ASAny>):Bool {
		var _loc2_ = false;
		var _loc3_:ASObject;
		if (checkNullIteratee(attempts))
			for (_tmp_ in attempts) {
				_loc3_ = _tmp_;
				if (ASCompat.toBool(_loc3_.closed)
					|| ASCompat.toNumberField(_loc3_, "code") != 602
					|| ASCompat.toInt(_loc3_.elapsedMs) < 4000
					|| _loc3_.cert != ""
					&& _loc3_.cert != "invalid") {
					return false;
				}
				if (_loc3_.cert == "invalid") {
					_loc2_ = true;
				}
			}
		return _loc2_;
	}

	public static function isIpLiteral(host:String):Bool {
		if (host == null || host == "") {
			return false;
		}
		if (host.indexOf(":") >= 0) {
			return true;
		}
		return new compat.RegExp("^\\d{1,3}(\\.\\d{1,3}){3}$").test(host);
	}

	public static function run(attempts:Array<ASAny>, endpoints:GameEndpoints, webServicesUrl:String) {
		Logger.warnch("WS", summarize(attempts));
		if (endpoints == null || endpoints.address == null || endpoints.address == "") {
			return;
		}
		new HttpsProbe("healthz", "https://" + endpoints.authority + "/healthz");
		if (webServicesUrl != null && webServicesUrl != "") {
			new HttpsProbe("game-status", webServicesUrl + "/game-status");
		}
		if (isIpLiteral(endpoints.address)) {
			Logger.infoch("WS", "dns " + endpoints.address + " skipped (IP literal)");
		} else {
			new DnsLookup(endpoints.address);
		}
	}
}

private class HttpsProbe {
	var mLabel:String;

	var mUrl:String;

	var mStartedAt:Int = 0;

	var mStatus:Int = 0;

	var mAnsweredBy:String = "";

	var mLoader:URLLoader;

	var mReported:Bool = false;

	public function new(label:String, url:String) {
		var _loc3_:URLRequest = null;

		mStartedAt = flash.Lib.getTimer();
		mLabel = label;
		mUrl = url;
		try {
			_loc3_ = new URLRequest(url);
			_loc3_.method = "GET";
			_loc3_.useCache = false;
			_loc3_.cacheResponse = false;
			_loc3_.idleTimeout = TransportSettings.connectTimeoutMilliseconds;
			mLoader = new URLLoader();
			mLoader.addEventListener("httpResponseStatus", onResponseStatus);
			mLoader.addEventListener("complete", onComplete);
			mLoader.addEventListener("ioError", onError);
			mLoader.addEventListener("securityError", onError);
			mLoader.load(_loc3_);
		} catch (error:Dynamic) {
			report("could not start: " + Std.string(error.message));
		}
	}

	function onResponseStatus(event:HTTPStatusEvent) {
		var _loc3_:URLRequestHeader;
		var __ax4_iter_82:Array<URLRequestHeader>;
		var _loc2_:String = null;
		mStatus = event.status;
		try {
			__ax4_iter_82 = event.responseHeaders;
			if (checkNullIteratee(__ax4_iter_82))
				for (_tmp_ in __ax4_iter_82) {
					_loc3_ = _tmp_;
					_loc2_ = _loc3_.name.toLowerCase();
					if (_loc2_ == "server" || _loc2_ == "via") {
						mAnsweredBy += " " + _loc2_ + "=" + _loc3_.value;
					}
				}
		} catch (error:Dynamic) {}
	}

	function onComplete(event:Event) {
		report(Std.string(mStatus) + mAnsweredBy);
	}

	function onError(event:ErrorEvent) {
		report((mStatus != 0 ? mStatus + " " : "") + event.type + ": " + event.text + mAnsweredBy);
	}

	function report(outcome:String) {
		if (mReported) {
			return;
		}
		mReported = true;
		Logger.warnch("WS", "probe " + mLabel + " " + mUrl + " -> " + outcome + " in " + (flash.Lib.getTimer() - mStartedAt) + "ms");
		if (mLoader != null) {
			mLoader.removeEventListener("httpResponseStatus", onResponseStatus);
			mLoader.removeEventListener("complete", onComplete);
			mLoader.removeEventListener("ioError", onError);
			mLoader.removeEventListener("securityError", onError);
			mLoader = null;
		}
	}
}

private class DnsLookup {
	static inline final MAX_ADDRESSES = 4;

	var mHost:String;

	var mA:String;

	var mAAAA:String;

	var mStartedAt:Int = 0;

	var mResolvers:Array<ASAny> = [];

	var mReported:Bool = false;

	public function new(host:String) {
		mHost = host;
		mStartedAt = flash.Lib.getTimer();
		if (!DNSResolver.isSupported) {
			Logger.warnch("WS", "dns " + host + " skipped (DNSResolver unsupported)");
			return;
		}
		lookup(ARecord, "A");
		lookup(AAAARecord, "AAAA");
	}

	function lookup(recordType:Dynamic, label:String) {
		var resolver:DNSResolver;
		try {
			resolver = new DNSResolver();
			resolver.addEventListener("lookup", function(param1:flash.events.DNSResolverEvent) {
				var _loc2_:Array<ASAny> = [];
				var _loc4_:ResourceRecord;
				final __ax4_iter_83 = param1.resourceRecords;
				if (checkNullIteratee(__ax4_iter_83))
					for (_tmp_ in __ax4_iter_83) {
						_loc4_ = ASCompat.coerce(_tmp_, flash.net.dns.ResourceRecord);
						_loc2_.push((_loc4_ : ASAny).hasOwnProperty("address") ? (_loc4_ : ASAny)["address"] : _loc4_.name);
					}
				var _loc3_ = _loc2_.slice(0, 4).join(",");
				if (_loc2_.length > 4) {
					_loc3_ += ",+" + (_loc2_.length - 4);
				}
				answer(label, _loc2_.length == 0 ? "none" : _loc3_);
			});
			resolver.addEventListener("error", function(param1:ErrorEvent) {
				answer(label, "error(" + param1.text + ")");
			});
			mResolvers.push(resolver);
			resolver.lookup(mHost, recordType);
		} catch (error:Dynamic) {
			answer(label, "error(" + Std.string(error.message) + ")");
		}
	}

	function answer(label:String, value:String) {
		if (mReported) {
			return;
		}
		if (label == "A" && mA == null) {
			mA = value;
		} else if (label == "AAAA" && mAAAA == null) {
			mAAAA = value;
		}
		if (mA == null || mAAAA == null) {
			return;
		}
		mReported = true;
		Logger.warnch("WS", "dns " + mHost + " A=" + mA + " AAAA=" + mAAAA + " in " + (flash.Lib.getTimer() - mStartedAt) + "ms");
		mResolvers = [];
	}
}

final CHANNEL:String = "WS";
