package com.greensock.plugins;

import com.greensock.TweenLite;

class BezierThroughPlugin extends BezierPlugin {
	public static inline final API:Float = 1;

	public function new() {
		super();
		this.propName = "bezierThrough";
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		if (!Std.isOfType(value, Array)) {
			return false;
		}
		init(tween, ASCompat.dynamicAs(value, Array), true);
		return true;
	}
}
