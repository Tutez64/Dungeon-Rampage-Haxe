package com.greensock;

import com.greensock.core.*;

final class OverwriteManager {
	public static var enabled:Bool = false;

	public static var mode:Int = 0;

	public static inline final version:Float = 6.1;

	public static inline final NONE = 0;

	public static inline final ALL_IMMEDIATE = 1;

	public static inline final AUTO = 2;

	public static inline final CONCURRENT = 3;

	public static inline final ALL_ONSTART = 4;

	public static inline final PREEXISTING = 5;

	public function new() {}

	public static function getGlobalPaused(tween:TweenCore):Bool {
		var _loc2_ = false;
		while (tween != null) {
			if (tween.cachedPaused) {
				_loc2_ = true;
				break;
			}
			tween = tween.timeline;
		}
		return _loc2_;
	}

	public static function init(defaultMode:Int = 2):Int {
		if (TweenLite.version < 11.6) {
			throw new Error("Warning: Your TweenLite class needs to be updated to work with OverwriteManager (or you may need to clear your ASO files). Please download and install the latest version from http://www.tweenlite.com.");
		}
		TweenLite.overwriteManager = OverwriteManager;
		mode = defaultMode;
		enabled = true;
		return mode;
	}

	public static function manageOverwrites(tween:TweenLite, props:ASObject, targetTweens:Array<ASAny>, mode:Int):Bool {
		var _loc19_:Float;
		var _loc5_ = 0;
		var _loc6_ = false;
		var _loc7_:TweenLite = null;
		var _loc13_ = 0;
		var _loc14_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_:TweenCore = null;
		var _loc17_ = Math.NaN;
		var _loc18_:SimpleTimeline = null;
		if (mode >= 4) {
			_loc13_ = targetTweens.length;
			_loc5_ = 0;
			while (_loc5_ < _loc13_) {
				_loc7_ = ASCompat.dynamicAs(targetTweens[_loc5_], com.greensock.TweenLite);
				if (_loc7_ != tween) {
					if (_loc7_.setEnabled(false, false)) {
						_loc6_ = true;
					}
				} else if (mode == 5) {
					break;
				}
				_loc5_ = ASCompat.toInt(_loc5_) + 1;
			}
			return _loc6_;
		}
		var _loc8_ = tween.cachedStartTime + 1e-10;
		var _loc9_:Array<ASAny> = [];
		var _loc10_:Array<ASAny> = [];
		var _loc11_ = 0;
		var _loc12_ = 0;
		_loc5_ = targetTweens.length;
		while (--_loc5_ > -1) {
			_loc7_ = ASCompat.dynamicAs(targetTweens[_loc5_], com.greensock.TweenLite);
			if (!(_loc7_ == tween || _loc7_.gc || !_loc7_.initted && _loc8_ - _loc7_.cachedStartTime <= 2e-10)) {
				if (_loc7_.timeline != tween.timeline) {
					if (!getGlobalPaused(_loc7_)) {
						_loc10_[Std.int(_loc19_ = ASCompat.toNumber(_loc11_++))] = _loc7_;
					}
				} else if (_loc7_.cachedStartTime <= _loc8_
					&& _loc7_.cachedStartTime + _loc7_.totalDuration + 1e-10 > _loc8_
					&& !_loc7_.cachedPaused
					&& !(tween.cachedDuration == 0 && _loc8_ - _loc7_.cachedStartTime <= 2e-10)) {
					_loc9_[Std.int(_loc19_ = ASCompat.toNumber(_loc12_++))] = _loc7_;
				}
			}
		}
		if (_loc11_ != 0) {
			_loc14_ = tween.cachedTimeScale;
			_loc15_ = _loc8_;
			_loc18_ = tween.timeline;
			while (_loc18_ != null) {
				_loc14_ *= _loc18_.cachedTimeScale;
				_loc15_ += _loc18_.cachedStartTime;
				_loc18_ = _loc18_.timeline;
			}
			_loc8_ = _loc14_ * _loc15_;
			_loc5_ = _loc11_;
			while (--_loc5_ > -1) {
				_loc16_ = ASCompat.dynamicAs(_loc10_[_loc5_], com.greensock.core.TweenCore);
				_loc14_ = _loc16_.cachedTimeScale;
				_loc15_ = _loc16_.cachedStartTime;
				_loc18_ = _loc16_.timeline;
				while (_loc18_ != null) {
					_loc14_ *= _loc18_.cachedTimeScale;
					_loc15_ += _loc18_.cachedStartTime;
					_loc18_ = _loc18_.timeline;
				}
				_loc17_ = _loc14_ * _loc15_;
				if (_loc17_ <= _loc8_ && (_loc17_ + _loc16_.totalDuration * _loc14_ + 1e-10 > _loc8_ || _loc16_.cachedDuration == 0)) {
					_loc9_[Std.int(_loc19_ = ASCompat.toNumber(_loc12_++))] = _loc16_;
				}
			}
		}
		if (_loc12_ == 0) {
			return _loc6_;
		}
		_loc5_ = _loc12_;
		if (mode == 2) {
			while (--_loc5_ > -1) {
				_loc7_ = ASCompat.dynamicAs(_loc9_[_loc5_], com.greensock.TweenLite);
				if (_loc7_.killVars(props)) {
					_loc6_ = true;
				}
				if (_loc7_.cachedPT1 == null && _loc7_.initted) {
					_loc7_.setEnabled(false, false);
				}
			}
		} else {
			while (--_loc5_ > -1) {
				if (cast(_loc9_[_loc5_], TweenLite).setEnabled(false, false)) {
					_loc6_ = true;
				}
			}
		}
		return _loc6_;
	}
}
