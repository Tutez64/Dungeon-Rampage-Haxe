package uI.hud.starlingConverted;

import brain.clock.GameClock;
import flash.display.Stage;
import flash.events.Event;

class HudTicker {
	var mViews:Vector<IHudTick> = new Vector((0 : UInt));

	var mStage:Stage;

	var mPending:Vector<ASFunction> = new Vector((0 : UInt));

	var mStageViews:Vector<IHudTick> = new Vector((0 : UInt));

	var mClock:GameClock;

	var mTicking:Bool = false;

	var mStageTicking:Bool = false;

	public var onError:ASFunction;

	public function new(clock:GameClock) {
		mClock = clock;
	}

	static function compact(views:Vector<IHudTick>) {
		var _loc2_ = 0;
		var _loc3_ = 0;
		_loc2_ = 0;
		while (_loc2_ < views.length) {
			if (views[_loc2_] != null) {
				views[_loc3_++] = views[_loc2_];
			}
			_loc2_++;
		}
		views.length = _loc3_;
	}

	public function attachStage(stage:Stage) {
		if (mStage == stage) {
			return;
		}
		if (mStage != null) {
			mStage.removeEventListener("enterFrame", onStageFrame);
		}
		mStage = stage;
		if (mStage != null) {
			mStage.addEventListener("enterFrame", onStageFrame);
		}
	}

	function onStageFrame(event:Event) {
		if (HudArtConverter.busy || mTicking || mStageTicking) {
			return;
		}
		try {
			advanceStage();
		} catch (error:Dynamic) {
			if (onError != null) {
				onError(error);
			} else {
				StarlingHud.reportError(error);
			}
		}
	}

	function advanceStage() {
		var _loc4_ = 0;
		var _loc2_:IHudTick = null;
		var _loc3_ = mViews.length;
		var _loc1_ = mStageViews.length;
		mTicking = mStageTicking = true;
		{
			try {
				_loc4_ = 0;
				while (_loc4_ < _loc1_ && _loc4_ < mStageViews.length) {
					_loc2_ = mStageViews[_loc4_];
					if (_loc2_ != null) {
						tickView(_loc2_, 0, true);
					}
					_loc4_++;
				}
				_loc4_ = 0;
				while (_loc4_ < _loc3_ && _loc4_ < mViews.length) {
					_loc2_ = mViews[_loc4_];
					if (Std.isOfType(_loc2_, TimelineView) && cast(_loc2_, TimelineView).stageRate) {
						tickView(_loc2_, 0, true);
					}
					_loc4_++;
				}
			} catch (__finallyError0:Dynamic) {
				{
					mTicking = mStageTicking = false;
					compact(mViews);
					compact(mStageViews);
				};
				throw __finallyError0;
			};
			{
				mTicking = mStageTicking = false;
				compact(mViews);
				compact(mStageViews);
			};
		}
	}

	function tickView(view:IHudTick, length:Float, stageFrame:Bool) {
		try {
			view.tick(length, stageFrame);
		} catch (error:Dynamic) {
			if (onError != null) {
				onError(error);
			} else {
				StarlingHud.reportError(error);
			}
		}
	}

	public function register(view:IHudTick) {
		if (mViews.indexOf(view) < 0) {
			mViews.push(view);
		}
	}

	public function registerStage(view:IHudTick) {
		if (mStageViews.indexOf(view) < 0) {
			mStageViews.push(view);
		}
	}

	public function unregisterStage(view:IHudTick) {
		var _loc2_ = mStageViews.indexOf(view);
		if (_loc2_ >= 0) {
			if (mStageTicking) {
				mStageViews[_loc2_] = null;
			} else {
				mStageViews.removeAt(_loc2_);
			}
		}
	}

	public function deferBake(retry:ASFunction) {
		if (mPending.indexOf(retry) < 0) {
			mPending.push(retry);
		}
	}

	public function cancelBake(retry:ASFunction) {
		var _loc2_ = mPending.indexOf(retry);
		if (_loc2_ >= 0) {
			mPending.removeAt(_loc2_);
		}
	}

	public function unregister(view:IHudTick) {
		var _loc2_ = mViews.indexOf(view);
		if (_loc2_ >= 0) {
			if (mTicking) {
				mViews[_loc2_] = null;
			} else {
				mViews.removeAt(_loc2_);
			}
		}
	}

	public function tick(tickLength:Float) {
		var _loc5_:ASFunction = null;
		var _loc2_:IHudTick = null;
		if (HudArtConverter.busy || mTicking || mStageTicking) {
			return;
		}
		var _loc4_ = 0;
		var _loc3_ = mViews.length;
		mTicking = true;
		{
			try {
				if (mPending.length > 0) {
					while (_loc4_ < mPending.length) {
						_loc5_ = mPending[_loc4_];
						try {
							if (ASCompat.toBool(_loc5_())) {
								cancelBake(_loc5_);
							}
						} catch (error:Dynamic) {
							cancelBake(_loc5_);
							StarlingHud.reportError(error);
						}
						if (_loc4_ < mPending.length && mPending[_loc4_] == _loc5_) {
							_loc4_++;
						}
					}
				}
				_loc4_ = 0;
				while (_loc4_ < _loc3_ && _loc4_ < mViews.length) {
					_loc2_ = mViews[_loc4_];
					if (_loc2_ != null) {
						tickView(_loc2_, tickLength, false);
					}
					_loc4_++;
				}
			} catch (__finallyError0:Dynamic) {
				{
					mTicking = false;
					compact(mViews);
				};
				throw __finallyError0;
			};
			{
				mTicking = false;
				compact(mViews);
			};
		}
	}

	@:isVar public var gameTime(get, never):Int;

	public function get_gameTime():Int {
		return mClock.gameTime;
	}

	public function dispose() {
		attachStage(null);
		mViews.length = mPending.length = mStageViews.length = 0;
		onError = null;
	}
}
