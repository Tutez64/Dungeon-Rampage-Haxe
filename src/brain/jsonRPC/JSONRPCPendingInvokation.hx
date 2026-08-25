package brain.jsonRPC;

import brain.utils.MemoryTracker;
import flash.events.EventDispatcher;
import org.as3commons.collections.Map;
import org.as3commons.collections.framework.IMapIterator;

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
		destory();
	}

	public function handleResult(r:ASAny) {
		if (mDestroyCallback != null) {
			mDestroyCallback(this);
		}
		mDestroyCallback = null;
		this.dispatchEvent(new ResultEvent(r));
		destory();
	}

	public function addDestroyCallback(f:ASFunction) {
		mDestroyCallback = f;
	}

	public function addListener(eventName:String, callback:ASFunction) {
		mRegisteredListeners.add(eventName, callback);
		addEventListener(eventName, callback);
	}

	public function removeListener(eventName:String) {
		if (!mRegisteredListeners.has(eventName)) {
			return;
		}
		var _loc2_ = ASCompat.asFunction(mRegisteredListeners.itemFor(eventName));
		removeEventListener(eventName, _loc2_);
		mRegisteredListeners.remove(eventName);
	}

	public function destory() {
		removeAllListeners();
		mRegisteredListeners.clear();
		mRegisteredListeners = null;
		mURLStream.close();
		mURLStream = null;
		if (mDestroyCallback != null) {
			mDestroyCallback(this);
		}
		mDestroyCallback = null;
	}

	public function removeAllListeners() {
		var _loc2_:String = null;
		var _loc1_ = ASCompat.reinterpretAs(mRegisteredListeners.iterator(), IMapIterator);
		while (_loc1_.hasNext()) {
			_loc1_.next();
			_loc2_ = ASCompat.asString(_loc1_.current);
			removeListener(_loc2_);
		}
	}
}
