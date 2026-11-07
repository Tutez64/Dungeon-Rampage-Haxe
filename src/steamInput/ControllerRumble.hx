package steamInput;

import facade.DBFacade;
import com.amanitadesign.steam.FRESteamWorks;
import steamInput.RumbleEffect;

class ControllerRumble {
	static inline final MAX_MOTOR_SPEED = (65535 : UInt);

	static inline final MILLISECONDS_PER_SECOND:Float = 1000;

	var mDBFacade:DBFacade;

	var mSteamworks:FRESteamWorks;

	var mActiveRumbles:Vector<ActiveRumble> = new Vector();

	var mIsEnabled:Bool = true;

	var mLastSentLeftSpeed:UInt = (0 : UInt);

	var mLastSentRightSpeed:UInt = (0 : UInt);

	public function new(dbFacade:DBFacade, steamworks:FRESteamWorks) {
		mDBFacade = dbFacade;
		mSteamworks = steamworks;
	}

	static function toMotorSpeed(intensity:Float):UInt {
		return (ASCompat.floatToInt(intensity * 65535) : UInt);
	}

	public function play(effect:RumbleEffect) {
		if (!mIsEnabled
			|| effect == null
			|| effect.durationSeconds <= 0
			|| !mDBFacade.featureFlags.getFlagValue("want-controller-rumble")) {
			return;
		}
		if (effect.leftIntensity <= 0 && effect.rightIntensity <= 0) {
			return;
		}
		mActiveRumbles.push(new ActiveRumble(effect, flash.Lib.getTimer() + effect.durationSeconds * 1000));
	}

	public function stopAll() {
		mActiveRumbles.length = 0;
	}

	public function update(connectedControllers:Vector<SteamController>) {
		var _loc4_ = 0;
		var _loc5_:ActiveRumble = null;
		var _loc6_:Float = flash.Lib.getTimer();
		var _loc2_:Float = 0;
		var _loc3_:Float = 0;
		_loc4_ = mActiveRumbles.length - 1;
		while (_loc4_ >= 0) {
			_loc5_ = mActiveRumbles[_loc4_];
			if (_loc6_ >= _loc5_.endTimeMs) {
				mActiveRumbles.removeAt(_loc4_);
			} else {
				if (_loc5_.effect.leftIntensity > _loc2_) {
					_loc2_ = _loc5_.effect.leftIntensity;
				}
				if (_loc5_.effect.rightIntensity > _loc3_) {
					_loc3_ = _loc5_.effect.rightIntensity;
				}
			}
			_loc4_--;
		}
		sendToControllers(connectedControllers, toMotorSpeed(_loc2_), toMotorSpeed(_loc3_));
	}

	public function forgetHardwareState() {
		mLastSentLeftSpeed = (0 : UInt);
		mLastSentRightSpeed = (0 : UInt);
	}

	@:isVar public var isEnabled(get, set):Bool;

	public function get_isEnabled():Bool {
		return mIsEnabled;
	}

	function set_isEnabled(value:Bool):Bool {
		if (mIsEnabled == value) {
			return value;
		}
		mIsEnabled = value;
		if (!mIsEnabled) {
			stopAll();
		}
		return value;
	}

	function sendToControllers(connectedControllers:Vector<SteamController>, leftSpeed:UInt, rightSpeed:UInt) {
		if (leftSpeed == mLastSentLeftSpeed && rightSpeed == mLastSentRightSpeed) {
			return;
		}
		mLastSentLeftSpeed = leftSpeed;
		mLastSentRightSpeed = rightSpeed;
		var _loc4_:SteamController;
		if (checkNullIteratee(connectedControllers))
			for (_tmp_ in connectedControllers) {
				_loc4_ = _tmp_;
				mSteamworks.triggerVibration(_loc4_.controllerHandle, leftSpeed, rightSpeed);
			}
	}
}

private class ActiveRumble {
	public var effect:RumbleEffect;

	public var endTimeMs:Float = Math.NaN;

	public function new(effect:RumbleEffect, endTimeMs:Float) {
		this.effect = effect;
		this.endTimeMs = endTimeMs;
	}
}
