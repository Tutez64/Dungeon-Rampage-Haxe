package brain.sceneGraph;

import brain.component.Component;
import brain.facade.Facade;
import brain.logger.Logger;
import brain.utils.MemoryTracker;
import com.greensock.TweenMax;
import flash.display.DisplayObject;
import flash.display.Sprite;
import org.as3commons.collections.Set;
import org.as3commons.collections.framework.ISetIterator;

class SceneGraphComponent extends Component {
	static var mFadeSprite:Sprite;

	static var mFadeTween:TweenMax;

	var mDisplayObjects:Set;

	var mCurtainActive:Bool = false;

	public function new(facade:Facade, ownerName:String = null) {
		super(facade);
		mDisplayObjects = new Set();
		MemoryTracker.track(this, "SceneGraphComponent - " + (if (ASCompat.stringAsBool(ownerName)) ownerName else "unknown"), "brain");
	}

	public static function bringToFront(child:DisplayObject) {
		if (child.parent != null) {
			child.parent.addChildAt(child, child.parent.numChildren);
		}
	}

	public static function sendToBack(child:DisplayObject) {
		if (child.parent != null) {
			child.parent.addChildAt(child, 0);
		}
	}

	public static function buildFadeSprite(facade:Facade) {
		mFadeSprite = new Sprite();
		mFadeSprite.graphics.beginFill((0 : UInt), 1);
		mFadeSprite.graphics.drawRect(0, 0, facade.viewWidth, facade.viewHeight);
		mFadeSprite.graphics.endFill();
		mFadeSprite.mouseEnabled = true;
		mFadeSprite.mouseChildren = false;
	}

	public function addChild(child:DisplayObject, layerIndex:UInt):DisplayObject {
		if (!mDisplayObjects.has(child)) {
			mDisplayObjects.add(child);
		}
		return mFacade.sceneGraphManager.addChild(child, (layerIndex : Int));
	}

	public function addChildAt(child:DisplayObject, layerIndex:UInt, childIndex:UInt):DisplayObject {
		if (!mDisplayObjects.has(child)) {
			mDisplayObjects.add(child);
		}
		return mFacade.sceneGraphManager.addChildAt(child, (layerIndex : Int), (childIndex : Int));
	}

	public function showPopupCurtain() {
		if (!mCurtainActive) {
			mFacade.sceneGraphManager.showPopupCurtain();
			mCurtainActive = true;
		}
	}

	public function removePopupCurtain() {
		if (mCurtainActive) {
			mFacade.sceneGraphManager.removePopupCurtain();
			mCurtainActive = false;
		}
	}

	public function removeChild(child:DisplayObject):DisplayObject {
		if (child == null) {
			Logger.warn("SceneGraphComponent:removeChild child is null");
			return null;
		}
		mDisplayObjects.remove(child);
		return mFacade.sceneGraphManager.removeChild(child);
	}

	public function contains(child:DisplayObject, layerIndex:UInt):Bool {
		return mDisplayObjects.has(child);
	}

	function killFadeTween() {
		if (mFadeTween != null) {
			mFadeTween.kill();
			mFadeTween = null;
		}
	}

	public function fadeIn(fadeLength:Float) {
		if (mFadeSprite == null) {
			buildFadeSprite(mFacade);
		}
		killFadeTween();
		if (fadeLength == 0) {
			this.removeChild(mFadeSprite);
			return;
		}
		this.addChild(mFadeSprite, (100 : UInt));
		mFadeTween = TweenMax.to(mFadeSprite, fadeLength, {
			"alpha": 0,
			"onComplete": finishFadeIn
		});
	}

	function finishFadeIn() {
		this.removeChild(mFadeSprite);
	}

	function finishFadeOut() {}

	public function fadeOut(fadeLength:Float, alphaValue:Float = 1) {
		if (mFadeSprite == null) {
			buildFadeSprite(mFacade);
		}
		killFadeTween();
		this.addChild(mFadeSprite, (100 : UInt));
		if (fadeLength == 0) {
			mFadeSprite.alpha = 1;
			return;
		}
		mFadeTween = TweenMax.to(mFadeSprite, fadeLength, {
			"alpha": alphaValue,
			"onComplete": finishFadeOut
		});
	}

	public function saturateLayers(value:Float, listOfLayersToBeAvoided:Array<ASAny>) {
		mFacade.sceneGraphManager.saturateLayers(value, listOfLayersToBeAvoided);
	}

	public function cleanBackgroundLayer() {
		mFacade.sceneGraphManager.cleanBackgroundLayer();
	}

	override public function destroy() {
		var _loc1_:DisplayObject = null;
		var _loc2_ = ASCompat.reinterpretAs(mDisplayObjects.iterator(), ISetIterator);
		while (_loc2_.hasNext()) {
			_loc1_ = ASCompat.dynamicAs(_loc2_.next(), DisplayObject);
			if (_loc1_.parent != null) {
				_loc1_.parent.removeChild(_loc1_);
			}
		}
		mDisplayObjects.clear();
		mDisplayObjects = null;
		removePopupCurtain();
		super.destroy();
	}
}
