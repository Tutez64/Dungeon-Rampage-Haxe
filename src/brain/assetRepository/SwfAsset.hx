package brain.assetRepository;

import brain.logger.Logger;
import flash.display.MovieClip;

class SwfAsset extends Asset {
	var mRootClip:MovieClip;

	var mSwfPath:String;

	var mHdRootClip:MovieClip = null;

	var mHdSwfPath:String = null;

	public function new(rootClip:MovieClip, swfPath:String) {
		mRootClip = rootClip;
		mSwfPath = swfPath;
		super();
	}

	override public function destroy() {
		mRootClip.loaderInfo.loader.unloadAndStop();
		mRootClip = null;
		if (mHdRootClip != null) {
			mHdRootClip.loaderInfo.loader.unloadAndStop();
			mHdRootClip = null;
		}
	}

	@:isVar public var swfPath(get, never):String;

	public function get_swfPath():String {
		return mSwfPath;
	}

	public function setHdAsset(hdRootClip:MovieClip, hdSwfPath:String) {
		mHdRootClip = hdRootClip;
		mHdSwfPath = hdSwfPath;
	}

	@:isVar public var hasHdAsset(get, never):Bool;

	public function get_hasHdAsset():Bool {
		return mHdRootClip != null;
	}

	@:isVar public var hdSwfPath(get, never):String;

	public function get_hdSwfPath():String {
		return mHdSwfPath;
	}

	@:isVar public var root(get, never):MovieClip;

	public function get_root():MovieClip {
		return mRootClip;
	}

	public function getClass(className:String, suppressWarnings:Bool = false):Dynamic {
		if (mHdRootClip != null && mHdRootClip.loaderInfo.applicationDomain.hasDefinition(className)) {
			return (mHdRootClip.loaderInfo.applicationDomain.getDefinition(className) : Dynamic);
		}
		if (!mRootClip.loaderInfo.applicationDomain.hasDefinition(className)) {
			if (!suppressWarnings) {
				Logger.warn("Could not find class name: "
					+ className
					+ " in SwfAsset "
					+ mRootClip.loaderInfo.url
					+ (mHdRootClip != null ? " or HD asset " + mHdRootClip.loaderInfo.url : ""));
			}
			return null;
		}
		return (mRootClip.loaderInfo.applicationDomain.getDefinition(className) : Dynamic);
	}
}
