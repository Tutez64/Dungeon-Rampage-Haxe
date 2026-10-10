package brain.render;

import brain.facade.Facade;
import brain.utils.IPoolable;
import flash.display.FrameLabel;
import flash.display.MovieClip;

class MovieClipRenderController implements IPoolable {
	var mClip:MovieClip;

	var mFacade:Facade;

	var mRenderer:MovieClipRenderer;

	var mStartScaleX:Float = Math.NaN;

	var mStartScaleY:Float = Math.NaN;

	public var swfPath:String = "";

	public var className:String = "";

	public function new(facade:Facade, clip:MovieClip, finishedCallback:ASFunction = null, assetLabel:String = null) {
		mFacade = facade;
		mClip = clip;
		mStartScaleX = mClip.scaleX;
		mStartScaleY = mClip.scaleY;
		determineRenderer(finishedCallback, assetLabel);
	}

	public function postCheckout(isNewObject:Bool) {
		if (!isNewObject) {
			mClip.scaleX = mStartScaleX;
			mClip.scaleY = mStartScaleY;
		}
	}

	public function postCheckin() {
		this.stop();
		if (mClip.parent != null) {
			mClip.parent.removeChild(mClip);
		}
	}

	public function getPoolKey():String {
		return swfPath + ":" + className;
	}

	function determineRenderer(finishedCallback:ASFunction, assetLabel:String = null) {
		var _loc3_:FrameLabel;
		final __ax4_iter_151 = mClip.currentLabels;
		if (checkNullIteratee(__ax4_iter_151))
			for (_tmp_ in __ax4_iter_151) {
				_loc3_ = _tmp_;
				if (_loc3_.name.indexOf("random") >= 0) {
					mRenderer = new MovieClipRandomRenderer(mFacade, mClip, finishedCallback, assetLabel);
					return;
				}
				if (_loc3_.name == "pause") {
					mRenderer = new MovieClipCutsceneRenderer(mFacade, mClip, finishedCallback, assetLabel);
					return;
				}
			}
		mRenderer = new MovieClipRenderer(mFacade, mClip, finishedCallback, assetLabel);
	}

	public function destroy() {
		if (mRenderer != null) {
			mRenderer.destroy();
		}
		mRenderer = null;
		mFacade = null;
		mClip = null;
	}

	public function stop() {
		mRenderer.stop();
	}

	public function play(startingFrame:UInt = (0 : UInt), loop:Bool = false, finishedCallback:ASFunction = null) {
		mRenderer.play(startingFrame, loop, finishedCallback);
	}

	@:isVar public var finishedCallback(never, set):ASFunction;

	public function set_finishedCallback(value:ASFunction):ASFunction {
		return mRenderer.finishedCallback = value;
	}

	public function setFrame(frameNumber:UInt) {
		mRenderer.setFrame(frameNumber);
	}

	@:isVar public var currentFrame(get, never):UInt;

	public function get_currentFrame():UInt {
		return mRenderer.currentFrame;
	}

	@:isVar public var clip(get, never):MovieClip;

	public function get_clip():MovieClip {
		return mRenderer.clip;
	}

	@:isVar public var durationInSeconds(get, never):Float;

	public function get_durationInSeconds():Float {
		return mRenderer.duration;
	}

	@:isVar public var frameCount(get, never):Float;

	public function get_frameCount():Float {
		return mRenderer.numFrames;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		return mRenderer.isPlaying;
	}

	@:isVar public var frameRate(never, set):Float;

	public function set_frameRate(value:Float):Float {
		return mRenderer.frameRate = value;
	}

	@:isVar public var startFrame(never, set):UInt;

	public function set_startFrame(value:UInt):UInt {
		return mRenderer.startFrame = value;
	}

	@:isVar public var loop(get, set):Bool;

	public function get_loop():Bool {
		return mRenderer.loop;
	}

	function set_loop(value:Bool):Bool {
		return mRenderer.loop = value;
	}

	@:isVar public var playRate(get, set):Float;

	public function get_playRate():Float {
		return mRenderer.playRate;
	}

	function set_playRate(value:Float):Float {
		return mRenderer.playRate = value;
	}
}
