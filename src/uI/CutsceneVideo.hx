package uI;

import brain.event.EventListeners;
import brain.logger.Logger;
import flash.display.MovieClip;
import flash.display.Stage;
import flash.events.AsyncErrorEvent;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class CutsceneVideo {
	static inline final START_TIMEOUT_MS = 5000;

	var mStage:Stage;

	var mStageFrameRate:Float = Math.NaN;

	var mClip:MovieClip;

	var mClipFrameRate:Float = Math.NaN;

	var mClipStarted:Bool = false;

	var mVideo:Video;

	var mNetConnection:NetConnection;

	var mNetStream:NetStream;

	var mUrl:String;

	var mRequestedAt:Int = 0;

	public function new(stage:Stage, clip:MovieClip, clipFrameRate:Float, url:String, volume:SoundTransform) {
		mStage = stage;
		mStageFrameRate = stage.frameRate;
		stage.frameRate = clipFrameRate;
		mClip = clip;
		mClipFrameRate = clipFrameRate;
		mClip.gotoAndStop(1);
		mUrl = url;
		mVideo = new Video(1920, 1080);
		mVideo.smoothing = true;
		mNetConnection = new NetConnection();
		mNetConnection.connect(null);
		mNetStream = new NetStream(mNetConnection);
		mNetStream.soundTransform = volume;
		mNetStream.client = {
			"onMetaData": function(param1:ASObject) {}
		};
		EventListeners.add(mNetStream, "netStatus", onNetStatus);
		EventListeners.add(mNetStream, "asyncError", onAsyncError);
		EventListeners.add(mNetStream, "ioError", onIOError);
		EventListeners.add(mClip, "enterFrame", onClipFrame);
		mVideo.attachNetStream(mNetStream);
		mRequestedAt = flash.Lib.getTimer();
		mNetStream.play(url);
	}

	@:isVar public var display(get, never):Video;

	public function get_display():Video {
		return mVideo;
	}

	function onClipFrame(event:Event) {
		if (mNetStream.time > 0) {
			startClip(ASCompat.floatToInt(mNetStream.time * mClipFrameRate) + 1);
		} else if (flash.Lib.getTimer() - mRequestedAt > 5000) {
			Logger.warn("CutsceneVideo: " + mUrl + " did not start within " + 5000 + " ms; playing the clip alone");
			dropVideo();
		}
	}

	function onNetStatus(event:NetStatusEvent) {
		var _loc2_:String = event.info.code;
		if (event.info.level == "error" || _loc2_ == "NetStream.Play.Failed" || _loc2_ == "NetStream.Play.Stop" && !mClipStarted) {
			Logger.warn("CutsceneVideo: " + mUrl + " failed with " + _loc2_ + "; playing the clip alone");
			dropVideo();
		}
	}

	function onIOError(event:IOErrorEvent) {
		Logger.warn("CutsceneVideo: " + mUrl + " IO error " + event.text + "; playing the clip alone");
		dropVideo();
	}

	function onAsyncError(event:AsyncErrorEvent) {
		Logger.debug("CutsceneVideo: " + mUrl + " async error " + event.text);
	}

	function startClip(frame:Int) {
		if (mClip == null || mClipStarted) {
			return;
		}
		mClipStarted = true;
		EventListeners.remove(mClip, "enterFrame", onClipFrame);
		mClip.gotoAndPlay(Math.min(frame, mClip.totalFrames));
	}

	function dropVideo() {
		if (mNetStream == null) {
			return;
		}
		closeStream();
		mVideo.clear();
		mVideo.visible = false;
		startClip(1);
	}

	function closeStream() {
		EventListeners.remove(mNetStream, "netStatus", onNetStatus);
		EventListeners.remove(mNetStream, "asyncError", onAsyncError);
		EventListeners.remove(mNetStream, "ioError", onIOError);
		mVideo.attachNetStream(null);
		mNetStream.close();
		mNetStream = null;
		mNetConnection.close();
		mNetConnection = null;
	}

	public function destroy() {
		if (mClip == null) {
			return;
		}
		if (!mClipStarted) {
			EventListeners.remove(mClip, "enterFrame", onClipFrame);
		}
		if (mNetStream != null) {
			closeStream();
		}
		mStage.frameRate = mStageFrameRate;
		mStage = null;
		mClip = null;
		mVideo = null;
	}
}
