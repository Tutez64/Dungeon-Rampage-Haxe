package uI.hud.starlingConverted;

import starling.display.DisplayObject;
import starling.styles.MeshStyle;

class TimelineView extends StatesView implements IHudTick {
	var mTicker:HudTicker;

	var mPlaying:Bool = false;

	var mPlayHead:Float = 0;

	var mPlayRate:Float = 1;

	var mLoop:Bool = false;

	var mComplete:ASFunction;

	var mPlayedIntro:Bool = false;

	var mStageRate:Bool = false;

	var mSweep:StarlingSweepMesh;

	var mSweepColor:StarlingColorStyle;

	var mSweepDefault:MeshStyle;

	public var advanceWhileHidden:Bool = false;

	public function new(art:ArtNode, ticker:HudTicker = null) {
		var __ax4_iter_166:Vector<Vector<Float>>;
		var _loc4_ = 0;
		var _loc3_:Vector<Float> = /*undefined*/ null;
		super(art);
		mTicker = ticker;
		mStageRate = art.stageRate;
		if (art.sweep != null) {
			_loc4_ = 1;
			__ax4_iter_166 = art.sweep.arcs;
			if (checkNullIteratee(__ax4_iter_166))
				for (_tmp_ in __ax4_iter_166) {
					_loc3_ = _tmp_;
					if (_loc3_ != null) {
						_loc4_ = ASCompat.floatToInt(Math.max(_loc4_, _loc3_.length / 2));
					}
				}
			mSweep = new StarlingSweepMesh(art.sweep.cx, art.sweep.cy, _loc4_ * 11);
			mSweep.cell = art.cell;
			mSweepColor = new StarlingColorStyle();
			mSweepDefault = mSweep.style;
			addChild(mSweep);
		}
	}

	public function play(startFrame:Float = 0, loop:Bool = false, onComplete:ASFunction = null) {
		mComplete = onComplete;
		mLoop = onComplete != null ? loop : (mArt.labelLoop == 0 ? loop : mArt.labelLoop > 0);
		mPlayHead = startFrame;
		mPlayedIntro = false;
		resetChildren();
		applyHead();
		mPlaying = mArt.totalFrames > 1;
		if (mPlaying && mTicker != null) {
			mTicker.register(this);
		} else if (!mPlaying && mComplete != null) {
			complete();
		}
	}

	public function stop() {
		mPlaying = false;
		if (mTicker != null) {
			mTicker.unregister(this);
		}
	}

	override public function gotoAndStop(frame:ASObject) {
		stop();
		mPlayHead = Std.isOfType(frame, String) ? ASCompat.toInt(mArt.labels[ASCompat.toString(frame)]) : ASCompat.toNumber(frame);
		mPlayedIntro = false;
		mPlayHead = Math.max(0, Math.min(mArt.totalFrames - 1, mPlayHead));
		resetChildren();
		applyHead();
	}

	public function tick(tickLength:Float, stageFrame:Bool) {
		if (!mPlaying || stageRate && !stageFrame) {
			return;
		}
		var _loc3_:DisplayObject = this;
		var _loc4_ = true;
		while (_loc3_ != null) {
			if (!_loc3_.visible || _loc3_.alpha <= 0) {
				_loc4_ = false;
				break;
			}
			_loc3_ = _loc3_.parent;
		}
		if (!_loc4_ && !advanceWhileHidden) {
			return;
		}
		mPlayHead += stageRate ? mPlayRate : 24 * tickLength * mPlayRate;
		if (mPlayHead > mArt.totalFrames - 1 && !mLoop) {
			mPlayHead = mArt.totalFrames - 1;
			applyHead();
			stop();
			complete();
			return;
		}
		if (_loc4_) {
			applyHead();
		}
	}

	function complete() {
		var _loc1_ = mComplete;
		mComplete = null;
		if (_loc1_ != null) {
			_loc1_();
		}
	}

	function applyHead() {
		driveHead(mPlayHead);
	}

	@:allow(UI.Hud.StarlingConverted) function driveHead(head:Float) {
		var _loc3_ = 0;
		var _loc2_ = mArt.kind == "flipbook" ? mArt.totalFrames : mArt.authoredFrames;
		if (mArt.loopFrame >= 0 && mPlayedIntro) {
			_loc2_ = mArt.authoredFrames - mArt.loopFrame;
			_loc3_ = ASCompat.floatToInt(Math.fround((head - mArt.loopFrame - 2) % _loc2_) + mArt.loopFrame);
		} else {
			_loc3_ = Math.round(head % _loc2_);
			if (mArt.loopFrame >= 0 && head >= mArt.authoredFrames) {
				mPlayedIntro = true;
			}
		}
		showFrame(ASCompat.floatToInt(Math.max(0, Math.min(mArt.totalFrames - 1, _loc3_))));
		driveChildren(head);
	}

	override function showFrame(index:Int) {
		if (index == mFrame) {
			return;
		}
		super.showFrame(index);
		if (mSweep != null) {
			mSweep.setArcs(mArt.sweep.arcs[index + 1]);
		}
	}

	override function applyContentColor(red:Float, green:Float, blue:Float, offsetRed:Float, offsetGreen:Float, offsetBlue:Float) {
		if (mSweep == null) {
			return;
		}
		var _loc7_ = red == 1 && green == 1 && blue == 1 && offsetRed == 0 && offsetGreen == 0 && offsetBlue == 0;
		var _loc8_ = ASCompat.coerce(_loc7_ ? mSweepDefault : mSweepColor, starling.styles.MeshStyle);
		if (mSweep.style != _loc8_) {
			mSweep.style = _loc8_;
		}
		if (!_loc7_) {
			mSweepColor.setTransform(red, green, blue, offsetRed, offsetGreen, offsetBlue);
		}
	}

	override function applyChildFrame(child:ArtDisplay, frame:Int) {
		if (!Std.isOfType(child, TimelineView)) {
			super.applyChildFrame(child, frame);
		}
	}

	@:allow(UI.Hud.StarlingConverted) function resetIntro() {
		stop();
		mPlayedIntro = false;
	}

	@:isVar public var playRate(get, set):Float;

	public function get_playRate():Float {
		return mPlayRate;
	}

	function set_playRate(value:Float):Float {
		return mPlayRate = value;
	}

	@:isVar public var stageRate(get, set):Bool;

	public function get_stageRate():Bool {
		return mStageRate;
	}

	function set_stageRate(value:Bool):Bool {
		if (value == mStageRate) {
			return value;
		}
		mStageRate = value;
		setStageRate(value);
		return value;
	}

	@:isVar public var isPlaying(get, never):Bool;

	public function get_isPlaying():Bool {
		return mPlaying;
	}

	@:allow(UI.Hud.StarlingConverted) @:isVar var playHead(get, never):Float;

	function get_playHead():Float {
		return mPlayHead;
	}

	@:allow(UI.Hud.StarlingConverted)
	override function setGrayscale(value:Bool):Bool {
		var _loc2_ = super.setGrayscale(value);
		if (mSweep != null) {
			mSweep.cell = value ? HudArtConverter.grayCell(mArt.cell) : mArt.cell;
		}
		return _loc2_;
	}

	override public function dispose() {
		stop();
		super.dispose();
	}
}
