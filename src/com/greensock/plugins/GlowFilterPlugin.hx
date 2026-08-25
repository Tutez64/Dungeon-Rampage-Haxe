package com.greensock.plugins;

import com.greensock.*;
import flash.filters.GlowFilter;

class GlowFilterPlugin extends FilterPlugin {
	public static inline final API:Float = 1;

	static var _propNames:Array<ASAny> = ["color", "alpha", "blurX", "blurY", "strength", "quality", "inner", "knockout"];

	public function new() {
		super();
		this.propName = "glowFilter";
		this.overwriteProps = ["glowFilter"];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_target = target;
		_type = GlowFilter;
		initFilter(value,
			new GlowFilter((16777215 : UInt), 0, 0, 0, ASCompat.toNumber(ASCompat.thisOrDefault(ASCompat.toNumber(value.strength), 1)),
				ASCompat.thisOrDefault(ASCompat.toInt(value.quality), 2), ASCompat.toBool(value.inner), ASCompat.toBool(value.knockout)),
			_propNames);
		return true;
	}
}
