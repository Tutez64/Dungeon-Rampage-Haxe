package brain.facebookAPI;

import brain.facade.Facade;
import brain.logger.Logger;
import com.facebook.graph.Facebook;
import flash.external.ExternalInterface;

class FacebookAPIController {
	var mAccessToken:String = "";

	var mScope:String;

	var mUserId:String = "";

	public function new(facade:Facade, fbAppID:String) {
		var _loc3_:ASObject = {
			"appId": fbAppID,
			"status": true,
			"cookie": true,
			"xfbml": true,
			"frictionlessRequests": true,
			"oauth": true
		};
		Logger.debug("Initing app: " + fbAppID.toString());
		if (ExternalInterface.available) {
			Facebook.addJSEventListener("auth.authResponseChange", onAuthResponseChange);
			Facebook.init(fbAppID, handleInit, _loc3_);
		}
	}

	@:isVar public var accessToken(get, never):String;

	public function get_accessToken():String {
		return mAccessToken;
	}

	@:isVar public var fbUserId(get, never):String;

	public function get_fbUserId():String {
		return mUserId;
	}

	function onAuthResponseChange(response:ASObject) {
		Logger.debug("Auth response Changed");
	}

	function handleLogin(successCallback:ASFunction) {
		Facebook.login(ASCompat.asFunction((function():ASAny {
			var detectLogin:ASFunction;
			return detectLogin = function(param1:ASObject, param2:ASObject) {
				if (ASCompat.toBool(param1)) {
					Logger.debug("Logged in to FB");
					mAccessToken = param1.accessToken;
					successCallback();
				} else {
					Logger.debug("Login Failed ");
				}
			};
		})()), {"scope": mScope});
	}

	function handleInit(success:ASObject, fail:ASObject) {
		if (ASCompat.toBool(success)) {
			Logger.debug("Init Success ");
			if (ASCompat.toBool(success.accessToken)) {
				mAccessToken = success.accessToken;
			}
		} else {
			Logger.debug("Init Failed");
		}
	}

	function detectLogin(success:ASObject, fail:ASObject) {
		if (ASCompat.toBool(success)) {
			Logger.debug("Logged in to FB");
			mAccessToken = success.accessToken;
		} else {
			Logger.debug("Login Failed ");
		}
	}

	function feedPost(feedName:String = " ", feedCaption:String = " ", feedDescription:String = " ", feedLink:String = "", feedPicLink:String = "",
			feedDisplay:String = "dialog", callback:ASFunction = null, feedReceiverId:String = "", feedPropertiesArray:ASObject = null,
			feedActions:ASObject = null) {
		var _loc11_:ASObject = {
			"name": feedName,
			"link": feedLink,
			"picture": feedPicLink,
			"caption": feedCaption,
			"description": feedDescription,
			"to": feedReceiverId,
			"properties": feedPropertiesArray,
			"actions": feedActions
		};
		Facebook.ui("feed", _loc11_, callback, feedDisplay);
	}

	function friendRequests(requestMessage:String, requestTitle:String = "Invite Friends", requestDisplay:String = "dialog", callback:ASFunction = null,
			requestFilters:Array<ASAny> = null, requestData:ASObject = null, requestMaxRecipients:String = "50", facebookId:String = "",
			excludeIds:Array<ASAny> = null) {
		var _loc10_:ASObject = {
			"message": requestMessage,
			"title": requestTitle,
			"filters": requestFilters,
			"max_recipients": requestMaxRecipients,
			"data": requestData,
			"to": facebookId,
			"exclude_ids": excludeIds
		};
		Facebook.ui("apprequests", _loc10_, callback, requestDisplay);
	}

	function postAchievement(fbID:String, params:ASObject, achievementCallback:ASFunction = null) {
		var _loc4_ = "/" + fbID + "/achievements";
		Facebook.api(_loc4_, achievementCallback, params, "POST");
	}
}
