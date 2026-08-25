package brain.clock;

import com.greensock.TweenMax;

class GameClock {
	public static inline final ANIMATION_FRAME_RATE:Float = 24;

	public static inline final ANIMATION_FRAME_DURATION:Float = 1 / ANIMATION_FRAME_RATE;

	public static inline final LEGACY_STAGE_FRAME_RATE:Float = 60;

	static var mServerTimeOffset:Float = 0;

	static var mWebServerTimeString:String = "";

	static var mWebServerDate:Date;

	static var mWebServerLocalStartDate:Date;

	static var mWebServerPingStartTime:Float = 0;

	static var mWebServerPingTime:Float = 0;

	static var mEpochDuration:Int = 604800;

	static var mEpochOffset:Int = 0;

	static var mUserTimeOffset:Int = 0;

	static var mTimeMinutes:Int = 60;

	static var mTimeHours:Int = mTimeMinutes * 60;

	static var mTimeDays:Int = mTimeHours * 24;

	static var mTimeWeeks:Int = mTimeDays * 7;

	var mRealTimeLastFrame:Int = 0;

	var mRealTime:Int = 0;

	var mTimeScale:Float = 1;

	var mGameTime:Int = 0;

	var mTickLength:Float = Math.NaN;

	var mFrame:UInt = (0 : UInt);

	public function new(tickLength:Float) {
		mTickLength = tickLength;
		mRealTimeLastFrame = -1;
		mFrame = (0 : UInt);
	}

	public static function parseW3CDTF(str:String, localTime:Bool = false):Date {
		var _loc4_:Date = null;
		var _loc8_:String = null;
		var _loc14_:String = null;
		var _loc19_:Array<ASAny> = null;
		var _loc10_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc20_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc22_:String = null;
		var _loc21_:Array<ASAny> = null;
		var _loc18_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc16_:Array<ASAny> = null;
		var _loc15_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc11_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc7_:String = null;
		try {
			_loc8_ = str.substring(0, str.indexOf("T"));
			_loc14_ = str.substring(str.indexOf("T") + 1, str.length);
			_loc19_ = (cast _loc8_.split("-"));
			_loc10_ = ASCompat.toNumber(_loc19_.shift());
			_loc17_ = ASCompat.toNumber(_loc19_.shift());
			_loc3_ = ASCompat.toNumber(_loc19_.shift());
			if (_loc14_.indexOf("Z") != -1) {
				_loc12_ = 1;
				_loc20_ = 0;
				_loc6_ = 0;
				_loc14_ = StringTools.replace(_loc14_, "Z", "");
			} else if (_loc14_.indexOf("+") != -1) {
				_loc12_ = 1;
				_loc22_ = _loc14_.substring(_loc14_.indexOf("+") + 1, _loc14_.length);
				_loc20_ = ASCompat.toNumber(_loc22_.substring(0, _loc22_.indexOf(":")));
				_loc6_ = ASCompat.toNumber(_loc22_.substring(_loc22_.indexOf(":") + 1, _loc22_.length));
				_loc14_ = _loc14_.substring(0, _loc14_.indexOf("+"));
			} else {
				_loc12_ = -1;
				_loc22_ = _loc14_.substring(_loc14_.indexOf("-") + 1, _loc14_.length);
				_loc20_ = ASCompat.toNumber(_loc22_.substring(0, _loc22_.indexOf(":")));
				_loc6_ = ASCompat.toNumber(_loc22_.substring(_loc22_.indexOf(":") + 1, _loc22_.length));
				_loc14_ = _loc14_.substring(0, _loc14_.indexOf("-"));
			}
			_loc21_ = (cast _loc14_.split(":"));
			_loc18_ = ASCompat.toNumber(_loc21_.shift());
			_loc13_ = ASCompat.toNumber(_loc21_.shift());
			_loc16_ = ASCompat.dynamicAs(_loc21_.length > 0 ? (cast ASCompat.toString(_loc21_.shift()).split(".")) : null, Array);
			_loc15_ = _loc16_ != null && _loc16_.length > 0 ? ASCompat.toNumber(_loc16_.shift()) : 0;
			_loc5_ = _loc16_ != null && _loc16_.length > 0 ? 1000 * Std.parseFloat("0." + Std.string(_loc16_.shift())) : 0;
			_loc11_ = ASCompat.ASDate.UTC(_loc10_, _loc17_ - 1, _loc3_, _loc18_, _loc13_, _loc15_, _loc5_);
			_loc9_ = (_loc20_ * 3600000 + _loc6_ * 60000) * _loc12_;
			if (localTime) {
				_loc4_ = Date.now();
				ASCompat.ASDate.setFullYear(_loc4_, _loc10_);
				ASCompat.ASDate.setMonth(_loc4_, _loc17_ - 1);
				ASCompat.ASDate.setDate(_loc4_, _loc3_);
				ASCompat.ASDate.setHours(_loc4_, _loc18_);
				ASCompat.ASDate.setMinutes(_loc4_, _loc13_);
				ASCompat.ASDate.setSeconds(_loc4_, _loc15_);
				ASCompat.ASDate.setMilliseconds(_loc4_, _loc5_);
			} else {
				_loc4_ = Date.fromTime(_loc11_ - _loc9_);
			}
			if (_loc4_.toString() == "Invalid Date") {
				throw new Error("This date does not conform to W3CDTF.");
			}
		} catch (e:Dynamic) {
			_loc7_ = "Unable to parse the string [" + str + "] into a date. ";
			_loc7_ = _loc7_ + ("The internal error was: " + Std.string(e));
			throw new Error(_loc7_);
		}
		return _loc4_;
	}

	public static function toW3CDTF(d:Date, includeMilliseconds:Bool = false, includeZone:Bool = true):String {
		var _loc4_ = d.getUTCDate();
		var _loc8_ = d.getUTCMonth();
		var _loc6_ = d.getUTCHours();
		var _loc9_ = d.getUTCMinutes();
		var _loc7_ = d.getUTCSeconds();
		var _loc5_ = ASCompat.ASDate.getUTCMilliseconds(d);
		var _loc10_ = "";
		_loc10_ = _loc10_ + d.getUTCFullYear();
		_loc10_ = _loc10_ + "-";
		if (_loc8_ + 1 < 10) {
			_loc10_ += "0";
		}
		_loc10_ += _loc8_ + 1;
		_loc10_ = _loc10_ + "-";
		if (_loc4_ < 10) {
			_loc10_ += "0";
		}
		_loc10_ += _loc4_;
		_loc10_ = _loc10_ + "T";
		if (_loc6_ < 10) {
			_loc10_ += "0";
		}
		_loc10_ += _loc6_;
		_loc10_ = _loc10_ + ":";
		if (_loc9_ < 10) {
			_loc10_ += "0";
		}
		_loc10_ += _loc9_;
		_loc10_ = _loc10_ + ":";
		if (_loc7_ < 10) {
			_loc10_ += "0";
		}
		_loc10_ += _loc7_;
		if (includeMilliseconds && _loc5_ > 0) {
			_loc10_ += ".";
			_loc10_ = _loc10_ + _loc5_;
		}
		if (includeZone) {
			_loc10_ += "-00:00";
		}
		return _loc10_;
	}

	@:isVar public static var date(get, never):Date;

	static public function get_date():Date {
		var _loc1_ = Date.now();
		var _loc2_ = _loc1_.getTime() + mServerTimeOffset;
		ASCompat.ASDate.setTime(_loc1_, _loc2_);
		return _loc1_;
	}

	@:isVar public static var serverTimeOffset(get, never):Float;

	static public function get_serverTimeOffset():Float {
		return mServerTimeOffset;
	}

	public static function computeServerTimeOffset(serverDate:Date) {
		var _loc2_ = Date.now();
		var _loc3_ = Std.int(serverDate.getTime() - _loc2_.getTime());
		mServerTimeOffset = _loc3_;
	}

	public static function getWebServerTime():Float {
		if (mWebServerLocalStartDate == null) {
			return 0;
		}
		var _loc2_ = Date.now();
		var _loc1_ = _loc2_.getTime() - mWebServerLocalStartDate.getTime();
		var _loc3_ = Date.now();
		ASCompat.ASDate.setTime(_loc3_, mWebServerDate.getTime() + _loc1_);
		return mWebServerDate.getTime() + _loc1_ + mUserTimeOffset;
	}

	public static function getEpoch():Float {
		var _loc1_ = Math.floor(getWebServerTime() / 1000);
		var _loc2_ = 0;
		return Std.int((_loc1_ + mEpochOffset) / mEpochDuration);
	}

	public static function getTimeToEpoch():Float {
		var _loc3_ = Std.int(getEpoch() + 1);
		var _loc4_ = _loc3_ * mEpochDuration - mEpochOffset;
		var _loc1_ = Math.floor(getWebServerTime() / 1000);
		return _loc4_ - _loc1_;
	}

	public static function getArrayTimeToEpoch():Array<ASAny> {
		var _loc2_ = getTimeToEpoch();
		var _loc1_ = Math.floor(_loc2_ / mTimeWeeks);
		_loc2_ -= _loc1_ * mTimeWeeks;
		var _loc5_ = Math.floor(_loc2_ / mTimeDays);
		_loc2_ -= _loc5_ * mTimeDays;
		var _loc3_ = Math.floor(_loc2_ / mTimeHours);
		_loc2_ -= _loc3_ * mTimeHours;
		var _loc4_ = Math.floor(_loc2_ / mTimeMinutes);
		_loc2_ -= _loc4_ * mTimeMinutes;
		var _loc6_ = Std.int(_loc2_);
		return [_loc6_, _loc4_, _loc3_, _loc5_, _loc1_];
	}

	public static function getWebServerDate():Date {
		if (mWebServerLocalStartDate == null) {
			return null;
		}
		var _loc3_ = Date.now();
		var _loc1_ = _loc3_.getTime() - mWebServerLocalStartDate.getTime();
		var _loc2_ = Date.now();
		ASCompat.ASDate.setTime(_loc2_, mWebServerDate.getTime() + _loc1_ + mUserTimeOffset);
		return _loc2_;
	}

	public static function getWebServerTimeStamp():String {
		if (mWebServerLocalStartDate == null) {
			return "not set";
		}
		return toW3CDTF(getWebServerDate(), false, false);
	}

	public static function startSetWebServerTime() {
		var _loc1_ = Date.now();
		mWebServerPingStartTime = _loc1_.getTime();
	}

	public static function finishSetWebServerTime(timeInfo:Array<ASAny>) {
		var _loc2_:String = timeInfo[0];
		mEpochDuration = ASCompat.toInt(timeInfo[1]);
		mEpochOffset = ASCompat.toInt(timeInfo[2]);
		var _loc3_ = Date.now();
		mWebServerPingTime = _loc3_.getTime() - mWebServerPingStartTime;
		mWebServerLocalStartDate = Date.now();
		ASCompat.ASDate.setTime(mWebServerLocalStartDate, _loc3_.getTime() - mWebServerPingTime * 0.5);
		mWebServerTimeString = _loc2_;
		mWebServerDate = parseW3CDTF(_loc2_, false);
	}

	public static function setUserWebOffset(days:Int, hours:Int, minutes:Int) {
		mUserTimeOffset = (minutes * 60 + hours * 60 * 60 + days * 24 * 60 * 60) * 1000;
	}

	public function initTime() {
		mRealTime = flash.Lib.getTimer();
		mRealTimeLastFrame = mRealTime;
	}

	public function update():Float {
		mRealTime = flash.Lib.getTimer();
		mFrame = mFrame + 1;
		var _loc1_ = (mRealTime - mRealTimeLastFrame) * this.timeScale / 1000;
		mRealTimeLastFrame = mRealTime;
		return _loc1_;
	}

	@:isVar public var timeScale(get, set):Float;

	public function get_timeScale():Float {
		return mTimeScale;
	}

	function set_timeScale(value:Float):Float {
		mTimeScale = Math.min(10, Math.max(0.1, value));
		TweenMax.globalTimeScale = mTimeScale;
		return value;
	}

	@:isVar public var gameTime(get, set):Int;

	public function get_gameTime():Int {
		return mGameTime;
	}

	function set_gameTime(gameTime:Int):Int {
		return mGameTime = gameTime;
	}

	@:isVar public var frame(get, never):UInt;

	public function get_frame():UInt {
		return mFrame;
	}

	@:isVar public var realTime(get, never):Int;

	public function get_realTime():Int {
		return mRealTime;
	}

	@:isVar public var tickLength(get, never):Float;

	public function get_tickLength():Float {
		return mTickLength * mTimeScale;
	}
}
