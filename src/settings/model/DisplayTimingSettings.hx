package settings.model;

import brain.logger.Logger;
import flash.desktop.NativeApplication;
import flash.display.Screen;
import flash.display.ScreenMode;
import flash.display.Stage;
import flash.events.Event;
import flash.events.VsyncStateChangeAvailabilityEvent;

class DisplayTimingSettings {
	var mStage:Stage;

	var mFrameRate:Float = 60;

	var mVsync:Bool = true;

	var mVsyncAvailable:Bool = false;

	var mFrameRates:FrameRateOptions = new FrameRateOptions();

	var mVsyncProbe:ASFunction;

	public var changed:ASFunction;

	public function new(stage:Stage) {
		mStage = stage;
		mStage.addEventListener("vSyncStateChangeAvailability", onVsyncAvailability);
		NativeApplication.nativeApplication.addEventListener("exiting", onExit);
		var _loc2_:ASObject = new LocalSettingsFile().read();
		frameRate = _loc2_ != null && _loc2_.hasOwnProperty("fps") ? FrameRateOptions.coerce(_loc2_["fps"]) : 60;
		if (_loc2_ != null && _loc2_.hasOwnProperty("vsync")) {
			mVsync = _loc2_["vsync"] == true || ASCompat.toString(_loc2_["vsync"]) == "true" || ASCompat.toString(_loc2_["vsync"]) == "1";
		}
	}

	@:isVar public var frameRates(get, never):FrameRateOptions;

	public function get_frameRates():FrameRateOptions {
		return mFrameRates;
	}

	@:isVar public var frameRate(get, set):Float;

	public function get_frameRate():Float {
		return mFrameRate;
	}

	function set_frameRate(value:Float):Float {
		mFrameRate = FrameRateOptions.coerce(value);
		mStage.frameRate = mFrameRate;
		if (mFrameRates.remember(mFrameRate)) {
			notify("fps");
		}
		return value;
	}

	@:isVar public var vsync(get, set):Bool;

	public function get_vsync():Bool {
		return mVsync;
	}

	function set_vsync(value:Bool):Bool {
		mVsync = value;
		applyVsync();
		return value;
	}

	public function vsyncDescriptionKey():String {
		return mVsyncAvailable ? "SETTING_VSYNC_DESC" : "SETTING_VSYNC_UNAVAILABLE_DESC";
	}

	function onVsyncAvailability(event:VsyncStateChangeAvailabilityEvent) {
		mVsyncAvailable = event.available;
		applyVsync();
		notify("vsync");
	}

	function applyVsync() {
		if (!mVsyncAvailable) {
			return;
		}
		try {
			if (mStage.vsyncEnabled != mVsync) {
				mStage.vsyncEnabled = mVsync;
			}
		} catch (error:Dynamic) {
			mVsyncAvailable = false;
			Logger.warn("Could not apply VSync preference: " + Std.string(error.message));
			notify("vsync");
		}
	}

	public function refreshMonitors() {
		var _loc3_:Screen;
		var __ax4_iter_448:Array<ASAny>;
		var _loc1_:ScreenMode = null;
		var _loc2_ = false;
		try {
			__ax4_iter_448 = Screen.screens;
			if (checkNullIteratee(__ax4_iter_448))
				for (_tmp_ in __ax4_iter_448) {
					_loc3_ = ASCompat.coerce(_tmp_, flash.display.Screen);
					try {
						_loc1_ = _loc3_.mode;
						if (_loc1_ != null && mFrameRates.rememberMonitor(_loc1_.refreshRate)) {
							_loc2_ = true;
						}
					} catch (screenError:Dynamic) {}
				}
		} catch (error:Dynamic) {}
		if (_loc2_) {
			notify("fps");
		}
		measureVsyncRate();
	}

	function measureVsyncRate() {
		var WARMUP:Int;
		var FRAMES:Int;
		var ATTEMPTS:Int;
		var attempt:Int;
		var times:Vector<Int>;
		if (!mVsyncAvailable || mVsyncProbe != null) {
			return;
		}
		try {
			mStage.vsyncEnabled = true;
		} catch (error:Dynamic) {
			return;
		}
		attempt = 1;
		times = new Vector<Int>();
		mVsyncProbe = function(param1:Event) {
			var _loc8_ = 0;
			times.push(flash.Lib.getTimer());
			if (times.length < 5 + 30 + 1) {
				return;
			}
			var _loc5_ = mVsyncAvailable && mStage.vsyncEnabled && mStage.frameRate == 1000;
			if (!_loc5_) {
				stopVsyncProbe();
				return;
			}
			var _loc3_:Array<ASAny> = [];
			_loc8_ = 6;
			while (_loc8_ < times.length) {
				_loc3_.push(times[_loc8_] - times[_loc8_ - 1]);
				_loc8_++;
			}
			ASCompat.ASArray.sortWithOptions(_loc3_, 16);
			var _loc6_ = ASCompat.toNumber(_loc3_[_loc3_.length >> 1]);
			var _loc9_:Float = 0;
			var _loc7_ = 0;
			var _loc10_:Int;
			if (checkNullIteratee(_loc3_))
				for (_tmp_ in _loc3_) {
					_loc10_ = ASCompat.toInt(_tmp_);
					if (Math.abs(_loc10_ - _loc6_) <= 2) {
						_loc9_ += _loc10_;
						_loc7_++;
					}
				}
			if (_loc6_ <= 0 || _loc7_ < _loc3_.length * 2 / 3) {
				if (attempt++ < 3) {
					times.length = 0;
				} else {
					stopVsyncProbe();
				}
				return;
			}
			stopVsyncProbe();
			var _loc2_ = 1000 * _loc7_ / _loc9_;
			var _loc11_ = Math.NaN;
			var _loc4_:Float;
			final __ax4_iter_449:Array<ASAny> = [48, 50, 60, 72, 75, 90, 100, 120, 144, 165, 180, 200, 240, 360];
			if (checkNullIteratee(__ax4_iter_449))
				for (_tmp_ in __ax4_iter_449) {
					_loc4_ = ASCompat.toNumber(_tmp_);
					if (Math.isNaN(_loc11_) || Math.abs(_loc2_ - _loc4_) < Math.abs(_loc2_ - _loc11_)) {
						_loc11_ = _loc4_;
					}
				}
			if (Math.abs(_loc2_ - _loc11_) > _loc11_ * 0.015) {
				return;
			}
			if (mFrameRates.rememberMonitor(_loc11_)) {
				notify("fps");
			}
		};
		mStage.frameRate = 1000;
		mStage.addEventListener("enterFrame", mVsyncProbe);
	}

	function stopVsyncProbe() {
		if (mVsyncProbe == null) {
			return;
		}
		mStage.removeEventListener("enterFrame", mVsyncProbe);
		mVsyncProbe = null;
		mStage.frameRate = mFrameRate;
		try {
			if (mStage.vsyncEnabled != mVsync) {
				mStage.vsyncEnabled = mVsync;
			}
		} catch (error:Dynamic) {}
	}

	function notify(id:String) {
		if (changed != null) {
			changed(id);
		}
	}

	function onExit(event:Event) {
		destroy();
	}

	public function destroy() {
		if (mStage == null) {
			return;
		}
		changed = null;
		stopVsyncProbe();
		mStage.removeEventListener("vSyncStateChangeAvailability", onVsyncAvailability);
		NativeApplication.nativeApplication.removeEventListener("exiting", onExit);
		mStage = null;
	}
}
