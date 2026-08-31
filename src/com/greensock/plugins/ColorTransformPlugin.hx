package com.greensock.plugins;

import com.greensock.*;
import flash.display.*;
import flash.geom.ColorTransform;

class ColorTransformPlugin extends TintPlugin {
	public static inline final API:Float = 1;

	public function new() {
		super();
		this.propName = "colorTransform";
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		var _loc4_:ColorTransform = null;
		var _loc6_:String = null;
		var _loc7_ = Math.NaN;
		var _loc5_ = new ColorTransform();
		if (Std.isOfType(target, DisplayObject)) {
			_transform = cast(target, DisplayObject).transform;
			_loc4_ = _transform.colorTransform;
		} else {
			if (!Std.isOfType(target, ColorTransform)) {
				return false;
			}
			_loc4_ = ASCompat.dynamicAs(target, ColorTransform);
		}
		_loc5_.concat(_loc4_);
		if (checkNullIteratee(value))
			for (_tmp_ in value.___keys()) {
				_loc6_ = _tmp_;
				if (_loc6_ == "tint" || _loc6_ == "color") {
					if (value[_loc6_] != null) {
						_loc5_.color = (ASCompat.toInt(value[_loc6_]) : UInt);
					}
				} else if (!(_loc6_ == "tintAmount" || _loc6_ == "exposure" || _loc6_ == "brightness")) {
					(_loc5_ : ASAny)[_loc6_] = value[_loc6_];
				}
			}
		if (!Math.isNaN(ASCompat.toNumberField(value, "tintAmount"))) {
			_loc7_ = ASCompat.toNumberField(value, "tintAmount") / (1 - (_loc5_.redMultiplier + _loc5_.greenMultiplier + _loc5_.blueMultiplier) / 3);
			_loc5_.redOffset *= _loc7_;
			_loc5_.greenOffset *= _loc7_;
			_loc5_.blueOffset *= _loc7_;
			_loc5_.redMultiplier = _loc5_.greenMultiplier = _loc5_.blueMultiplier = ASCompat.toNumber(1 - ASCompat.toNumberField(value, "tintAmount"));
		} else if (!Math.isNaN(ASCompat.toNumberField(value, "exposure"))) {
			_loc5_.redOffset = _loc5_.greenOffset = _loc5_.blueOffset = ASCompat.toNumber(255 * ASCompat.toNumber(ASCompat.toNumberField(value,
				"exposure") - 1));
			_loc5_.redMultiplier = _loc5_.greenMultiplier = _loc5_.blueMultiplier = 1;
		} else if (!Math.isNaN(ASCompat.toNumberField(value, "brightness"))) {
			_loc5_.redOffset = _loc5_.greenOffset = _loc5_.blueOffset = Math.max(0,
				ASCompat.toNumber(ASCompat.toNumber(ASCompat.toNumberField(value, "brightness") - 1) * 255));
			_loc5_.redMultiplier = _loc5_.greenMultiplier = _loc5_.blueMultiplier = 1
				- Math.abs(ASCompat.toNumber(ASCompat.toNumberField(value, "brightness") - 1));
		}
		_ignoreAlpha = tween.vars.alpha != /*undefined*/ null && value.alphaMultiplier == /*undefined*/ null;
		init(_loc4_, _loc5_);
		return true;
	}
}
