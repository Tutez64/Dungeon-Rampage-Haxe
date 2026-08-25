package metrics;

import brain.logger.Logger;
import facade.DBFacade;
import com.maccherone.json.JSON;
import flash.events.Event;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;

class MetricsLogger {
	var mMetricsURL:String;

	var mDBFacade:DBFacade;

	public function new(dbFacade:DBFacade, metricsLoggingUrl:String) {
		mDBFacade = dbFacade;
		mMetricsURL = metricsLoggingUrl;
		if (!ASCompat.stringAsBool(mMetricsURL) || mMetricsURL.length == 0) {
			Logger.info("Empty metrics URL. Cannot log metrics.");
		}
	}

	public function log(eventName:String, eventData:ASObject = null) {
		if (!ASCompat.stringAsBool(mMetricsURL)) {
			return;
		}
		var _loc3_ = new URLRequest(mMetricsURL);
		if (eventData == null) {
			eventData = {};
		}
		var _loc6_:String;
		final __ax4_iter_131:ASObject = mDBFacade.demographics;
		if (checkNullIteratee(__ax4_iter_131))
			for (_tmp_ in __ax4_iter_131.___keys()) {
				_loc6_ = _tmp_;
				if (eventData.hasOwnProperty(_loc6_)) {
					Logger.warn("Duplicate metric property: " + _loc6_ + " in event: " + eventName);
				}
				eventData[_loc6_] = mDBFacade.demographics[_loc6_];
			}
		var _loc4_ = com.maccherone.json.JSON.encode(eventData);
		var _loc7_ = new URLVariables();
		ASCompat.setProperty(_loc7_, "e", eventName);
		ASCompat.setProperty(_loc7_, "parameters", _loc4_);
		_loc3_.data = _loc7_;
		_loc3_.method = "POST";
		var _loc5_ = new URLLoader(_loc3_);
		_loc5_.addEventListener("complete", completeHandler);
		_loc5_.addEventListener("securityError", securityErrorHandler);
		_loc5_.addEventListener("ioError", ioErrorHandler);
		_loc5_.load(_loc3_);
	}

	function completeHandler(e:Event) {}

	function securityErrorHandler(e:Event) {
		Logger.warn("SecurityError on metrics logging: " + e.toString());
	}

	function ioErrorHandler(e:Event) {
		Logger.warn("IOError on metrics logging: " + e.toString());
	}
}
