package uI.training;

import brain.uI.UIProgressBar;
import facade.DBFacade;
import flash.display.MovieClip;

class UIStatProgressBar {
	var mDBFacade:DBFacade;

	var mProgressBar:UIProgressBar;

	var mCompletedClip:MovieClip;

	public function new(dbFacade:DBFacade, progressClip:MovieClip, completedClip:MovieClip) {
		mDBFacade = dbFacade;
		mProgressBar = new UIProgressBar(mDBFacade, ASCompat.dynamicAs((progressClip : ASAny).training_bar, flash.display.MovieClip));
		mProgressBar.enabled = false;
		mCompletedClip = completedClip;
		completed = false;
	}

	@:isVar public var progressBar(get, never):UIProgressBar;

	public function get_progressBar():UIProgressBar {
		return mProgressBar;
	}

	@:isVar public var value(never, set):Float;

	public function set_value(val:Float):Float {
		return mProgressBar.value = val;
	}

	@:isVar public var completed(never, set):Bool;

	public function set_completed(val:Bool):Bool {
		return mCompletedClip.visible = val;
	}

	public function destroy() {
		mProgressBar.destroy();
	}
}
