package brain.mouseCursor;

import brain.event.EventListeners;
import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.text.TextField;
import flash.ui.Mouse;
import flash.ui.MouseCursorData;

class MouseCursorManager {
	public static inline final MAX_CURSOR_SIZE = 32;

	static inline final NATIVE_NAME_PREFIX = "custom_";

	static var BUILT_IN_CURSORS:Array<ASAny>;

	var mFacade:Facade;

	var mCursors:ASDictionary<ASAny, ASAny>;

	var mStack:Vector<CursorEntry>;

	var mDefaultCursor:String;

	var mNextKey:UInt = 0;

	var mHoveredTextInput:TextField;

	var mTextInputCursorKey:UInt = 0;

	var mCursorHidden:Bool = false;

	public function new(facade:Facade) {
		mFacade = facade;
		mCursors = new ASDictionary<ASAny, ASAny>();
		var _loc2_:String;
		final __ax4_iter_529 = BUILT_IN_CURSORS;
		if (checkNullIteratee(__ax4_iter_529))
			for (_tmp_ in __ax4_iter_529) {
				_loc2_ = _tmp_;
				mCursors[_loc2_] = _loc2_;
			}
		mStack = new Vector<CursorEntry>();
		mDefaultCursor = "auto";
		mNextKey = (1 : UInt);
		EventListeners.add(mFacade.stageRef, "mouseOver", onStageMouseOver, true);
		EventListeners.add(mFacade.stageRef, "mouseMove", onMouseKeyboardInput, true);
		EventListeners.add(mFacade.stageRef, "mouseDown", onMouseKeyboardInput, true);
		EventListeners.add(mFacade.stageRef, "mouseWheel", onMouseKeyboardInput, true);
		EventListeners.add(mFacade.stageRef, "keyDown", onMouseKeyboardInput, true);
		refresh();
	}

	static function rasterize(art:DisplayObject):MouseCursorData {
		var _loc4_ = art.getBounds(art);
		var _loc5_ = Math.min(1, 32 / Math.max(_loc4_.width, _loc4_.height));
		var _loc3_ = new BitmapData(32, 32, true, (0 : UInt));
		var _loc6_ = new Matrix(_loc5_, 0, 0, _loc5_, -_loc4_.x * _loc5_, -_loc4_.y * _loc5_);
		_loc3_.drawWithQuality(art, _loc6_, null, null, null, true, "best");
		var _loc2_ = new MouseCursorData();
		_loc2_.data = Vector.ofArray([_loc3_]);
		_loc2_.hotSpot = new Point(clampToCursor(-_loc4_.x * _loc5_), clampToCursor(-_loc4_.y * _loc5_));
		return _loc2_;
	}

	static function clampToCursor(value:Float):Int {
		return ASCompat.floatToInt(Math.max(0, Math.min(32 - 1, Math.fround(value))));
	}

	public function hideMouseCursor() {
		if (mCursorHidden) {
			return;
		}
		mCursorHidden = true;
		Mouse.hide();
		mFacade.stageRef.mouseChildren = false;
	}

	function onMouseKeyboardInput(event:Event) {
		if (!mCursorHidden) {
			return;
		}
		mCursorHidden = false;
		mFacade.stageRef.mouseChildren = true;
		Mouse.show();
		refresh();
	}

	public function registerMouseCursor(name:String, art:DisplayObject) {
		if (art == null) {
			Logger.error("Trying to register mouse cursor " + name + " without art.");
			return;
		}
		if (BUILT_IN_CURSORS.indexOf(name) != -1) {
			Logger.error("Trying to replace built-in mouse cursor " + name + ".");
			return;
		}
		if (!Mouse.supportsNativeCursor) {
			Logger.warn("Native mouse cursors are not supported, " + name + " will show the system cursor.");
			return;
		}
		var _loc3_ = "custom_" + name;
		Mouse.registerCursor(_loc3_, rasterize(art));
		mCursors[name] = _loc3_;
		refresh();
	}

	@:isVar public var defaultMouseCursor(never, set):String;

	public function set_defaultMouseCursor(name:String):String {
		mDefaultCursor = name;
		refresh();
		return name;
	}

	public function pushMouseCursor(name:String, transient:Bool = false):UInt {
		if (mStack.length > 0 && mStack[mStack.length - 1].transient) {
			mStack.pop();
		}
		var _loc3_ = mNextKey++;
		mStack.push(new CursorEntry(_loc3_, name, transient));
		refresh();
		return _loc3_;
	}

	public function popMouseCursor(key:UInt) {
		var _loc2_ = 0;
		_loc2_ = mStack.length - 1;
		while (_loc2_ >= 0) {
			if (mStack[_loc2_].key == key) {
				mStack.splice(_loc2_, (1 : UInt));
				refresh();
				return;
			}
			_loc2_--;
		}
	}

	function refresh() {
		var _loc2_ = mStack.length > 0 ? mStack[mStack.length - 1].name : mDefaultCursor;
		var _loc1_:String = mCursors[_loc2_];
		Mouse.cursor = ASCompat.stringAsBool(_loc1_) ? _loc1_ : "auto";
	}

	function onStageMouseOver(event:MouseEvent) {
		var _loc2_ = ASCompat.dynamicAs(event.target, TextField);
		if (_loc2_ == mHoveredTextInput) {
			return;
		}
		releaseTextInputCursor();
		if (_loc2_ != null && _loc2_.type == "input") {
			mHoveredTextInput = _loc2_;
			EventListeners.add(mHoveredTextInput, "mouseOut", onTextInputLeft);
			EventListeners.add(mHoveredTextInput, "removedFromStage", onTextInputLeft);
			mTextInputCursorKey = pushMouseCursor("ibeam");
		}
	}

	function onTextInputLeft(event:Event) {
		releaseTextInputCursor();
	}

	function releaseTextInputCursor() {
		if (mHoveredTextInput == null) {
			return;
		}
		EventListeners.remove(mHoveredTextInput, "mouseOut", onTextInputLeft);
		EventListeners.remove(mHoveredTextInput, "removedFromStage", onTextInputLeft);
		mHoveredTextInput = null;
		popMouseCursor(mTextInputCursorKey);
		mTextInputCursorKey = (0 : UInt);
	}

	static function __init__() {
		BUILT_IN_CURSORS = ["arrow", "auto", "button", "hand", "ibeam"];
	}
}

private class CursorEntry {
	public var key:UInt = 0;

	public var name:String;

	public var transient:Bool = false;

	public function new(key:UInt, name:String, transient:Bool) {
		this.key = key;
		this.name = name;
		this.transient = transient;
	}
}
