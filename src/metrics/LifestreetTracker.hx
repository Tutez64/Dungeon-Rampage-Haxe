package metrics;

import brain.logger.Logger;
import facade.DBFacade;
import com.adobe.serialization.json.JSON;
import flash.external.ExternalInterface;
import flash.net.URLLoader;
import flash.net.URLRequest;

class LifestreetTracker {
	static var LIFESTREET_NODE_COMPLETED_URL:String = "https://pix.lfstmedia.com/_tracker/455?__noscript=true&propname=%7Cadvertiser_offer_id&propvalue=125041";

	static var LIFESTREET_CAMPAIGN:String = "lifestreet";

	public static var IS_FUNCTIONAL:Bool = true;

	public static var LIFESTREET_NODE_ID:UInt = (50007 : UInt);

	public static var LIFESTREET_TUTORIAL_COMPLETED:String = "LIFESTREET_TUTORIAL_COMPLETED";

	public static var LIFESTREET_NODE_COMPLETED:String = "LIFESTREET_NODE_COMPLETED";

	public function new() {}

	public static function isLifestreetUser(dbFacade:DBFacade):Bool {
		if (!dbFacade.isFacebookPlayer) {
			return false;
		}
		var _loc2_ = dbFacade.dbConfigManager.getConfigString("AncestorCampaign", "");
		Logger.info("Ancestor Campaign:" + _loc2_);
		return _loc2_.indexOf(LIFESTREET_CAMPAIGN) == 0;
	}

	static function callURL(dbFacade:DBFacade, url:String) {
		var loader:URLLoader;
		var facebookIdUrl = "https://graph.facebook.com/" + dbFacade.dbAccountInfo.facebookId;
		var fbURLRequest = new URLRequest(facebookIdUrl);
		fbURLRequest.method = "GET";
		loader = new URLLoader(fbURLRequest);
		loader.addEventListener("ioError", (cast function() {}));
		loader.addEventListener("securityError", (cast function() {}));
		loader.addEventListener("complete", function(param1:flash.events.Event) {
			var _loc2_:URLRequest = null;
			Logger.debug("Lifestreet graph event received");
			var _loc3_ = cast(param1.target, URLLoader);
			var _loc4_:ASObject = com.adobe.serialization.json.JSON.decode(_loc3_.data);
			if (_loc4_.gender == "male") {
				_loc2_ = new URLRequest(url);
				_loc2_.method = "GET";
				Logger.debug("LifestreetTracker: " + _loc2_.url);
				if (ExternalInterface.available) {
					ExternalInterface.call("addLifestreetNodeCompletionTracker");
				}
			}
		});
		loader.load(fbURLRequest);
	}

	public static function nodeCompleted(dbFacade:DBFacade) {
		callURL(dbFacade, LIFESTREET_NODE_COMPLETED_URL);
		dbFacade.dbAccountInfo.dbAccountParams.setLifestreetParam();
	}
}
