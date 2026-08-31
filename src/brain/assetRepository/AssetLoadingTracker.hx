package brain.assetRepository;

class AssetLoadingTracker {
	public var pendingLoadCallback:ASFunction;

	public var pendingErrorCallback:ASFunction;

	public var assetLoadingComponent:AssetLoadingComponent;

	public var assetKey:String;

	public function new(assetKey:String, assetLoadingComponent:AssetLoadingComponent, pendingLoadCallback:ASFunction, pendingErrorCallback:ASFunction) {
		this.assetKey = assetKey;
		this.assetLoadingComponent = assetLoadingComponent;
		this.pendingLoadCallback = pendingLoadCallback;
		this.pendingErrorCallback = pendingErrorCallback;
		this.assetLoadingComponent.mPendingDownloads.add(this);
	}

	public function errorCallback() {
		if (pendingErrorCallback != null) {
			pendingErrorCallback();
		}
		if (assetLoadingComponent != null) {
			assetLoadingComponent.RemoveLoader(this);
		}
	}

	public function successCallback(asset:Asset) {
		if (pendingLoadCallback != null) {
			pendingLoadCallback(asset);
		}
		if (assetLoadingComponent != null) {
			assetLoadingComponent.RemoveLoader(this);
		}
	}

	public function destroy() {
		pendingLoadCallback = null;
		pendingErrorCallback = null;
		assetLoadingComponent = null;
		assetKey = null;
	}
}
