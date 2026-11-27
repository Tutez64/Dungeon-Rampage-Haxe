package brain.starling.swfConverter;

import flash.geom.Point;

class ShelfPacker {
	var mWidth:Int = 0;

	var mHeight:Int = 0;

	var mShelfY:Vector<Int> = new Vector((0 : UInt));

	var mShelfHeight:Vector<Int> = new Vector((0 : UInt));

	var mShelfFree:Vector<Vector<Int>> = new Vector((0 : UInt));

	var mUsedHeight:Int = 0;

	public function new(width:Int, height:Int) {
		mWidth = width;
		mHeight = height;
	}

	public function place(w:Int, h:Int, out:Point):Bool {
		var _loc5_ = 0;
		if (w > mWidth || h > mHeight) {
			return false;
		}
		var _loc6_ = findShelf(w, h, h + (h >> 1) + 4);
		if (_loc6_ < 0 && mUsedHeight + h <= mHeight) {
			_loc6_ = mShelfY.length;
			mShelfY.push(mUsedHeight);
			mShelfHeight.push(h);
			mShelfFree.push(Vector.ofArray([0, mWidth]));
			mUsedHeight += h;
		}
		if (_loc6_ < 0) {
			_loc6_ = findShelf(w, h, 2147483647);
		}
		if (_loc6_ < 0) {
			return false;
		}
		var _loc4_ = mShelfFree[_loc6_];
		_loc5_ = 0;
		while (_loc5_ < _loc4_.length) {
			if (_loc4_[_loc5_ + 1] >= w) {
				out.setTo(_loc4_[_loc5_], mShelfY[_loc6_]);
				_loc4_[_loc5_] += w;
				_loc4_[_loc5_ + 1] -= w;
				if (_loc4_[_loc5_ + 1] == 0) {
					_loc4_.splice(_loc5_, (2 : UInt));
				}
				return true;
			}
			_loc5_ += 2;
		}
		return false;
	}

	public function free(x:Int, y:Int, w:Int) {
		var _loc8_:Float;
		var _loc9_:Float;
		var _loc5_:Vector<Int> = /*undefined*/ null;
		var _loc7_ = mShelfY.indexOf(y);
		if (_loc7_ < 0) {
			return;
		}
		var _loc4_ = mShelfFree[_loc7_];
		var _loc6_ = 0;
		while (_loc6_ < _loc4_.length && _loc4_[_loc6_] < x) {
			_loc6_ += 2;
		}
		ASCompat.vectorSplice(_loc4_, _loc6_, (0 : UInt), [x, w]);
		if (_loc6_ + 2 < _loc4_.length && _loc4_[_loc6_] + _loc4_[_loc6_ + 1] == _loc4_[_loc6_ + 2]) {
			_loc8_ = _loc6_ + 1;
			_loc9_ = _loc4_[ASCompat.floatToInt(_loc8_)] + _loc4_[_loc6_ + 3];
			_loc4_[ASCompat.floatToInt(_loc8_)] = ASCompat.floatToInt(_loc9_);
			_loc4_.splice(_loc6_ + 2, (2 : UInt));
		}
		if (_loc6_ >= 2 && _loc4_[_loc6_ - 2] + _loc4_[_loc6_ - 1] == _loc4_[_loc6_]) {
			_loc9_ = _loc6_ - 1;
			_loc8_ = _loc4_[ASCompat.floatToInt(_loc9_)] + _loc4_[_loc6_ + 1];
			_loc4_[ASCompat.floatToInt(_loc9_)] = ASCompat.floatToInt(_loc8_);
			_loc4_.splice(_loc6_, (2 : UInt));
		}
		while (mShelfY.length > 0) {
			_loc5_ = mShelfFree[mShelfFree.length - 1];
			if (_loc5_.length != 2 || _loc5_[0] != 0 || _loc5_[1] != mWidth) {
				break;
			}
			mUsedHeight -= mShelfHeight.pop();
			mShelfY.pop();
			mShelfFree.pop();
		}
	}

	function findShelf(w:Int, h:Int, maxHeight:Int):Int {
		var _loc5_ = 0;
		var _loc7_ = 0;
		var _loc4_:Vector<Int> = /*undefined*/ null;
		var _loc6_ = 0;
		_loc5_ = 0;
		while (_loc5_ < mShelfY.length) {
			_loc7_ = mShelfHeight[_loc5_];
			if (!(_loc7_ < h || _loc7_ > maxHeight)) {
				_loc4_ = mShelfFree[_loc5_];
				_loc6_ = 1;
				while (_loc6_ < _loc4_.length) {
					if (_loc4_[_loc6_] >= w) {
						return _loc5_;
					}
					_loc6_ += 2;
				}
			}
			_loc5_++;
		}
		return -1;
	}
}
