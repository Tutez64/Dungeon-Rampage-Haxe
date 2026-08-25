package brain.mouseCursor;

import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.ui.Mouse;
import org.as3commons.collections.Map;
import flash.display.MovieClip;

class MouseCursorManager {
	var mCursorTypes:Map;

	var mCurrentCursor:String;

	var mIsTransient:Bool = false;

	var mCursorClip:MovieClip;

	var mCursorStack:Array<ASAny>;

	var mFacade:Facade;

	var mNextKey:UInt = 0;

	var mDisabled:Bool = false;

	public function new(facade:Facade) {
		mFacade = facade;
		mCursorTypes = new Map();
		mNextKey = (1 : UInt);
		mIsTransient = false;
		mDisabled = false;
		mCursorStack = [];
		registerBuiltInTypes();
		setMouseCursor("auto");
	}

	@:isVar public var disable(never, set):Bool;

	public function set_disable(disabled:Bool):Bool {
		mDisabled = disabled;
		if (mDisabled) {
			if (mCursorClip != null) {
				mFacade.stageRef.removeEventListener("mouseOver", onMouseOver);
				mFacade.stageRef.removeEventListener("mouseMove", onMouseMove);
				mFacade.stageRef.removeEventListener("mouseOut", onMouseOut);
				mFacade.sceneGraphManager.removeChild(mCursorClip);
			}
			setBuiltInCursor("auto");
		}
		return disabled;
	}

	function registerBuiltInTypes() {
		var _loc1_ = new CursorType(null, true);
		mCursorTypes.add("arrow", _loc1_);
		mCursorTypes.add("auto", _loc1_);
		mCursorTypes.add("button", _loc1_);
		mCursorTypes.add("hand", _loc1_);
		mCursorTypes.add("ibeam", _loc1_);
	}

	public function registerMouseCursor(root:MovieClip, name:String, override_ /*haxe keyword*/:Bool = false) {
		var _loc4_:CursorType = null;
		if (root == null) {
			Logger.error("Trying to register a mouse cursor with a null MovieClip.");
			return;
		}
		root.mouseChildren = false;
		root.mouseEnabled = false;
		if (mCursorTypes.hasKey(name)) {
			if (!override_) {
				return;
			}
			_loc4_ = ASCompat.dynamicAs(mCursorTypes.itemFor(name), CursorType);
			_loc4_.isBuiltIn = false;
			_loc4_.root = root;
			if (name == mCurrentCursor) {
				setMouseCursor(name);
			}
		} else {
			_loc4_ = new CursorType(root, false);
			mCursorTypes.add(name, _loc4_);
		}
	}

	function onMouseMove(event:MouseEvent) {
		mCursorClip.x = event.stageX;
		mCursorClip.y = event.stageY;
		event.updateAfterEvent();
	}

	function onMouseOver(event:MouseEvent) {
		if (mCursorClip != null) {
			mCursorClip.visible = true;
			mFacade.stageRef.removeEventListener("mouseOver", onMouseOver);
		}
	}

	function onMouseOut(event:MouseEvent) {
		if (mCursorClip != null && mCursorClip.visible) {
			mCursorClip.visible = false;
			mFacade.stageRef.addEventListener("mouseOver", onMouseOver);
			mFacade.stageRef.removeEventListener("mouseOut", onMouseOut);
		}
	}

	function setBuiltInCursor(name:String) {
		Mouse.show();
		Mouse.cursor = name;
		mCursorClip = null;
	}

	function setCustomCursor(type:CursorType) {
		Mouse.hide();
		mCursorClip = type.root;
		mCursorClip.visible = true;
		mCursorClip.mouseChildren = false;
		mCursorClip.mouseEnabled = false;
		mFacade.sceneGraphManager.addChild(mCursorClip, 200);
		type.root.x = type.root.stage.mouseX;
		type.root.y = type.root.stage.mouseY;
		mFacade.stageRef.addEventListener("mouseMove", onMouseMove);
		mFacade.stageRef.addEventListener("mouseOut", onMouseOut);
	}

	public function pushMouseCursor(name:String, transient:Bool = false):UInt {
		return (0 : UInt);
	}

	public function popMouseCursor(key:UInt = (0 : UInt)) {}

	public function setMouseCursor(name:String) {
		var _loc2_:ASAny = null;
	}
}

private class CursorType {
	public var isBuiltIn:Bool = false;

	public var root:MovieClip;

	public function new(clip:MovieClip, builtIn:Bool) {
		root = clip;
		isBuiltIn = builtIn;
	}
}
