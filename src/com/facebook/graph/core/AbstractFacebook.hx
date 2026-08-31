package com.facebook.graph.core;

import com.facebook.graph.data.Batch;
import com.facebook.graph.data.FQLMultiQuery;
import com.facebook.graph.data.FacebookAuthResponse;
import com.facebook.graph.data.FacebookSession;
import com.facebook.graph.net.FacebookBatchRequest;
import com.facebook.graph.net.FacebookRequest;
import com.facebook.graph.utils.FQLMultiQueryParser;
import com.facebook.graph.utils.IResultParser;
import flash.net.URLRequestMethod;

class AbstractFacebook {
	var session:FacebookSession;

	var authResponse:FacebookAuthResponse;

	var oauth2:Bool = false;

	var openRequests:ASDictionary<ASAny, ASAny>;

	var resultHash:ASDictionary<ASAny, ASAny>;

	var _locale /*renamed*/:String;

	var parserHash:ASDictionary<ASAny, ASAny>;

	public function new() {
		this.openRequests = new ASDictionary<ASAny, ASAny>();
		this.resultHash = new ASDictionary<ASAny, ASAny>(true);
		this.parserHash = new ASDictionary<ASAny, ASAny>();
	}

	@:isVar var accessToken(get, never):String;

	function get_accessToken():String {
		if (this.oauth2 && this.authResponse != null || this.session != null) {
			return this.oauth2 ? this.authResponse.accessToken : this.session.accessToken;
		}
		return null;
	}

	function _api /*renamed*/ (method:String, callback:ASFunction = null, params:ASAny = null, requestMethod:String = "GET") {
		method = method.indexOf("/") != 0 ? "/" + method : method;
		if (ASCompat.stringAsBool(this.accessToken)) {
			if (params == null) {
				params = {};
			}
			if (params.access_token == null) {
				ASCompat.setProperty(params, "access_token", this.accessToken);
			}
		}
		var _loc5_ = new FacebookRequest();
		if (ASCompat.stringAsBool(this._locale)) {
			ASCompat.setProperty(params, "locale", this._locale);
		}
		this.openRequests[_loc5_] = callback;
		_loc5_.call(FacebookURLDefaults.GRAPH_URL + method, requestMethod, this.handleRequestLoad, params);
	}

	function _uploadVideo /*renamed*/ (method:String, callback:ASFunction = null, params:ASAny = null) {
		method = method.indexOf("/") != 0 ? "/" + method : method;
		if (ASCompat.stringAsBool(this.accessToken)) {
			if (params == null) {
				params = {};
			}
			if (params.access_token == null) {
				ASCompat.setProperty(params, "access_token", this.accessToken);
			}
		}
		var _loc4_ = new FacebookRequest();
		if (ASCompat.stringAsBool(this._locale)) {
			ASCompat.setProperty(params, "locale", this._locale);
		}
		this.openRequests[_loc4_] = callback;
		_loc4_.call(FacebookURLDefaults.VIDEO_URL + method, "POST", this.handleRequestLoad, params);
	}

	function pagingCall(url:String, callback:ASFunction):FacebookRequest {
		var _loc3_ = new FacebookRequest();
		this.openRequests[_loc3_] = callback;
		_loc3_.callURL(this.handleRequestLoad, url, this._locale);
		return _loc3_;
	}

	function _getRawResult /*renamed*/ (data:ASObject):ASObject {
		return this.resultHash[data];
	}

	function _nextPage /*renamed*/ (data:ASObject, callback:ASFunction = null):FacebookRequest {
		var _loc3_:FacebookRequest = null;
		var _loc4_:ASObject = this._getRawResult(data);
		if (ASCompat.toBool(_loc4_) && ASCompat.toBool(_loc4_.paging) && ASCompat.toBool(_loc4_.paging.next)) {
			_loc3_ = this.pagingCall(_loc4_.paging.next, callback);
		} else if (callback != null) {
			callback(null, "no page");
		}
		return _loc3_;
	}

	function _previousPage /*renamed*/ (data:ASObject, callback:ASFunction = null):FacebookRequest {
		var _loc3_:FacebookRequest = null;
		var _loc4_:ASObject = this._getRawResult(data);
		if (ASCompat.toBool(_loc4_) && ASCompat.toBool(_loc4_.paging) && ASCompat.toBool(_loc4_.paging.previous)) {
			_loc3_ = this.pagingCall(_loc4_.paging.previous, callback);
		} else if (callback != null) {
			callback(null, "no page");
		}
		return _loc3_;
	}

	function handleRequestLoad(target:FacebookRequest) {
		var _loc3_:ASObject = null;
		var _loc4_:IResultParser = null;
		var _loc2_ = ASCompat.asFunction(this.openRequests[target]);
		if (_loc2_ == null) {
			this.openRequests.remove(target);
		}
		if (target.success) {
			_loc3_ = target.data.hasOwnProperty("data") ? target.data.data : target.data;
			this.resultHash[_loc3_] = target.data;
			if (_loc3_.hasOwnProperty("error_code")) {
				_loc2_(null, _loc3_);
			} else {
				if (Std.isOfType(this.parserHash[target], IResultParser)) {
					_loc4_ = ASCompat.dynamicAs(this.parserHash[target], IResultParser);
					_loc3_ = _loc4_.parse(_loc3_);
					this.parserHash[target] = null;
					this.parserHash.remove(target);
				}
				_loc2_(_loc3_, null);
			}
		} else {
			_loc2_(null, target.data);
		}
		this.openRequests.remove(target);
	}

	function _callRestAPI /*renamed*/ (methodName:String, callback:ASFunction = null, values:ASAny = null, requestMethod:String = "GET") {
		var _loc6_:IResultParser = null;
		if (values == null) {
			values = {};
		}
		ASCompat.setProperty(values, "format", "json");
		if (ASCompat.stringAsBool(this.accessToken)) {
			ASCompat.setProperty(values, "access_token", this.accessToken);
		}
		if (ASCompat.stringAsBool(this._locale)) {
			ASCompat.setProperty(values, "locale", this._locale);
		}
		var _loc5_ = new FacebookRequest();
		this.openRequests[_loc5_] = callback;
		if (Std.isOfType(this.parserHash[values["queries"]], IResultParser)) {
			_loc6_ = ASCompat.dynamicAs(this.parserHash[values["queries"]], IResultParser);
			this.parserHash[values["queries"]] = null;
			this.parserHash.remove(values["queries"]);
			this.parserHash[_loc5_] = _loc6_;
		}
		_loc5_.call(FacebookURLDefaults.API_URL + "/method/" + methodName, requestMethod, this.handleRequestLoad, values);
	}

	function _fqlQuery /*renamed*/ (query:String, callback:ASFunction = null, values:ASObject = null) {
		var _loc4_:String = null;
		if (checkNullIteratee(values))
			for (_tmp_ in values.___keys()) {
				_loc4_ = _tmp_;
				query = new compat.RegExp("\\{" + _loc4_ + "\\}", "g").replace(query, values[_loc4_]);
			}
		this._callRestAPI("fql.query", callback, {"query": query});
	}

	function _fqlMultiQuery /*renamed*/ (queries:FQLMultiQuery, callback:ASFunction = null, parser:IResultParser = null) {
		this.parserHash[queries.toString()] = parser != null ? parser : new FQLMultiQueryParser();
		this._callRestAPI("fql.multiquery", callback, {"queries": queries.toString()});
	}

	function _batchRequest /*renamed*/ (batch:Batch, callback:ASFunction = null) {
		var _loc3_:FacebookBatchRequest = null;
		if (ASCompat.stringAsBool(this.accessToken)) {
			_loc3_ = new FacebookBatchRequest(batch, callback);
			this.resultHash[_loc3_] = true;
			_loc3_.call(this.accessToken);
		}
	}

	function _deleteObject /*renamed*/ (method:String, callback:ASFunction = null) {
		var _loc3_:ASObject = {"method": "delete"};
		this._api(method, callback, _loc3_, URLRequestMethod.POST);
	}

	function _getImageUrl /*renamed*/ (id:String, type:String = null):String {
		return FacebookURLDefaults.GRAPH_URL + "/" + id + "/picture" + (type != null ? "?type=" + type : "");
	}
}
