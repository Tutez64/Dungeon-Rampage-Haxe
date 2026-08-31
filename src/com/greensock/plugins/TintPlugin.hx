package com.greensock.plugins;

import com.greensock.*;
import com.greensock.core.*;
import flash.display.*;
import flash.geom.ColorTransform;
import flash.geom.Transform;

class TintPlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	static var _props:Array<ASAny> = [
		"redMultiplier",
		"greenMultiplier",
		"blueMultiplier",
		"alphaMultiplier",
		"redOffset",
		"greenOffset",
		"blueOffset",
		"alphaOffset"
	];

	var _ct:ColorTransform;

	var _transform:Transform;

	var _ignoreAlpha:Bool = false;

	public function new() {
		super();
		this.propName = "tint";
		this.overwriteProps = ["tint"];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		if (!Std.isOfType(target, DisplayObject)) {
			return false;
		}
		var _loc4_ = new ColorTransform();
		if (value != null && tween.vars.removeTint != true) {
			_loc4_.color = (ASCompat.toInt(value) : UInt);
		}
		_ignoreAlpha = true;
		_transform = cast(target, DisplayObject).transform;
		init(_transform.colorTransform, _loc4_);
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		var _loc2_:ColorTransform = null;
		updateTweens(n);
		if (_transform != null) {
			if (_ignoreAlpha) {
				_loc2_ = _transform.colorTransform;
				_ct.alphaMultiplier = _loc2_.alphaMultiplier;
				_ct.alphaOffset = _loc2_.alphaOffset;
			}
			_transform.colorTransform = _ct;
		}
		return n;
	}

	public function init(start:ColorTransform, end:ColorTransform) {
		var _loc6_:Float;
		var _loc4_:String = null;
		_ct = start;
		var _loc3_ = _props.length;
		var _loc5_ = _tweens.length;
		while (ASCompat.toBool(_loc3_--)) {
			_loc4_ = _props[_loc3_];
			if ((_ct : ASAny)[_loc4_] != (end : ASAny)[_loc4_]) {
				_tweens[Std.int(_loc6_ = ASCompat.toNumber(_loc5_++))] = new PropTween(_ct, _loc4_, ASCompat.toNumber((_ct : ASAny)[_loc4_]),
					ASCompat.toNumber(ASCompat.toNumber((end : ASAny)[_loc4_]) - ASCompat.toNumber((_ct : ASAny)[_loc4_])), "tint", false);
			}
		}
	}
}
