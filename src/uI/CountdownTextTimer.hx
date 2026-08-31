package uI;

import brain.clock.GameClock;
import flash.events.TimerEvent;
import flash.text.TextField;
import flash.utils.Timer;

class CountdownTextTimer {
	public static inline final millisecondsPerMinute = 60000;

	public static inline final millisecondsPerHour = 3600000;

	public static inline final millisecondsPerDay = 86400000;

	var mCountdownText:TextField;

	var mDateToFinish:Date;

	var mGetDateFunction:ASFunction;

	var mOnFinishFunc:ASFunction;

	var mPostfixText:String;

	var mPrefixText:String;

	var mExpireText:String;

	var mTimer:Timer;

	public function new(countdownText:TextField, dateToFinish:Date, getDateFunc:ASFunction = null, onFinishFunc:ASFunction = null, postfixText:String = "",
			prefixText:String = "", expireText:String = "") {
		mCountdownText = countdownText;
		mDateToFinish = dateToFinish;
		mGetDateFunction = getDateFunc;
		mOnFinishFunc = onFinishFunc;
		mPostfixText = postfixText;
		mPrefixText = prefixText;
		mExpireText = expireText;
		if (mGetDateFunction == null) {
			mGetDateFunction = getNow;
		}
	}

	public function destroy() {
		stop();
		mCountdownText = null;
		mDateToFinish = null;
		mGetDateFunction = null;
		mOnFinishFunc = null;
		mPostfixText = null;
		mPrefixText = null;
		mExpireText = null;
	}

	public function start() {
		mTimer = new Timer(1000);
		mTimer.addEventListener("timer", onTick);
		mTimer.start();
		onTick(null);
	}

	public function stop() {
		if (mTimer != null) {
			mTimer.removeEventListener("timer", onTick);
			mTimer.stop();
			mTimer = null;
		}
	}

	function getNow():Date {
		return GameClock.getWebServerDate();
	}

	function getTimeLeft():Int {
		var _loc1_ = ASCompat.dynamicAs(mGetDateFunction(), Date);
		return Std.int(mDateToFinish.getTime() - _loc1_.getTime());
	}

	function onTick(event:TimerEvent) {
		var _loc5_ = 0;
		var _loc2_ = 0;
		var _loc4_ = 0;
		var _loc3_ = 0;
		if (getTimeLeft() <= 0) {
			mCountdownText.text = mExpireText;
			if (mOnFinishFunc != null) {
				mOnFinishFunc();
			}
		} else {
			_loc5_ = getTimeLeft();
			_loc2_ = Std.int(_loc5_ / 3600000);
			_loc5_ -= _loc2_ * 3600000;
			_loc4_ = Std.int(_loc5_ / 60000);
			_loc5_ -= _loc4_ * 60000;
			_loc3_ = Std.int(_loc5_ / 1000);
			mCountdownText.text = mPrefixText + Std.string(_loc2_) + ":" + zeroPad(_loc4_, 2) + ":" + zeroPad(_loc3_, 2) + mPostfixText;
		}
	}

	public function zeroPad(number:Int, width:Int):String {
		var _loc3_ = "" + number;
		while (_loc3_.length < width) {
			_loc3_ = "0" + _loc3_;
		}
		return _loc3_;
	}
}
