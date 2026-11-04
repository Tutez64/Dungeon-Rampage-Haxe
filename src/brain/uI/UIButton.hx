package brain.uI;

import brain.clock.GameClock;
import brain.event.EventListeners;
import brain.facade.Facade;
import brain.render.MovieClipRenderController;
import flash.display.Bitmap;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.filters.GlowFilter;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.text.TextField;

class UIButton extends UIObject {
	static inline final UP = (0 : UInt);

	static inline final DOWN = (1 : UInt);

	static inline final OVER = (2 : UInt);

	static inline final DISABLED = (3 : UInt);

	static inline final SELECTED = (4 : UInt);

	var mUpState:MovieClip;

	var mDownState:MovieClip;

	var mOverState:MovieClip;

	var mDisabledState:MovieClip;

	var mUpRenderer:MovieClipRenderController;

	var mDownRenderer:MovieClipRenderController;

	var mOverRenderer:MovieClipRenderController;

	var mDisabledRenderer:MovieClipRenderController;

	var mSelected:Bool = false;

	var mSelectedState:MovieClip;

	var mSelectedRenderer:MovieClipRenderController;

	var mHitArea:MovieClip;

	var mLabel:TextField;

	var mDraggable:Bool = false;

	var mDragged:Bool = false;

	var mDragStartParent:DisplayObjectContainer;

	var mDragStartPos:Point;

	var mStates:Array<ASAny>;

	var mRenderers:Array<ASAny>;

	var mRolloverFilter:GlowFilter;

	var mSelectedFilter:GlowFilter;

	var mFiltersBeforeRollover:Array<ASAny>;

	var mFiltersCaptured:Bool = false;

	var mMouseDown:Bool = false;

	var mPressCallback:ASFunction;

	var mReleaseCallback:ASFunction;

	var mDragReleaseCallback:ASFunction;

	var mEnterCallback:ASFunction;

	var mPressRollOutCallback:ASFunction;

	var mRollOverCallback:ASFunction;

	var mRollOutCallback:ASFunction;

	var mRollOverCursor:String = "POINT";

	var mRollOverCursorKey:UInt = 0;

	var mDragBounds:Rectangle;

	var mDisableEventPropogation:Bool = false;

	public function new(facade:Facade, root:MovieClip, tooltipDrawLayer:Int = 0, disableEventPropogation:Bool = true) {
		if ((root : ASAny).hasOwnProperty("theButton")) {
			root = ASCompat.coerce((root : ASAny).theButton, flash.display.MovieClip);
		}
		if ((root : ASAny).hasOwnProperty("up")) {
			mUpState = ASCompat.coerce((root : ASAny).up, flash.display.MovieClip);
			mUpState.mouseChildren = false;
			mUpRenderer = new MovieClipRenderController(facade, mUpState);
		}
		if ((root : ASAny).hasOwnProperty("down")) {
			mDownState = ASCompat.coerce((root : ASAny).down, flash.display.MovieClip);
			mDownState.mouseChildren = false;
			mDownRenderer = new MovieClipRenderController(facade, mDownState);
		} else {
			mDownState = mUpState;
			mDownRenderer = mUpRenderer;
		}
		if ((root : ASAny).hasOwnProperty("over")) {
			mOverState = ASCompat.coerce((root : ASAny).over, flash.display.MovieClip);
			mOverState.mouseChildren = false;
			mOverRenderer = new MovieClipRenderController(facade, mOverState);
		} else {
			mOverState = mUpState;
			mOverRenderer = mUpRenderer;
		}
		if ((root : ASAny).hasOwnProperty("disabled")) {
			mDisabledState = ASCompat.coerce((root : ASAny).disabled, flash.display.MovieClip);
			mDisabledState.mouseChildren = false;
			mDisabledRenderer = new MovieClipRenderController(facade, mDisabledState);
		} else {
			mDisabledState = mUpState;
			mDisabledRenderer = mUpRenderer;
		}
		if ((root : ASAny).hasOwnProperty("selected")) {
			mSelectedState = ASCompat.coerce((root : ASAny).selected, flash.display.MovieClip);
			mSelectedState.mouseChildren = false;
			mSelectedRenderer = new MovieClipRenderController(facade, mSelectedState);
		} else {
			mSelectedState = mUpState;
			mSelectedRenderer = mUpRenderer;
		}
		mStates = [mUpState, mDownState, mOverState, mDisabledState, mSelectedState];
		mRenderers = [mUpRenderer, mDownRenderer, mOverRenderer, mDisabledRenderer, mSelectedRenderer];
		if ((root : ASAny).hasOwnProperty("hit")) {
			mHitArea = ASCompat.coerce((root : ASAny).hit, flash.display.MovieClip);
			mHitArea.visible = false;
			mHitArea.mouseEnabled = false;
			root.hitArea = mHitArea;
		}
		if ((root : ASAny).hasOwnProperty("label")) {
			mLabel = ASCompat.coerce((root : ASAny).label, flash.text.TextField);
			mLabel.mouseEnabled = false;
		}
		super(facade, root, tooltipDrawLayer);
		mFiltersBeforeRollover = [];
		mDisableEventPropogation = disableEventPropogation;
	}

	public function allowEventPropogation() {
		mDisableEventPropogation = false;
	}

	@:isVar public var label(get, set):TextField;

	public function get_label():TextField {
		return mLabel;
	}

	function set_label(value:TextField):TextField {
		mLabel = value;
		mLabel.mouseEnabled = false;
		return value;
	}

	public function flattenLabelToBitmap() {
		var _loc1_ = new BitmapData(ASCompat.floatToInt(mLabel.width), ASCompat.floatToInt(mLabel.height), true, (0 : UInt));
		_loc1_.draw(mLabel);
		var _loc2_ = new Bitmap(_loc1_, "auto", true);
		_loc2_.transform.matrix = mLabel.transform.matrix;
		mLabel.parent.addChild(_loc2_);
		mLabel.parent.removeChild(mLabel);
		mLabel = null;
	}

	@:isVar public var selected(get, set):Bool;

	public function get_selected():Bool {
		return mSelected;
	}

	function set_selected(value:Bool):Bool {
		mSelected = value;
		if (mSelectedFilter != null) {
			mSelectedState.filters = cast(value ? [mSelectedFilter] : []);
		}
		refreshVisualState();
		return value;
	}

	@:isVar public var rolloverFilter(get, set):GlowFilter;

	public function set_rolloverFilter(value:GlowFilter):GlowFilter {
		return mRolloverFilter = value;
	}

	function get_rolloverFilter():GlowFilter {
		return mRolloverFilter;
	}

	@:isVar public var selectedFilter(get, set):GlowFilter;

	public function set_selectedFilter(value:GlowFilter):GlowFilter {
		return mSelectedFilter = value;
	}

	function get_selectedFilter():GlowFilter {
		return mSelectedFilter;
	}

	@:isVar public var pressCallback(never, set):ASFunction;

	public function set_pressCallback(value:ASFunction):ASFunction {
		return mPressCallback = value;
	}

	@:isVar public var pressCallbackThis(never, set):ASFunction;

	public function set_pressCallbackThis(value:ASFunction):ASFunction {
		var _this = this;
		mPressCallback = function() {
			value(_this);
		};
		return value;
	}

	@:isVar public var releaseCallback(get, set):ASFunction;

	public function set_releaseCallback(value:ASFunction):ASFunction {
		return mReleaseCallback = value;
	}

	@:isVar public var releaseCallbackThis(never, set):ASFunction;

	public function set_releaseCallbackThis(value:ASFunction):ASFunction {
		var _this = this;
		mReleaseCallback = function() {
			value(_this);
		};
		return value;
	}

	function get_releaseCallback():ASFunction {
		return mReleaseCallback;
	}

	@:isVar public var dragReleaseCallback(get, set):ASFunction;

	public function set_dragReleaseCallback(value:ASFunction):ASFunction {
		return mDragReleaseCallback = value;
	}

	function get_dragReleaseCallback():ASFunction {
		return mDragReleaseCallback;
	}

	@:isVar public var enterCallback(never, set):ASFunction;

	public function set_enterCallback(value:ASFunction):ASFunction {
		return mEnterCallback = value;
	}

	@:isVar public var pressRollOutCallback(never, set):ASFunction;

	public function set_pressRollOutCallback(value:ASFunction):ASFunction {
		return mPressRollOutCallback = value;
	}

	@:isVar public var rollOverCallback(never, set):ASFunction;

	public function set_rollOverCallback(value:ASFunction):ASFunction {
		return mRollOverCallback = value;
	}

	@:isVar public var rollOutCallback(never, set):ASFunction;

	public function set_rollOutCallback(value:ASFunction):ASFunction {
		return mRollOutCallback = value;
	}

	@:isVar public var draggable(get, set):Bool;

	public function get_draggable():Bool {
		return mDraggable;
	}

	function set_draggable(value:Bool):Bool {
		return mDraggable = value;
	}

	@:isVar public var rollOverCursor(never, set):String;

	public function set_rollOverCursor(name:String):String {
		return mRollOverCursor = name;
	}

	public function click() {
		onRelease(new MouseEvent("click"));
	}

	override function addListeners() {
		super.addListeners();
		EventListeners.add(mRoot, "mouseDown", onPress);
		EventListeners.add(mRoot, "keyDown", onKey);
	}

	function popRollOverMouseCursor() {
		if (ASCompat.stringAsBool(mRollOverCursor) && mRollOverCursorKey > 0) {
			mFacade.mouseCursorManager.popMouseCursor(mRollOverCursorKey);
			mRollOverCursorKey = (0 : UInt);
		}
	}

	function applyRolloverFilter() {
		if (mRolloverFilter == null || mFiltersCaptured || mRoot == null) {
			return;
		}
		mFiltersBeforeRollover = mRoot.filters.slice(0);
		mFiltersCaptured = true;
		mRoot.filters = cast([mRolloverFilter]);
	}

	function restoreFiltersBeforeRollover() {
		if (!mFiltersCaptured) {
			return;
		}
		if (mRoot != null) {
			mRoot.filters = cast(mFiltersBeforeRollover);
		}
		mFiltersBeforeRollover = null;
		mFiltersCaptured = false;
	}

	function refreshVisualState() {
		if (mRoot == null) {
			return;
		}
		if (!mEnabled) {
			showState((3 : UInt));
			return;
		}
		if (mMouseDown && mIsHovered) {
			showState(downState);
			return;
		}
		if (isHighlighted) {
			showState(overState);
		} else {
			showState(upState);
		}
	}

	override function removeListeners() {
		super.removeListeners();
		EventListeners.remove(mRoot, "mouseDown", onPress);
		EventListeners.remove(mRoot, "keyDown", onKey);
		EventListeners.remove(mRoot, "mouseUp", onMouseUp);
		EventListeners.remove(mFacade.stageRef, "mouseUp", onMouseUp);
		EventListeners.remove(mFacade.stageRef, "mouseLeave", onStageMouseLeave);
	}

	override public function set_enabled(value:Bool):Bool {
		super.enabled = value;
		mRoot.buttonMode = mEnabled;
		mRoot.tabEnabled = false;
		mMouseDown = false;
		if (!value) {
			restoreFiltersBeforeRollover();
			popRollOverMouseCursor();
		}
		refreshVisualState();
		return value;
	}

	override public function destroy() {
		popRollOverMouseCursor();
		mFiltersBeforeRollover = null;
		mFiltersCaptured = false;
		mStates = null;
		var _loc1_:MovieClipRenderController;
		final __ax4_iter_157 = mRenderers;
		if (checkNullIteratee(__ax4_iter_157))
			for (_tmp_ in __ax4_iter_157) {
				_loc1_ = ASCompat.coerce(_tmp_, brain.render.MovieClipRenderController);
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
		mRenderers = null;
		mPressCallback = null;
		mReleaseCallback = null;
		mLabel = null;
		mDisabledRenderer = null;
		mDisabledState = null;
		mDownRenderer = null;
		mDownState = null;
		mUpRenderer = null;
		mUpState = null;
		mOverRenderer = null;
		mOverState = null;
		mSelectedRenderer = null;
		mSelectedState = null;
		super.destroy();
	}

	function showState(i:UInt) {
		var _loc3_:MovieClip;
		final __ax4_iter_158 = mStates;
		if (checkNullIteratee(__ax4_iter_158))
			for (_tmp_ in __ax4_iter_158) {
				_loc3_ = ASCompat.coerce(_tmp_, flash.display.MovieClip);
				if (_loc3_ != null) {
					_loc3_.visible = false;
				}
			}
		var _loc2_:MovieClipRenderController;
		final __ax4_iter_159 = mRenderers;
		if (checkNullIteratee(__ax4_iter_159))
			for (_tmp_ in __ax4_iter_159) {
				_loc2_ = ASCompat.coerce(_tmp_, brain.render.MovieClipRenderController);
				if (_loc2_ != null) {
					_loc2_.stop();
				}
			}
		if (mStates != null && ASCompat.toBool(mStates[(i : Int)])) {
			ASCompat.setProperty(mStates[(i : Int)], "visible", true);
		}
		if (mRenderers != null && ASCompat.toBool(mRenderers[(i : Int)])) {
			mRenderers[(i : Int)].play(0, true);
		}
	}

	function onKey(event:KeyboardEvent) {
		event.stopImmediatePropagation();
		if (event.keyCode == 13) {
			if (mEnterCallback != null) {
				mEnterCallback();
			}
		}
	}

	override function onFocused() {
		super.onFocused();
		refreshVisualState();
	}

	override function onUnfocused() {
		super.onUnfocused();
		refreshVisualState();
	}

	function onPress(event:MouseEvent) {
		if (mDisableEventPropogation) {
			event.stopImmediatePropagation();
		}
		EventListeners.add(mRoot, "mouseUp", onMouseUp);
		EventListeners.add(mFacade.stageRef, "mouseUp", onMouseUp);
		EventListeners.add(mFacade.stageRef, "mouseLeave", onStageMouseLeave);
		if (mDraggable) {
			EventListeners.add(mFacade.stageRef, "mouseMove", onMouseMove);
		}
		mMouseDown = true;
		if (!mIsHovered) {
			onMouseRollOver(event);
		}
		showState(downState);
		if (mDraggable) {
			mDragged = false;
		}
		if (mPressCallback != null) {
			mPressCallback();
		}
	}

	function onMouseMove(event:MouseEvent) {
		if (mDraggable) {
			EventListeners.remove(mFacade.stageRef, "mouseMove", onMouseMove);
			startDrag();
		}
	}

	override function showTooltip(gameClock:GameClock = null) {
		if (mDragged) {
			return;
		}
		super.showTooltip(gameClock);
	}

	function startDrag() {
		this.hideTooltip();
		mDragged = true;
		mDragStartPos = new Point(mRoot.x, mRoot.y);
		mDragStartParent = mRoot.parent;
		var _loc1_ = mFacade.designLocalToGlobal(mRoot, new Point(0, 0));
		mFacade.sceneGraphManager.addChild(mRoot, 75);
		mRoot.x = _loc1_.x;
		mRoot.y = _loc1_.y;
		mRoot.startDrag(false, mDragBounds);
	}

	@:isVar public var dragBounds(never, set):Rectangle;

	public function set_dragBounds(value:Rectangle):Rectangle {
		return mDragBounds = value;
	}

	function onMouseUp(event:MouseEvent) {
		var _loc2_ = false;
		var _loc4_:DisplayObject = null;
		var _loc5_:MovieClip = null;
		var _loc3_:DisplayObject = null;
		if (mDisableEventPropogation) {
			event.stopImmediatePropagation();
		}
		if (mRoot == null) {
			return;
		}
		if (mDraggable) {
			EventListeners.remove(mFacade.stageRef, "mouseMove", onMouseMove);
		}
		EventListeners.remove(mRoot, "mouseUp", onMouseUp);
		EventListeners.remove(mFacade.stageRef, "mouseUp", onMouseUp);
		EventListeners.remove(mFacade.stageRef, "mouseLeave", onStageMouseLeave);
		if (!mEnabled || !mMouseDown) {
			return;
		}
		if (mDraggable && mDragged) {
			mDragged = false;
			_loc2_ = false;
			this.stopDrag();
			_loc4_ = mRoot.dropTarget;
			while (_loc4_ != null) {
				_loc5_ = ASCompat.reinterpretAs(_loc4_, MovieClip);
				if (_loc5_ != null) {
					if (!_loc5_.mouseEnabled) {
						_loc4_.visible = false;
						mRoot.startDrag(true);
						mRoot.stopDrag();
						_loc4_.visible = true;
						_loc4_ = mRoot.dropTarget;
						continue;
					}
					if ((_loc5_ : ASAny).hasOwnProperty("UIObject")) {
						if (cast((_loc5_ : ASAny).UIObject, UIObject).handleDrop(this)) {
							_loc2_ = true;
							break;
						}
					}
				}
				_loc4_ = _loc4_.parent;
			}
			if (!_loc2_) {
				resetDrag();
			}
			onDragRelease(event);
		} else {
			_loc3_ = ASCompat.dynamicAs(event.target, DisplayObject);
			while (_loc3_ != null) {
				if (_loc3_ == mRoot) {
					onRelease(event);
					return;
				}
				_loc3_ = _loc3_.parent;
			}
			onReleaseOutside(event);
		}
	}

	function stopDrag() {
		mRoot.stopDrag();
	}

	function resetDrag() {
		mDragStartParent.addChild(mRoot);
		this.bringToFront();
		mRoot.x = mDragStartPos.x;
		mRoot.y = mDragStartPos.y;
		mDragStartParent = null;
		mDragStartPos = null;
	}

	function onReleaseOutside(event:MouseEvent) {
		mMouseDown = false;
	}

	function onRelease(event:MouseEvent) {
		mMouseDown = false;
		refreshVisualState();
		if (mReleaseCallback != null) {
			mReleaseCallback();
		}
	}

	function onDragRelease(event:MouseEvent) {
		if (mRoot == null) {
			return;
		}
		mMouseDown = false;
		refreshVisualState();
		if (mDragReleaseCallback != null) {
			mDragReleaseCallback();
		}
	}

	override function onRollOver(event:MouseEvent) {
		super.onRollOver(event);
		refreshVisualState();
		applyRolloverFilter();
	}

	@:isVar var downState(get, never):UInt;

	function get_downState():UInt {
		return (mSelected ? (4 : UInt) : (1 : UInt) : UInt);
	}

	@:isVar var upState(get, never):UInt;

	function get_upState():UInt {
		return (mSelected ? (4 : UInt) : (0 : UInt) : UInt);
	}

	@:isVar var overState(get, never):UInt;

	function get_overState():UInt {
		return (mSelected ? (4 : UInt) : (2 : UInt) : UInt);
	}

	override function onRollOut(event:MouseEvent) {
		super.onRollOut(event);
		refreshVisualState();
		restoreFiltersBeforeRollover();
	}

	override function onMouseRollOver(event:MouseEvent) {
		var _loc2_ = mIsHovered;
		super.onMouseRollOver(event);
		refreshVisualState();
		if (_loc2_) {
			return;
		}
		if (ASCompat.stringAsBool(mRollOverCursor)) {
			popRollOverMouseCursor();
			mRollOverCursorKey = mFacade.mouseCursorManager.pushMouseCursor(mRollOverCursor, true);
		}
		if (mRollOverCallback != null) {
			mRollOverCallback();
		}
	}

	override function onMouseRollOut(event:MouseEvent) {
		var _loc2_ = mIsHovered;
		if (mIsHovered && mMouseDown && mPressRollOutCallback != null) {
			mPressRollOutCallback();
		}
		super.onMouseRollOut(event);
		refreshVisualState();
		if (!_loc2_) {
			return;
		}
		popRollOverMouseCursor();
		if (mRollOutCallback != null) {
			mRollOutCallback();
		}
	}

	function onStageMouseLeave(event:Event) {
		hideTooltip();
		EventListeners.remove(mRoot, "mouseUp", onMouseUp);
		EventListeners.remove(mFacade.stageRef, "mouseUp", onMouseUp);
		EventListeners.remove(mFacade.stageRef, "mouseLeave", onStageMouseLeave);
		onMouseRollOut(null);
		refreshVisualState();
	}

	override public function onSelected(fromController:Bool = false) {
		if (mReleaseCallback != null) {
			mReleaseCallback();
		}
	}
}
