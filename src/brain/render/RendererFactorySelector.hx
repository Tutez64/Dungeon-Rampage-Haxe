package brain.render;

import brain.facade.Facade;
import brain.logger.Logger;
import collections.Map;

class RendererFactorySelector {
	var mFacade:Facade;

	var mFlashFactory:RendererFactory;

	var mStarlingFactory:RendererFactory;

	var mLayerToBackend:Map;

	public function new(facade:Facade) {
		mFacade = facade;
		mLayerToBackend = new Map();
	}

	@:isVar public var flashFactory(get, never):RendererFactory;

	public function get_flashFactory():RendererFactory {
		return mFlashFactory;
	}

	@:isVar public var starlingFactory(get, never):RendererFactory;

	public function get_starlingFactory():RendererFactory {
		return mStarlingFactory;
	}

	public function registerFlashFactory(flashFactory:RendererFactory) {
		mFlashFactory = flashFactory;
	}

	public function registerStarlingFactory(starlingFactory:RendererFactory) {
		mStarlingFactory = starlingFactory;
	}

	public function setLayerBackend(layerIndex:Int, backendType:String) {
		if (mLayerToBackend.hasKey(layerIndex)) {
			mLayerToBackend.removeKey(layerIndex);
		}
		mLayerToBackend.add(layerIndex, backendType);
	}

	public function getLayerBackend(layerIndex:Int):String {
		if (!mLayerToBackend.hasKey(layerIndex)) {
			return "flash";
		}
		return ASCompat.asString(mLayerToBackend.itemFor(layerIndex));
	}

	public function getFactoryForLayer(layerIndex:Int):RendererFactory {
		var _loc2_ = getLayerBackend(layerIndex);
		if (_loc2_ == "starling" && mStarlingFactory != null) {
			if (mStarlingFactory.backend.isReady) {
				return mStarlingFactory;
			}
			Logger.warn("RendererFactorySelector: Starling requested for layer "
				+ layerIndex
				+ " but backend is not ready; falling back to available factory");
		}
		if (mFlashFactory != null) {
			return mFlashFactory;
		}
		Logger.error("RendererFactorySelector: No rendering factories registered for layer " + layerIndex);
		return null;
	}

	public function clearLayer(layerIndex:Int) {
		var _loc2_ = getFactoryForLayer(layerIndex);
		if (_loc2_ == null) {
			Logger.warn("RendererFactorySelector: Cannot clear layer " + layerIndex + " - no factory available");
			return;
		}
		var _loc3_ = getLayerBackend(layerIndex);
		if (_loc3_ == "starling" && mStarlingFactory != null && mStarlingFactory.backend.isReady) {
			if (mFacade.starlingRenderingBackend != null) {
				mFacade.starlingRenderingBackend.clearLayer(layerIndex);
			}
		}
		if (mFlashFactory != null && mFacade.flashRenderingBackend != null) {
			mFacade.flashRenderingBackend.clearLayer(layerIndex);
		}
	}

	public function destroy() {
		mFacade = null;
		mFlashFactory = null;
		mStarlingFactory = null;
		mLayerToBackend.clear();
		mLayerToBackend = null;
	}
}
