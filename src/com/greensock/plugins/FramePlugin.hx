package com.greensock.plugins;

import com.greensock.TweenLite;
import flash.display.MovieClip;

class FramePlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _target:MovieClip;

	public var frame:Int = 0;

	public function new() {
		super();
		this.propName = "frame";
		this.overwriteProps = ["frame", "frameLabel"];
		this.round = true;
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		if (!Std.isOfType(target, MovieClip) || Math.isNaN(ASCompat.toNumber(value))) {
			return false;
		}
		_target = ASCompat.dynamicAs(target, MovieClip);
		this.frame = _target.currentFrame;
		addTween(this, "frame", this.frame, value, "frame");
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		updateTweens(n);
		_target.gotoAndStop(this.frame);
		return n;
	}
}
