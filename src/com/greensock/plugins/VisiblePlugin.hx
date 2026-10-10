package com.greensock.plugins;

import com.greensock.*;

class VisiblePlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _target:ASObject;

	var _initVal:Bool = false;

	var _visible:Bool = false;

	var _tween:TweenLite;

	public function new() {
		super();
		this.propName = "visible";
		this.overwriteProps = ["visible"];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_target = target;
		_tween = tween;
		_initVal = ASCompat.toBool(_target.visible);
		_visible = ASCompat.toBool(value);
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		if (n == 1 && (_tween.cachedDuration == _tween.cachedTime || _tween.cachedTime == 0)) {
			ASCompat.setProperty(_target, "visible", _visible);
		} else {
			ASCompat.setProperty(_target, "visible", _initVal);
		}
		return n;
	}
}
