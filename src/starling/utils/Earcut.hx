package starling.utils;

final class Earcut {
	public function new() {}

	public static function earcut(vertices:Vector<Float>, holes:Vector<UInt> = null, dimensions:UInt = (2 : UInt)):Vector<UInt> {
		var _loc11_ = Math.NaN;
		var _loc15_ = Math.NaN;
		var _loc12_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc4_ = Math.NaN;
		var _loc7_ = 0;
		var _loc13_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc5_ = holes != null && holes.length != 0;
		var _loc8_ = ASCompat.toNumber(_loc5_ ? holes[0] * dimensions : vertices.length);
		var _loc9_ = linkedList(vertices, 0, _loc8_, dimensions, true);
		var _loc10_ = new Vector<UInt>((0 : UInt));
		if (_loc9_ == null || _loc9_.next == _loc9_.prev) {
			return _loc10_;
		}
		if (_loc5_) {
			_loc9_ = eliminateHoles(vertices, holes, _loc9_, dimensions);
		}
		if ((vertices.length : UInt) > 80 * dimensions) {
			_loc12_ = Math.POSITIVE_INFINITY;
			_loc11_ = Math.POSITIVE_INFINITY;
			_loc6_ = Math.NEGATIVE_INFINITY;
			_loc4_ = Math.NEGATIVE_INFINITY;
			_loc7_ = dimensions;
			while (_loc7_ < _loc8_) {
				_loc13_ = vertices[_loc7_];
				_loc14_ = vertices[_loc7_ + 1];
				if (_loc13_ < _loc12_) {
					_loc12_ = _loc13_;
				}
				if (_loc14_ < _loc11_) {
					_loc11_ = _loc14_;
				}
				if (_loc13_ > _loc6_) {
					_loc6_ = _loc13_;
				}
				if (_loc14_ > _loc4_) {
					_loc4_ = _loc14_;
				}
				_loc7_ += (dimensions : Int);
			}
			_loc15_ = Math.max(_loc6_ - _loc12_, _loc4_ - _loc11_);
			_loc15_ = _loc15_ != 0 ? 32767 / _loc15_ : 0;
		}
		earcutLinked(_loc9_, _loc10_, dimensions, _loc12_, _loc11_, _loc15_, 0);
		return _loc10_;
	}

	static function linkedList(data:Vector<Float>, start:Float, end:Float, dim:UInt, clockwise:Bool):Node {
		var _loc6_:Node = null;
		var _loc7_ = Math.NaN;
		var _loc8_ = Math.NaN;
		if (clockwise == (signedArea(data, start, end, dim) > 0)) {
			_loc7_ = start;
			while (_loc7_ < end) {
				_loc6_ = insertNode(ASCompat.floatToInt(_loc7_ / dim) | 0, data[ASCompat.floatToInt(_loc7_)], data[ASCompat.floatToInt(_loc7_ + 1)], _loc6_);
				_loc7_ += dim;
			}
		} else {
			_loc8_ = end - dim;
			while (_loc8_ >= start) {
				_loc6_ = insertNode(ASCompat.floatToInt(_loc8_ / dim) | 0, data[ASCompat.floatToInt(_loc8_)], data[ASCompat.floatToInt(_loc8_ + 1)], _loc6_);
				_loc8_ -= dim;
			}
		}
		if (_loc6_ != null && equals(_loc6_, _loc6_.next)) {
			removeNode(_loc6_);
			_loc6_ = _loc6_.next;
		}
		return _loc6_;
	}

	static function filterPoints(start:Node = null, end:Node = null):Node {
		var _loc4_ = false;
		if (start == null) {
			return start;
		}
		if (end == null) {
			end = start;
		}
		var _loc3_ = start;
		do {
			_loc4_ = false;
			if (!_loc3_.steiner && (equals(_loc3_, _loc3_.next) || area(_loc3_.prev, _loc3_, _loc3_.next) == 0)) {
				removeNode(_loc3_);
				_loc3_ = end = _loc3_.prev;
				if (_loc3_ == _loc3_.next) {
					break;
				}
				_loc4_ = true;
			} else {
				_loc3_ = _loc3_.next;
			}
		} while (_loc4_ || _loc3_ != end);
		return end;
	}

	static function earcutLinked(ear:Node, triangles:Vector<UInt>, dim:UInt, minX:Float, minY:Float, invSize:Float, pass:Float) {
		var _loc10_:Node = null;
		var _loc8_:Node = null;
		if (ear == null) {
			return;
		}
		if (!ASCompat.floatAsBool(pass) && ASCompat.floatAsBool(invSize)) {
			indexCurve(ear, minX, minY, invSize);
		}
		var _loc9_ = ear;
		while (ear.prev != ear.next) {
			_loc10_ = ear.prev;
			_loc8_ = ear.next;
			if (ASCompat.floatAsBool(invSize) ? isEarHashed(ear, minX, minY, invSize) : isEar(ear)) {
				ASCompat.ASArray.pushMultiple(triangles, (ASCompat.floatToInt(_loc10_.i) : UInt), (ASCompat.floatToInt(ear.i) : UInt),
					(ASCompat.floatToInt(_loc8_.i) : UInt));
				removeNode(ear);
				ear = _loc8_.next;
				_loc9_ = _loc8_.next;
			} else {
				ear = _loc8_;
				if (ear == _loc9_) {
					if (!ASCompat.floatAsBool(pass)) {
						earcutLinked(filterPoints(ear), triangles, dim, minX, minY, invSize, 1);
					} else {
						switch (pass) {
							case 1:
								ear = cureLocalIntersections(filterPoints(ear), triangles);
								earcutLinked(ear, triangles, dim, minX, minY, invSize, 2);

							case 2:
								splitEarcut(ear, triangles, dim, minX, minY, invSize);
						}
					}
					break;
				}
			}
		}
	}

	static function isEar(ear:Node):Bool {
		var _loc2_ = ear.prev;
		var _loc3_ = ear;
		var _loc4_ = ear.next;
		if (area(_loc2_, _loc3_, _loc4_) >= 0) {
			return false;
		}
		var _loc10_ = _loc2_.x;
		var _loc7_ = _loc3_.x;
		var _loc6_ = _loc4_.x;
		var _loc12_ = _loc2_.y;
		var _loc9_ = _loc3_.y;
		var _loc8_ = _loc4_.y;
		var _loc14_ = Math.min(_loc10_, Math.min(_loc7_, _loc6_));
		var _loc11_ = Math.min(_loc12_, Math.min(_loc9_, _loc8_));
		var _loc15_ = Math.max(_loc10_, Math.max(_loc7_, _loc6_));
		var _loc13_ = Math.max(_loc12_, Math.max(_loc9_, _loc8_));
		var _loc5_ = _loc4_.next;
		while (_loc5_ != _loc2_) {
			if (_loc5_.x >= _loc14_
				&& _loc5_.x <= _loc15_
				&& _loc5_.y >= _loc11_
				&& _loc5_.y <= _loc13_
				&& pointInTriangleExceptFirst(_loc10_, _loc12_, _loc7_, _loc9_, _loc6_, _loc8_, _loc5_.x, _loc5_.y)
				&& area(_loc5_.prev, _loc5_, _loc5_.next) >= 0) {
				return false;
			}
			_loc5_ = _loc5_.next;
		}
		return true;
	}

	static function isEarHashed(ear:Node, minX:Float, minY:Float, invSize:Float):Bool {
		var _loc5_ = ear.prev;
		var _loc6_ = ear;
		var _loc7_ = ear.next;
		if (area(_loc5_, _loc6_, _loc7_) >= 0) {
			return false;
		}
		var _loc15_ = _loc5_.x;
		var _loc12_ = _loc6_.x;
		var _loc11_ = _loc7_.x;
		var _loc17_ = _loc5_.y;
		var _loc14_ = _loc6_.y;
		var _loc13_ = _loc7_.y;
		var _loc19_ = Math.min(_loc15_, Math.min(_loc12_, _loc11_));
		var _loc16_ = Math.min(_loc17_, Math.min(_loc14_, _loc13_));
		var _loc20_ = Math.max(_loc15_, Math.max(_loc12_, _loc11_));
		var _loc18_ = Math.max(_loc17_, Math.max(_loc14_, _loc13_));
		var _loc21_ = zOrder(_loc19_, _loc16_, minX, minY, invSize);
		var _loc8_ = zOrder(_loc20_, _loc18_, minX, minY, invSize);
		var _loc10_ = ear.prevZ;
		var _loc9_ = ear.nextZ;
		while (_loc10_ != null && _loc10_.z >= _loc21_ && _loc9_ != null && _loc9_.z <= _loc8_) {
			if (_loc10_.x >= _loc19_
				&& _loc10_.x <= _loc20_
				&& _loc10_.y >= _loc16_
				&& _loc10_.y <= _loc18_
				&& _loc10_ != _loc5_
				&& _loc10_ != _loc7_
				&& pointInTriangleExceptFirst(_loc15_, _loc17_, _loc12_, _loc14_, _loc11_, _loc13_, _loc10_.x, _loc10_.y)
				&& area(_loc10_.prev, _loc10_, _loc10_.next) >= 0) {
				return false;
			}
			_loc10_ = _loc10_.prevZ;
			if (_loc9_.x >= _loc19_
				&& _loc9_.x <= _loc20_
				&& _loc9_.y >= _loc16_
				&& _loc9_.y <= _loc18_
				&& _loc9_ != _loc5_
				&& _loc9_ != _loc7_
				&& pointInTriangleExceptFirst(_loc15_, _loc17_, _loc12_, _loc14_, _loc11_, _loc13_, _loc9_.x, _loc9_.y)
				&& area(_loc9_.prev, _loc9_, _loc9_.next) >= 0) {
				return false;
			}
			_loc9_ = _loc9_.nextZ;
		}
		while (_loc10_ != null && _loc10_.z >= _loc21_) {
			if (_loc10_.x >= _loc19_
				&& _loc10_.x <= _loc20_
				&& _loc10_.y >= _loc16_
				&& _loc10_.y <= _loc18_
				&& _loc10_ != _loc5_
				&& _loc10_ != _loc7_
				&& pointInTriangleExceptFirst(_loc15_, _loc17_, _loc12_, _loc14_, _loc11_, _loc13_, _loc10_.x, _loc10_.y)
				&& area(_loc10_.prev, _loc10_, _loc10_.next) >= 0) {
				return false;
			}
			_loc10_ = _loc10_.prevZ;
		}
		while (_loc9_ != null && _loc9_.z <= _loc8_) {
			if (_loc9_.x >= _loc19_
				&& _loc9_.x <= _loc20_
				&& _loc9_.y >= _loc16_
				&& _loc9_.y <= _loc18_
				&& _loc9_ != _loc5_
				&& _loc9_ != _loc7_
				&& pointInTriangleExceptFirst(_loc15_, _loc17_, _loc12_, _loc14_, _loc11_, _loc13_, _loc9_.x, _loc9_.y)
				&& area(_loc9_.prev, _loc9_, _loc9_.next) >= 0) {
				return false;
			}
			_loc9_ = _loc9_.nextZ;
		}
		return true;
	}

	static function cureLocalIntersections(start:Node, triangles:Vector<UInt>):Node {
		var _loc5_:Node;
		var _loc4_:Node = null;
		var _loc3_ = start;
		do {
			_loc4_ = _loc3_.prev;
			_loc5_ = _loc3_.next.next;
			if (!equals(_loc4_, _loc5_)
				&& intersects(_loc4_, _loc3_, _loc3_.next, _loc5_)
				&& locallyInside(_loc4_, _loc5_)
				&& locallyInside(_loc5_, _loc4_)) {
				ASCompat.ASArray.pushMultiple(triangles, (ASCompat.floatToInt(_loc4_.i) : UInt), (ASCompat.floatToInt(_loc3_.i) : UInt),
					(ASCompat.floatToInt(_loc5_.i) : UInt));
				removeNode(_loc3_);
				removeNode(_loc3_.next);
				_loc3_ = start = _loc5_;
			}
			_loc3_ = _loc3_.next;
		} while (_loc3_ != start);
		return filterPoints(_loc3_);
	}

	static function splitEarcut(start:Node, triangles:Vector<UInt>, dim:UInt, minX:Float, minY:Float, invSize:Float) {
		var _loc8_:Node = null;
		var _loc9_:Node = null;
		var _loc7_ = start;
		do {
			_loc8_ = _loc7_.next.next;
			while (_loc8_ != _loc7_.prev) {
				if (_loc7_.i != _loc8_.i && isValidDiagonal(_loc7_, _loc8_)) {
					_loc9_ = splitPolygon(_loc7_, _loc8_);
					_loc7_ = filterPoints(_loc7_, _loc7_.next);
					_loc9_ = filterPoints(_loc9_, _loc9_.next);
					earcutLinked(_loc7_, triangles, dim, minX, minY, invSize, 0);
					earcutLinked(_loc9_, triangles, dim, minX, minY, invSize, 0);
					return;
				}
				_loc8_ = _loc8_.next;
			}
		} while ({
			_loc7_ = _loc7_.next;
			_loc7_ != start;
			});
	}

	static function eliminateHoles(data:Vector<Float>, holeIndices:Vector<UInt>, outerNode:Node, dim:UInt):Node {
		var _loc7_ = (0 : UInt);
		var _loc5_ = (0 : UInt);
		var _loc6_ = (0 : UInt);
		var _loc8_ = (0 : UInt);
		var _loc9_:Node = null;
		var _loc10_ = (0 : UInt);
		var _loc11_ = new Vector<Node>((0 : UInt));
		_loc7_ = (0 : UInt);
		_loc5_ = (holeIndices.length : UInt);
		while (_loc7_ < _loc5_) {
			_loc6_ = holeIndices[(_loc7_ : Int)] * dim;
			_loc8_ = (ASCompat.toInt(_loc7_ < (_loc5_:Float) - 1 ? holeIndices[(_loc7_ + 1 : Int)] * dim : data.length) : UInt);
			_loc9_ = linkedList(data, _loc6_, _loc8_, dim, false);
			if (_loc9_ == _loc9_.next) {
				_loc9_.steiner = true;
			}
			_loc11_.push(getLeftmost(_loc9_));
			_loc7_++;
		}
		ASCompat.ASVector.sort(_loc11_, compareXYSlope);
		_loc10_ = (0 : UInt);
		while (_loc10_ < (_loc11_.length:UInt)) {
			outerNode = eliminateHole(_loc11_[(_loc10_ : Int)], outerNode);
			_loc10_++;
		}
		return outerNode;
	}

	static function compareXYSlope(a:Node, b:Node):Float {
		var _loc4_ = Math.NaN;
		var _loc5_ = Math.NaN;
		var _loc3_ = a.x - b.x;
		if (_loc3_ == 0) {
			_loc3_ = a.y - b.y;
			if (_loc3_ == 0) {
				_loc4_ = (a.next.y - a.y) / (a.next.x - a.x);
				_loc5_ = (b.next.y - b.y) / (b.next.x - b.x);
				_loc3_ = _loc4_ - _loc5_;
			}
		}
		return _loc3_;
	}

	static function eliminateHole(hole:Node, outerNode:Node):Node {
		var _loc3_ = findHoleBridge(hole, outerNode);
		if (_loc3_ == null) {
			return outerNode;
		}
		var _loc4_ = splitPolygon(_loc3_, hole);
		filterPoints(_loc4_, _loc4_.next);
		return filterPoints(_loc3_, _loc3_.next);
	}

	static function findHoleBridge(hole:Node, outerNode:Node):Node {
		var _loc12_:Node;
		var _loc5_:Float;
		var _loc6_:Float;
		var _loc8_:Float;
		var _loc7_:Node = null;
		var _loc13_ = Math.NaN;
		var _loc3_ = Math.NaN;
		var _loc9_ = outerNode;
		var _loc10_ = hole.x;
		var _loc11_ = hole.y;
		var _loc4_ = Math.NEGATIVE_INFINITY;
		if (equals(hole, _loc9_)) {
			return _loc9_;
		}
		while (!equals(hole, _loc9_.next)) {
			if (_loc11_ <= _loc9_.y && _loc11_ >= _loc9_.next.y && _loc9_.next.y != _loc9_.y) {
				_loc13_ = _loc9_.x + (_loc11_ - _loc9_.y) * (_loc9_.next.x - _loc9_.x) / (_loc9_.next.y - _loc9_.y);
				if (_loc13_ <= _loc10_ && _loc13_ > _loc4_) {
					_loc4_ = _loc13_;
					_loc7_ = _loc9_.x < _loc9_.next.x ? _loc9_ : _loc9_.next;
					if (_loc13_ == _loc10_) {
						return _loc7_;
					}
				}
			}
			_loc9_ = _loc9_.next;
			if (_loc9_ == outerNode) {
				if (_loc7_ == null) {
					return null;
				}
				_loc12_ = _loc7_;
				_loc5_ = _loc7_.x;
				_loc6_ = _loc7_.y;
				_loc8_ = Math.POSITIVE_INFINITY;
				_loc9_ = _loc7_;
				do {
					if (_loc10_ >= _loc9_.x
						&& _loc9_.x >= _loc5_
						&& _loc10_ != _loc9_.x
						&& pointInTriangle(_loc11_ < _loc6_ ? _loc10_ : _loc4_, _loc11_, _loc5_, _loc6_, _loc11_ < _loc6_ ? _loc4_ : _loc10_, _loc11_,
							_loc9_.x, _loc9_.y)) {
						_loc3_ = Math.abs(_loc11_ - _loc9_.y) / (_loc10_ - _loc9_.x);
						if (locallyInside(_loc9_, hole)
							&& (_loc3_ < _loc8_
								|| _loc3_ == _loc8_
								&& (_loc9_.x > _loc7_.x || _loc9_.x == _loc7_.x && sectorContainsSector(_loc7_, _loc9_)))) {
							_loc7_ = _loc9_;
							_loc8_ = _loc3_;
						}
					}
				} while ({
					_loc9_ = _loc9_.next;
					_loc9_ != _loc12_;
					});
				return _loc7_;
			}
		}
		return _loc9_.next;
	}

	static function sectorContainsSector(m:Node, p:Node):Bool {
		return area(m.prev, m, p.prev) < 0 && area(p.next, m, m.next) < 0;
	}

	static function indexCurve(start:Node, minX:Float, minY:Float, invSize:Float) {
		var _loc5_ = start;
		do {
			if (_loc5_.z == 0) {
				_loc5_.z = zOrder(_loc5_.x, _loc5_.y, minX, minY, invSize);
			}
			_loc5_.prevZ = _loc5_.prev;
			_loc5_.nextZ = _loc5_.next;
		} while ({
			_loc5_ = _loc5_.next;
			_loc5_ != start;
			});
		_loc5_.prevZ.nextZ = null;
		_loc5_.prevZ = null;
		sortLinked(_loc5_);
	}

	static function sortLinked(list:Node):Node {
		var _loc5_ = (0 : UInt);
		var _loc2_:Node = null;
		var _loc7_:Node = null;
		var _loc8_:Node = null;
		var _loc4_:Node = null;
		var _loc3_ = 0;
		var _loc9_ = (0 : UInt);
		var _loc10_ = 0;
		var _loc6_ = (1 : UInt);
		do {
			_loc2_ = list;
			list = null;
			_loc8_ = null;
			_loc5_ = (0 : UInt);
			while (_loc2_ != null) {
				_loc5_++;
				_loc4_ = _loc2_;
				_loc3_ = 0;
				_loc9_ = (0 : UInt);
				while (_loc9_ < _loc6_) {
					_loc3_++;
					_loc4_ = _loc4_.nextZ;
					if (_loc4_ == null) {
						break;
					}
					_loc9_++;
				}
				_loc10_ = (_loc6_ : Int);
				while (_loc3_ > 0 || _loc10_ > 0 && _loc4_ != null) {
					if (_loc3_ != 0 && (_loc10_ == 0 || _loc4_ == null || _loc2_.z <= _loc4_.z)) {
						_loc7_ = _loc2_;
						_loc2_ = _loc2_.nextZ;
						_loc3_--;
					} else {
						_loc7_ = _loc4_;
						_loc4_ = _loc4_.nextZ;
						_loc10_--;
					}
					if (_loc8_ != null) {
						_loc8_.nextZ = _loc7_;
					} else {
						list = _loc7_;
					}
					_loc7_.prevZ = _loc8_;
					_loc8_ = _loc7_;
				}
				_loc2_ = _loc4_;
			}
			_loc8_.nextZ = null;
			_loc6_ *= (2 : UInt);
		} while (_loc5_ > 1);
		return list;
	}

	static function zOrder(x:Float, y:Float, minX:Float, minY:Float, invSize:Float):Float {
		x = ASCompat.floatToInt((x - minX) * invSize) | 0;
		y = ASCompat.floatToInt((y - minY) * invSize) | 0;
		x = (ASCompat.floatToInt(x) | ASCompat.floatToInt(x) << 8) & 0xFF00FF;
		x = (ASCompat.floatToInt(x) | ASCompat.floatToInt(x) << 4) & 0x0F0F0F0F;
		x = (ASCompat.floatToInt(x) | ASCompat.floatToInt(x) << 2) & 0x33333333;
		x = (ASCompat.floatToInt(x) | ASCompat.floatToInt(x) << 1) & 0x55555555;
		y = (ASCompat.floatToInt(y) | ASCompat.floatToInt(y) << 8) & 0xFF00FF;
		y = (ASCompat.floatToInt(y) | ASCompat.floatToInt(y) << 4) & 0x0F0F0F0F;
		y = (ASCompat.floatToInt(y) | ASCompat.floatToInt(y) << 2) & 0x33333333;
		y = (ASCompat.floatToInt(y) | ASCompat.floatToInt(y) << 1) & 0x55555555;
		return ASCompat.floatToInt(x) | ASCompat.floatToInt(y) << 1;
	}

	static function getLeftmost(start:Node):Node {
		var _loc2_ = start;
		var _loc3_ = start;
		do {
			if (_loc2_.x < _loc3_.x || _loc2_.x == _loc3_.x && _loc2_.y < _loc3_.y) {
				_loc3_ = _loc2_;
			}
			_loc2_ = _loc2_.next;
		} while (_loc2_ != start);
		return _loc3_;
	}

	static function pointInTriangle(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, px:Float, py:Float):Bool {
		return (cx - px) * (ay - py) >= (ax - px) * (cy - py)
			&& (ax - px) * (by - py) >= (bx - px) * (ay - py) && (bx - px) * (cy - py) >= (cx - px) * (by - py);
	}

	static function pointInTriangleExceptFirst(ax:Float, ay:Float, bx:Float, by:Float, cx:Float, cy:Float, px:Float, py:Float):Bool {
		return !(ax == px && ay == py) && pointInTriangle(ax, ay, bx, by, cx, cy, px, py);
	}

	static function isValidDiagonal(a:Node, b:Node):Bool {
		return a.next.i != b.i
			&& a.prev.i != b.i
			&& !intersectsPolygon(a, b)
			&& (locallyInside(a, b)
				&& locallyInside(b, a)
				&& middleInside(a, b)
				&& (ASCompat.floatAsBool(area(a.prev, a, b.prev)) || ASCompat.floatAsBool(area(a, b.prev, b)))
				|| equals(a, b)
				&& area(a.prev, a, a.next) > 0
				&& area(b.prev, b, b.next) > 0);
	}

	static function area(p:Node, q:Node, r:Node):Float {
		return (q.y - p.y) * (r.x - q.x) - (q.x - p.x) * (r.y - q.y);
	}

	static function equals(p1:Node, p2:Node):Bool {
		return p1.x == p2.x && p1.y == p2.y;
	}

	static function intersects(p1:Node, q1:Node, p2:Node, q2:Node):Bool {
		var _loc5_:Float = sign(area(p1, q1, p2));
		var _loc6_:Float = sign(area(p1, q1, q2));
		var _loc7_:Float = sign(area(p2, q2, p1));
		var _loc8_:Float = sign(area(p2, q2, q1));
		if (_loc5_ != _loc6_ && _loc7_ != _loc8_) {
			return true;
		}
		if (_loc5_ == 0 && onSegment(p1, p2, q1)) {
			return true;
		}
		if (_loc6_ == 0 && onSegment(p1, q2, q1)) {
			return true;
		}
		if (_loc7_ == 0 && onSegment(p2, p1, q2)) {
			return true;
		}
		if (_loc8_ == 0 && onSegment(p2, q1, q2)) {
			return true;
		}
		return false;
	}

	static function onSegment(p:Node, q:Node, r:Node):Bool {
		return q.x <= Math.max(p.x, r.x) && q.x >= Math.min(p.x, r.x) && q.y <= Math.max(p.y, r.y) && q.y >= Math.min(p.y, r.y);
	}

	static function sign(num:Float):Int {
		return num > 0 ? 1 : (num < 0 ? -1 : 0);
	}

	static function intersectsPolygon(a:Node, b:Node):Bool {
		var _loc3_ = a;
		while (!(_loc3_.i != a.i && _loc3_.next.i != a.i && _loc3_.i != b.i && _loc3_.next.i != b.i && intersects(_loc3_, _loc3_.next, a, b))) {
			_loc3_ = _loc3_.next;
			if (_loc3_ == a) {
				return false;
			}
		}
		return true;
	}

	static function locallyInside(a:Node, b:Node):Bool {
		return area(a.prev, a, a.next) < 0 ? area(a, b, a.next) >= 0 && area(a, a.prev, b) >= 0 : area(a, b, a.prev) < 0 || area(a, a.next, b) < 0;
	}

	static function middleInside(a:Node, b:Node):Bool {
		var _loc3_ = a;
		var _loc6_ = false;
		var _loc4_ = (a.x + b.x) / 2;
		var _loc5_ = (a.y + b.y) / 2;
		do {
			if (_loc3_.y > _loc5_ != (_loc3_.next.y > _loc5_)
				&& _loc3_.next.y != _loc3_.y
				&& _loc4_ < (_loc3_.next.x - _loc3_.x) * (_loc5_ - _loc3_.y) / (_loc3_.next.y - _loc3_.y) + _loc3_.x) {
				_loc6_ = !_loc6_;
			}
			_loc3_ = _loc3_.next;
		} while (_loc3_ != a);
		return _loc6_;
	}

	static function splitPolygon(a:Node, b:Node):Node {
		var _loc4_ = createNode(a.i, a.x, a.y);
		var _loc3_ = createNode(b.i, b.x, b.y);
		var _loc5_ = a.next;
		var _loc6_ = b.prev;
		a.next = b;
		b.prev = a;
		_loc4_.next = _loc5_;
		_loc5_.prev = _loc4_;
		_loc3_.next = _loc4_;
		_loc4_.prev = _loc3_;
		_loc6_.next = _loc3_;
		_loc3_.prev = _loc6_;
		return _loc3_;
	}

	static function insertNode(i:Float, x:Float, y:Float, last:Node):Node {
		var _loc5_ = createNode(i, x, y);
		if (last == null) {
			_loc5_.prev = _loc5_;
			_loc5_.next = _loc5_;
		} else {
			_loc5_.next = last.next;
			_loc5_.prev = last;
			last.next.prev = _loc5_;
			last.next = _loc5_;
		}
		return _loc5_;
	}

	static function removeNode(p:Node) {
		p.next.prev = p.prev;
		p.prev.next = p.next;
		if (p.prevZ != null) {
			p.prevZ.nextZ = p.nextZ;
		}
		if (p.nextZ != null) {
			p.nextZ.prevZ = p.prevZ;
		}
	}

	static function createNode(i:Float, x:Float, y:Float):Node {
		return new Node(i, x, y);
	}

	public static function deviation(vertices:Vector<Float>, holes:Vector<Float>, dimensions:UInt, triangles:Vector<Float>):Float {
		var _loc10_ = (0 : UInt);
		var _loc15_ = (0 : UInt);
		var _loc9_ = Math.NaN;
		var _loc16_ = Math.NaN;
		var _loc13_ = (0 : UInt);
		var _loc5_ = Math.NaN;
		var _loc6_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc8_ = holes != null && holes.length != 0;
		var _loc11_ = _loc8_ ? holes[0] * dimensions : vertices.length;
		var _loc12_ = Math.abs(signedArea(vertices, 0, _loc11_, dimensions));
		if (_loc8_) {
			_loc10_ = (0 : UInt);
			_loc15_ = (holes.length : UInt);
			while (_loc10_ < _loc15_) {
				_loc9_ = holes[(_loc10_ : Int)] * dimensions;
				_loc16_ = _loc10_ < (_loc15_:Float) - 1 ? holes[(_loc10_ + 1 : Int)] * dimensions : vertices.length;
				_loc12_ -= Math.abs(signedArea(vertices, _loc9_, _loc16_, dimensions));
				_loc10_++;
			}
		}
		var _loc14_:Float = 0;
		_loc13_ = (0 : UInt);
		while (_loc13_ < (triangles.length:UInt)) {
			_loc5_ = triangles[(_loc13_ : Int)] * dimensions;
			_loc6_ = triangles[(_loc13_ + 1 : Int)] * dimensions;
			_loc7_ = triangles[(_loc13_ + 2 : Int)] * dimensions;
			_loc14_ += Math.abs((triangles[ASCompat.floatToInt(_loc5_)] - triangles[ASCompat.floatToInt(_loc7_)]) * (triangles[ASCompat.floatToInt(_loc6_ + 1)]
				- triangles[ASCompat.floatToInt(_loc5_ + 1)])
				- (triangles[ASCompat.floatToInt(_loc5_)] - triangles[ASCompat.floatToInt(_loc6_)]) * (triangles[ASCompat.floatToInt(_loc7_ + 1)]
					- triangles[ASCompat.floatToInt(_loc5_ + 1)]));
			_loc13_ += (3 : UInt);
		}
		return _loc12_ == 0 && _loc14_ == 0 ? 0 : Math.abs((_loc14_ - _loc12_) / _loc12_);
	}

	static function signedArea(data:Vector<Float>, start:Float, end:Float, dim:UInt):Float {
		var _loc5_ = Math.NaN;
		var _loc7_ = Math.NaN;
		var _loc6_:Float = 0;
		_loc5_ = start;
		_loc7_ = end - dim;
		while (_loc5_ < end) {
			_loc6_ += (data[ASCompat.floatToInt(_loc7_)] - data[ASCompat.floatToInt(_loc5_)]) * (data[ASCompat.floatToInt(_loc5_ + 1)]
				+ data[ASCompat.floatToInt(_loc7_ + 1)]);
			_loc7_ = _loc5_;
			_loc5_ += dim;
		}
		return _loc6_;
	}

	public static function flatten(data:Vector<Vector<Vector<Float>>>):ASObject {
		var _loc3_:Vector<Float>;
		var _loc4_ = 0;
		var _loc5_ = new Vector<Float>((0 : UInt));
		var _loc8_ = new Vector<Float>((0 : UInt));
		var _loc9_ = (data[0][0].length : UInt);
		var _loc2_ = (0 : UInt);
		var _loc7_ = (0 : UInt);
		var _loc6_:Vector<Vector<Float>>;
		if (checkNullIteratee(data))
			for (_tmp_ in data) {
				_loc6_ = _tmp_;
				if (checkNullIteratee(_loc6_))
					for (_tmp_ in _loc6_) {
						_loc3_ = _tmp_;
						_loc4_ = 0;
						while ((_loc4_ : UInt) < _loc9_) {
							_loc5_.push(_loc3_[_loc4_]);
							_loc4_++;
						}
					}
				if (_loc7_ != 0) {
					_loc2_ += _loc7_;
					_loc8_.push(_loc2_);
				}
				_loc7_ = (_loc6_.length : UInt);
			}
		return {
			"vertices": _loc5_,
			"holes": _loc8_,
			"dimensions": _loc9_
		};
	}
}

private class Node {
	public var i:Float = Math.NaN;

	public var x:Float = Math.NaN;

	public var y:Float = Math.NaN;

	public var prev:Node;

	public var next:Node;

	public var z:Float = Math.NaN;

	public var prevZ:Node;

	public var nextZ:Node;

	public var steiner:Bool = false;

	public function new(i:Float, x:Float, y:Float) {
		this.i = i;
		this.x = x;
		this.y = y;
		this.prev = null;
		this.next = null;
		this.z = 0;
		this.prevZ = null;
		this.nextZ = null;
		this.steiner = false;
	}
}
