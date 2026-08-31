package dungeon;

import brain.logger.Logger;
import flash.geom.Rectangle;
import flash.geom.Vector3D;

class TileGrid {
	public static inline final DEFAULT_GRID_WIDTH = (12 : UInt);

	public static inline final DEFAULT_GRID_HEIGHT = (12 : UInt);

	static inline final MAX_VISIBLE_TILES = (16 : UInt);

	var mGridWidth:UInt = 0;

	var mGridHeight:UInt = 0;

	var mTiles:Vector<Tile>;

	var mEmptyTileColiders:Vector<RectangleNavCollider>;

	public function new(gridWidth:UInt = (12 : UInt), gridHeight:UInt = (12 : UInt)) {
		var _loc4_ = 0;
		var _loc3_ = 0;

		mGridWidth = gridWidth;
		mGridHeight = gridHeight;
		mTiles = new Vector<Tile>();
		mEmptyTileColiders = new Vector<RectangleNavCollider>();
		_loc4_ = 0;
		while ((_loc4_ : UInt) < mGridHeight) {
			_loc3_ = 0;
			while ((_loc3_ : UInt) < mGridWidth) {
				mTiles.push(null);
				mEmptyTileColiders.push(null);
				_loc3_ = ASCompat.toInt(_loc3_) + 1;
			}
			_loc4_ = ASCompat.toInt(_loc4_) + 1;
		}
	}

	public function getNonFillTilePositions():Vector<Vector3D> {
		var _loc1_ = new Vector<Vector3D>();
		var _loc2_:Tile;
		final __ax4_iter_143 = mTiles;
		if (checkNullIteratee(__ax4_iter_143))
			for (_tmp_ in __ax4_iter_143) {
				_loc2_ = _tmp_;
				if (_loc2_ != null && !_loc2_.isFiller()) {
					_loc1_.push(_loc2_.position.clone());
				}
			}
		return _loc1_;
	}

	public function isPositionOpenForATile(pos:Vector3D):Bool {
		if (getTileIndexAtPosition(pos) >= 0) {
			return getTileAtPosition(pos) == null;
		}
		return false;
	}

	function setTileAtIndex(i:UInt, j:UInt, tile:Tile) {
		if (i >= mGridWidth || j >= mGridHeight) {
			throw new Error("index out of range");
		}
		mTiles[(i + j * mGridWidth : Int)] = tile;
		var _loc4_ = mEmptyTileColiders[(i + j * mGridWidth : Int)];
		if (_loc4_ != null) {
			_loc4_.destroy();
			mEmptyTileColiders[(i + j * mGridWidth : Int)] = null;
		}
	}

	public function SetEmptyColliderAtIndex(i:UInt, j:UInt, col:RectangleNavCollider) {
		if (i >= mGridWidth || j >= mGridHeight) {
			throw new Error("index out of range");
		}
		mEmptyTileColiders[(i + j * mGridWidth : Int)] = col;
	}

	public function getEmptyColliderAtIndex(i:UInt, j:UInt):RectangleNavCollider {
		if (i >= mGridWidth || j >= mGridHeight) {
			return null;
		}
		return mEmptyTileColiders[(i + j * mGridWidth : Int)];
	}

	public function setTileAtPosition(pos:Vector3D, tile:Tile) {
		if (pos.x < -900 || pos.y < -900) {
			Logger.error("setTileAtPosition: position must be positive: " + pos.toString());
			return;
		}
		var _loc3_ = (Std.int((pos.x + 900) / 900) : UInt);
		var _loc4_ = (Std.int((pos.y + 900) / 900) : UInt);
		setTileAtIndex(_loc3_, _loc4_, tile);
	}

	public function getTileAtIndex(i:UInt, j:UInt):Tile {
		if (i >= mGridWidth || j >= mGridHeight) {
			return null;
		}
		return mTiles[(i + j * mGridWidth : Int)];
	}

	public function getTileAtPosition(pos:Vector3D):Tile {
		if (pos.x < -900 || pos.y < -900) {
			return null;
		}
		var _loc2_ = (Std.int((pos.x + 900) / 900) : UInt);
		var _loc3_ = (Std.int((pos.y + 900) / 900) : UInt);
		return getTileAtIndex(_loc2_, _loc3_);
	}

	public function getTileIndexAtPosition(pos:Vector3D):Int {
		if (pos.x < -900 || pos.y < -900) {
			return -1;
		}
		var _loc2_ = (Std.int((pos.x + 900) / 900) : UInt);
		var _loc3_ = (Std.int((pos.y + 900) / 900) : UInt);
		if (_loc2_ >= mGridWidth || _loc3_ >= mGridHeight) {
			return -1;
		}
		return (_loc2_ + _loc3_ * mGridWidth : Int);
	}

	public function getVisibleTiles(rect:Rectangle):Vector<Tile> {
		var _loc3_:Tile = null;
		var _loc4_ = 0;
		var _loc2_ = 0;
		var _loc5_ = new Vector<Tile>();
		_loc4_ = 0;
		_loc2_ = mTiles.length;
		while (_loc4_ < _loc2_) {
			_loc3_ = mTiles[_loc4_];
			if (_loc3_ != null && _loc3_.bounds.intersects(rect)) {
				_loc5_.push(_loc3_);
			}
			_loc4_++;
		}
		if (_loc5_.length > 16) {
			Logger.warn("getVisibleTiles: found " + _loc5_.length + " visible. Something wrong?");
		}
		return _loc5_;
	}

	public function iterator(onlyOnStage:Bool = false):TileGridIterator {
		return new TileGridIterator(mTiles, onlyOnStage);
	}

	public function removeAllFromWorld() {
		var _loc1_:Tile;
		final __ax4_iter_144 = mTiles;
		if (checkNullIteratee(__ax4_iter_144))
			for (_tmp_ in __ax4_iter_144) {
				_loc1_ = _tmp_;
				if (_loc1_ != null) {
					_loc1_.destroy();
				}
			}
	}

	public function removeTileAtPosition(pos:Vector3D) {
		var _loc2_:Float = getTileIndexAtPosition(pos);
		if (_loc2_ >= 0) {
			if (mTiles[Std.int(_loc2_)] != null) {
				mTiles[Std.int(_loc2_)].removeFromStage();
				mTiles[Std.int(_loc2_)].destroy();
			}
			mTiles[Std.int(_loc2_)] = null;
		}
	}

	public function destroy() {
		var _loc2_ = 0;
		var _loc1_:RectangleNavCollider = null;
		removeAllFromWorld();
		if (mEmptyTileColiders != null) {
			_loc2_ = 0;
			while (_loc2_ < mEmptyTileColiders.length) {
				_loc1_ = mEmptyTileColiders[_loc2_];
				if (_loc1_ != null) {
					_loc1_.destroy();
					_loc1_ = null;
				}
				_loc2_ = ASCompat.toInt(_loc2_) + 1;
			}
			mEmptyTileColiders.length = 0;
			mEmptyTileColiders = null;
		}
		mTiles = null;
	}
}
