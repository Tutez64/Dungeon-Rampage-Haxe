package uI.hud.starlingConverted;

import facade.DBFacade;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Matrix;

class StarlingInput {
	static var sTypes:Vector<String>;

	var mFacade:DBFacade;

	var mWidgets:Vector<StarlingButton> = new Vector((0 : UInt));

	var mCursors:Vector<Bool> = new Vector((0 : UInt));

	var mHoverOnly:Vector<Bool> = new Vector((0 : UInt));

	var mGroups:Vector<DisplayObjectContainer>;

	var mInverse:Matrix = new Matrix();

	var mHover:StarlingButton;

	var mPress:StarlingButton;

	var mAttached:Bool = false;

	var mLeft:Bool = false;

	var mGamePress:Bool = false;

	var mRight:Bool = false;

	var mMiddle:Bool = false;

	var mClick:Bool = false;

	var mRightClick:Bool = false;

	var mMiddleClick:Bool = false;

	var mCursorKey:UInt = 0;

	var mPointCursor:Bool = false;

	public var onError:ASFunction;

	public var boundsChanged:ASFunction;

	public function new(facade:DBFacade) {
		if (sTypes == null) {
			sTypes = Vector.ofArray([
				"mouseMove",
				"mouseDown",
				"mouseUp",
				"click",
				"rightMouseDown",
				"rightMouseUp",
				"rightClick",
				"middleMouseDown",
				"middleMouseUp",
				"middleClick"
			]);
		}
		mFacade = facade;
		mGroups = Vector.ofArray(([facade.sceneGraphManager.UILayerGroup] : Array<DisplayObjectContainer>));
		var _loc2_ = mGroups[0].parent != null ? ASCompat.reinterpretAs(mGroups[0].parent.getChildByName("SceneGraphManager.UILayerGroupT"),
			DisplayObjectContainer) : null;
		if (_loc2_ != null) {
			mGroups.push(_loc2_);
		}
	}

	public function add(widget:StarlingButton, pointCursor:Bool = true, hoverOnly:Bool = false) {
		mWidgets.push(widget);
		mCursors.push(pointCursor);
		mHoverOnly.push(hoverOnly);
	}

	public function remove(widget:StarlingButton) {
		var _loc2_ = mWidgets.indexOf(widget);
		if (_loc2_ < 0) {
			return;
		}
		if (mHover == widget) {
			setHover(null, false);
		}
		if (mPress == widget) {
			if (widget.pressHandedToGame) {
				mGamePress = true;
			}
			mPress = null;
		}
		mWidgets.removeAt(_loc2_);
		mCursors.removeAt(_loc2_);
		mHoverOnly.removeAt(_loc2_);
	}

	public function attach() {
		var _loc1_:String = null;
		if (mAttached) {
			return;
		}
		mAttached = true;
		final __ax4_iter_189 = sTypes;
		if (checkNullIteratee(__ax4_iter_189))
			for (_tmp_ in __ax4_iter_189) {
				_loc1_ = _tmp_;
				mFacade.stageRef.addEventListener(_loc1_, capture, true, 1000);
				mFacade.stageRef.addEventListener(_loc1_, target, false, 1000);
			}
		mFacade.stageRef.addEventListener("mouseLeave", leave, false, 1000);
	}

	function capture(event:MouseEvent) {
		if (event.eventPhase == 1) {
			routeSafely(event);
		}
	}

	function target(event:MouseEvent) {
		if (event.eventPhase == 2) {
			routeSafely(event);
		}
	}

	function routeSafely(event:MouseEvent) {
		try {
			route(event);
		} catch (error:Dynamic) {
			if (onError != null) {
				onError(error);
			}
		}
	}

	function overFlash(target:DisplayObject):Bool {
		var _loc2_:DisplayObjectContainer = null;
		final __ax4_iter_190 = mGroups;
		if (checkNullIteratee(__ax4_iter_190))
			for (_tmp_ in __ax4_iter_190) {
				_loc2_ = _tmp_;
				if (target != null && _loc2_.contains(target)) {
					return true;
				}
			}
		return false;
	}

	function route(event:MouseEvent) {
		var _loc2_:StarlingButton = null;
		var _loc6_ = 0;
		var _loc4_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc3_:StarlingButton = null;
		HudTransform.inverse(mFacade, mInverse);
		if (overFlash(ASCompat.dynamicAs(event.target, DisplayObject))) {
			leave();
			return;
		}
		var _loc5_ = -1;
		if (mFacade.stageRef.mouseChildren) {
			_loc4_ = mInverse.a * event.stageX + mInverse.c * event.stageY + mInverse.tx;
			_loc7_ = mInverse.b * event.stageX + mInverse.d * event.stageY + mInverse.ty;
			_loc6_ = mWidgets.length - 1;
			while (_loc6_ >= 0) {
				if (mWidgets[_loc6_].hitTest(_loc4_, _loc7_)) {
					_loc5_ = _loc6_;
					break;
				}
				_loc6_--;
			}
		}
		_loc2_ = _loc5_ >= 0 ? mWidgets[_loc5_] : null;
		setHover(_loc2_, _loc5_ >= 0 && mCursors[_loc5_]);
		if (_loc5_ >= 0 && mHoverOnly[_loc5_]) {
			_loc2_ = null;
		}
		switch (event.type) {
			case "mouseDown":
				mClick = false;
				mGamePress = false;
				if (_loc2_ != null) {
					event.stopImmediatePropagation();
					mLeft = true;
					mPress = _loc2_;
					_loc2_.onMouseDown();
					if (boundsChanged != null) {
						boundsChanged();
					}
				}

			case "mouseUp":
				if (mLeft) {
					if (!mGamePress) {
						event.stopImmediatePropagation();
					}
					mLeft = false;
					mClick = true;
					_loc3_ = mPress;
					mPress = null;
					if (_loc3_ != null) {
						_loc3_.onMouseUp(_loc3_ == _loc2_);
					}
					mGamePress = false;
					if (boundsChanged != null) {
						boundsChanged();
					}
				}

			case "click":
				if (mClick || _loc2_ != null) {
					event.stopImmediatePropagation();
				}
				mClick = false;

			case "rightMouseDown":
				mRightClick = false;
				if (_loc2_ != null) {
					mRight = true;
					event.stopImmediatePropagation();
				}

			case "rightMouseUp":
				if (mRight) {
					mRight = false;
					mRightClick = true;
					event.stopImmediatePropagation();
				}

			case "rightClick":
				if (mRightClick || _loc2_ != null) {
					event.stopImmediatePropagation();
				}
				mRightClick = false;

			case "middleMouseDown":
				mMiddleClick = false;
				if (_loc2_ != null) {
					mMiddle = true;
					event.stopImmediatePropagation();
				}

			case "middleMouseUp":
				if (mMiddle) {
					mMiddle = false;
					mMiddleClick = true;
					event.stopImmediatePropagation();
				}

			case "middleClick":
				if (mMiddleClick || _loc2_ != null) {
					event.stopImmediatePropagation();
				}
				mMiddleClick = false;
		}
	}

	function setHover(widget:StarlingButton, pointCursor:Bool) {
		if (widget != mHover) {
			if (mHover != null) {
				mHover.onRollOut();
			}
			if (mLeft && mPress != null && mPress.pressHandedToGame) {
				mGamePress = true;
			}
			mHover = widget;
			if (mHover != null) {
				mHover.onRollOver();
			}
			if (boundsChanged != null) {
				boundsChanged();
			}
		}
		if (pointCursor == mPointCursor) {
			return;
		}
		mPointCursor = pointCursor;
		if (pointCursor) {
			mCursorKey = mFacade.mouseCursorManager.pushMouseCursor("POINT", true);
		} else if (mCursorKey > 0) {
			mFacade.mouseCursorManager.popMouseCursor(mCursorKey);
			mCursorKey = (0 : UInt);
		}
	}

	function leave(event:Event = null) {
		try {
			setHover(null, false);
			if (mPress != null) {
				mPress.onMouseUp(false);
			}
			if (mGamePress) {
				mFacade.inputManager.onMouseUp(null);
			}
			mPress = null;
			mLeft = mRight = mMiddle = mClick = mRightClick = mMiddleClick = mGamePress = false;
		} catch (error:Dynamic) {
			if (onError != null) {
				onError(error);
			}
		}
	}

	public function detach() {
		var _loc1_:String = null;
		if (!mAttached) {
			return;
		}
		mAttached = false;
		leave();
		final __ax4_iter_191 = sTypes;
		if (checkNullIteratee(__ax4_iter_191))
			for (_tmp_ in __ax4_iter_191) {
				_loc1_ = _tmp_;
				mFacade.stageRef.removeEventListener(_loc1_, capture, true);
				mFacade.stageRef.removeEventListener(_loc1_, target, false);
			}
		mFacade.stageRef.removeEventListener("mouseLeave", leave);
	}

	public function dispose() {
		var _loc1_:StarlingButton = null;
		detach();
		final __ax4_iter_192 = mWidgets;
		if (checkNullIteratee(__ax4_iter_192))
			for (_tmp_ in __ax4_iter_192) {
				_loc1_ = _tmp_;
				try {
					_loc1_.dispose();
				} catch (error:Dynamic) {
					if (onError != null) {
						onError(error);
					}
				}
			}
		mWidgets.length = mCursors.length = mHoverOnly.length = 0;
		onError = null;
		boundsChanged = null;
		mFacade = null;
	}
}
