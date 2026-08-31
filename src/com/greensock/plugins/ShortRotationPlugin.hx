package com.greensock.plugins;

import com.greensock.*;

class ShortRotationPlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	public function new() {
		super();
		this.propName = "shortRotation";
		this.overwriteProps = [];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		var _loc4_:String = null;
		if (ASCompat.typeof(value) == "number") {
			return false;
		}
		if (checkNullIteratee(value))
			for (_tmp_ in value.___keys()) {
				_loc4_ = _tmp_;
				initRotation(target, _loc4_, ASCompat.toNumber(target[_loc4_]),
					ASCompat.toNumber(ASCompat.typeof(value[_loc4_]) == "number" ? ASCompat.toNumber(value[_loc4_]) : ASCompat.toNumber(target[_loc4_]
						+ ASCompat.toNumber(value[_loc4_]))));
			}
		return true;
	}

	public function initRotation(target:ASObject, propName:String, start:Float, end:Float) {
		var _loc5_ = (end - start) % 360;
		if (_loc5_ != _loc5_ % 180) {
			_loc5_ = _loc5_ < 0 ? _loc5_ + 360 : _loc5_ - 360;
		}
		addTween(target, propName, start, start + _loc5_, propName);
		this.overwriteProps[this.overwriteProps.length] = propName;
	}
}
