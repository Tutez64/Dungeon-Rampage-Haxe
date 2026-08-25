package brain.uI;

import brain.facade.Facade;
import flash.display.MovieClip;
import flash.events.MouseEvent;
import flash.geom.Rectangle;

class UISliderHandleButton extends UIButton {
	var mSliderWidth:Float = Math.NaN;

	var mSliderHeight:Float = Math.NaN;

	var mOrientation:UInt = 0;

	var mSlideCallback:ASFunction;

	public function new(facade:Facade, root:MovieClip, orientation:UInt, sliderWidth:Float, sliderHeight:Float) {
		super(facade, root);
		mOrientation = orientation;
		mSliderWidth = sliderWidth;
		mSliderHeight = sliderHeight;
	}

	override public function destroy() {
		mSlideCallback = null;
		super.destroy();
	}

	@:isVar public var slideCallback(never, set):ASFunction;

	public function set_slideCallback(value:ASFunction):ASFunction {
		return mSlideCallback = value;
	}

	override function onPress(event:MouseEvent) {
		super.onPress(event);
		if (mOrientation == 0) {
			mRoot.startDrag(false, new Rectangle(0, 0, mSliderWidth, 0));
		} else {
			mRoot.startDrag(false, new Rectangle(0, 0, 0, mSliderHeight));
		}
		mFacade.stageRef.addEventListener("mouseMove", onMouseMove);
	}

	override function onRelease(event:MouseEvent) {
		super.onRelease(event);
		mFacade.stageRef.removeEventListener("mouseMove", onMouseMove);
	}

	override function onMouseUp(event:MouseEvent) {
		super.onMouseUp(event);
		mRoot.stopDrag();
		mSlideCallback();
	}

	override function onMouseMove(event:MouseEvent) {
		if (mSlideCallback != null) {
			mSlideCallback();
		}
		super.onMouseMove(event);
	}
}
