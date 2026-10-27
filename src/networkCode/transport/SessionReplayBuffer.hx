package networkCode.transport;

import flash.utils.ByteArray;

final class SessionReplayBuffer {
	public static inline final CHUNK_BYTES = (4096 : UInt);

	var mBytes:ByteArray;

	var mAcknowledgedBytes:Float = 0;

	var mForwardedBytes:Float = 0;

	var mHandedBytes:Float = 0;

	public function new() {
		mBytes = newBuffer();
	}

	static function newBuffer():ByteArray {
		var _loc1_ = new ByteArray();
		_loc1_.endian = "littleEndian";
		return _loc1_;
	}

	@:isVar public var sentBytes(get, never):Float;

	public function get_sentBytes():Float {
		return mAcknowledgedBytes + mBytes.length;
	}

	@:isVar public var acknowledgedBytes(get, never):Float;

	public function get_acknowledgedBytes():Float {
		return mAcknowledgedBytes;
	}

	@:isVar public var forwardedBytes(get, never):Float;

	public function get_forwardedBytes():Float {
		return mForwardedBytes;
	}

	@:isVar public var handedBytes(get, never):Float;

	public function get_handedBytes():Float {
		return mHandedBytes;
	}

	@:isVar public var unacknowledgedBytes(get, never):Float;

	public function get_unacknowledgedBytes():Float {
		return mBytes.length;
	}

	@:isVar public var hasPending(get, never):Bool;

	public function get_hasPending():Bool {
		return mForwardedBytes < sentBytes;
	}

	public function append(bytes:ByteArray):Bool {
		mBytes.position = mBytes.length;
		mBytes.writeBytes(bytes, (0 : UInt), bytes.length);
		return mBytes.length <= TransportSettings.sessionOutboundBufferBytes;
	}

	public function discardAcknowledged(acknowledged:Float) {
		if (acknowledged <= mAcknowledgedBytes) {
			return;
		}
		var _loc2_ = (ASCompat.floatToInt(acknowledged - mAcknowledgedBytes) : UInt);
		var _loc3_ = newBuffer();
		if (mBytes.length > _loc2_) {
			_loc3_.writeBytes(mBytes, _loc2_, mBytes.length - _loc2_);
		}
		_loc3_.position = (0 : UInt);
		mBytes = _loc3_;
		mAcknowledgedBytes = acknowledged;
		if (mForwardedBytes < mAcknowledgedBytes) {
			mForwardedBytes = mAcknowledgedBytes;
		}
	}

	public function rewindTo(forwarded:Float) {
		mForwardedBytes = forwarded;
	}

	public function nextChunk():ByteArray {
		var _loc3_ = sentBytes - mForwardedBytes;
		if (_loc3_ <= 0) {
			return null;
		}
		var _loc1_ = (_loc3_ > 4096 ? (4096 : UInt) : (ASCompat.floatToInt(_loc3_) : UInt) : UInt);
		if (_loc1_ == 0) {
			return null;
		}
		var _loc2_ = newBuffer();
		_loc2_.writeBytes(mBytes, (ASCompat.floatToInt(mForwardedBytes - mAcknowledgedBytes) : UInt), _loc1_);
		_loc2_.position = (0 : UInt);
		mForwardedBytes += _loc1_;
		mHandedBytes = Math.max(mHandedBytes, mForwardedBytes);
		return _loc2_;
	}

	public function clear() {
		mBytes.clear();
	}
}
