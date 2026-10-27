package com.greensock.plugins;

import com.greensock.*;

class AutoAlphaPlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _target:ASObject;

	var _ignoreVisible:Bool = false;

	public function new() {
		super();
		this.propName = "autoAlpha";
		this.overwriteProps = ["alpha", "visible"];
	}

	override public function killProps(lookup:ASObject) {
		super.killProps(lookup);
		_ignoreVisible = lookup.hasOwnProperty("visible");
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_target = target;
		addTween(target, "alpha", ASCompat.toNumberField(target, "alpha"), value, "alpha");
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		updateTweens(n);
		if (!_ignoreVisible) {
			ASCompat.setProperty(_target, "visible", ASCompat.toNumberField(_target, "alpha") != 0);
		}
		return n;
	}
}
