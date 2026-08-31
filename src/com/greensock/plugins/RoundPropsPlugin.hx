package com.greensock.plugins;

import com.greensock.TweenLite;
import com.greensock.core.PropTween;

class RoundPropsPlugin extends TweenPlugin {
	public static inline final API:Float = 1;

	var _tween:TweenLite;

	public function new() {
		super();
		this.propName = "roundProps";
		this.overwriteProps = ["roundProps"];
		this.round = true;
		this.priority = -1;
		this.onInitAllProps = _initAllProps;
	}

	public function add(object:ASObject, propName:String, start:Float, change:Float) {
		addTween(object, propName, start, start + change, propName);
		this.overwriteProps[this.overwriteProps.length] = propName;
	}

	function _removePropTween(propTween:PropTween) {
		if (propTween.nextNode != null) {
			propTween.nextNode.prevNode = propTween.prevNode;
		}
		if (propTween.prevNode != null) {
			propTween.prevNode.nextNode = propTween.nextNode;
		} else if (_tween.cachedPT1 == propTween) {
			_tween.cachedPT1 = propTween.nextNode;
		}
		if (propTween.isPlugin && ASCompat.toBool(propTween.target.onDisable)) {
			propTween.target.onDisable();
		}
	}

	override public function onInitTween(target:ASObject, value:ASAny, tween:TweenLite):Bool {
		_tween = tween;
		this.overwriteProps = this.overwriteProps.concat(ASCompat.dynamicAs(value, Array));
		return true;
	}

	function _initAllProps() {
		var _loc1_:String = null;
		var _loc2_:String = null;
		var _loc4_:PropTween = null;
		var _loc3_:Array<ASAny> = ASCompat.dynamicAs(_tween.vars.roundProps, Array);
		var _loc5_ = _loc3_.length;
		while (--_loc5_ > -1) {
			_loc1_ = _loc3_[_loc5_];
			_loc4_ = _tween.cachedPT1;
			while (_loc4_ != null) {
				if (_loc4_.name == _loc1_) {
					if (_loc4_.isPlugin) {
						ASCompat.setProperty(_loc4_.target, "round", true);
					} else {
						add(_loc4_.target, _loc1_, _loc4_.start, _loc4_.change);
						_removePropTween(_loc4_);
						_tween.propTweenLookup[_loc1_] = _tween.propTweenLookup.roundProps;
					}
				} else if (_loc4_.isPlugin && _loc4_.name == "_MULTIPLE_" && !ASCompat.toBool(_loc4_.target.round)) {
					_loc2_ = " " + Std.string(ASCompat.dynJoin(_loc4_.target.overwriteProps, " ")) + " ";
					if (_loc2_.indexOf(" " + _loc1_ + " ") != -1) {
						ASCompat.setProperty(_loc4_.target, "round", true);
					}
				}
				_loc4_ = _loc4_.nextNode;
			}
		}
	}
}
