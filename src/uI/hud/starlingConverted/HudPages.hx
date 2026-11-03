package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakeBudget;
import brain.starling.swfConverter.BakedCell;
import brain.starling.swfConverter.BakedPages;
import brain.starling.swfConverter.BakedPicture;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.textures.SubTexture;

/*internal*/
class HudPages extends BakedPages {
	@:allow(UI.Hud.StarlingConverted) static var sCapacityRefused:Bool = false;

	@:allow(UI.Hud.StarlingConverted) var mPinBakes:Bool = false;

	var mCells:ASObject = {};

	var mPages:Vector<HudPage> = new Vector((0 : UInt));

	var mPoint:Point = new Point();

	var mRegion:Rectangle = new Rectangle();

	public function new(frames:Bool = false) {
		super("hudStarling", frames ? 512 : 1024, frames ? 512 : 1024);
	}

	@:isVar public var accountedBytes(get, never):Float;

	public function get_accountedBytes():Float {
		var _loc2_:HudPage = null;
		var _loc1_:Float = 0;
		final __ax4_iter_256 = mPages;
		if (checkNullIteratee(__ax4_iter_256))
			for (_tmp_ in __ax4_iter_256) {
				_loc2_ = _tmp_;
				_loc1_ += BakeBudget.accountedBytes(_loc2_.mWidth, _loc2_.mHeight, _loc2_.mRectangle);
			}
		return _loc1_;
	}

	@:allow(UI.Hud.StarlingConverted) @:isVar var pinnedBytes(get, never):Float;

	function get_pinnedBytes():Float {
		var _loc2_:HudCell = null;
		var _loc1_:Float = 0;
		final __ax4_iter_257:ASObject = mCells;
		if (checkNullIteratee(__ax4_iter_257))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_257)) {
				_loc2_ = ASCompat.coerce(_tmp_, uI.hud.starlingConverted.HudCell);
				if (_loc2_.mPinned) {
					_loc1_ += _loc2_.pixelWidth * _loc2_.pixelHeight * 4;
				}
			}
		return _loc1_;
	}

	override public function acquire(key:String):BakedCell {
		var _loc2_ = ASCompat.coerce(mCells[key], uI.hud.starlingConverted.HudCell);
		if (_loc2_ != null) {
			_loc2_.mReferences++;
			if (mPinBakes) {
				_loc2_.mPinned = true;
			}
		}
		return _loc2_;
	}

	override public function add(key:String, bake:BakedPicture, force:Bool = false):BakedCell {
		var __finallyReturn35:BakedCell;
		var __finallyReturn36:BakedCell;
		var _loc4_ = ASCompat.reinterpretAs(acquire(key), HudCell);
		if (_loc4_ != null) {
			bake.dispose();
			return _loc4_;
		}
		_loc4_ = new HudCell();
		_loc4_.mKey = key;
		_loc4_.mPinned = mPinBakes;
		{
			var __finallyReturn35:BakedCell;
			var __finallyReturn36:BakedCell;
			try {
				StarlingRaster.limit(bake);
				if (!place(_loc4_, bake)) {
					{
						__finallyReturn35 = null;
						{
							bake.dispose();
						};
						return __finallyReturn35;
					};
				}
				mCells[key] = _loc4_;
				{
					__finallyReturn36 = _loc4_;
					{
						bake.dispose();
					};
					return __finallyReturn36;
				};
			} catch (__finallyError37:Dynamic) {
				{
					bake.dispose();
				};
				throw __finallyError37;
			};
			{
				bake.dispose();
			};
		}
		return null;
	}

	function place(cell:HudCell, bake:BakedPicture):Bool {
		var __ax4_iter_258:Vector<HudPage>;
		var _loc6_:HudPage = null;
		var _loc4_:HudPage = null;
		sCapacityRefused = false;
		if (Starling.current == null || !Starling.current.contextValid) {
			return false;
		}
		var _loc5_ = bake.bitmap.width;
		var _loc7_ = bake.bitmap.height;
		var _loc3_ = _loc5_ + 1 > pageWidth || _loc7_ + 1 > pageHeight;
		HudArt.beginEviction();
		while (true) {
			if (!_loc3_) {
				__ax4_iter_258 = mPages;
				if (checkNullIteratee(__ax4_iter_258))
					for (_tmp_ in __ax4_iter_258) {
						_loc4_ = _tmp_;
						if (!_loc4_.mSingle && _loc4_.place(_loc5_ + 1, _loc7_ + 1, mPoint)) {
							_loc6_ = _loc4_;
							break;
						}
					}
			}
			if (_loc6_ == null) {
				_loc6_ = HudPage.create(_loc3_ ? _loc5_ : pageWidth, _loc3_ ? _loc7_ : pageHeight, _loc3_);
				if (_loc6_ != null) {
					_loc6_.place(_loc3_ ? _loc5_ : _loc5_ + 1, _loc3_ ? _loc7_ : _loc7_ + 1, mPoint);
					mPages.push(_loc6_);
				}
			}
			if (_loc6_ != null) {
				break;
			}
			if (!sCapacityRefused) {
				return false;
			}
			if (!HudArt.evictContent()) {
				return false;
			}
		}
		cell.mPage = _loc6_;
		cell.mX = ASCompat.floatToInt(mPoint.x);
		cell.mY = ASCompat.floatToInt(mPoint.y);
		cell.mSlotWidth = _loc5_;
		cell.mSlotHeight = _loc7_;
		_loc6_.mCells++;
		try {
			_loc6_.write(bake, cell.mX, cell.mY, _loc5_, _loc7_);
			mRegion.setTo(cell.mX, cell.mY, _loc5_, _loc7_);
			cell.mTexture = new SubTexture(_loc6_.mTexture, mRegion, false, null, false, bake.pixelScale);
			cell.mBake = bake;
		} catch (error:Dynamic) {
			free(_loc6_, cell.mX, cell.mY, _loc5_);
			throw error;
		}
		return true;
	}

	override public function release(value:BakedCell) {
		var _loc2_ = ASCompat.reinterpretAs(value, HudCell);
		if (_loc2_ == null || mCells[_loc2_.key] != _loc2_ || _loc2_.mReferences <= 0) {
			return;
		}
		if (--_loc2_.mReferences > 0 || _loc2_.mPinned) {
			return;
		}
		ASCompat.deleteProperty(mCells, _loc2_.key);
		_loc2_.mTexture.dispose();
		_loc2_.mTexture = null;
		free(_loc2_.mPage, _loc2_.mX, _loc2_.mY, _loc2_.mSlotWidth);
		_loc2_.mPage = null;
	}

	function free(page:HudPage, x:Int, y:Int, width:Int) {
		page.mCells--;
		page.free(x, y, width + 1);
		if (page.mCells == 0) {
			mPages.removeAt(mPages.indexOf(page));
			page.dispose();
		}
	}

	override public function uploadDirty() {
		var _loc1_:HudPage = null;
		final __ax4_iter_259 = mPages;
		if (checkNullIteratee(__ax4_iter_259))
			for (_tmp_ in __ax4_iter_259) {
				_loc1_ = _tmp_;
				try {
					_loc1_.upload();
				} catch (error:Dynamic) {
					StarlingHud.reportError(error);
				}
			}
	}

	override public function dispose() {
		var _loc2_:HudCell = null;
		var _loc1_:HudPage = null;
		final __ax4_iter_260:ASObject = mCells;
		if (checkNullIteratee(__ax4_iter_260))
			for (_tmp_ in iterateDynamicValues(__ax4_iter_260)) {
				_loc2_ = ASCompat.coerce(_tmp_, uI.hud.starlingConverted.HudCell);
				_loc2_.mTexture.dispose();
				_loc2_.mTexture = null;
			}
		final __ax4_iter_261 = mPages;
		if (checkNullIteratee(__ax4_iter_261))
			for (_tmp_ in __ax4_iter_261) {
				_loc1_ = _tmp_;
				_loc1_.dispose();
			}
		mPages.length = 0;
		mCells = {};
		super.dispose();
	}
}
