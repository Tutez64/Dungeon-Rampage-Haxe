package brain.jsonRPC;

import brain.event.EventListeners;
import brain.utils.MemoryTracker;
import collections.IMapIterator;
import collections.Map;
import flash.events.EventDispatcher;

class JSONRPCPendingInvokation extends EventDispatcher {
	var mRegisteredListeners:Map = new Map();

	var mURLStream:flash.net.URLLoader;

	var mDestroyCallback:ASFunction;

	public function new(stream:flash.net.URLLoader) {
		mURLStream = stream;
		super(this);
		MemoryTracker.track(mRegisteredListeners, "Map - registered listeners in JSONRPCPendingInvokation()", "brain");
	}

	public function handleError(e:Error) {
		if (mDestroyCallback != null) {
			mDestroyCallback(this);
		}
		mDestroyCallback = null;
		this.dispatchEvent(new FaultEvent(e));
		destroy();
	}

	public function handleResult(r:ASAny) {
		if (mDestroyCallback != null) {
			mDestroyCallback(this);
		}
		mDestroyCallback = null;
		this.dispatchEvent(new ResultEvent(r));
		destroy();
	}

	public function addDestroyCallback(f:ASFunction) {
		mDestroyCallback = f;
	}

	public function addListener(eventName:String, callback:ASFunction) {
		mRegisteredListeners.add(eventName, callback);
		EventListeners.add(this, eventName, callback);
	}

	public function destroy() {
		removeAllListeners();
		mRegisteredListeners = null;
		mURLStream.close();
		mURLStream = null;
		if (mDestroyCallback != null) {
			mDestroyCallback(this);
		}
		mDestroyCallback = null;
	}

	public function removeAllListeners() {
		var _loc2_:ASFunction = null;
		var _loc1_ = ASCompat.reinterpretAs(mRegisteredListeners.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc2_ = ASCompat.coerceFunction(_loc1_.next());
			EventListeners.remove(this, _loc1_.key, _loc2_);
		}
		mRegisteredListeners.clear();
	}
}
