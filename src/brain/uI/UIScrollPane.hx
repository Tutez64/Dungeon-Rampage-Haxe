package brain.uI;

import brain.facade.Facade;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Point;
import flash.geom.Rectangle;

class UIScrollPane extends UIObject {
	var mSlider:UISlider;

	var mMouseWheelDeltaMultiplier:Float = Math.NaN;

	var mMouseFlickDeltaMultiplier:Float = Math.NaN;

	var mParentContainer:MovieClip;

	var mFlickMouseDown:Bool = false;

	var mFlickMousePoint:Point;

	public function new(facade:Facade, root:MovieClip, tooltipDrawLayer:Int = 0) {
		super(facade, root, tooltipDrawLayer);
		var _loc4_ = new Rectangle(0, 0, root.width, root.height);
		root.scrollRect = _loc4_;
		mFlickMousePoint = new Point();
	}

	public function scrollTo(sx:Float, sy:Float) {
		var _loc3_ = root.scrollRect;
		_loc3_.x = sx;
		_loc3_.y = sy;
		root.scrollRect = _loc3_;
	}

	public function scrollBy(sx:Float, sy:Float) {
		var _loc3_ = root.scrollRect;
		_loc3_.x += sx;
		_loc3_.y += sy;
		root.scrollRect = _loc3_;
	}

	public function scrollByX(value:Float) {
		this.scrollBy(value, 0);
	}

	public function scrollByY(value:Float) {
		this.scrollBy(0, value);
	}

	public function scrollToX(value:Float) {
		this.scrollTo(value, root.scrollRect.y);
	}

	public function scrollToY(value:Float) {
		this.scrollTo(root.scrollRect.x, value);
	}

	public function addMouseWheelFunctionality(slider:UISlider, deltaMultiplier:Float = 20, parentContainer:MovieClip = null) {
		mParentContainer = parentContainer;
		mSlider = slider;
		mMouseWheelDeltaMultiplier = deltaMultiplier;
		if (parentContainer == null) {
			mRoot.addEventListener("mouseWheel", onMouseWheel);
		} else {
			mParentContainer.addEventListener("mouseWheel", onMouseWheel);
		}
	}

	public function onMouseWheel(mEvt:MouseEvent) {
		mSlider.valueWithCallback = mSlider.value - mEvt.delta * mMouseWheelDeltaMultiplier;
	}

	public function addMouseFlickFunctionality(slider:UISlider, deltaMultiplier:Float = 20, parentContainer:MovieClip = null) {
		mParentContainer = parentContainer;
		mSlider = slider;
		mMouseFlickDeltaMultiplier = deltaMultiplier;
		if (parentContainer == null) {
			mRoot.addEventListener("mouseDown", onMouseDown);
			mRoot.addEventListener("mouseMove", onMouseMove);
			mRoot.addEventListener("mouseUp", onMouseUp);
		} else {
			mParentContainer.addEventListener("mouseDown", onMouseDown);
			mParentContainer.addEventListener("mouseMove", onMouseMove);
			mParentContainer.addEventListener("mouseUp", onMouseUp);
		}
		mFacade.stageRef.addEventListener("mouseUp", onMouseUp);
	}

	public function onMouseDown(mEvt:MouseEvent) {
		mFlickMousePoint.x = mEvt.stageX;
		mFlickMousePoint.y = mEvt.stageY;
		mFlickMouseDown = true;
	}

	public function onMouseMove(mEvt:MouseEvent) {
		var _loc2_ = Math.NaN;
		if (mFlickMouseDown && mSlider != null) {
			_loc2_ = 0;
			if (mSlider.orientation == 0) {
				_loc2_ = mEvt.stageX - mFlickMousePoint.x;
			} else if (mSlider.orientation == 1) {
				_loc2_ = mEvt.stageY - mFlickMousePoint.y;
			}
			mSlider.valueWithCallback = mSlider.value - _loc2_ * mMouseFlickDeltaMultiplier;
			mFlickMousePoint.x = mEvt.stageX;
			mFlickMousePoint.y = mEvt.stageY;
		}
	}

	public function onMouseUp(mEvt:MouseEvent) {
		mFlickMouseDown = false;
	}

	override public function destroy() {
		if (mSlider != null) {
			if (mParentContainer == null) {
				mRoot.removeEventListener("mouseWheel", onMouseWheel);
				mRoot.removeEventListener("mouseDown", onMouseDown);
				mRoot.removeEventListener("mouseMove", onMouseMove);
				mRoot.removeEventListener("mouseUp", onMouseUp);
			} else {
				mParentContainer.removeEventListener("mouseWheel", onMouseWheel);
				mParentContainer.removeEventListener("mouseDown", onMouseDown);
				mParentContainer.removeEventListener("mouseMove", onMouseMove);
				mParentContainer.removeEventListener("mouseUp", onMouseUp);
			}
			mFacade.stageRef.removeEventListener("mouseUp", onMouseUp);
		}
		mSlider = null;
		mParentContainer = null;
		super.destroy();
	}
}
