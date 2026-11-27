package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedCell;
import starling.display.Mesh;
import starling.rendering.IndexData;
import starling.rendering.Painter;
import starling.rendering.VertexData;

/*internal*/
class StarlingSweepMesh extends Mesh {
	static inline final sDeg:Float = 0.017453292519943295;

	var mCell:BakedCell;

	var mArcs:Vector<Float>;

	var mCx:Float = Math.NaN;

	var mCy:Float = Math.NaN;

	var mDirty:Bool = true;

	var mTint:UInt = (16777215 : UInt);

	var mCorners:Vector<Float> = new Vector((8 : UInt), true);

	public function new(cx:Float, cy:Float, capacity:Int) {
		super(new VertexData(null, capacity), new IndexData(capacity * 3));
		indexData.addTriangle((0 : UInt), (2 : UInt), (1 : UInt));
		indexData.numIndices = 0;
		touchable = false;
		mCx = cx;
		mCy = cy;
	}

	static function sortFour(v:Vector<Float>) {
		var _loc3_ = 0;
		var _loc2_ = Math.NaN;
		var _loc4_ = 0;
		_loc3_ = 1;
		while (_loc3_ < 4) {
			_loc2_ = v[_loc3_];
			_loc4_ = _loc3_ - 1;
			while (_loc4_ >= 0 && v[_loc4_] > _loc2_) {
				v[_loc4_ + 1] = v[_loc4_];
				_loc4_--;
			}
			v[_loc4_ + 1] = _loc2_;
			_loc3_++;
		}
	}

	@:isVar public var cell(get, set):BakedCell;

	public function get_cell():BakedCell {
		return mCell;
	}

	function set_cell(value:BakedCell):BakedCell {
		mCell = value;
		if (value != null && value.alive) {
			texture = value.texture;
		}
		mDirty = true;
		setRequiresRedraw();
		return value;
	}

	override public function get_color():UInt {
		return mTint;
	}

	override public function set_color(value:UInt):UInt {
		if (value == mTint) {
			return value;
		}
		mTint = value;
		mDirty = true;
		setRequiresRedraw();
		return value;
	}

	public function setArcs(arcs:Vector<Float>) {
		if (arcs == mArcs) {
			return;
		}
		mArcs = arcs;
		mDirty = true;
		setRequiresRedraw();
	}

	override public function render(painter:Painter) {
		if (mCell == null || !mCell.alive) {
			return;
		}
		if (mDirty) {
			rebuild();
		}
		if (numIndices == 0) {
			return;
		}
		super.render(painter);
	}

	function rebuild() {
		var _loc6_:Float;
		var _loc5_:Float;
		var _loc12_:Float;
		var _loc9_:Float;
		var _loc3_:Float;
		var _loc18_:Float;
		var _loc4_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc2_ = 0;
		var _loc11_ = 0;
		var _loc1_ = 0;
		var _loc16_ = Math.NaN;
		var _loc7_ = 0;
		var _loc19_ = 0;
		var _loc13_ = Math.NaN;
		var _loc8_ = 0;
		mDirty = false;
		var _loc10_ = vertexData;
		var _loc17_ = indexData;
		_loc10_.numVertices = 0;
		_loc17_.numIndices = 0;
		if (mArcs != null && mArcs.length > 0 && texture != null) {
			_loc4_ = mCell.pivotX;
			_loc6_ = mCell.pivotY;
			_loc15_ = texture.width;
			_loc5_ = texture.height;
			_loc14_ = -_loc4_;
			_loc12_ = -_loc6_;
			_loc9_ = _loc15_ - _loc4_;
			_loc3_ = _loc5_ - _loc6_;
			mCorners[0] = angleTo(_loc14_, _loc12_);
			mCorners[1] = angleTo(_loc9_, _loc12_);
			mCorners[2] = angleTo(_loc9_, _loc3_);
			mCorners[3] = angleTo(_loc14_, _loc3_);
			sortFour(mCorners);
			_loc2_ = 0;
			while (_loc2_ < 4) {
				mCorners[_loc2_ + 4] = mCorners[_loc2_] + 360;
				_loc2_++;
			}
			_loc11_ = 0;
			_loc1_ = 0;
			while (_loc1_ + 1 < mArcs.length) {
				_loc16_ = mArcs[_loc1_];
				_loc18_ = mArcs[_loc1_ + 1];
				_loc7_ = _loc11_;
				addVertex(_loc11_++, mCx, mCy, _loc4_, _loc6_, _loc15_, _loc5_);
				_loc19_ = _loc11_;
				_loc11_ = addEdge(_loc11_, _loc16_, _loc14_, _loc12_, _loc9_, _loc3_, _loc4_, _loc6_, _loc15_, _loc5_);
				_loc2_ = 0;
				while (_loc2_ < 8) {
					_loc13_ = mCorners[_loc2_];
					if (_loc13_ > _loc16_ && _loc13_ < _loc18_) {
						_loc11_ = addEdge(_loc11_, _loc13_, _loc14_, _loc12_, _loc9_, _loc3_, _loc4_, _loc6_, _loc15_, _loc5_);
					}
					_loc2_++;
				}
				_loc11_ = addEdge(_loc11_, _loc18_, _loc14_, _loc12_, _loc9_, _loc3_, _loc4_, _loc6_, _loc15_, _loc5_);
				_loc8_ = _loc19_;
				while (_loc8_ < _loc11_ - 1) {
					_loc17_.addTriangle((_loc7_ : UInt), (_loc8_ : UInt), (_loc8_ + 1 : UInt));
					_loc8_++;
				}
				_loc1_ += 2;
			}
			_loc10_.colorize("color", mTint, 1, 0, _loc11_);
		}
		setVertexDataChanged();
		setIndexDataChanged();
	}

	function angleTo(x:Float, y:Float):Float {
		var _loc3_ = Math.atan2(x - mCx, mCy - y) / 0.017453292519943295;
		return _loc3_ < 0 ? _loc3_ + 360 : _loc3_;
	}

	function addEdge(n:Int, deg:Float, left:Float, top:Float, right:Float, bottom:Float, px:Float, py:Float, w:Float, h:Float):Int {
		var _loc11_ = Math.sin(deg * 0.017453292519943295);
		var _loc13_ = -Math.cos(deg * 0.017453292519943295);
		var _loc12_:Float = 1.7976931348623157e+308;
		if (_loc11_ > 1e-9) {
			_loc12_ = Math.min(_loc12_, (right - mCx) / _loc11_);
		} else if (_loc11_ < -1e-9) {
			_loc12_ = Math.min(_loc12_, (left - mCx) / _loc11_);
		}
		if (_loc13_ > 1e-9) {
			_loc12_ = Math.min(_loc12_, (bottom - mCy) / _loc13_);
		} else if (_loc13_ < -1e-9) {
			_loc12_ = Math.min(_loc12_, (top - mCy) / _loc13_);
		}
		if (_loc12_ < 0 || _loc12_ == 1.7976931348623157e+308) {
			_loc12_ = 0;
		}
		addVertex(n, mCx + _loc11_ * _loc12_, mCy + _loc13_ * _loc12_, px, py, w, h);
		return n + 1;
	}

	function addVertex(n:Int, x:Float, y:Float, px:Float, py:Float, w:Float, h:Float) {
		var _loc8_ = vertexData;
		_loc8_.setPoint(n, "position", x, y);
		texture.setTexCoords(_loc8_, n, "texCoords", (x + px) / w, (y + py) / h);
	}

	override public function dispose() {
		mCell = null;
		super.dispose();
	}
}
