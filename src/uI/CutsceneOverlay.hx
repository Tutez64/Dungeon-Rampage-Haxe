package uI;

import brain.uI.UIButton;
import facade.DBFacade;
import flash.display.MovieClip;

class CutsceneOverlay {
	static var SkipButtonArt:Dynamic = Db_UI_skip_button_swf;

	static var ColiseumAdvertArt:Dynamic = Db_UI_skip_button_swf_f3d44e943f8de259a193faafa412a2681948871216;

	var mDBFacade:DBFacade;

	var mSkipButton:UIButton;

	var mColiseumAdvert:MovieClip;

	var mColiseumAdvertButton:UIButton;

	public function new(dbFacade:DBFacade, skipCallback:ASFunction, withColiseumAdvert:Bool = true) {
		mDBFacade = dbFacade;
		mSkipButton = new UIButton(mDBFacade, ASCompat.dynamicAs(ASCompat.createInstance(SkipButtonArt, []), MovieClip));
		mSkipButton.root.x = 1850;
		mSkipButton.root.y = 120;
		mSkipButton.releaseCallback = skipCallback;
		if (!withColiseumAdvert) {
			return;
		}
		mColiseumAdvert = ASCompat.dynamicAs(ASCompat.createInstance(ColiseumAdvertArt, []), MovieClip);
		mColiseumAdvert.gotoAndStop(1);
		mColiseumAdvert.x = 250;
		mColiseumAdvert.y = 928;
		mColiseumAdvertButton = new UIButton(mDBFacade, ASCompat.coerce((mColiseumAdvert : ASAny).button, flash.display.MovieClip));
		mColiseumAdvertButton.releaseCallback = onColiseumAdvertClicked;
		mSkipButton.isAbove(mColiseumAdvertButton);
		mColiseumAdvertButton.isToTheLeftOf(mSkipButton);
	}

	@:isVar public var skipButton(get, never):UIButton;

	public function get_skipButton():UIButton {
		return mSkipButton;
	}

	@:isVar public var coliseumAdvert(get, never):MovieClip;

	public function get_coliseumAdvert():MovieClip {
		return mColiseumAdvert;
	}

	function onColiseumAdvertClicked() {
		mDBFacade.steamAchievementsHelper.unlockAchievement("TROJAN_HORSE");
	}

	public function destroy() {
		mSkipButton.destroy();
		if (mColiseumAdvertButton != null) {
			mColiseumAdvertButton.destroy();
		}
		mSkipButton = null;
		mColiseumAdvert = null;
		mColiseumAdvertButton = null;
		mDBFacade = null;
	}
}
