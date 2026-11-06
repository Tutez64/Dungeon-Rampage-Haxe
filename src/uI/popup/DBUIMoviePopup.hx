package uI.popup;

import brain.event.EventListeners;
import brain.uI.UIButton;
import brain.utils.MemoryTracker;
import brain.utils.TextUtil;
import dBGlobals.DBGlobal;
import facade.DBFacade;
import flash.display.Loader;
import flash.display.MovieClip;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.net.URLRequest;

class DBUIMoviePopup extends DBUIOneButtonPopup {
	static inline final SWF_PATH = "Resources/Art2D/UI/db_UI_screens.swf";

	var mContainerMC:MovieClip = new MovieClip();

	var mLoader:Loader;

	var mMoviePlayer:ASObject;

	var mWidth:Float = Math.NaN;

	var mHeight:Float = Math.NaN;

	var mPopUpClassName:String;

	var mLoadingPopUp:DBUIPopup;

	var mUseCurtain:Bool = true;

	public function new(dbFacade:DBFacade, popUpClassName:String, titleText:String, contentText:String, moviePath:String, centerText:String,
			centerCallback:ASFunction, width:Float, height:Float, showPagination:Bool) {
		mPopUpClassName = popUpClassName;
		mWidth = width;
		mHeight = height;
		mUseCurtain = !showPagination;
		super(dbFacade, "NEWS_MOVIE_POPUP", titleText, mContainerMC, centerText, centerCallback);
		TextUtil.setText(mMessage, contentText);
		if (moviePath != null && moviePath.length > 0) {
			mLoadingPopUp = new DBUIPopup(mDBFacade, "", "LOADING", null, true, false);
			MemoryTracker.track(mLoadingPopUp, "DBUIPopup - created in DBUIMoviePopup.DBUIMoviePopup()");
			mLoader = new Loader();
			EventListeners.add(mLoader.contentLoaderInfo, "init", onLoaderInit);
			EventListeners.add(mLoader.contentLoaderInfo, "ioError", loaderIOErrorHandler);
			mLoader.load(new URLRequest(moviePath));
		}
		if (!showPagination) {
			ASCompat.setProperty((mPopup : ASAny).center_button_news, "visible", false);
			ASCompat.setProperty((mPopup : ASAny).pagination, "visible", false);
		} else {
			ASCompat.setProperty((mPopup : ASAny).center_button, "visible", false);
			mCenterButton = new UIButton(mDBFacade, ASCompat.coerce((mPopup : ASAny).center_button_news, flash.display.MovieClip));
			mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
			TextUtil.setText(mCenterButton.label, mCenterText);
			mCenterButton.releaseCallback = function() {
				close(mCenterCallback);
			};
		}
	}

	override function animatedEntrance() {
		super.animatedEntrance();
	}

	override public function getPagination():MovieClip {
		return ASCompat.coerce((mPopup : ASAny).pagination, flash.display.MovieClip);
	}

	override function getSwfPath():String {
		return "Resources/Art2D/UI/db_UI_screens.swf";
	}

	override function getClassName():String {
		return mPopUpClassName;
	}

	function loaderIOErrorHandler(e:IOErrorEvent) {
		mLoadingPopUp.destroy();
		mLoadingPopUp = null;
		destroy();
	}

	function onLoaderInit(event:Event) {
		mContainerMC.addChild(mLoader);
		mLoader.x = -mWidth / 2;
		mLoader.y = -mHeight / 2;
		EventListeners.add(mLoader.content, "onReady", onPlayerReady);
		EventListeners.add(mLoader.content, "onError", onPlayerError);
		EventListeners.add(mLoader.content, "onStateChange", onPlayerStateChange);
		EventListeners.add(mLoader.content, "onPlaybackQualityChange", onVideoPlaybackQualityChange);
	}

	function onPlayerReady(event:Event) {
		mLoadingPopUp.destroy();
		mLoadingPopUp = null;
		mMoviePlayer = mLoader.content;
		mMoviePlayer.setSize(mWidth, mHeight);
	}

	function onPlayerError(event:Event) {
		mLoadingPopUp.destroy();
		mLoadingPopUp = null;
	}

	function onPlayerStateChange(event:Event) {}

	function onVideoPlaybackQualityChange(event:Event) {}

	override public function destroy() {
		super.destroy();
		mContainerMC = null;
		if (mLoader != null) {
			EventListeners.remove(mLoader.contentLoaderInfo, "init", onLoaderInit);
			if (mLoader.content != null) {
				EventListeners.remove(mLoader.content, "onReady", onPlayerReady);
				EventListeners.remove(mLoader.content, "onError", onPlayerError);
				EventListeners.remove(mLoader.content, "onStateChange", onPlayerStateChange);
				EventListeners.remove(mLoader.content, "onPlaybackQualityChange", onVideoPlaybackQualityChange);
				mLoader.unloadAndStop();
			}
			mLoader = null;
		}
	}
}
