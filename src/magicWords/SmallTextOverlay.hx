package magicWords;

import brain.event.EventListeners;
import brain.logger.Logger;
import brain.utils.TextUtil;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Loader;
import flash.display.Sprite;
import flash.events.Event;
import flash.text.TextField;
import flash.text.TextFormat;

class SmallTextOverlay extends Sprite {
	public static inline final DEFAULT_MIN_PX:Float = 9;

	static inline final LAYER:Float = 1003;

	static inline final OUTLINE_COLOR = (16719904 : UInt);

	static inline final REDRAW_EVERY_FRAMES = 5;

	var mDBFacade:DBFacade;

	var mMinPx:Float = Math.NaN;

	var mUseLowercase:Bool = false;

	var mLabels:Vector<TextField> = new Vector();

	var mLabelsUsed:Int = 0;

	var mFrame:Int = 0;

	public function new(dbFacade:DBFacade, minPx:Float, useLowercase:Bool = false) {
		super();
		mDBFacade = dbFacade;
		mMinPx = minPx;
		mUseLowercase = useLowercase;
		mouseEnabled = false;
		mouseChildren = false;
		mDBFacade.addRootDisplayObject(this, 1003);
		EventListeners.add(this, "enterFrame", onEnterFrame);
	}

	public static function logSmallText(dbFacade:DBFacade, minPx:Float, useLowercase:Bool = false) {
		var count = 0;
		forEachSmallField(dbFacade, minPx, function(param1:TextField, param2:Float) {
			count = count + 1;
			Logger.log(ASCompat.toFixed(param2, (1 : UInt)) + "px  " + pathOf(param1) + "  \"" + param1.text.substr(0, 30) + "\"");
		}, useLowercase);
		Logger.log(count + " visible text field(s) under " + minPx + "px (" + (useLowercase ? "lowercase" : "uppercase") + " height)");
	}

	static function forEachSmallField(dbFacade:DBFacade, minPx:Float, callback:ASFunction, useLowercase:Bool) {
		if (dbFacade.stageRef == null) {
			return;
		}
		walk(dbFacade.stageRef, dbFacade.scalingRoot, minPx, callback, useLowercase);
	}

	static function walk(node:DisplayObject, scalingRoot:DisplayObjectContainer, minPx:Float, callback:ASFunction, useLowercase:Bool) {
		var _loc8_ = Math.NaN;
		var _loc9_ = 0;
		if (node == null || !node.visible || node.alpha == 0 || Std.isOfType(node, SmallTextOverlay)) {
			return;
		}
		var _loc7_ = ASCompat.reinterpretAs(node, TextField);
		if (_loc7_ != null) {
			if (_loc7_.text == "" || node.parent == scalingRoot) {
				return;
			}
			_loc8_ = TextUtil.glyphHeightPx(_loc7_, useLowercase);
			if (!Math.isNaN(_loc8_) && _loc8_ < minPx) {
				callback(_loc7_, _loc8_);
			}
			return;
		}
		var _loc6_ = ASCompat.reinterpretAs(node, DisplayObjectContainer);
		if (_loc6_ == null) {
			return;
		}
		if (Std.isOfType(_loc6_, Loader)) {
			return;
		}
		if (_loc6_.parent == _loc6_.stage && ASCompat.getQualifiedClassName(_loc6_).indexOf("com.junkbyte") == 0) {
			return;
		}
		_loc9_ = 0;
		while (_loc9_ < _loc6_.numChildren) {
			walk(_loc6_.getChildAt(_loc9_), scalingRoot, minPx, callback, useLowercase);
			_loc9_++;
		}
	}

	static function pathOf(node:DisplayObject):String {
		var _loc2_ = "";
		while (node != null && node.parent != null) {
			_loc2_ = "/" + node.name + _loc2_;
			node = node.parent;
		}
		return _loc2_;
	}

	public function destroy() {
		EventListeners.remove(this, "enterFrame", onEnterFrame);
		mDBFacade.removeRootDisplayObject(this);
		mDBFacade = null;
	}

	function onEnterFrame(event:Event) {
		var overlay:SmallTextOverlay;
		var i:Int;
		if (++mFrame % 5 != 0) {
			return;
		}
		graphics.clear();
		graphics.lineStyle(2, (16719904 : UInt));
		mLabelsUsed = 0;
		overlay = this;
		forEachSmallField(mDBFacade, mMinPx, function(param1:TextField, param2:Float) {
			var _loc3_ = param1.getBounds(overlay);
			overlay.graphics.drawRect(_loc3_.x, _loc3_.y, _loc3_.width, _loc3_.height);
			overlay.placeLabel(ASCompat.toFixed(param2, (1 : UInt)), _loc3_.x, _loc3_.y);
		}, mUseLowercase);
		i = mLabelsUsed;
		while (i < mLabels.length) {
			mLabels[i].visible = false;
			i = i + 1;
		}
	}

	function placeLabel(text:String, x:Float, y:Float) {
		var _loc4_:TextField = null;
		if (mLabelsUsed < mLabels.length) {
			_loc4_ = mLabels[mLabelsUsed];
		} else {
			_loc4_ = new TextField();
			_loc4_.autoSize = "left";
			_loc4_.selectable = false;
			_loc4_.background = true;
			_loc4_.backgroundColor = (16719904 : UInt);
			_loc4_.defaultTextFormat = new TextFormat("_sans", 11, 16777215, true);
			_loc4_.scaleX = _loc4_.scaleY = 1 / mDBFacade.viewScale;
			mLabels.push(_loc4_);
			addChild(_loc4_);
		}
		mLabelsUsed = mLabelsUsed + 1;
		_loc4_.text = text;
		_loc4_.x = x;
		_loc4_.y = y - _loc4_.height;
		_loc4_.visible = true;
	}
}
