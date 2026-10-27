package com.greensock.plugins;

import com.greensock.*;
import flash.filters.BlurFilter;

class BlurFilterPlugin extends FilterPlugin {
	public static inline final API:Float = 1;

	static var _propNames:Array<ASAny> = ["blurX", "blurY", "quality"];

	public function new() {
		super();
		this.propName = "blurFilter";
		this.overwriteProps = ["blurFilter"];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_target = target;
		_type = BlurFilter;
		initFilter(value, new BlurFilter(0, 0, ASCompat.thisOrDefault(ASCompat.toInt(value.quality), 2)), _propNames);
		return true;
	}
}
