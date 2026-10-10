package com.facebook.graph.net;

import com.adobe.images.PNGEncoder;
import com.adobe.serialization.json.JSON;
import com.facebook.graph.utils.PostRequest;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.net.FileReference;
import flash.net.URLLoader;
import flash.net.URLRequest;
import flash.net.URLVariables;
import flash.utils.ByteArray;

class AbstractFacebookRequest {
	var urlLoader:URLLoader;

	var urlRequest:URLRequest;

	var _rawResult:String;

	var _data:ASObject;

	var _success:Bool = false;

	var _url:String;

	var _requestMethod:String;

	var _callback:ASFunction;

	public function new() {}

	@:isVar public var rawResult(get, never):String;

	public function get_rawResult():String {
		return this._rawResult;
	}

	@:isVar public var success(get, never):Bool;

	public function get_success():Bool {
		return this._success;
	}

	@:isVar public var data(get, never):ASObject;

	public function get_data():ASObject {
		return this._data;
	}

	public function callURL(callback:ASFunction, url:String = "", locale:String = null) {
		var _loc4_:URLVariables = null;
		this._callback = callback;
		this.urlRequest = new URLRequest(url.length != 0 ? url : this._url);
		if (ASCompat.stringAsBool(locale)) {
			_loc4_ = new URLVariables();
			ASCompat.setProperty(_loc4_, "locale", locale);
			this.urlRequest.data = _loc4_;
		}
		this.loadURLLoader();
	}

	@:isVar public var successCallback(never, set):ASFunction;

	public function set_successCallback(value:ASFunction):ASFunction {
		return this._callback = value;
	}

	function isValueFile(value:ASObject):Bool {
		return Std.isOfType(value, FileReference) || Std.isOfType(value, Bitmap) || Std.isOfType(value, BitmapData) || ASCompat.isByteArray(value);
	}

	function objectToURLVariables(values:ASObject):URLVariables {
		var _loc3_:String = null;
		var _loc2_ = new URLVariables();
		if (values == null) {
			return _loc2_;
		}
		if (checkNullIteratee(values))
			for (_tmp_ in values.___keys()) {
				_loc3_ = _tmp_;
				(_loc2_ : ASAny)[_loc3_] = values[_loc3_];
			}
		return _loc2_;
	}

	public function close() {
		if (this.urlLoader != null) {
			this.urlLoader.removeEventListener(Event.COMPLETE, this.handleURLLoaderComplete);
			this.urlLoader.removeEventListener(IOErrorEvent.IO_ERROR, this.handleURLLoaderIOError);
			this.urlLoader.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleURLLoaderSecurityError);
			try {
				this.urlLoader.close();
			} catch (e:ASAny) {}
			this.urlLoader = null;
		}
	}

	function loadURLLoader() {
		this.urlLoader = new URLLoader();
		this.urlLoader.addEventListener(Event.COMPLETE, this.handleURLLoaderComplete, false, 0, false);
		this.urlLoader.addEventListener(IOErrorEvent.IO_ERROR, this.handleURLLoaderIOError, false, 0, true);
		this.urlLoader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.handleURLLoaderSecurityError, false, 0, true);
		this.urlLoader.load(this.urlRequest);
	}

	function handleURLLoaderComplete(event:Event) {
		this.handleDataLoad(this.urlLoader.data);
	}

	function handleDataLoad(result:ASObject, dispatchCompleteEvent:Bool = true) {
		this._rawResult = ASCompat.asString(result);
		this._success = true;
		try {
			this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
		} catch (e:ASAny) {
			_data = _rawResult;
			_success = false;
		}
		this.handleDataReady();
		if (dispatchCompleteEvent) {
			this.dispatchComplete();
		}
	}

	function handleDataReady() {}

	function dispatchComplete() {
		if (this._callback != null) {
			this._callback(this);
		}
		this.close();
	}

	function handleURLLoaderIOError(event:IOErrorEvent) {
		this._success = false;
		this._rawResult = ASCompat.dynamicAs(event.target, URLLoader).data;
		if (this._rawResult != "") {
			try {
				this._data = com.adobe.serialization.json.JSON.decode(this._rawResult);
			} catch (e:ASAny) {
				_data = {
					"type": "Exception",
					"message": _rawResult
				};
			}
		} else {
			this._data = event;
		}
		this.dispatchComplete();
	}

	function handleURLLoaderSecurityError(event:SecurityErrorEvent) {
		this._success = false;
		this._rawResult = ASCompat.dynamicAs(event.target, URLLoader).data;
		try {
			this._data = com.adobe.serialization.json.JSON.decode(ASCompat.dynamicAs(event.target, URLLoader).data);
		} catch (e:ASAny) {
			_data = event;
		}
		this.dispatchComplete();
	}

	function extractFileData(values:ASObject):ASObject {
		var _loc2_:ASObject = null;
		var _loc3_:String = null;
		if (values == null) {
			return null;
		}
		if (this.isValueFile(values)) {
			_loc2_ = values;
		} else if (values != null) {
			if (checkNullIteratee(values))
				for (_tmp_ in values.___keys()) {
					_loc3_ = _tmp_;
					if (this.isValueFile(values[_loc3_])) {
						_loc2_ = values[_loc3_];
						ASCompat.deleteProperty(values, _loc3_);
						break;
					}
				}
		}
		return _loc2_;
	}

	function createUploadFileRequest(fileData:ASObject, values:ASObject = null):PostRequest {
		var _loc4_:String = null;
		var _loc5_:ByteArray = null;
		var _loc3_ = new PostRequest();
		if (ASCompat.toBool(values)) {
			if (checkNullIteratee(values))
				for (_tmp_ in values.___keys()) {
					_loc4_ = _tmp_;
					_loc3_.writePostData(_loc4_, values[_loc4_]);
				}
		}
		if (Std.isOfType(fileData, Bitmap)) {
			fileData = ASCompat.dynamicAs(fileData, Bitmap).bitmapData;
		}
		if (ASCompat.isByteArray(fileData)) {
			_loc3_.writeFileData(values.fileName, (fileData : ByteArray), values.contentType);
		} else if (Std.isOfType(fileData, BitmapData)) {
			_loc5_ = PNGEncoder.encode(ASCompat.dynamicAs(fileData, BitmapData));
			_loc3_.writeFileData(values.fileName, _loc5_, "image/png");
		}
		_loc3_.close();
		this.urlRequest.contentType = "multipart/form-data; boundary=" + _loc3_.boundary;
		return _loc3_;
	}

	public function toString():String {
		return this.urlRequest.url + (this.urlRequest.data == null ? "" : "?" + ASCompat.unescape(Std.string(this.urlRequest.data)));
	}
}
