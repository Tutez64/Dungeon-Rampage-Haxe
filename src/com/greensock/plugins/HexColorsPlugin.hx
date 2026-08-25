package com.greensock.plugins;

import com.greensock.*;

class HexColorsPlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _colors:Array<ASAny>;

	public function new() {
		super();
		this.propName = "hexColors";
		this.overwriteProps = [];
		_colors = [];
	}

	override public function killProps(lookup:ASObject) {
		var _loc2_ = _colors.length - 1;
		while (_loc2_ > -1) {
			if (ASCompat.hasProperty(lookup, ASCompat.dynGetIndex(_colors[_loc2_], 1))) {
				_colors.splice(_loc2_, (1 : UInt));
			}
			_loc2_ = ASCompat.toInt(_loc2_) - 1;
		}
		super.killProps(lookup);
	}

	public function initColor(target:ASObject, propName:String, start:UInt, end:UInt) {
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		if (start != end) {
			_loc5_ = (start : Int) >> 16;
			_loc6_ = (start : Int) >> 8 & 0xFF;
			_loc7_ = (start : Int) & 0xFF;
			_colors[_colors.length] = ([
				target,
				propName,
				_loc5_,
				((end : Int) >> 16) - _loc5_,
				_loc6_,
				((end : Int) >> 8 & 0xFF) - _loc6_,
				_loc7_,
				((end : Int) & 0xFF) - _loc7_
			] : Array<ASAny>);
			this.overwriteProps[this.overwriteProps.length] = propName;
		}
	}

	override public function set_changeFactor(n:Float):Float {
		var _loc3_:Array<ASAny> = null;
		var _loc2_ = _colors.length;
		while (--_loc2_ > -1) {
			_loc3_ = ASCompat.dynamicAs(_colors[_loc2_], Array);
			_loc3_[0][_loc3_[1]] = ASCompat.toInt(_loc3_[2] + n * ASCompat.toNumber(_loc3_[3])) << 16 | ASCompat.toInt(_loc3_[4]
				+ n * ASCompat.toNumber(_loc3_[5])) << 8 | ASCompat.toInt(_loc3_[6] + n * ASCompat.toNumber(_loc3_[7]));
		}
		return n;
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		var _loc4_:String = null;
		if (checkNullIteratee(value))
			for (_tmp_ in value.___keys()) {
				_loc4_ = _tmp_;
				initColor(target, _loc4_, (ASCompat.toInt(target[_loc4_]) : UInt), (ASCompat.toInt(value[_loc4_]) : UInt));
			}
		return true;
	}
}
