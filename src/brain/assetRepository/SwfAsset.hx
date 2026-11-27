package brain.assetRepository;

import brain.logger.Logger;
import flash.display.MovieClip;

class SwfAsset extends Asset {
	var mRootClip:MovieClip;

	var mSwfPath:String;

	public function new(rootClip:MovieClip, swfPath:String) {
		mRootClip = rootClip;
		mSwfPath = swfPath;
		super();
	}

	override public function destroy() {
		mRootClip.loaderInfo.loader.unloadAndStop();
		mRootClip = null;
	}

	@:isVar public var swfPath(get, never):String;

	public function get_swfPath():String {
		return mSwfPath;
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		return mRootClip;
	}

	public function getClass(className:String, suppressWarnings:Bool = false):Dynamic {
		if (!mRootClip.loaderInfo.applicationDomain.hasDefinition(className)) {
			if (!suppressWarnings) {
				Logger.warn("Could not find class name: \'" + className + "\' in SwfAsset " + mRootClip.loaderInfo.url);
			}
			return null;
		}
		return (mRootClip.loaderInfo.applicationDomain.getDefinition(className) : Dynamic);
	}
}
