package brain.starling.swfConverter;

import flash.display.DisplayObject;
import flash.geom.Point;
import flash.geom.Rectangle;
import starling.core.Starling;
import starling.events.Event;
import starling.textures.SubTexture;

class BakedPages {
	static var sAttached:Starling;

	static var sRenders:Int = 0;

	static final sAll:Vector<BakedPages> = new Vector((0 : UInt));

	static final sSlotPages:Vector<BakedPage> = new Vector((0 : UInt));

	static final sSlotX:Vector<Int> = new Vector((0 : UInt));

	static final sSlotY:Vector<Int> = new Vector((0 : UInt));

	static final sSlotWidth:Vector<Int> = new Vector((0 : UInt));

	static final sSlotStamp:Vector<Int> = new Vector((0 : UInt));

	static final sRetired:Vector<BakedPage> = new Vector((0 : UInt));

	static final sPoint:Point = new Point();

	static final sRegion:Rectangle = new Rectangle();

	var mPool:String;

	var mPageWidth:Int = 0;

	var mPageHeight:Int = 0;

	var mCells__Brain_Starling_SwfConverter_BakedPages /*redefined private*/:ASObject = {};

	var mPages__Brain_Starling_SwfConverter_BakedPages /*redefined private*/:Vector<BakedPage> = new Vector((0 : UInt));

	public function new(pool:String, pageWidth:Int = 1024, pageHeight:Int = 512) {
		mPool = pool;
		mPageWidth = pageWidth;
		mPageHeight = pageHeight;
		sAll.push(this);
	}

	public static function scaleKey(pixelScale:Float):String {
		return Std.string(Math.fround(pixelScale * 1000) / 1000);
	}

	public static function attach(starling:Starling) {
		if (sAttached == starling) {
			return;
		}
		if (sAttached != null) {
			sAttached.removeEventListener("render", onRender);
		}
		sAttached = starling;
		if (starling != null) {
			starling.addEventListener("render", onRender);
		}
	}

	static function onRender(event:Event) {
		var _loc3_ = 0;
		var _loc2_ = 0;
		var _loc4_:BakedPage = null;
		_loc3_ = sRetired.length - 1;
		while (_loc3_ >= 0) {
			if (sRetired[_loc3_].retiredAt < sRenders) {
				sRetired[_loc3_].dispose();
				sRetired.removeAt(_loc3_);
			}
			_loc3_--;
		}
		_loc2_ = sSlotPages.length - 1;
		while (_loc2_ >= 0) {
			if (sSlotStamp[_loc2_] < sRenders) {
				_loc4_ = sSlotPages[_loc2_];
				if (_loc4_.texture != null && _loc4_.retiredAt < 0) {
					_loc4_.free(sSlotX[_loc2_], sSlotY[_loc2_], sSlotWidth[_loc2_]);
				}
				sSlotPages.removeAt(_loc2_);
				sSlotX.removeAt(_loc2_);
				sSlotY.removeAt(_loc2_);
				sSlotWidth.removeAt(_loc2_);
				sSlotStamp.removeAt(_loc2_);
			}
			_loc2_--;
		}
		sRenders = sRenders + 1;
		uploadAll();
	}

	static function retire(page:BakedPage) {
		page.retiredAt = sRenders;
		sRetired.push(page);
	}

	public static function uploadAll() {
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < sAll.length) {
			try {
				sAll[_loc1_].uploadDirty();
			} catch (error:Dynamic) {}
			_loc1_++;
		}
	}

	public static function restoreAll() {
		var _loc3_:BakedPage;
		var __ax4_iter_497:Vector<BakedPage>;
		var _loc1_ = 0;
		_loc1_ = 0;
		while (_loc1_ < sAll.length) {
			__ax4_iter_497 = sAll[_loc1_].mPages__Brain_Starling_SwfConverter_BakedPages;
			if (checkNullIteratee(__ax4_iter_497))
				for (_tmp_ in __ax4_iter_497) {
					_loc3_ = _tmp_;
					restorePage(_loc3_);
				}
			_loc1_++;
		}
		var _loc2_:BakedPage;
		final __ax4_iter_498 = sRetired;
		if (checkNullIteratee(__ax4_iter_498))
			for (_tmp_ in __ax4_iter_498) {
				_loc2_ = _tmp_;
				restorePage(_loc2_);
			}
	}

	static function restorePage(page:BakedPage) {
		try {
			page.restore();
		} catch (error:Dynamic) {
			page.dirty = true;
		}
	}

	public static function disposeAll() {
		while (sAll.length > 0) {
			sAll[sAll.length - 1].dispose();
		}
		flushRetired();
		attach(null);
	}

	static function flushRetired() {
		while (sRetired.length > 0) {
			sRetired.pop().dispose();
		}
		sSlotPages.length = sSlotX.length = sSlotY.length = sSlotWidth.length = sSlotStamp.length = 0;
	}

	@:isVar public var pageWidth(get, never):Int;

	public function get_pageWidth():Int {
		return mPageWidth;
	}

	@:isVar public var pageHeight(get, never):Int;

	public function get_pageHeight():Int {
		return mPageHeight;
	}

	public function acquire(key:String):BakedCell {
		var _loc2_ = ASCompat.coerce(mCells__Brain_Starling_SwfConverter_BakedPages[key], brain.starling.swfConverter.BakedCell);
		if (_loc2_ != null) {
			_loc2_.mRefCount++;
		}
		return _loc2_;
	}

	public function bake(key:String, source:DisplayObject, pixelScale:Float, hide:Vector<DisplayObject> = null):BakedCell {
		var _loc6_ = acquire(key);
		if (_loc6_ != null) {
			return _loc6_;
		}
		var _loc5_ = FlashBaker.bake(source, pixelScale, hide);
		return ASCompat.coerce(_loc5_ != null ? add(key, _loc5_) : null, brain.starling.swfConverter.BakedCell);
	}

	public function add(key:String, bake:BakedPicture, force:Bool = false):BakedCell {
		var __finallyReturn0:BakedCell;
		var __finallyReturn1:BakedCell;
		var __finallyReturn2:BakedCell;
		var _loc4_:BakedCell = null;
		{
			var __finallyReturn0:BakedCell;
			var __finallyReturn1:BakedCell;
			var __finallyReturn2:BakedCell;
			try {
				_loc4_ = acquire(key);
				if (_loc4_ != null) {
					{
						__finallyReturn0 = _loc4_;
						{
							bake.dispose();
						};
						return __finallyReturn0;
					};
				}
				_loc4_ = new BakedCell();
				_loc4_.mKey__Brain_Starling_SwfConverter_BakedCell = key;
				if (!placeAndWrite(_loc4_, bake, force)) {
					{
						__finallyReturn1 = null;
						{
							bake.dispose();
						};
						return __finallyReturn1;
					};
				}
				_loc4_.mRefCount = 1;
				mCells__Brain_Starling_SwfConverter_BakedPages[key] = _loc4_;
				{
					__finallyReturn2 = _loc4_;
					{
						bake.dispose();
					};
					return __finallyReturn2;
				};
			} catch (__finallyError3:Dynamic) {
				{
					bake.dispose();
				};
				throw __finallyError3;
			};
			{
				bake.dispose();
			};
		}
		return null;
	}

	public function release(cell:BakedCell) {
		if (cell == null || mCells__Brain_Starling_SwfConverter_BakedPages[cell.mKey__Brain_Starling_SwfConverter_BakedCell] != cell) {
			return;
		}
		if (--cell.mRefCount > 0) {
			return;
		}
		ASCompat.deleteProperty(mCells__Brain_Starling_SwfConverter_BakedPages, cell.mKey__Brain_Starling_SwfConverter_BakedCell);
		cell.mTexture__Brain_Starling_SwfConverter_BakedCell.dispose();
		cell.mTexture__Brain_Starling_SwfConverter_BakedCell = null;
		freeSlot(cell.mPage__Brain_Starling_SwfConverter_BakedCell, cell.mSlotX, cell.mSlotY, cell.mSlotWidth__Brain_Starling_SwfConverter_BakedCell);
		cell.mPage__Brain_Starling_SwfConverter_BakedCell = null;
	}

	public function uploadDirty() {
		var _loc1_:BakedPage;
		final __ax4_iter_499 = mPages__Brain_Starling_SwfConverter_BakedPages;
		if (checkNullIteratee(__ax4_iter_499))
			for (_tmp_ in __ax4_iter_499) {
				_loc1_ = _tmp_;
				if (_loc1_.dirty) {
					_loc1_.upload();
				}
			}
	}

	public function dispose() {
		var _loc3_:BakedCell = null;
		var _loc4_:String;
		final __ax4_iter_500:ASObject = mCells__Brain_Starling_SwfConverter_BakedPages;
		if (checkNullIteratee(__ax4_iter_500))
			for (_tmp_ in __ax4_iter_500.___keys()) {
				_loc4_ = _tmp_;
				_loc3_ = ASCompat.coerce(mCells__Brain_Starling_SwfConverter_BakedPages[_loc4_], brain.starling.swfConverter.BakedCell);
				_loc3_.mTexture__Brain_Starling_SwfConverter_BakedCell.dispose();
				_loc3_.mTexture__Brain_Starling_SwfConverter_BakedCell = null;
				_loc3_.mPage__Brain_Starling_SwfConverter_BakedCell = null;
				_loc3_.mRefCount = 0;
			}
		mCells__Brain_Starling_SwfConverter_BakedPages = {};
		var _loc2_:BakedPage;
		final __ax4_iter_501 = mPages__Brain_Starling_SwfConverter_BakedPages;
		if (checkNullIteratee(__ax4_iter_501))
			for (_tmp_ in __ax4_iter_501) {
				_loc2_ = _tmp_;
				retire(_loc2_);
			}
		mPages__Brain_Starling_SwfConverter_BakedPages.length = 0;
		var _loc1_ = sAll.indexOf(this);
		if (_loc1_ >= 0) {
			sAll.splice(_loc1_, (1 : UInt));
		}
	}

	function placeAndWrite(cell:BakedCell, bake:BakedPicture, force:Bool):Bool {
		var _loc4_:BakedPage;
		var __ax4_iter_502:Vector<BakedPage>;
		var _loc5_ = bake.bitmap.width;
		var _loc7_ = bake.bitmap.height;
		var _loc6_ = 1;
		var _loc9_:BakedPage = null;
		if (_loc5_ + _loc6_ <= mPageWidth && _loc7_ + _loc6_ <= mPageHeight) {
			__ax4_iter_502 = mPages__Brain_Starling_SwfConverter_BakedPages;
			if (checkNullIteratee(__ax4_iter_502))
				for (_tmp_ in __ax4_iter_502) {
					_loc4_ = _tmp_;
					if (!_loc4_.single && _loc4_.place(_loc5_ + _loc6_, _loc7_ + _loc6_, sPoint)) {
						_loc9_ = _loc4_;
						break;
					}
				}
			if (_loc9_ == null) {
				_loc9_ = BakedPage.create(mPool, mPageWidth, mPageHeight, false, force);
				if (_loc9_ == null || !_loc9_.place(_loc5_ + _loc6_, _loc7_ + _loc6_, sPoint)) {
					if (_loc9_ != null) {
						_loc9_.dispose();
					}
					return false;
				}
				mPages__Brain_Starling_SwfConverter_BakedPages.push(_loc9_);
			}
		} else {
			_loc9_ = BakedPage.create(mPool, _loc5_, _loc7_, true, force);
			if (_loc9_ == null) {
				return false;
			}
			_loc9_.place(_loc5_, _loc7_, sPoint);
			mPages__Brain_Starling_SwfConverter_BakedPages.push(_loc9_);
		}
		if (sAll.indexOf(this) < 0) {
			sAll.push(this);
		}
		cell.mPage__Brain_Starling_SwfConverter_BakedCell = _loc9_;
		cell.mSlotX = ASCompat.floatToInt(sPoint.x);
		cell.mSlotY = ASCompat.floatToInt(sPoint.y);
		cell.mSlotWidth__Brain_Starling_SwfConverter_BakedCell = _loc9_.single ? _loc9_.width : _loc5_;
		var _loc8_ = _loc9_.single ? _loc9_.height : _loc7_;
		_loc9_.cells++;
		_loc9_.write(bake, cell.mSlotX, cell.mSlotY, cell.mSlotWidth__Brain_Starling_SwfConverter_BakedCell, _loc8_);
		cell.mWidth = _loc5_;
		cell.mHeight = _loc7_;
		cell.mOriginX = bake.originX;
		cell.mOriginY = bake.originY;
		cell.mPixelScale = bake.pixelScale;
		cell.mEmpty = bake.empty;
		sRegion.setTo(cell.mSlotX, cell.mSlotY, cell.mSlotWidth__Brain_Starling_SwfConverter_BakedCell, _loc8_);
		cell.mTexture__Brain_Starling_SwfConverter_BakedCell = new SubTexture(_loc9_.texture, sRegion, false, null, false, bake.pixelScale);
		return true;
	}

	function freeSlot(page:BakedPage, x:Int, y:Int, slotWidth:Int) {
		var _loc5_:BakedPage;
		var __ax4_iter_503:Vector<BakedPage>;
		var _loc7_ = false;
		page.cells--;
		if (!page.single) {
			sSlotPages.push(page);
			sSlotX.push(x);
			sSlotY.push(y);
			sSlotWidth.push(slotWidth + 1);
			sSlotStamp.push(sRenders);
		}
		if (page.cells > 0) {
			return;
		}
		if (!page.single) {
			_loc7_ = false;
			__ax4_iter_503 = mPages__Brain_Starling_SwfConverter_BakedPages;
			if (checkNullIteratee(__ax4_iter_503))
				for (_tmp_ in __ax4_iter_503) {
					_loc5_ = _tmp_;
					if (_loc5_ != page && !_loc5_.single && _loc5_.cells == 0) {
						_loc7_ = true;
					}
				}
			if (!_loc7_) {
				return;
			}
		}
		var _loc6_ = mPages__Brain_Starling_SwfConverter_BakedPages.indexOf(page);
		if (_loc6_ >= 0) {
			mPages__Brain_Starling_SwfConverter_BakedPages.splice(_loc6_, (1 : UInt));
		}
		retire(page);
	}
}
