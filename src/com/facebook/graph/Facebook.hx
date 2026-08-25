package com.facebook.graph;

import com.adobe.serialization.json.JSON;
import com.facebook.graph.core.AbstractFacebook;
import com.facebook.graph.core.FacebookJSBridge;
import com.facebook.graph.core.FacebookURLDefaults;
import com.facebook.graph.data.Batch;
import com.facebook.graph.data.FQLMultiQuery;
import com.facebook.graph.data.FacebookAuthResponse;
import com.facebook.graph.net.FacebookRequest;
import com.facebook.graph.utils.IResultParser;
import flash.external.ExternalInterface;
import flash.net.URLRequest;
import flash.net.URLRequestMethod;
import flash.net.URLVariables;

class Facebook extends AbstractFacebook {
	static var _instance:Facebook;

	static var _canInit:Bool = false;

	var jsCallbacks:ASObject;

	var openUICalls:ASDictionary<ASAny, ASAny>;

	var jsBridge:FacebookJSBridge;

	var applicationId:String;

	var _initCallback:ASFunction;

	var _loginCallback:ASFunction;

	var _logoutCallback:ASFunction;

	public function new() {
		super();
		if (_canInit == false) {
			throw new Error("Facebook is an singleton and cannot be instantiated.");
		}
		this.jsBridge = new FacebookJSBridge();
		this.jsCallbacks = {};
		this.openUICalls = new ASDictionary<ASAny, ASAny>();
	}

	public static function init(applicationId:String, callback:ASFunction = null, options:ASObject = null, accessToken:String = null) {
		getInstance()._init(applicationId, callback, options, accessToken);
	}

	@:isVar public static var locale(never, set):String;

	static public function set_locale(value:String):String {
		return getInstance()._locale = value;
	}

	public static function login(callback:ASFunction, options:ASObject = null) {
		getInstance()._login(callback, options);
	}

	public static function mobileLogin(redirectUri:String, display:String = "touch", extendedPermissions:Array<ASAny> = null) {
		var _loc4_ = new URLVariables();
		ASCompat.setProperty(_loc4_, "client_id", getInstance().applicationId);
		ASCompat.setProperty(_loc4_, "redirect_uri", redirectUri);
		ASCompat.setProperty(_loc4_, "display", display);
		if (extendedPermissions != null) {
			ASCompat.setProperty(_loc4_, "scope", extendedPermissions.join(","));
		}
		var _loc5_ = new URLRequest(FacebookURLDefaults.AUTH_URL);
		_loc5_.method = URLRequestMethod.GET;
		_loc5_.data = _loc4_;
		flash.Lib.getURL(_loc5_, "_self");
	}

	public static function mobileLogout(redirectUri:String) {
		getInstance().authResponse = null;
		var _loc2_ = new URLVariables();
		ASCompat.setProperty(_loc2_, "confirm", 1);
		ASCompat.setProperty(_loc2_, "next", redirectUri);
		var _loc3_ = new URLRequest("http://m.facebook.com/logout.php");
		_loc3_.method = URLRequestMethod.GET;
		_loc3_.data = _loc2_;
		flash.Lib.getURL(_loc3_, "_self");
	}

	public static function logout(callback:ASFunction) {
		getInstance()._logout(callback);
	}

	public static function ui(method:String, data:ASObject, callback:ASFunction = null, display:String = null) {
		getInstance()._ui(method, data, callback, display);
	}

	public static function api(method:String, callback:ASFunction = null, params:ASAny = null, requestMethod:String = "GET") {
		getInstance()._api(method, callback, params, requestMethod);
	}

	public static function getRawResult(data:ASObject):ASObject {
		return getInstance()._getRawResult(data);
	}

	public static function hasNext(data:ASObject):Bool {
		var _loc2_:ASObject = getInstance()._getRawResult(data);
		if (!ASCompat.toBool(_loc2_.paging)) {
			return false;
		}
		return _loc2_.paging.next != null;
	}

	public static function hasPrevious(data:ASObject):Bool {
		var _loc2_:ASObject = getInstance()._getRawResult(data);
		if (!ASCompat.toBool(_loc2_.paging)) {
			return false;
		}
		return _loc2_.paging.previous != null;
	}

	public static function nextPage(data:ASObject, callback:ASFunction):FacebookRequest {
		return getInstance()._nextPage(data, callback);
	}

	public static function previousPage(data:ASObject, callback:ASFunction):FacebookRequest {
		return getInstance()._previousPage(data, callback);
	}

	public static function postData(method:String, callback:ASFunction = null, params:ASObject = null) {
		api(method, callback, params, URLRequestMethod.POST);
	}

	public static function uploadVideo(method:String, callback:ASFunction = null, params:ASAny = null) {
		getInstance()._uploadVideo(method, callback, params);
	}

	public static function fqlQuery(query:String, callback:ASFunction = null, values:ASObject = null) {
		getInstance()._fqlQuery(query, callback, values);
	}

	public static function fqlMultiQuery(queries:FQLMultiQuery, callback:ASFunction = null, parser:IResultParser = null) {
		getInstance()._fqlMultiQuery(queries, callback, parser);
	}

	public static function batchRequest(batch:Batch, callback:ASFunction = null) {
		getInstance()._batchRequest(batch, callback);
	}

	public static function callRestAPI(methodName:String, callback:ASFunction, values:ASAny = null, requestMethod:String = "GET") {
		getInstance()._callRestAPI(methodName, callback, values, requestMethod);
	}

	public static function getImageUrl(id:String, type:String = null):String {
		return getInstance()._getImageUrl(id, type);
	}

	public static function deleteObject(method:String, callback:ASFunction = null) {
		getInstance()._deleteObject(method, callback);
	}

	public static function addJSEventListener(event:String, listener:ASFunction) {
		getInstance()._addJSEventListener(event, listener);
	}

	public static function removeJSEventListener(event:String, listener:ASFunction) {
		getInstance()._removeJSEventListener(event, listener);
	}

	public static function hasJSEventListener(event:String, listener:ASFunction):Bool {
		return getInstance()._hasJSEventListener(event, listener);
	}

	public static function setCanvasAutoResize(autoSize:Bool = true, interval:UInt = (100 : UInt)) {
		getInstance()._setCanvasAutoResize(autoSize, interval);
	}

	public static function setCanvasSize(width:Float, height:Float) {
		getInstance()._setCanvasSize(width, height);
	}

	public static function callJS(methodName:String, params:ASObject) {
		getInstance()._callJS(methodName, params);
	}

	public static function getAuthResponse():FacebookAuthResponse {
		return getInstance()._getAuthResponse();
	}

	public static function getLoginStatus() {
		getInstance()._getLoginStatus();
	}

	static function getInstance():Facebook {
		if (_instance == null) {
			_canInit = true;
			_instance = new Facebook();
			_canInit = false;
		}
		return _instance;
	}

	function _init /*renamed*/ (applicationId:String, callback:ASFunction = null, options:ASObject = null, accessToken:String = null) {
		ExternalInterface.addCallback("handleJsEvent", this.handleJSEvent);
		ExternalInterface.addCallback("authResponseChange", this.handleAuthResponseChange);
		ExternalInterface.addCallback("logout", this.handleLogout);
		ExternalInterface.addCallback("uiResponse", this.handleUI);
		this._initCallback = callback;
		this.applicationId = applicationId;
		this.oauth2 = true;
		if (options == null) {
			options = {};
		}
		ASCompat.setProperty(options, "appId", applicationId);
		ASCompat.setProperty(options, "oauth", true);
		ExternalInterface.call("FBAS.init", com.adobe.serialization.json.JSON.encode(options));
		if (accessToken != null) {
			authResponse = new FacebookAuthResponse();
			authResponse.accessToken = accessToken;
		}
		if (options.status != false) {
			this._getLoginStatus();
		} else if (this._initCallback != null) {
			this._initCallback(authResponse, null);
			this._initCallback = null;
		}
	}

	function _getLoginStatus /*renamed*/ () {
		ExternalInterface.call("FBAS.getLoginStatus");
	}

	function _callJS /*renamed*/ (methodName:String, params:ASObject) {
		ExternalInterface.call(methodName, params);
	}

	function _setCanvasSize /*renamed*/ (width:Float, height:Float) {
		ExternalInterface.call("FBAS.setCanvasSize", width, height);
	}

	function _setCanvasAutoResize /*renamed*/ (autoSize:Bool = true, interval:UInt = (100 : UInt)) {
		ExternalInterface.call("FBAS.setCanvasAutoResize", autoSize, interval);
	}

	function _login /*renamed*/ (callback:ASFunction, options:ASObject = null) {
		this._loginCallback = callback;
		ExternalInterface.call("FBAS.login", com.adobe.serialization.json.JSON.encode(options));
	}

	function _logout /*renamed*/ (callback:ASFunction) {
		this._logoutCallback = callback;
		ExternalInterface.call("FBAS.logout");
	}

	function _getAuthResponse /*renamed*/ ():FacebookAuthResponse {
		var a:FacebookAuthResponse;
		var authResponseObj:ASObject = null;
		var result:String = ExternalInterface.call("FBAS.getAuthResponse");
		try {
			authResponseObj = com.adobe.serialization.json.JSON.decode(result);
		} catch (e:ASAny) {
			return null;
		}
		a = new FacebookAuthResponse();
		a.fromJSON(authResponseObj);
		this.authResponse = a;
		return authResponse;
	}

	function _ui /*renamed*/ (method:String, data:ASObject, callback:ASFunction = null, display:String = null) {
		ASCompat.setProperty(data, "method", method);
		if (callback != null) {
			this.openUICalls[method] = callback;
		}
		if (ASCompat.stringAsBool(display)) {
			ASCompat.setProperty(data, "display", display);
		}
		ExternalInterface.call("FBAS.ui", com.adobe.serialization.json.JSON.encode(data));
	}

	function _addJSEventListener /*renamed*/ (event:String, listener:ASFunction) {
		if (this.jsCallbacks[event] == null) {
			this.jsCallbacks[event] = new ASDictionary<ASAny, ASAny>();
			ExternalInterface.call("FBAS.addEventListener", event);
		}
		this.jsCallbacks[event][listener] = null;
	}

	function _removeJSEventListener /*renamed*/ (event:String, listener:ASFunction) {
		if (this.jsCallbacks[event] == null) {
			return;
		}
		ASCompat.deleteProperty(this.jsCallbacks[event], listener);
	}

	function _hasJSEventListener /*renamed*/ (event:String, listener:ASFunction):Bool {
		if (this.jsCallbacks[event] == null || this.jsCallbacks[event][listener] != null) {
			return false;
		}
		return true;
	}

	function handleUI(result:String, method:String) {
		var _loc3_:ASObject = ASCompat.stringAsBool(result) ? com.adobe.serialization.json.JSON.decode(result) : null;
		var _loc4_ = ASCompat.asFunction(this.openUICalls[method]);
		if (_loc4_ == null) {
			this.openUICalls.remove(method);
		} else {
			_loc4_(_loc3_);
			this.openUICalls.remove(method);
		}
	}

	function handleLogout() {
		authResponse = null;
		if (this._logoutCallback != null) {
			this._logoutCallback(true);
			this._logoutCallback = null;
		}
	}

	function handleJSEvent(event:String, result:String = null) {
		var __ax4_iter_154:ASAny;
		var _loc3_:ASObject = null;
		var _loc4_:ASObject = null;
		if (this.jsCallbacks[event] != null) {
			try {
				_loc3_ = com.adobe.serialization.json.JSON.decode(result);
			} catch (e:com.adobe.serialization.json.JSONParseError) {}
			__ax4_iter_154 = this.jsCallbacks[event];
			if (checkNullIteratee(__ax4_iter_154))
				for (_tmp_ in __ax4_iter_154.___keys()) {
					_loc4_ = _tmp_;
					ASCompat.asFunction(_loc4_)(_loc3_);
					ASCompat.deleteProperty(this.jsCallbacks[event], _loc4_);
				}
		}
	}

	function handleAuthResponseChange(result:String) {
		var resultObj:ASObject = null;
		var success = true;
		if (result != null) {
			try {
				resultObj = com.adobe.serialization.json.JSON.decode(result);
			} catch (e:com.adobe.serialization.json.JSONParseError) {
				success = false;
			}
		} else {
			success = false;
		}
		if (success) {
			if (authResponse == null) {
				authResponse = new FacebookAuthResponse();
				authResponse.fromJSON(resultObj);
			} else {
				authResponse.fromJSON(resultObj);
			}
		}
		if (this._initCallback != null) {
			this._initCallback(authResponse, null);
			this._initCallback = null;
		}
		if (this._loginCallback != null) {
			this._loginCallback(authResponse, null);
			this._loginCallback = null;
		}
	}
}
