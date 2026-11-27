package starling.rendering;

import flash.display3D.IndexBuffer3D;
import flash.errors.EOFError;
import flash.utils.ByteArray;
import starling.core.Starling;
import starling.errors.MissingContextError;
import starling.utils.StringUtil;

class IndexData {
	static inline final INDEX_SIZE = 2;

	static var sQuadDataNumIndices:UInt = (0 : UInt);

	static var sQuadData:ByteArray = new ByteArray();

	static var sVector:Vector<UInt> = new Vector((0 : UInt));

	static var sTrimData:ByteArray = new ByteArray();

	var _rawData:ByteArray;

	var _numIndices:Int = 0;

	var _initialCapacity:Int = 0;

	var _useQuadLayout:Bool = false;

	public function new(initialCapacity:Int = 48) {
		_numIndices = 0;
		_initialCapacity = initialCapacity;
		_useQuadLayout = true;
	}

	static function getBasicQuadIndexAt(indexID:Int):Int {
		var _loc3_ = 0;
		var _loc2_ = ASCompat.floatToInt(indexID / 6);
		var _loc4_ = indexID - _loc2_ * 6;
		if (_loc4_ == 0) {
			_loc3_ = 0;
		} else if (_loc4_ == 1 || _loc4_ == 3) {
			_loc3_ = 1;
		} else if (_loc4_ == 2 || _loc4_ == 5) {
			_loc3_ = 2;
		} else {
			_loc3_ = 3;
		}
		return _loc2_ * 4 + _loc3_;
	}

	public function clear() {
		if (_rawData != null) {
			_rawData.clear();
		}
		_numIndices = 0;
		_useQuadLayout = true;
	}

	public function clone():IndexData {
		var _loc1_ = new IndexData(_numIndices);
		if (!_useQuadLayout) {
			_loc1_.switchToGenericData();
			_loc1_._rawData.writeBytes(_rawData);
		}
		_loc1_._numIndices = _numIndices;
		return _loc1_;
	}

	public function copyTo(target:IndexData, targetIndexID:Int = 0, offset:Int = 0, indexID:Int = 0, numIndices:Int = -1) {
		var _loc6_:ByteArray = null;
		var _loc15_:ByteArray = null;
		var _loc16_ = false;
		var _loc7_ = 0;
		var _loc9_ = 0;
		var _loc13_ = 0;
		var _loc12_ = 0;
		var _loc11_ = (0 : UInt);
		var _loc10_ = (0 : UInt);
		var _loc14_ = (0 : UInt);
		if (numIndices < 0 || indexID + numIndices > _numIndices) {
			numIndices = _numIndices - indexID;
		}
		var _loc8_ = targetIndexID + numIndices;
		if (target._numIndices < _loc8_) {
			target._numIndices = _loc8_;
			if (sQuadDataNumIndices < (_loc8_:UInt)) {
				ensureQuadDataCapacity(_loc8_);
			}
		}
		if (_useQuadLayout) {
			if (target._useQuadLayout) {
				_loc16_ = true;
				_loc7_ = targetIndexID - indexID;
				_loc9_ = ASCompat.floatToInt(_loc7_ / 6);
				_loc13_ = ASCompat.floatToInt(offset / 4);
				if (_loc9_ == _loc13_ && (offset & 3) == 0 && _loc9_ * 6 == _loc7_) {
					_loc16_ = true;
				} else if (numIndices > 2) {
					_loc16_ = false;
				} else {
					_loc12_ = 0;
					while (_loc12_ < numIndices) {
						if (_loc16_) {
							_loc16_ = getBasicQuadIndexAt(indexID + _loc12_) + offset == getBasicQuadIndexAt(targetIndexID + _loc12_);
						}
						_loc12_++;
					}
				}
				if (_loc16_) {
					return;
				}
				target.switchToGenericData();
			}
			_loc15_ = sQuadData;
			_loc6_ = target._rawData;
			if ((offset & 3) == 0) {
				indexID += ASCompat.floatToInt(6 * offset / 4);
				offset = 0;
				ensureQuadDataCapacity(indexID + numIndices);
			}
		} else {
			if (target._useQuadLayout) {
				target.switchToGenericData();
			}
			_loc15_ = _rawData;
			_loc6_ = target._rawData;
		}
		_loc6_.position = (targetIndexID * 2 : UInt);
		if (offset == 0) {
			_loc6_.writeBytes(_loc15_, (indexID * 2 : UInt), (numIndices * 2 : UInt));
		} else {
			_loc15_.position = (indexID * 2 : UInt);
			while (numIndices > 1) {
				_loc11_ = _loc15_.readUnsignedInt();
				_loc10_ = ((((_loc11_ : Int) & ASCompat.floatToInt(0xFFFF0000)) >> 16) + offset : UInt);
				_loc14_ = (((_loc11_ : Int) & 0xFFFF) + offset : UInt);
				_loc6_.writeUnsignedInt(((_loc10_ : Int) << 16 | (_loc14_ : Int) : UInt));
				numIndices -= 2;
			}
			if (numIndices != 0) {
				_loc6_.writeShort((_loc15_.readUnsignedShort() + offset:Int));
			}
		}
	}

	public function setIndex(indexID:Int, index:UInt) {
		if (_numIndices < indexID + 1) {
			numIndices = indexID + 1;
		}
		if (_useQuadLayout) {
			if ((getBasicQuadIndexAt(indexID) : UInt) == index) {
				return;
			}
			switchToGenericData();
		}
		_rawData.position = (indexID * 2 : UInt);
		_rawData.writeShort((index : Int));
	}

	public function getIndex(indexID:Int):Int {
		if (_useQuadLayout) {
			if (indexID < _numIndices) {
				return getBasicQuadIndexAt(indexID);
			}
			throw new EOFError();
		}
		_rawData.position = (indexID * 2 : UInt);
		return (_rawData.readUnsignedShort() : Int);
	}

	public function offsetIndices(offset:Int, indexID:Int = 0, numIndices:Int = -1) {
		var _loc5_ = 0;
		if (numIndices < 0 || indexID + numIndices > _numIndices) {
			numIndices = _numIndices - indexID;
		}
		var _loc4_ = indexID + numIndices;
		_loc5_ = indexID;
		while (_loc5_ < _loc4_) {
			setIndex(_loc5_, (getIndex(_loc5_) + offset : UInt));
			_loc5_++;
		}
	}

	public function addTriangle(a:UInt, b:UInt, c:UInt) {
		var _loc5_ = false;
		var _loc4_ = false;
		if (_useQuadLayout) {
			if (a == (getBasicQuadIndexAt(_numIndices) : UInt)) {
				_loc5_ = (_numIndices & 1) != 0;
				_loc4_ = !_loc5_;
				if (_loc4_ && b == a + 1 && c == b + 1 || _loc5_ && c == a + 1 && b == c + 1) {
					_numIndices += 3;
					ensureQuadDataCapacity(_numIndices);
					return;
				}
			}
			switchToGenericData();
		}
		_rawData.position = (_numIndices * 2 : UInt);
		_rawData.writeShort((a : Int));
		_rawData.writeShort((b : Int));
		_rawData.writeShort((c : Int));
		_numIndices += 3;
	}

	public function addQuad(a:UInt, b:UInt, c:UInt, d:UInt) {
		if (_useQuadLayout) {
			if (a == (getBasicQuadIndexAt(_numIndices) : UInt) && b == a + 1 && c == b + 1 && d == c + 1) {
				_numIndices += 6;
				ensureQuadDataCapacity(_numIndices);
				return;
			}
			switchToGenericData();
		}
		_rawData.position = (_numIndices * 2 : UInt);
		_rawData.writeShort((a : Int));
		_rawData.writeShort((b : Int));
		_rawData.writeShort((c : Int));
		_rawData.writeShort((b : Int));
		_rawData.writeShort((d : Int));
		_rawData.writeShort((c : Int));
		_numIndices += 6;
	}

	public function toVector(out:Vector<UInt> = null):Vector<UInt> {
		var _loc2_ = 0;
		if (out == null) {
			out = new Vector<UInt>((_numIndices : UInt));
		} else {
			out.length = _numIndices;
		}
		var _loc3_ = _useQuadLayout ? sQuadData : _rawData;
		_loc3_.position = (0 : UInt);
		_loc2_ = 0;
		while (_loc2_ < _numIndices) {
			out[_loc2_] = _loc3_.readUnsignedShort();
			_loc2_++;
		}
		return out;
	}

	public function toString():String {
		var _loc1_ = StringUtil.format("[IndexData numIndices={0} indices=\"{1}\"]", _numIndices, toVector(sVector).join());
		sVector.length = 0;
		return _loc1_;
	}

	function switchToGenericData() {
		if (_useQuadLayout) {
			_useQuadLayout = false;
			if (_rawData == null) {
				_rawData = new ByteArray();
				_rawData.endian = "littleEndian";
				_rawData.length = (_initialCapacity * 2 : UInt);
				_rawData.length = (_numIndices * 2 : UInt);
			}
			if (_numIndices != 0) {
				_rawData.writeBytes(sQuadData, (0 : UInt), (_numIndices * 2 : UInt));
			}
		}
	}

	function ensureQuadDataCapacity(numIndices:Int) {
		var _loc2_ = 0;
		if (sQuadDataNumIndices >= (numIndices : UInt)) {
			return;
		}
		var _loc4_ = ASCompat.floatToInt(sQuadDataNumIndices / 6);
		var _loc3_ = Math.ceil(numIndices / 6);
		sQuadData.endian = "littleEndian";
		sQuadData.position = sQuadData.length;
		sQuadDataNumIndices = (_loc3_ * 6 : UInt);
		_loc2_ = _loc4_;
		while (_loc2_ < _loc3_) {
			sQuadData.writeShort(4 * _loc2_);
			sQuadData.writeShort(4 * _loc2_ + 1);
			sQuadData.writeShort(4 * _loc2_ + 2);
			sQuadData.writeShort(4 * _loc2_ + 1);
			sQuadData.writeShort(4 * _loc2_ + 3);
			sQuadData.writeShort(4 * _loc2_ + 2);
			_loc2_++;
		}
	}

	public function createIndexBuffer(upload:Bool = false, bufferUsage:String = "staticDraw"):IndexBuffer3D {
		var _loc3_ = Starling.context;
		if (_loc3_ == null) {
			throw new MissingContextError();
		}
		if (_numIndices == 0) {
			return null;
		}
		var _loc4_ = _loc3_.createIndexBuffer(_numIndices, bufferUsage);
		if (upload) {
			uploadToIndexBuffer(_loc4_);
		}
		return _loc4_;
	}

	public function uploadToIndexBuffer(buffer:IndexBuffer3D, indexID:Int = 0, numIndices:Int = -1) {
		if (numIndices < 0 || indexID + numIndices > _numIndices) {
			numIndices = _numIndices - indexID;
		}
		if (numIndices > 0) {
			buffer.uploadFromByteArray(rawData, 0, indexID, numIndices);
		}
	}

	public function trim() {
		if (_useQuadLayout) {
			return;
		}
		sTrimData.length = _rawData.length;
		sTrimData.position = (0 : UInt);
		sTrimData.writeBytes(_rawData);
		_rawData.clear();
		_rawData.length = sTrimData.length;
		_rawData.writeBytes(sTrimData);
		sTrimData.clear();
	}

	@:isVar public var numIndices(get, set):Int;

	public function get_numIndices():Int {
		return _numIndices;
	}

	function set_numIndices(value:Int):Int {
		if (value != _numIndices) {
			if (_useQuadLayout) {
				ensureQuadDataCapacity(value);
			} else {
				_rawData.length = (value * 2 : UInt);
			}
			if (value == 0) {
				_useQuadLayout = true;
			}
			_numIndices = value;
		}
		return value;
	}

	@:isVar public var numTriangles(get, set):Int;

	public function get_numTriangles():Int {
		return ASCompat.floatToInt(_numIndices / 3);
	}

	function set_numTriangles(value:Int):Int {
		numIndices = value * 3;
		return value;
	}

	@:isVar public var numQuads(get, set):Int;

	public function get_numQuads():Int {
		return ASCompat.floatToInt(_numIndices / 6);
	}

	function set_numQuads(value:Int):Int {
		numIndices = value * 6;
		return value;
	}

	@:isVar public var indexSizeInBytes(get, never):Int;

	public function get_indexSizeInBytes():Int {
		return 2;
	}

	@:isVar public var useQuadLayout(get, set):Bool;

	public function get_useQuadLayout():Bool {
		return _useQuadLayout;
	}

	function set_useQuadLayout(value:Bool):Bool {
		if (value != _useQuadLayout) {
			if (value) {
				ensureQuadDataCapacity(_numIndices);
				_rawData.length = (0 : UInt);
				_useQuadLayout = true;
			} else {
				switchToGenericData();
			}
		}
		return value;
	}

	@:isVar public var rawData(get, never):ByteArray;

	public function get_rawData():ByteArray {
		if (_useQuadLayout) {
			return sQuadData;
		}
		return _rawData;
	}
}
