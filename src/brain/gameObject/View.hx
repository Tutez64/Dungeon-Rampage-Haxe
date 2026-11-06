package brain.gameObject;

import brain.clock.GameClock;
import brain.facade.Facade;
import brain.render.MovieClipRenderController;
import brain.sceneGraph.SceneGraphComponent;
import brain.utils.MemoryTracker;
import brain.workLoop.LogicalWorkComponent;
import brain.workLoop.Task;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.Sprite;
import flash.geom.Vector3D;

class View {
	static var sAllViews:Vector<View> = new Vector();

	var mFacade:Facade;

	var mRoot:Sprite;

	var mSceneGraphComponent:SceneGraphComponent;

	var mMovieClipRenderer:MovieClipRenderController;

	var mWorkComponent:LogicalWorkComponent;

	var mFadeResetTask:Task;

	var mFading:Bool = false;

	var mTickPosX:Float = Math.NaN;

	var mTickPosY:Float = Math.NaN;

	var mPrevPosX:Float = Math.NaN;

	var mPrevPosY:Float = Math.NaN;

	public function new(facade:Facade, category:String = "brain") {
		mFacade = facade;
		var _loc3_ = "View";
		mSceneGraphComponent = new SceneGraphComponent(mFacade, _loc3_, category);
		mWorkComponent = new LogicalWorkComponent(mFacade, _loc3_, category);
		mRoot = new Sprite();
		mFading = false;
		sAllViews.push(this);
		MemoryTracker.track(this, _loc3_ + " - created in View()", category);
	}

	static function recursiveFindChildrenOfClass(foundArray:Array<ASAny>, node:DisplayObject, classNames:Array<ASAny>) {
		var _loc5_ = 0;
		var _loc6_ = ASCompat.getQualifiedClassName(node);
		if (classNames.indexOf(_loc6_) != -1) {
			foundArray.push(node);
		}
		var _loc4_ = ASCompat.reinterpretAs(node, DisplayObjectContainer);
		if (_loc4_ != null) {
			_loc5_ = 0;
			while (_loc5_ < _loc4_.numChildren) {
				recursiveFindChildrenOfClass(foundArray, _loc4_.getChildAt(_loc5_), classNames);
				_loc5_++;
			}
		}
	}

	public static function findChildrenOfClass(searchNode:DisplayObjectContainer, classNames:Array<ASAny>):Array<ASAny> {
		var _loc3_:Array<ASAny> = [];
		recursiveFindChildrenOfClass(_loc3_, searchNode, classNames);
		return _loc3_;
	}

	public static function beginTickAll() {
		var _loc1_:View;
		final __ax4_iter_538 = sAllViews;
		if (checkNullIteratee(__ax4_iter_538))
			for (_tmp_ in __ax4_iter_538) {
				_loc1_ = _tmp_;
				_loc1_.beginTick();
			}
	}

	public static function renderInterpolatedAll(alpha:Float) {
		var _loc2_:View;
		final __ax4_iter_539 = sAllViews;
		if (checkNullIteratee(__ax4_iter_539))
			for (_tmp_ in __ax4_iter_539) {
				_loc2_ = _tmp_;
				_loc2_.renderInterpolated(alpha);
			}
	}

	public function init() {}

	public function unFade() {
		mRoot.alpha = 1;
		mFadeResetTask.destroy();
		mFadeResetTask = null;
		mFading = false;
	}

	public function updateFade(gameClock:GameClock) {
		var _loc2_ = Math.NaN;
		if (mFading) {
			mRoot.alpha *= 0.85;
			if (mRoot.alpha <= 0.3) {
				mFading = false;
				mRoot.alpha = 0.3;
			}
		} else {
			_loc2_ = 1 - mRoot.alpha;
			mRoot.alpha = 1 - _loc2_ * _loc2_;
			if (mRoot.alpha > 0.975) {
				unFade();
			}
		}
	}

	public function doFade() {
		mFading = true;
		if (mFadeResetTask == null) {
			mFadeResetTask = mWorkComponent.doEveryFrame(updateFade);
		}
	}

	@:isVar public var movieClipRenderer(get, never):MovieClipRenderController;

	public function get_movieClipRenderer():MovieClipRenderController {
		return mMovieClipRenderer;
	}

	@:isVar public var position(get, set):Vector3D;

	public function get_position():Vector3D {
		if (Math.isNaN(mTickPosX)) {
			return new Vector3D(mRoot.x, mRoot.y);
		}
		return new Vector3D(mTickPosX, mTickPosY);
	}

	@:isVar public var positionX(get, never):Float;

	public function get_positionX():Float {
		return Math.isNaN(mTickPosX) ? mRoot.x : mTickPosX;
	}

	@:isVar public var positionY(get, never):Float;

	public function get_positionY():Float {
		return Math.isNaN(mTickPosX) ? mRoot.y : mTickPosY;
	}

	function set_position(pos:Vector3D):Vector3D {
		if (Math.isNaN(mPrevPosX)) {
			mPrevPosX = pos.x;
			mPrevPosY = pos.y;
		}
		mTickPosX = pos.x;
		mTickPosY = pos.y;
		mRoot.x = pos.x;
		mRoot.y = pos.y;
		return pos;
	}

	public function snapPosition(pos:Vector3D) {
		mPrevPosX = pos.x;
		mPrevPosY = pos.y;
		mTickPosX = pos.x;
		mTickPosY = pos.y;
		mRoot.x = pos.x;
		mRoot.y = pos.y;
	}

	@:isVar public var rotation(get, set):Float;

	public function get_rotation():Float {
		return mRoot.rotation;
	}

	function set_rotation(rot:Float):Float {
		return mRoot.rotation = rot;
	}

	@:isVar public var rotationX(get, set):Float;

	public function get_rotationX():Float {
		return mRoot.rotationX;
	}

	function set_rotationX(rot:Float):Float {
		return mRoot.rotationX = rot;
	}

	@:isVar public var rotationY(get, set):Float;

	public function get_rotationY():Float {
		return mRoot.rotationY;
	}

	function set_rotationY(rot:Float):Float {
		return mRoot.rotationY = rot;
	}

	@:isVar public var rotationZ(get, set):Float;

	public function get_rotationZ():Float {
		return mRoot.rotationZ;
	}

	function set_rotationZ(rot:Float):Float {
		return mRoot.rotationZ = rot;
	}

	@:isVar public var root(get, never):Sprite;

	public function get_root():Sprite {
		return mRoot;
	}

	public function isViewObjectTweenDriven():Bool {
		return false;
	}

	public function beginTick() {
		mPrevPosX = mTickPosX;
		mPrevPosY = mTickPosY;
		if (!Math.isNaN(mTickPosX) && (mPrevPosX != mTickPosX || mPrevPosY != mTickPosY)) {
			mRoot.x = mTickPosX;
			mRoot.y = mTickPosY;
		}
		mPrevPosX = mTickPosX;
		mPrevPosY = mTickPosY;
	}

	public function renderInterpolated(alpha:Float) {
		if (Math.isNaN(mTickPosX)) {
			return;
		}
		if (isViewObjectTweenDriven()) {
			return;
		}
		if (mPrevPosX == mTickPosX && mPrevPosY == mTickPosY) {
			mRoot.x = mTickPosX;
			mRoot.y = mTickPosY;
			return;
		}
		mRoot.x = mPrevPosX + (mTickPosX - mPrevPosX) * alpha;
		mRoot.y = mPrevPosY + (mTickPosY - mPrevPosY) * alpha;
	}

	public function destroy() {
		var _loc1_ = sAllViews.indexOf(this);
		if (_loc1_ >= 0) {
			sAllViews.splice(_loc1_, (1 : UInt));
		}
		if (mSceneGraphComponent != null) {
			mSceneGraphComponent.destroy();
			mSceneGraphComponent = null;
		}
		if (mFadeResetTask != null) {
			mFadeResetTask.destroy();
			mFadeResetTask = null;
		}
		if (mWorkComponent != null) {
			mWorkComponent.destroy();
			mWorkComponent = null;
		}
		if (mRoot.parent != null) {
			mRoot.parent.removeChild(mRoot);
		}
		if (mMovieClipRenderer != null) {
			mMovieClipRenderer.destroy();
			mMovieClipRenderer = null;
		}
		mRoot = null;
		mFacade = null;
	}
}
