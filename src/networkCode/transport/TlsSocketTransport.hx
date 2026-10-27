package networkCode.transport;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.net.SecureSocket;
import flash.utils.ByteArray;

/**
 * The official client runs its SecureSocket in a Worker, a second SWF embedded as bytes, which no
 * native target can run. OpenFL's SecureSocket does not block the main thread, so this drives it
 * directly, as that worker (TlsSocketWorker) does, and reports the way the worker's replies did.
 */
class TlsSocketTransport extends EventDispatcher implements IGameTransport {
	var mHost:String;

	var mPort:Int = 0;

	var mEnforceServerCertificate:Bool = false;

	var mSocket:SecureSocket;

	var mConnected:Bool = false;

	var mFinished:Bool = false;

	public function new(host:String, port:Int, enforceServerCertificate:Bool) {
		super();
		mHost = host;
		mPort = port;
		mEnforceServerCertificate = enforceServerCertificate;
	}

	static function day(date:Date):String {
		if (date == null) {
			return "?";
		}
		return date.getUTCFullYear() + "-" + pad(date.getUTCMonth() + 1) + "-" + pad(date.getUTCDate());
	}

	static function pad(value:Int):String {
		return (value < 10 ? "0" : "") + value;
	}

	static function absorbError(event:Event) {}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return "tlsSocket " + mHost + ":" + mPort;
	}

	@:isVar public var connected(get, never):Bool;

	public function get_connected():Bool {
		return mConnected && !mFinished;
	}

	@:isVar public var supportsSessions(get, never):Bool;

	public function get_supportsSessions():Bool {
		return false;
	}

	public function sendText(text:String) {
		throw new Error("TlsSocketTransport carries no text frames; it cannot resume a session.");
	}

	public function connect() {
		if (mSocket != null || mFinished) {
			return;
		}
		if (!SecureSocket.isSupported) {
			fail((603 : UInt), "Secure connections are not supported by this runtime.");
			return;
		}
		try {
			mSocket = new SecureSocket();
			mSocket.endian = "littleEndian";
			mSocket.timeout = TransportSettings.connectTimeoutMilliseconds;
			mSocket.addEventListener("connect", onConnect);
			mSocket.addEventListener("close", onClose);
			mSocket.addEventListener("socketData", onData);
			mSocket.addEventListener("ioError", onIoError);
			mSocket.addEventListener("securityError", onSecurityError);
			mSocket.addEventListener("certificateError", onCertificateError);
			mSocket.connect(mHost, mPort);
		} catch (error:Dynamic) {
			fail((602 : UInt), error.message);
		}
	}

	public function send(bytes:ByteArray) {
		if (!connected || bytes == null || bytes.length == 0) {
			return;
		}
		try {
			mSocket.writeBytes(bytes, 0, bytes.length);
			mSocket.flush();
		} catch (error:Dynamic) {
			fail((602 : UInt), error.message);
		}
	}

	public function close() {
		if (mFinished) {
			return;
		}
		mFinished = true;
		mConnected = false;
		var socket = mSocket;
		mSocket = null;
		if (socket == null) {
			return;
		}
		socket.removeEventListener("connect", onConnect);
		socket.removeEventListener("close", onClose);
		socket.removeEventListener("socketData", onData);
		socket.removeEventListener("ioError", onIoError);
		socket.removeEventListener("securityError", onSecurityError);
		socket.removeEventListener("certificateError", onCertificateError);
		socket.addEventListener("ioError", absorbError);
		socket.addEventListener("securityError", absorbError);
		socket.addEventListener("certificateError", absorbError);
		try {
			socket.close();
		} catch (error:Dynamic) {}
	}

	public function abandon() {
		close();
	}

	function onConnect(event:Event) {
		mConnected = true;
		dispatchEvent(GameTransportEvent.connectedEvent());
	}

	function onData(event:ProgressEvent) {
		if (mFinished) {
			return;
		}
		var bytes = new ByteArray();
		try {
			mSocket.readBytes(bytes, 0, mSocket.bytesAvailable);
		} catch (error:Dynamic) {
			fail((602 : UInt), error.message);
			return;
		}
		if (bytes.length > 0) {
			bytes.endian = "littleEndian";
			bytes.position = 0;
			dispatchEvent(GameTransportEvent.dataEvent(bytes));
		}
	}

	function onClose(event:Event) {
		close();
		dispatchEvent(GameTransportEvent.closedEvent(0, "", "server"));
	}

	function onIoError(event:IOErrorEvent) {
		fail((602 : UInt), event.text);
	}

	function onSecurityError(event:SecurityErrorEvent) {
		fail((603 : UInt), event.text);
	}

	function onCertificateError(event:SecurityErrorEvent) {
		if (mEnforceServerCertificate) {
			fail((603 : UInt), "Server certificate rejected: " + event.text);
		} else if (event.cancelable) {
			event.preventDefault();
		}
	}

	function certificateStatus():String {
		try {
			if (mSocket != null) {
				return Std.string(mSocket.serverCertificateStatus);
			}
		} catch (error:Dynamic) {}
		return "";
	}

	function certificateDetail():String {
		try {
			var certificate = mSocket != null ? mSocket.serverCertificate : null;
			if (certificate == null) {
				return "";
			}
			return "CN=" + certificate.subject.commonName + " by CN=" + certificate.issuer.commonName + " valid "
				+ day(certificate.validNotBefore) + ".." + day(certificate.validNotAfter);
		} catch (error:Dynamic) {}
		return "";
	}

	function fail(code:UInt, text:String) {
		if (mFinished) {
			return;
		}
		var status = certificateStatus();
		var detail = certificateDetail();
		close();
		dispatchEvent(GameTransportEvent.failedEvent(code, text, status, detail));
	}
}
