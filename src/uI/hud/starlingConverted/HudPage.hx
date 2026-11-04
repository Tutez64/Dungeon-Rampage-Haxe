package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakeBudget;
import brain.starling.swfConverter.BakedPicture;
import brain.starling.swfConverter.ShelfPacker;
import flash.display.BitmapData;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.textures.Texture;
import starling.utils.MathUtil;

/*internal*/
class HudPage {
	static inline final POOL = "hudStarling";

	static final sRect:Rectangle = new Rectangle();

	static final sPoint:Point = new Point();

	@:allow(uI.hud.starlingConverted) var mTexture:Texture;

	@:allow(uI.hud.starlingConverted) var mPixels:BitmapData;

	@:allow(uI.hud.starlingConverted) var mSingle:Bool = false;

	@:allow(uI.hud.starlingConverted) var mDirty:Bool = false;

	@:allow(uI.hud.starlingConverted) var mCells:Int = 0;

	@:allow(uI.hud.starlingConverted) var mWidth:Int = 0;

	@:allow(uI.hud.starlingConverted) var mHeight:Int = 0;

	@:allow(uI.hud.starlingConverted) var mRectangle:Bool = true;

	var mPacker:ShelfPacker;

	public function new() {}

	@:allow(uI.hud.starlingConverted) static function create(width:Int, height:Int, single:Bool):HudPage {
		HudPages.sCapacityRefused = false;
		var _loc4_ = Starling.current;
		if (_loc4_ == null || !_loc4_.contextValid) {
			return null;
		}
		var _loc5_ = _loc4_.profile != "baselineConstrained";
		if (!_loc5_) {
			width = MathUtil.getNextPowerOfTwo(width);
			height = MathUtil.getNextPowerOfTwo(height);
		}
		if (!BakeBudget.reserve("hudStarling", width, height, true, _loc5_)) {
			HudPages.sCapacityRefused = true;
			return null;
		}
		var _loc6_ = new HudPage();
		_loc6_.mWidth = width;
		_loc6_.mHeight = height;
		_loc6_.mSingle = single;
		_loc6_.mRectangle = _loc5_;
		_loc6_.mPacker = new ShelfPacker(width, height);
		try {
			_loc6_.mTexture = Texture.empty(width, height, true, false, false, 1);
			_loc6_.mTexture.root.onRestore = _loc6_.restorePixels;
			_loc6_.mPixels = new BitmapData(width, height, true, (0 : UInt));
			_loc6_.mDirty = true;
		} catch (error:Dynamic) {
			if (_loc6_.mTexture != null) {
				_loc6_.mTexture.dispose();
			}
			if (_loc6_.mPixels != null) {
				_loc6_.mPixels.dispose();
			}
			BakeBudget.unreserve("hudStarling", width, height, _loc5_);
			StarlingHud.reportError(error);
			return null;
		}
		return _loc6_;
	}

	@:allow(uI.hud.starlingConverted) function place(w:Int, h:Int, out:Point):Bool {
		if (w > mWidth || h > mHeight) {
			return false;
		}
		if (mSingle) {
			if (mCells > 0) {
				return false;
			}
			out.setTo(0, 0);
			return true;
		}
		return mPacker.place(w, h, out);
	}

	@:allow(uI.hud.starlingConverted) function free(x:Int, y:Int, w:Int) {
		if (mSingle) {
			return;
		}
		mPacker.free(x, y, w);
	}

	@:allow(uI.hud.starlingConverted) function write(bake:BakedPicture, x:Int, y:Int, slotWidth:Int, slotHeight:Int) {
		sRect.setTo(x, y, slotWidth + 1, slotHeight + 1);
		mPixels.fillRect(sRect, (0 : UInt));
		sPoint.setTo(x, y);
		mPixels.copyPixels(bake.bitmap, bake.bitmap.rect, sPoint);
		mDirty = true;
		if (Starling.current != null) {
			Starling.current.setRequiresRedraw();
		}
	}

	@:allow(uI.hud.starlingConverted) function upload():Bool {
		if (!mDirty || mTexture == null) {
			return false;
		}
		mTexture.root.uploadBitmapData(mPixels);
		mDirty = false;
		return true;
	}

	function restorePixels() {
		try {
			mTexture.root.uploadBitmapData(mPixels);
			mDirty = false;
		} catch (error:Dynamic) {
			mDirty = true;
			StarlingHud.reportError(error);
		}
	}

	@:allow(uI.hud.starlingConverted) function dispose() {
		if (mTexture == null) {
			return;
		}
		mTexture.dispose();
		mTexture = null;
		mPixels.dispose();
		mPixels = null;
		BakeBudget.unreserve("hudStarling", mWidth, mHeight, mRectangle);
	}
}
