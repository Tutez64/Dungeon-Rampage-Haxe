package brain.render;

import brain.facade.Facade;
import brain.starling.StarlingSourceCache;

class StarlingRendererFactory extends RendererFactory {
	static inline final DEFAULT_FRAME_RATE:Float = 24;

	var mSourceCache:StarlingSourceCache;

	public function new(facade:Facade, backend:IRenderingBackend) {
		super(facade, backend);
	}

	@:isVar public var sourceCache(get, set):StarlingSourceCache;

	public function set_sourceCache(value:StarlingSourceCache):StarlingSourceCache {
		return mSourceCache = value;
	}

	function get_sourceCache():StarlingSourceCache {
		if (mSourceCache != null) {
			return mSourceCache;
		}
		if (mFacade.starlingLayerManager != null) {
			mSourceCache = mFacade.starlingLayerManager.sourceCache;
		}
		return mSourceCache;
	}
}
