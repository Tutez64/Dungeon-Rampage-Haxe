package actor.starlingConvertedOverlay;

import brain.render.tweens.Quad;
import brain.render.tweens.Quint;
import brain.starling.swfConverter.BakedGlyphFont;
import brain.starling.swfConverter.BakedGlyphText;
import starling.display.Sprite;

/*internal*/
class StarlingDamageFloater extends Sprite {
	static inline final DEG_TO_RAD:Float = 0.017453292519943295;

	public var big:Bool = false;

	public var crit:Bool = false;

	var mCrit:BakedGlyphText;

	var mGlow:BakedGlyphText;

	var mFill:BakedGlyphText;

	var mBuff:Bool = false;

	var mElapsed:Float = Math.NaN;

	var mHold:Float = Math.NaN;

	var mTotal:Float = Math.NaN;

	var mStartX:Float = Math.NaN;

	var mStartY:Float = Math.NaN;

	var mEndX:Float = Math.NaN;

	var mEndY:Float = Math.NaN;

	var mStartScale:Float = Math.NaN;

	var mEndScale:Float = Math.NaN;

	var mPeakY:Float = Math.NaN;

	public function new() {
		super();
	}

	static function placeRow(row:BakedGlyphText, x:Float, y:Float, scaleX:Float, scaleY:Float) {
		row.x = x;
		row.y = y;
		row.scaleX = scaleX;
		row.scaleY = scaleY;
	}

	static function ratio(time:Float, duration:Float):Float {
		if (time <= 0) {
			return 0;
		}
		if (duration <= 0 || time >= duration) {
			return 1;
		}
		return time / duration;
	}

	public function setFonts(glow:BakedGlyphFont, fill:BakedGlyphFont, crit:BakedGlyphFont) {
		setCritFont(crit);
		if (glow != null) {
			if (mGlow == null) {
				mGlow = new BakedGlyphText(glow);
				addChildAt(mGlow, mCrit != null ? 1 : 0);
			} else if (mGlow.font != glow) {
				mGlow.font = glow;
			}
			mGlow.visible = true;
		} else if (mGlow != null) {
			mGlow.visible = false;
		}
		if (mFill == null) {
			mFill = new BakedGlyphText(fill);
			addChild(mFill);
		} else if (mFill.font != fill) {
			mFill.font = fill;
		}
	}

	function setCritFont(crit:BakedGlyphFont) {
		if (crit == null) {
			if (mCrit != null) {
				mCrit.visible = false;
			}
			return;
		}
		if (mCrit == null) {
			mCrit = new BakedGlyphText(crit);
			addChildAt(mCrit, 0);
		} else if (mCrit.font != crit) {
			mCrit.font = crit;
		}
		mCrit.visible = true;
	}

	public function setText(text:String, color:UInt):Float {
		if (mCrit != null && mCrit.visible) {
			mCrit.setText(text);
		}
		if (mGlow != null && mGlow.visible) {
			mGlow.setText(text);
		}
		mFill.setText(text);
		mFill.color = color;
		return mFill.textWidth;
	}

	public function placeRows(x:Float, y:Float, scaleX:Float, scaleY:Float) {
		placeRow(mFill, x, y, scaleX, scaleY);
		if (mGlow != null) {
			placeRow(mGlow, x, y, scaleX, scaleY);
		}
		if (mCrit != null) {
			placeRow(mCrit, x, y, scaleX, scaleY);
		}
	}

	public function start(x:Float, y:Float, scale:Float, rotationDegrees:Float, directionX:Float, directionY:Float, hold:Float, total:Float,
			scaleDampening:Float, speed:Float, buff:Bool) {
		var _loc13_ = Math.NaN;
		var _loc12_ = Math.NaN;
		this.x = mStartX = x;
		this.y = mStartY = y;
		scaleX = scaleY = mStartScale = scale;
		rotation = rotationDegrees * 0.017453292519943295;
		alpha = 1;
		mEndScale = scale * scaleDampening;
		mElapsed = 0;
		mHold = hold;
		mTotal = total;
		mBuff = buff;
		if (buff) {
			_loc13_ = speed * total * 2;
			mEndX = x + directionX * _loc13_;
			mPeakY = y + directionY * _loc13_ * 0.5;
			mEndY = mPeakY - directionY * _loc13_ * 0.7;
		} else {
			_loc12_ = speed * total;
			mEndX = x + directionX * _loc12_;
			mEndY = y + directionY * _loc12_;
		}
	}

	public function advance(seconds:Float):Bool {
		var _loc5_ = Math.NaN;
		var _loc4_ = Math.NaN;
		mElapsed += seconds;
		var _loc3_ = mElapsed;
		if (!mBuff) {
			_loc4_ = mTotal * 0.8;
			_loc5_ = Quint.easeOut(ratio(_loc3_ - mHold, _loc4_));
			x = mStartX + (mEndX - mStartX) * _loc5_;
			y = mStartY + (mEndY - mStartY) * _loc5_;
			scaleX = scaleY = mStartScale + (mEndScale - mStartScale) * _loc5_;
			alpha = 1 - Quad.easeOut(ratio(_loc3_ - mHold - _loc4_, mTotal * 0.2));
			return _loc3_ < mHold + mTotal;
		}
		_loc5_ = Quad.easeOut(ratio(_loc3_, mTotal));
		x = mStartX + (mEndX - mStartX) * _loc5_;
		scaleX = scaleY = mStartScale + (mEndScale - mStartScale) * _loc5_;
		alpha = 1 - Quad.easeOut(ratio(_loc3_ - mTotal * 0.7, mTotal * 0.3));
		var _loc2_ = mTotal * 0.1;
		if (_loc3_ < _loc2_) {
			y = mStartY + (mPeakY - mStartY) * Quint.easeOut(ratio(_loc3_, _loc2_));
		} else {
			y = mPeakY + (mEndY - mPeakY) * Quint.easeIn(ratio(_loc3_ - _loc2_, mTotal * 0.7));
		}
		return _loc3_ < mTotal;
	}
}
