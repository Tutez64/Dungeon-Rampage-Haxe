package actor;

import brain.event.EventListeners;
import brain.workLoop.LogicalWorkComponent;
import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.display.Stage;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

class ActorMousePicker {
	static var sInstance:ActorMousePicker;

	static var sPointerOnStage:Bool = true;

	static var sWorldUnderPointer:Bool = true;

	var mStage:Stage;

	var mWorld:DisplayObject;

	var mWork:LogicalWorkComponent;

	var mHandlers:Vector<MouseEventHandler> = new Vector((0 : UInt));

	var mViews:Vector<ActorView> = new Vector((0 : UInt));

	var mRoots:Vector<Sprite> = new Vector((0 : UInt));

	var mParents:Vector<DisplayObjectContainer> = new Vector((0 : UInt));

	var mParentX:Vector<Float> = new Vector((0 : UInt));

	var mParentY:Vector<Float> = new Vector((0 : UInt));

	var mParentOpen:Vector<Bool> = new Vector((0 : UInt));

	var mCandidates:Vector<MouseEventHandler> = new Vector((0 : UInt));

	var mRects:Vector<Float> = new Vector((0 : UInt));

	var mPoint:Point = new Point();

	var mHovered:MouseEventHandler;

	var mHistory:Array<ASAny>;

	public var pointerOverride:Point;

	public function new(facade:DBFacade) {
		mStage = facade.stageRef;
		mWorld = facade.sceneGraphManager.worldLayerGroup;
		mWork = new LogicalWorkComponent(facade, "ActorMousePicker");
		EventListeners.add(mStage, "mouseMove", onMouseMove);
		EventListeners.add(mStage, "mouseDown", onMouseDown);
		EventListeners.add(mStage, "mouseUp", onMouseUp);
		EventListeners.add(mStage, "mouseLeave", onMouseLeave);
		EventListeners.add(mStage, "mouseOver", onMouseOver);
		EventListeners.add(mStage, "mouseOut", onMouseOut);
		mWork.doEveryFrame(onFrame);
	}

	public static function register(handler:MouseEventHandler, facade:DBFacade) {
		if (sInstance == null) {
			sInstance = new ActorMousePicker(facade);
		}
		sInstance.add(handler);
	}

	public static function unregister(handler:MouseEventHandler) {
		if (sInstance != null) {
			sInstance.remove(handler);
		}
	}

	@:isVar public static var instance(get, never):ActorMousePicker;

	static public function get_instance():ActorMousePicker {
		return sInstance;
	}

	static function isOpenToMouse(parent:DisplayObjectContainer):Bool {
		var _loc2_:DisplayObjectContainer = null;
		_loc2_ = parent;
		while (_loc2_ != null) {
			if (!_loc2_.visible || !_loc2_.mouseChildren) {
				return false;
			}
			_loc2_ = _loc2_.parent;
		}
		return true;
	}

	function add(handler:MouseEventHandler) {
		if (mHandlers.indexOf(handler) >= 0 || handler.actorView == null || handler.actorView.root == null) {
			return;
		}
		mHandlers.push(handler);
		mViews.push(handler.actorView);
		mRoots.push(handler.actorView.root);
	}

	function remove(handler:MouseEventHandler) {
		var _loc2_ = mHandlers.indexOf(handler);
		if (_loc2_ >= 0) {
			mHandlers.splice(_loc2_, (1 : UInt));
			mViews.splice(_loc2_, (1 : UInt));
			mRoots.splice(_loc2_, (1 : UInt));
		}
		if (mHovered == handler) {
			setHovered(null);
		}
		if (mHandlers.length == 0) {
			destroy();
		}
	}

	function destroy() {
		EventListeners.remove(mStage, "mouseMove", onMouseMove);
		EventListeners.remove(mStage, "mouseDown", onMouseDown);
		EventListeners.remove(mStage, "mouseUp", onMouseUp);
		EventListeners.remove(mStage, "mouseLeave", onMouseLeave);
		EventListeners.remove(mStage, "mouseOver", onMouseOver);
		EventListeners.remove(mStage, "mouseOut", onMouseOut);
		mWork.destroy();
		mWork = null;
		mHovered = null;
		if (sInstance == this) {
			sInstance = null;
		}
	}

	@:isVar public var handlerCount(get, never):Int;

	public function get_handlerCount():Int {
		return mHandlers.length;
	}

	@:isVar public var hovered(get, never):MouseEventHandler;

	public function get_hovered():MouseEventHandler {
		return mHovered;
	}

	function onMouseMove(event:MouseEvent) {
		track(event);
	}

	function onMouseDown(event:MouseEvent) {
		track(event);
		pickAt(event.stageX, event.stageY);
		if (mHovered != null && mHovered.wantsClicks) {
			note("down", mHovered);
			mHovered.onMouseDown(event);
		}
	}

	function onMouseUp(event:MouseEvent) {
		track(event);
		pickAt(event.stageX, event.stageY);
		if (mHovered != null && mHovered.wantsClicks) {
			note("up", mHovered);
			mHovered.onMouseUp(event);
		}
	}

	function onMouseLeave(event:Event) {
		sPointerOnStage = false;
		setHovered(null);
	}

	function onMouseOver(event:MouseEvent) {
		sPointerOnStage = true;
		sWorldUnderPointer = isWorld(ASCompat.dynamicAs(event.target, DisplayObject));
	}

	function onMouseOut(event:MouseEvent) {
		sWorldUnderPointer = isWorld(event.relatedObject);
	}

	function onFrame(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (!sPointerOnStage) {
			return;
		}
		if (pointerOverride != null) {
			pickAt(pointerOverride.x, pointerOverride.y);
			return;
		}
		pickAt(mStage.mouseX, mStage.mouseY);
	}

	function track(event:MouseEvent) {
		sPointerOnStage = true;
		sWorldUnderPointer = isWorld(ASCompat.dynamicAs(event.target, DisplayObject));
	}

	function isWorld(target:DisplayObject):Bool {
		var _loc2_:DisplayObject = null;
		if (target == null || target == mStage) {
			return true;
		}
		_loc2_ = target;
		while (_loc2_ != null) {
			if (_loc2_ == mWorld) {
				return true;
			}
			_loc2_ = _loc2_.parent;
		}
		return false;
	}

	public function pickAt(stageX:Float, stageY:Float) {
		setHovered(sWorldUnderPointer ? pick(stageX, stageY) : null);
	}

	public function pick(stageX:Float, stageY:Float):MouseEventHandler {
		var _loc21_ = 0;
		var _loc14_:Sprite = null;
		var _loc3_:DisplayObjectContainer = null;
		var _loc10_:ActorView = null;
		var _loc23_ = 0;
		var _loc8_:Point = null;
		var _loc9_:Rectangle = null;
		var _loc17_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc28_ = Math.NaN;
		var _loc29_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc26_ = Math.NaN;
		var _loc22_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc19_ = Math.NaN;
		var _loc4_:MouseEventHandler = null;
		var _loc25_ = 0;
		var _loc20_ = 0;
		var _loc27_ = -1;
		var _loc11_:DisplayObjectContainer = null;
		var _loc5_:Float = 0;
		var _loc6_:Float = 0;
		var _loc24_ = 0;
		var _loc31_ = false;
		var _loc30_ = mViews.length;
		_loc21_ = 0;
		while (_loc21_ < _loc30_) {
			_loc14_ = mRoots[_loc21_];
			_loc3_ = _loc14_.parent;
			if (_loc3_ != null) {
				_loc10_ = mViews[_loc21_];
				if (_loc3_ != _loc11_) {
					_loc23_ = mParents.indexOf(_loc3_);
					if (_loc23_ < 0 || _loc23_ >= _loc24_) {
						mPoint.x = stageX;
						mPoint.y = stageY;
						_loc8_ = _loc3_.globalToLocal(mPoint);
						_loc23_ = _loc24_++;
						mParents[_loc23_] = _loc3_;
						mParentX[_loc23_] = _loc8_.x;
						mParentY[_loc23_] = _loc8_.y;
						mParentOpen[_loc23_] = isOpenToMouse(_loc3_);
					}
					_loc31_ = mParentOpen[_loc23_];
					_loc5_ = mParentX[_loc23_];
					_loc6_ = mParentY[_loc23_];
					_loc11_ = _loc3_;
				}
				if (_loc31_) {
					_loc9_ = _loc10_.fixedMouseHitRect;
					if (_loc9_ == null) {
						if (!_loc10_.mousePickable || !_loc14_.visible || _loc14_.stage == null) {
							_loc21_++;
							continue;
						}
						_loc9_ = _loc10_.mouseHitRect;
						if (_loc9_ == null) {
							_loc21_++;
							continue;
						}
					}
					_loc17_ = _loc14_.scaleX;
					_loc18_ = _loc14_.scaleY;
					_loc28_ = _loc14_.x + _loc9_.x * _loc17_ - _loc5_;
					_loc29_ = _loc28_ + _loc9_.width * _loc17_;
					_loc15_ = _loc14_.y + _loc9_.y * _loc18_ - _loc6_;
					_loc16_ = _loc15_ + _loc9_.height * _loc18_;
					_loc26_ = _loc28_ < _loc29_ ? _loc28_ : _loc29_;
					_loc22_ = _loc28_ < _loc29_ ? _loc29_ : _loc28_;
					_loc12_ = _loc15_ < _loc16_ ? _loc15_ : _loc16_;
					_loc19_ = _loc15_ < _loc16_ ? _loc16_ : _loc15_;
					if (!(_loc26_ > 0 || _loc22_ < 0 || _loc12_ > 0 || _loc19_ < 0)) {
						if (!(!_loc10_.mousePickable || !_loc14_.visible || _loc14_.stage == null)) {
							_loc4_ = mHandlers[_loc21_];
							_loc25_ = _loc20_ * 4;
							mRects[_loc25_] = _loc26_;
							mRects[_loc25_ + 1] = _loc12_;
							mRects[_loc25_ + 2] = _loc22_;
							mRects[_loc25_ + 3] = _loc19_;
							mCandidates[_loc20_] = _loc4_;
							if (_loc4_ == mHovered) {
								_loc27_ = _loc20_;
							}
							_loc20_++;
						}
					}
				}
			}
			_loc21_++;
		}
		var _loc7_ = ActorMousePick.nearest(0, 0, mRects, _loc20_, _loc27_);
		var _loc13_ = _loc7_ >= 0 ? mCandidates[_loc7_] : null;
		_loc21_ = 0;
		while (_loc21_ < _loc20_) {
			mCandidates[_loc21_] = null;
			_loc21_++;
		}
		_loc21_ = 0;
		while (_loc21_ < _loc24_) {
			mParents[_loc21_] = null;
			_loc21_++;
		}
		return _loc13_;
	}

	public function census():ASObject {
		var _loc5_ = 0;
		var _loc2_ = 0;
		var _loc4_ = 0;
		var _loc3_ = 0;
		var _loc6_ = 0;
		var _loc1_:ActorView;
		final __ax4_iter_11 = mViews;
		if (checkNullIteratee(__ax4_iter_11))
			for (_tmp_ in __ax4_iter_11) {
				_loc1_ = _tmp_;
				if (_loc1_.root == null || _loc1_.root.parent == null) {
					_loc5_++;
				} else {
					if (_loc1_.root.stage != null) {
						_loc6_++;
					}
					if (_loc1_.fixedMouseHitRect != null) {
						_loc2_++;
					} else if (_loc1_.mouseHitRect != null) {
						_loc4_++;
					} else {
						_loc3_++;
					}
				}
			}
		return {
			"handlers": mViews.length,
			"offList": _loc5_,
			"onStage": _loc6_,
			"fixed": _loc2_,
			"bodyFallback": _loc4_,
			"noRect": _loc3_
		};
	}

	function setHovered(handler:MouseEventHandler) {
		if (handler == mHovered) {
			return;
		}
		var _loc2_ = mHovered;
		mHovered = handler;
		if (_loc2_ != null) {
			note("out", _loc2_);
			_loc2_.onMouseOut(null);
		}
		if (handler != null) {
			note("over", handler);
			handler.onMouseOver(null);
		}
	}

	function note(kind:String, handler:MouseEventHandler) {
		if (mHistory == null) {
			return;
		}
		mHistory.push({
			"kind": kind,
			"id": handler.actorId,
			"ms": flash.Lib.getTimer(),
			"x": mStage.mouseX,
			"y": mStage.mouseY
		});
		if (mHistory.length > 64) {
			mHistory.shift();
		}
	}

	public function takeHistory(clear:Bool):Array<ASAny> {
		if (mHistory == null) {
			mHistory = [];
		}
		var _loc2_ = mHistory.copy();
		if (clear) {
			mHistory.resize(0);
		}
		return _loc2_;
	}
}
