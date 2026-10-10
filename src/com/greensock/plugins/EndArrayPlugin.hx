package com.greensock.plugins;

import com.greensock.*;

class EndArrayPlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _a:Array<ASAny>;

	var _info:Array<ASAny> = [];

	public function new() {
		super();
		this.propName = "endArray";
		this.overwriteProps = ["endArray"];
	}

	public function init(start:Array<ASAny>, end:Array<ASAny>) {
		_a = start;
		var _loc3_ = end.length;
		while (_loc3_-- != 0) {
			if (start[_loc3_] != end[_loc3_] && start[_loc3_] != null) {
				_info[_info.length] = new ArrayTweenInfo((_loc3_ : UInt), ASCompat.toNumber(_a[_loc3_]),
					ASCompat.toNumber(end[_loc3_]) - ASCompat.toNumber(_a[_loc3_]));
			}
		}
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		if (!Std.isOfType(target, Array) || !Std.isOfType(value, Array)) {
			return false;
		}
		init(ASCompat.dynamicAs(target, Array), ASCompat.coerce(value, Array));
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		var _loc3_:ArrayTweenInfo = null;
		var _loc4_ = Math.NaN;
		var _loc2_ = _info.length;
		if (this.round) {
			while (_loc2_-- != 0) {
				_loc3_ = ASCompat.coerce(_info[_loc2_], ArrayTweenInfo);
				_loc4_ = _loc3_.start + _loc3_.change * n;
				if (_loc4_ > 0) {
					_a[(_loc3_.index : Int)] = ASCompat.floatToInt(_loc4_ + 0.5) >> 0;
				} else {
					_a[(_loc3_.index : Int)] = ASCompat.floatToInt(_loc4_ - 0.5) >> 0;
				}
			}
		} else {
			while (_loc2_-- != 0) {
				_loc3_ = ASCompat.coerce(_info[_loc2_], ArrayTweenInfo);
				_a[(_loc3_.index : Int)] = _loc3_.start + _loc3_.change * n;
			}
		}
		return n;
	}
}

private class ArrayTweenInfo {
	public var change:Float = Math.NaN;

	public var start:Float = Math.NaN;

	public var index:UInt = 0;

	public function new(index:UInt, start:Float, change:Float) {
		this.index = index;
		this.start = start;
		this.change = change;
	}
}
