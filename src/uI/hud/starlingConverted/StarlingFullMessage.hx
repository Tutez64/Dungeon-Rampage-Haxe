package uI.hud.starlingConverted;

import facade.DBFacade;
import starling.display.DisplayObject;

class StarlingFullMessage implements IHudTick {
	var mFacade:DBFacade;

	var mRoot:DisplayObject;

	var mTicker:HudTicker;

	var mStart:UInt = 0;

	var mFloatAt:Int = 0;

	var mTickLength:Float = Math.NaN;

	var mPhase:Int = 0;

	public var changed:ASFunction;

	public function new(facade:DBFacade, root:DisplayObject, ticker:HudTicker) {
		mFacade = facade;
		mRoot = root;
		mTicker = ticker;
		if (root != null) {
			root.visible = false;
		}
		if (Std.isOfType(root, ArtDisplay)) {
			cast(root, ArtDisplay).setHudVisibility(false);
		}
	}

	public function show() {
		if (mRoot == null || mPhase != 0) {
			return;
		}
		mStart = mFacade.gameClock.frame;
		mTickLength = mFacade.gameClock.tickLength;
		mPhase = 1;
		mRoot.visible = true;
		if (Std.isOfType(mRoot, ArtDisplay)) {
			cast(mRoot, ArtDisplay).setHudVisibility(true);
		}
		mRoot.alpha = 1;
		mRoot.scaleX = mRoot.scaleY = 1;
		mTicker.register(this);
		mTicker.registerStage(this);
		if (changed != null) {
			changed();
		}
	}

	public function tick(tickLength:Float, stageFrame:Bool) {
		var _loc5_ = Math.NaN;
		var _loc3_ = (0 : UInt);
		var _loc4_ = Math.NaN;
		if (mPhase == 1 && !stageFrame) {
			_loc3_ = mFacade.gameClock.frame - mStart;
			if (_loc3_ > 8) {
				mRoot.alpha = mRoot.scaleX = mRoot.scaleY = 1;
				mFloatAt = flash.Lib.getTimer();
				mPhase = 2;
			} else {
				_loc5_ = _loc3_ / 8;
				mRoot.alpha = _loc5_ * _loc5_ * _loc5_ * _loc5_;
				mRoot.scaleX = mRoot.scaleY = _loc3_ / 16;
			}
		} else if (mPhase == 2 && stageFrame) {
			_loc4_ = (flash.Lib.getTimer() - mFloatAt) / (1000 * mTickLength);
			_loc5_ = Math.max(0, Math.min(1, (_loc4_ - 2) / 12.8));
			mRoot.scaleX = mRoot.scaleY = 1 + 0.125 * (1 - Math.pow(1 - _loc5_, 5));
			_loc5_ = Math.max(0, Math.min(1, (_loc4_ - 14.8) / 3.2));
			mRoot.alpha = (1 - _loc5_) * (1 - _loc5_);
			if (_loc4_ >= 18) {
				stop();
			}
		}
		if (changed != null) {
			changed();
		}
	}

	public function stop() {
		mPhase = 0;
		mTicker.unregister(this);
		mTicker.unregisterStage(this);
		if (mRoot == null) {
			return;
		}
		mRoot.alpha = 0;
		mRoot.scaleX = mRoot.scaleY = 1;
	}

	public function dispose() {
		stop();
		changed = null;
		mFacade = null;
		mRoot = null;
		mTicker = null;
	}
}
