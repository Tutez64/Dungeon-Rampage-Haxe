package networkCode.transport;

import brain.utils.ConfigManager;

class TransportSettings {
	public static inline final DEFAULT_DROP_DETECT_SECONDS:Float = 15;

	public static inline final DEFAULT_RECONNECT_GRACE_SECONDS:Float = 60;

	public static inline final DEFAULT_HEARTBEAT_SECONDS:Float = 10;

	public static inline final DEFAULT_CONNECT_TIMEOUT_SECONDS:Float = 10;

	public static inline final DEFAULT_SESSIONS_ENABLED = true;

	public static inline final DEFAULT_SESSION_OUTBOUND_BUFFER_BYTES:Float = 262144;

	public static inline final DEFAULT_SESSION_ACK_EVERY_BYTES:Float = 65536;

	public static inline final DEFAULT_SESSION_ACK_EVERY_SECONDS:Float = 5;

	public static inline final KEY_DROP_DETECT = "TransportDropDetectSeconds";

	public static inline final KEY_RECONNECT_GRACE = "TransportReconnectGraceSeconds";

	public static inline final KEY_HEARTBEAT = "TransportHeartbeatSeconds";

	public static inline final KEY_CONNECT_TIMEOUT = "TransportConnectTimeoutSeconds";

	public static inline final KEY_SESSIONS_ENABLED = "TransportSessionsEnabled";

	public static inline final KEY_SESSION_OUTBOUND_BUFFER = "TransportSessionOutboundBufferBytes";

	public static inline final KEY_SESSION_ACK_EVERY_BYTES = "TransportSessionAckEveryBytes";

	public static inline final KEY_SESSION_ACK_EVERY_SECONDS = "TransportSessionAckEverySeconds";

	static var mDropDetectSeconds:Float = 15;

	static var mReconnectGraceSeconds:Float = 60;

	static var mHeartbeatSeconds:Float = 10;

	static var mConnectTimeoutSeconds:Float = 10;

	static var mSessionsEnabled:Bool = true;

	static var mSessionOutboundBufferBytes:Float = 262144;

	static var mSessionAckEveryBytes:Float = 65536;

	static var mSessionAckEverySeconds:Float = 5;

	public function new() {}

	@:isVar public static var dropDetectSeconds(get, never):Float;

	static public function get_dropDetectSeconds():Float {
		return mDropDetectSeconds;
	}

	@:isVar public static var reconnectGraceSeconds(get, never):Float;

	static public function get_reconnectGraceSeconds():Float {
		return mReconnectGraceSeconds;
	}

	@:isVar public static var heartbeatSeconds(get, never):Float;

	static public function get_heartbeatSeconds():Float {
		return mHeartbeatSeconds;
	}

	@:isVar public static var connectTimeoutSeconds(get, never):Float;

	static public function get_connectTimeoutSeconds():Float {
		return mConnectTimeoutSeconds;
	}

	@:isVar public static var connectTimeoutMilliseconds(get, never):UInt;

	static public function get_connectTimeoutMilliseconds():UInt {
		return (ASCompat.floatToInt(mConnectTimeoutSeconds * 1000) : UInt);
	}

	@:isVar public static var sessionsEnabled(get, never):Bool;

	static public function get_sessionsEnabled():Bool {
		return mSessionsEnabled;
	}

	@:isVar public static var sessionOutboundBufferBytes(get, never):Float;

	static public function get_sessionOutboundBufferBytes():Float {
		return mSessionOutboundBufferBytes;
	}

	@:isVar public static var sessionAckEveryBytes(get, never):Float;

	static public function get_sessionAckEveryBytes():Float {
		return mSessionAckEveryBytes;
	}

	@:isVar public static var sessionAckEverySeconds(get, never):Float;

	static public function get_sessionAckEverySeconds():Float {
		return mSessionAckEverySeconds;
	}

	public static function overrideForTest(dropDetectSeconds:Float = 0, reconnectGraceSeconds:Float = 0, connectTimeoutSeconds:Float = 0,
			sessionAckEveryBytes:Float = 0, sessionOutboundBufferBytes:Float = 0, sessionAckEverySeconds:Float = 0) {
		if (dropDetectSeconds > 0) {
			mDropDetectSeconds = dropDetectSeconds;
		}
		if (reconnectGraceSeconds > 0) {
			mReconnectGraceSeconds = reconnectGraceSeconds;
		}
		if (connectTimeoutSeconds > 0) {
			mConnectTimeoutSeconds = connectTimeoutSeconds;
		}
		if (sessionAckEveryBytes > 0) {
			mSessionAckEveryBytes = sessionAckEveryBytes;
		}
		if (sessionOutboundBufferBytes > 0) {
			mSessionOutboundBufferBytes = sessionOutboundBufferBytes;
		}
		if (sessionAckEverySeconds > 0) {
			mSessionAckEverySeconds = sessionAckEverySeconds;
		}
	}

	public static function applyOverrides(config:ConfigManager) {
		if (config == null) {
			return;
		}
		mDropDetectSeconds = positiveOr(config.getConfigNumber("TransportDropDetectSeconds", 15), 15);
		mReconnectGraceSeconds = positiveOr(config.getConfigNumber("TransportReconnectGraceSeconds", 60), 60);
		mHeartbeatSeconds = positiveOr(config.getConfigNumber("TransportHeartbeatSeconds", 10), 10);
		mConnectTimeoutSeconds = positiveOr(config.getConfigNumber("TransportConnectTimeoutSeconds", 10), 10);
		mSessionsEnabled = config.getConfigBoolean("TransportSessionsEnabled", true);
		mSessionOutboundBufferBytes = positiveOr(config.getConfigNumber("TransportSessionOutboundBufferBytes", 262144), 262144);
		mSessionAckEveryBytes = positiveOr(config.getConfigNumber("TransportSessionAckEveryBytes", 65536), 65536);
		mSessionAckEverySeconds = positiveOr(config.getConfigNumber("TransportSessionAckEverySeconds", 5), 5);
	}

	public static function overrideSessionsEnabledForTest(enabled:Bool) {
		mSessionsEnabled = enabled;
	}

	public static function resetToDefaults() {
		mDropDetectSeconds = 15;
		mReconnectGraceSeconds = 60;
		mHeartbeatSeconds = 10;
		mConnectTimeoutSeconds = 10;
		mSessionsEnabled = true;
		mSessionOutboundBufferBytes = 262144;
		mSessionAckEveryBytes = 65536;
		mSessionAckEverySeconds = 5;
	}

	static function positiveOr(value:Float, fallback:Float):Float {
		return Math.isNaN(value) || value <= 0 ? fallback : value;
	}
}
