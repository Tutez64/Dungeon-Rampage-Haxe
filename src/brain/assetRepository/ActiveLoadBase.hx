package brain.assetRepository;

import org.as3commons.collections.Set;
import org.as3commons.collections.framework.core.SetIterator;

class ActiveLoadBase {
	public var mPendingSuccessCallback:Set;

	public var mPendingErrorCallbacks:Set;

	public var mInfo:AssetLoaderInfo;

	public var mAssetRepository:AssetRepository;

	public function new(assetRepository:AssetRepository, info:AssetLoaderInfo) {
		mPendingErrorCallbacks = new Set();
		mPendingSuccessCallback = new Set();
		mInfo = info;
		mAssetRepository = assetRepository;
	}

	public function AddCallback(success:ASFunction, failure:ASFunction) {
		if (success != null) {
			mPendingSuccessCallback.add(success);
		}
		if (failure != null) {
			mPendingErrorCallbacks.add(failure);
		}
	}

	public function removeCallback(success:ASFunction, failure:ASFunction):Bool {
		var _loc3_ = false;
		if (success != null) {
			_loc3_ = mPendingSuccessCallback.remove(success);
		}
		if (failure != null) {
			_loc3_ = _loc3_ || mPendingErrorCallbacks.remove(failure);
		}
		return _loc3_;
	}

	public function hasNoCallbacks():Bool {
		return mPendingSuccessCallback.size != 0 || mPendingErrorCallbacks.size != 0;
	}

	public function executeErrorCallbacks(assetLoaderInfo:AssetLoaderInfo) {
		var _loc3_:ASFunction = null;
		var _loc2_ = ASCompat.reinterpretAs(mPendingErrorCallbacks.iterator(), SetIterator);
		while (_loc2_.hasNext()) {
			_loc3_ = ASCompat.asFunction(_loc2_.next());
			if (_loc3_ != null) {
				_loc3_();
			}
		}
		mPendingErrorCallbacks.clear();
	}

	public function executeSucessCallbacks(assetLoaderInfo:AssetLoaderInfo, asset:Asset) {
		var _loc4_:ASFunction = null;
		var _loc3_ = ASCompat.reinterpretAs(mPendingSuccessCallback.iterator(), SetIterator);
		while (_loc3_.hasNext()) {
			_loc4_ = ASCompat.asFunction(_loc3_.next());
			if (_loc4_ != null) {
				_loc4_(asset);
			}
		}
		mPendingSuccessCallback.clear();
	}

	public function destroy() {
		mPendingSuccessCallback.clear();
		mPendingErrorCallbacks.clear();
		mAssetRepository = null;
		mInfo = null;
	}
}
