package brain.render;

import brain.facade.Facade;
import brain.logger.Logger;
import brain.starling.StarlingLayerManager;
import flash.display.Sprite;
import flash.display.Stage;
import flash.geom.Rectangle;
import starling.display.DisplayObject;

class StarlingRenderingBackend implements IRenderingBackend {
	var mFacade:Facade;

	var mStarlingLayerManager:StarlingLayerManager;

	public var onContextReady:ASFunction;

	public var contextReady:Bool = false;

	public function new(facade:Facade) {
		mFacade = facade;
	}

	@:isVar public var backendType(get, never):String;

	public function get_backendType():String {
		return "starling";
	}

	@:isVar public var isReady(get, never):Bool;

	public function get_isReady():Bool {
		return mStarlingLayerManager != null && mStarlingLayerManager.isReady();
	}

	@:isVar public var starlingLayerManager(get, never):StarlingLayerManager;

	public function get_starlingLayerManager():StarlingLayerManager {
		return mStarlingLayerManager;
	}

	public function init(facade:ASObject, stage:Stage, designWidth:Float, designHeight:Float) {
		if (mStarlingLayerManager != null) {
			Logger.warn("StarlingRenderingBackend.init: already initialized");
			return;
		}
		mStarlingLayerManager = new StarlingLayerManager(mFacade, stage, designWidth, designHeight, onContextReady);
	}

	public function addChildToLayer(displayObject:ASObject, layerIndex:Int) {
		if (!isReady) {
			Logger.warn("StarlingRenderingBackend.addChildToLayer: backend not ready");
			return;
		}
		if (displayObject == null) {
			Logger.warn("StarlingRenderingBackend.addChildToLayer: displayObject is null");
			return;
		}
		var _loc3_ = ASCompat.dynamicAs(displayObject, DisplayObject);
		if (_loc3_ == null) {
			Logger.warn("StarlingRenderingBackend.addChildToLayer: displayObject is not a Starling DisplayObject");
			return;
		}
		var _loc4_ = mStarlingLayerManager.getLayer(layerIndex);
		if (_loc4_ != null) {
			_loc4_.addChild(_loc3_);
		} else {
			Logger.error("StarlingRenderingBackend.addChildToLayer: layer " + layerIndex + " not found in starling layer map");
		}
	}

	public function removeChild(displayObject:ASObject) {
		if (displayObject == null) {
			return;
		}
		var _loc2_ = ASCompat.dynamicAs(displayObject, DisplayObject);
		if (_loc2_ == null) {
			return;
		}
		if (_loc2_.parent != null) {
			_loc2_.parent.removeChild(_loc2_);
		} else {
			Logger.error("StarlingRenderingBackend.removeChild: displayObject is not a child of any layer");
		}
	}

	public function clearLayer(layerIndex:Int) {
		if (!isReady) {
			return;
		}
		var _loc2_ = mStarlingLayerManager.getLayer(layerIndex);
		if (_loc2_ != null) {
			_loc2_.clean();
		}
	}

	public function markLayerDirty(layerIndex:Int) {
		if (!isReady) {
			return;
		}
		mStarlingLayerManager.markLayerDirty(layerIndex);
	}

	public function syncWorldTransform(worldTransformNode:Sprite) {
		if (!isReady) {
			return;
		}
		mStarlingLayerManager.syncWorldTransform(worldTransformNode);
	}

	public function updateViewPort(rect:Rectangle) {
		if (mStarlingLayerManager != null) {
			mStarlingLayerManager.updateViewPort(rect);
		}
	}

	public function destroy() {
		onContextReady = null;
		if (mStarlingLayerManager != null) {
			mStarlingLayerManager.destroy();
			mStarlingLayerManager = null;
		}
		mFacade = null;
	}
}
