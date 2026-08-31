package com.greensock.plugins;

import com.greensock.*;
import flash.filters.DropShadowFilter;

class DropShadowFilterPlugin extends FilterPlugin {
	public static inline final API:Float = 1;

	static var _propNames:Array<ASAny> = [
		"distance",
		"angle",
		"color",
		"alpha",
		"blurX",
		"blurY",
		"strength",
		"quality",
		"inner",
		"knockout",
		"hideObject"
	];

	public function new() {
		super();
		this.propName = "dropShadowFilter";
		this.overwriteProps = ["dropShadowFilter"];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_target = target;
		_type = DropShadowFilter;
		initFilter(value,
			new DropShadowFilter(0, 45, (0 : UInt), 0, 0, 0, 1, ASCompat.thisOrDefault(ASCompat.toInt(value.quality), 2), ASCompat.toBool(value.inner),
				ASCompat.toBool(value.knockout), ASCompat.toBool(value.hideObject)),
			_propNames);
		return true;
	}
}
