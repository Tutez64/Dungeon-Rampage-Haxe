package brain.render;

import brain.facade.Facade;

class RendererFactory {
	var mFacade:Facade;

	var mBackend:IRenderingBackend;

	public function new(facade:Facade, backend:IRenderingBackend) {
		mFacade = facade;
		mBackend = backend;
	}

	@:isVar public var backendType(get, never):String;

	public function get_backendType():String {
		return mBackend.backendType;
	}

	@:isVar public var backend(get, never):IRenderingBackend;

	public function get_backend():IRenderingBackend {
		return mBackend;
	}

	public function destroy() {
		mBackend = null;
		mFacade = null;
	}
}
