package networkCode.transport;

import brain.logger.Logger;
import air.net.WebSocket;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;

class NativeWebSocketTransport extends EventDispatcher implements IGameTransport {
	public static inline final FORMAT_STRING = (1 : UInt);

	public static inline final FORMAT_BINARY = (2 : UInt);

	static inline final CLOSE_NORMAL = 1000;

	static inline final EVENT_CONNECT = "connect";

	static inline final EVENT_DATA = "websocketData";

	static inline final EVENT_CLOSE = "close";

	static inline final EVENT_CERTIFICATE_ERROR = "certificateError";

	var mUrl:String;

	var mEnforceServerCertificate:Bool = false;

	var mNative:ASObject;

	var mConnected:Bool = false;

	var mFinished:Bool = false;

	public function new(url:String, enforceServerCertificate:Bool) {
		super();
		mUrl = url;
		mEnforceServerCertificate = enforceServerCertificate;
	}

	static function readStringData(payloadEvent:ASObject):String {
		try {
			if (payloadEvent.stringData != null) {
				return ASCompat.toString(payloadEvent.stringData);
			}
		} catch (stringDataError:Dynamic) {}
		try {
			if (payloadEvent.data != null) {
				return ASCompat.toString(payloadEvent.data);
			}
		} catch (dataError:Dynamic) {}
		return null;
	}

	static function readErrorText(event:Event):String {
		var _loc4_:String;
		try {
			return ASCompat.toString((event : ASObject).text);
		} catch (error:Dynamic) {
			_loc4_ = event.type;
		}
		return _loc4_;
	}

	static function absorbLateError(event:Event) {
		Logger.debugch("WS", "A native WebSocket transport ignored an error raised after it finished: " + event);
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return "nativeWss " + mUrl;
	}

	@:isVar public var connected(get, never):Bool;

	public function get_connected():Bool {
		return mConnected;
	}

	@:isVar public var supportsSessions(get, never):Bool;

	public function get_supportsSessions():Bool {
		return true;
	}

	public function connect() {
		if (mNative != null || mFinished) {
			return;
		}
		try {
			mNative = new WebSocket();
			mNative.addEventListener("connect", onNativeConnect);
			mNative.addEventListener("websocketData", onNativeData);
			mNative.addEventListener("close", onNativeClose);
			mNative.addEventListener("ioError", onNativeIoError);
			mNative.addEventListener("securityError", onNativeSecurityError);
			mNative.addEventListener("certificateError", onNativeCertificateError);
			mNative.connect(mUrl);
		} catch (error:Dynamic) {
			fail((602 : UInt), error.message);
		}
	}

	public function send(bytes:ByteArray) {
		if (!connected || bytes == null || bytes.length == 0) {
			return;
		}
		try {
			bytes.position = (0 : UInt);
			mNative.sendMessage(2, bytes);
		} catch (error:Dynamic) {
			Logger.warnch("WS", "NativeWebSocketTransport send failed: " + Std.string(error.message));
			fail((602 : UInt), error.message);
		}
	}

	public function sendText(text:String) {
		if (!connected || text == null) {
			return;
		}
		try {
			mNative.sendMessage(1, text);
		} catch (error:Dynamic) {
			Logger.warnch("WS", "NativeWebSocketTransport sendText failed: " + Std.string(error.message));
			fail((602 : UInt), error.message);
		}
	}

	public function close() {
		closeWith(1000);
	}

	public function abandon() {
		closeWith(4000);
	}

	function closeWith(closeStatus:Int) {
		mFinished = true;
		mConnected = false;
		var _loc2_:ASObject = mNative;
		releaseNative();
		if (_loc2_ != null) {
			try {
				_loc2_.close(closeStatus);
			} catch (error:Dynamic) {}
		}
	}

	function onNativeConnect(event:Event) {
		mConnected = true;
		dispatchEvent(GameTransportEvent.connectedEvent());
	}

	function onNativeData(event:Event) {
		var _loc3_:ByteArray = null;
		var _loc2_:ASObject = null;
		var _loc4_ = 0;
		var _loc5_:String = null;
		try {
			_loc2_ = event;
			_loc4_ = ASCompat.toInt(_loc2_.format);
			if (_loc4_ == 1) {
				_loc5_ = readStringData(_loc2_);
				if (_loc5_ == null) {
					Logger.warnch("WS", "NativeWebSocketTransport got a text frame it cannot read the payload of.");
					return;
				}
			} else {
				if (_loc4_ != 2) {
					Logger.warnch("WS", "NativeWebSocketTransport ignoring a frame of format " + _loc4_);
					return;
				}
				_loc3_ = (_loc2_.data : ByteArray);
			}
		} catch (error:Dynamic) {
			Logger.error("NativeWebSocketTransport cannot read a websocketData event: " + Std.string(error.message));
			fail((602 : UInt), "Unreadable websocketData event: " + Std.string(error.message));
			return;
		}
		if (_loc5_ != null) {
			dispatchEvent(GameTransportEvent.textEvent(_loc5_));
			return;
		}
		if (_loc3_ == null || _loc3_.length == 0) {
			return;
		}
		_loc3_.endian = "littleEndian";
		_loc3_.position = (0 : UInt);
		dispatchEvent(GameTransportEvent.dataEvent(_loc3_));
	}

	function onNativeClose(event:Event) {
		if (mFinished) {
			return;
		}
		var _loc2_ = readCloseReason();
		mFinished = true;
		mConnected = false;
		releaseNative();
		dispatchEvent(GameTransportEvent.closedEvent(_loc2_, "", "server"));
	}

	function onNativeIoError(event:IOErrorEvent) {
		fail((602 : UInt), event.text);
	}

	function onNativeSecurityError(event:SecurityErrorEvent) {
		fail((603 : UInt), event.text);
	}

	function onNativeCertificateError(event:Event) {
		var _loc2_ = readErrorText(event);
		if (mEnforceServerCertificate) {
			Logger.warnch("WS", "NativeWebSocketTransport rejecting server certificate: " + _loc2_);
			fail((603 : UInt), "Server certificate rejected: " + _loc2_);
			return;
		}
		Logger.warnch("WS", "NativeWebSocketTransport accepting an invalid server certificate because EnforceServerCertificate is false: " + _loc2_);
		if (event.cancelable) {
			event.preventDefault();
		}
	}

	function readCloseReason():Int {
		var _loc3_:Int;
		try {
			return ASCompat.toInt(mNative.closeReason);
		} catch (error:Dynamic) {
			_loc3_ = 0;
		}
		return _loc3_;
	}

	function fail(errorCode:UInt, text:String) {
		if (mFinished) {
			return;
		}
		closeWith(4000);
		dispatchEvent(GameTransportEvent.failedEvent(errorCode, text));
	}

	function releaseNative() {
		if (mNative != null) {
			mNative.removeEventListener("connect", onNativeConnect);
			mNative.removeEventListener("websocketData", onNativeData);
			mNative.removeEventListener("close", onNativeClose);
			mNative.removeEventListener("ioError", onNativeIoError);
			mNative.removeEventListener("securityError", onNativeSecurityError);
			mNative.removeEventListener("certificateError", onNativeCertificateError);
			mNative.addEventListener("ioError", absorbLateError);
			mNative.addEventListener("securityError", absorbLateError);
			mNative.addEventListener("certificateError", absorbLateError);
		}
		mNative = null;
	}
}
