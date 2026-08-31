package com.greensock.plugins;

import com.greensock.*;
import flash.media.SoundTransform;

class VolumePlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _target:ASObject;

	var _st:SoundTransform;

	public function new() {
		super();
		this.propName = "volume";
		this.overwriteProps = ["volume"];
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		if (Math.isNaN(ASCompat.toNumber(value)) || target.hasOwnProperty("volume") || !target.hasOwnProperty("soundTransform")) {
			return false;
		}
		_target = target;
		_st = ASCompat.dynamicAs(_target.soundTransform, flash.media.SoundTransform);
		addTween(_st, "volume", _st.volume, value, "volume");
		return true;
	}

	override public function set_changeFactor(n:Float):Float {
		updateTweens(n);
		ASCompat.setProperty(_target, "soundTransform", _st);
		return n;
	}
}
