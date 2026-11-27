package brain.render;

import brain.facade.Facade;
import brain.logger.Logger;
import flash.display.DisplayObject;

class FlashRenderingBackend implements IRenderingBackend {
	var mFacade:Facade;

	public function new(facade:Facade) {
		mFacade = facade;
	}

	@:isVar public var backendType(get, never):String;

	public function get_backendType():String {
		return "flash";
	}

	@:isVar public var isReady(get, never):Bool;

	public function get_isReady():Bool {
		return true;
	}

	public function addChildToLayer(displayObject:ASObject, layerIndex:Int) {
		if (displayObject == null) {
			Logger.warn("FlashRenderingBackend.addChildToLayer: displayObject is null");
			return;
		}
		mFacade.sceneGraphManager.addChild(ASCompat.dynamicAs(displayObject, DisplayObject), layerIndex);
	}

	public function removeChild(displayObject:ASObject) {
		if (displayObject == null) {
			return;
		}
		mFacade.sceneGraphManager.removeChild(ASCompat.dynamicAs(displayObject, DisplayObject));
	}

	public function clearLayer(layerIndex:Int) {
		var _loc2_ = mFacade.sceneGraphManager.getLayer(layerIndex);
		if (_loc2_ == null) {
			Logger.warn("FlashRenderingBackend.clearLayer: unknown layer index " + layerIndex);
			return;
		}
		while (_loc2_.numChildren > 0) {
			_loc2_.removeChildAt(0);
		}
	}

	public function destroy() {
		mFacade = null;
	}
}
