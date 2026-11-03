package uI.hud.starlingConverted;

import brain.assetRepository.SwfAsset;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Matrix;
import flash.geom.Rectangle;
import flash.utils.ByteArray;

class TimelineMasks {
	static var sSymbols:ASObject = {};

	static var sLoaded:ASDictionary<ASAny, ASAny> = new ASDictionary(true);

	var mBytes:ByteArray;

	var mBit:Int = 0;

	var mByte:Int = 0;

	var mSprites:ASObject = {};

	var mBounds:ASObject = {};

	public function new() {}

	public static function register(asset:SwfAsset) {
		if (ASCompat.toBool(sLoaded[asset.root])) {
			return;
		}
		var _loc2_ = new TimelineMasks();
		_loc2_.read(asset.root.loaderInfo.bytes);
		sLoaded[asset.root] = true;
	}

	static function definition(source:DisplayObject):ASObject {
		var _loc4_:ASObject = sSymbols[StringTools.replace(ASCompat.getQualifiedClassName(source), "::", ".")];
		if (_loc4_ != null) {
			return _loc4_;
		}
		if (source.parent == null) {
			return null;
		}
		var _loc2_:ASObject = definition(source.parent);
		var _loc5_ = placements(source.parent, _loc2_);
		var _loc3_ = source.parent.getChildIndex(source);
		return _loc5_ != null && _loc3_ < _loc5_.length ? {
			"parser": _loc2_.parser,
			"id": _loc5_[_loc3_].id
		} : null;
	}

	static function placements(source:DisplayObject, linked:ASObject):Array<ASAny> {
		if (linked == null) {
			return null;
		}
		var _loc3_ = ASCompat.asVector(cast(linked.parser, TimelineMasks).mSprites[linked.id], (_ : Array<ASAny>));
		var _loc4_ = ASCompat.reinterpretAs(source, MovieClip);
		return ASCompat.coerce(_loc3_ != null
			&& _loc3_.length > 0 ? _loc3_[(_loc4_ != null ? _loc4_.currentFrame - 1 : 0) % _loc3_.length] : null, Array);
	}

	@:allow(UI.Hud.StarlingConverted) static function isMask(parent:DisplayObjectContainer, child:DisplayObject):Bool {
		var _loc4_ = placements(parent, definition(parent));
		var _loc3_ = parent.getChildIndex(child);
		return _loc4_ != null && _loc3_ < _loc4_.length && ASCompat.toNumberField(_loc4_[_loc3_], "clip") > 0;
	}

	@:allow(UI.Hud.StarlingConverted) static function clip(parent:DisplayObjectContainer, child:DisplayObject):Rectangle {
		var _loc7_:ASObject = null;
		var _loc5_:Rectangle = null;
		var _loc3_:Rectangle = null;
		var _loc4_:Matrix = null;
		var _loc8_:ASObject = definition(parent);
		var _loc9_ = placements(parent, _loc8_);
		var _loc6_ = parent.getChildIndex(child);
		if (_loc9_ == null || _loc6_ >= _loc9_.length) {
			return null;
		}
		if (checkNullIteratee(_loc9_))
			for (_tmp_ in _loc9_) {
				_loc7_ = _tmp_;
				if (!(_loc7_.clip < _loc9_[_loc6_].depth || _loc7_.depth >= _loc9_[_loc6_].depth)) {
					_loc5_ = ASCompat.dynamicAs(cast(_loc8_.parser, TimelineMasks).mBounds[_loc7_.id], Rectangle);
					_loc4_ = ASCompat.coerce(_loc7_.matrix, flash.geom.Matrix);
					if (_loc5_ == null || _loc4_.b != 0 || _loc4_.c != 0) {
						return null;
					}
					_loc5_ = new Rectangle(_loc4_.a * _loc5_.x + _loc4_.tx, _loc4_.d * _loc5_.y + _loc4_.ty, _loc4_.a * _loc5_.width, _loc4_.d * _loc5_.height);
					_loc3_ = _loc3_ != null ? _loc3_.intersection(_loc5_) : _loc5_;
				}
			}
		return _loc3_;
	}

	function read(bytes:ByteArray) {
		var _loc2_ = 0;
		var _loc4_:ByteArray = null;
		var _loc3_ = bytes.position;
		{
			try {
				mBytes = new ByteArray();
				bytes.position = (0 : UInt);
				bytes.readBytes(mBytes);
				mBytes.endian = "littleEndian";
				mBytes.position = (0 : UInt);
				_loc2_ = mBytes.readUnsignedByte();
				if (_loc2_ == 67) {
					_loc4_ = new ByteArray();
					mBytes.position = (8 : UInt);
					mBytes.readBytes(_loc4_);
					_loc4_.uncompress();
					mBytes.length = (8 : UInt);
					mBytes.position = (8 : UInt);
					mBytes.writeBytes(_loc4_);
				}
				mBytes.position = (8 : UInt);
				rect();
				mBytes.position += (4 : UInt);
				tags(mBytes.length, null);
				prune();
			} catch (__finallyError46:Dynamic) {
				{
					mBytes = null;
					bytes.position = _loc3_;
				};
				throw __finallyError46;
			};
			{
				mBytes = null;
				bytes.position = _loc3_;
			};
		}
	}

	function prune() {
		var __ax4_iter_163:ASObject;
		var _loc4_:String = null;
		var _loc1_:Vector<Array<ASAny>> = /*undefined*/ null;
		var _loc6_:Array<ASAny> = null;
		var _loc5_:ASObject = null;
		var _loc7_ = false;
		var _loc2_:ASObject = {};
		var _loc3_:ASObject = {};
		final __ax4_iter_162:ASObject = mSprites;
		if (checkNullIteratee(__ax4_iter_162))
			for (_tmp_ in __ax4_iter_162.___keys()) {
				_loc4_ = _tmp_;
				_loc1_ = (mSprites[_loc4_] : Vector<Array<ASAny>>);
				if (checkNullIteratee(_loc1_))
					for (_tmp_ in _loc1_) {
						_loc6_ = _tmp_;
						if (checkNullIteratee(_loc6_))
							for (_tmp_ in _loc6_) {
								_loc5_ = _tmp_;
								if (ASCompat.toNumberField(_loc5_, "clip") > 0) {
									_loc2_[_loc4_] = true;
									_loc3_[_loc5_.id] = mBounds[_loc5_.id];
								}
							}
					}
			}
		do {
			_loc7_ = false;
			__ax4_iter_163 = mSprites;
			if (checkNullIteratee(__ax4_iter_163))
				for (_tmp_ in __ax4_iter_163.___keys()) {
					_loc4_ = _tmp_;
					if (!ASCompat.toBool(_loc2_[_loc4_])) {
						_loc1_ = (mSprites[_loc4_] : Vector<Array<ASAny>>);
						if (checkNullIteratee(_loc1_))
							for (_tmp_ in _loc1_) {
								_loc6_ = _tmp_;
								if (checkNullIteratee(_loc6_))
									for (_tmp_ in _loc6_) {
										_loc5_ = _tmp_;
										if (ASCompat.toBool(_loc2_[_loc5_.id])) {
											_loc2_[_loc4_] = true;
											_loc7_ = true;
										}
									}
							}
					}
				}
		} while (_loc7_);
		final __ax4_iter_164:ASObject = mSprites;
		if (checkNullIteratee(__ax4_iter_164))
			for (_tmp_ in __ax4_iter_164.___keys()) {
				_loc4_ = _tmp_;
				if (!ASCompat.toBool(_loc2_[_loc4_])) {
					ASCompat.deleteProperty(mSprites, _loc4_);
				}
			}
		mBounds = _loc3_;
	}

	function tags(end:UInt, frames:Vector<Array<ASAny>>) {
		var _loc15_ = 0;
		var _loc10_ = 0;
		var _loc6_ = (0 : UInt);
		var _loc3_ = (0 : UInt);
		var _loc16_ = 0;
		var _loc7_ = 0;
		var _loc9_ = 0;
		var _loc12_ = 0;
		var _loc8_ = 0;
		var _loc5_ = 0;
		var _loc13_:String = null;
		var _loc17_:ASObject = null;
		var _loc4_:Array<ASAny> = null;
		var _loc18_:String = null;
		var _loc11_:Vector<Array<ASAny>> = /*undefined*/ null;
		var _loc14_:ASObject = {};
		while (mBytes.position < end) {
			_loc15_ = mBytes.readUnsignedShort();
			_loc10_ = _loc15_ >> 6;
			_loc6_ = (_loc15_ & 0x3F : UInt);
			if (_loc6_ == 63) {
				_loc6_ = mBytes.readUnsignedInt();
			}
			_loc3_ = mBytes.position + _loc6_;
			if (_loc10_ == 39) {
				_loc16_ = mBytes.readUnsignedShort();
				mBytes.position += (2 : UInt);
				_loc11_ = new Vector<Array<ASAny>>((0 : UInt));
				mSprites[Std.string(_loc16_)] = _loc11_;
				tags(_loc3_, _loc11_);
			} else if (_loc10_ == 76 || _loc10_ == 56) {
				_loc7_ = mBytes.readUnsignedShort();
				_loc9_ = 0;
				while (_loc9_ < _loc7_) {
					_loc16_ = mBytes.readUnsignedShort();
					_loc13_ = string();
					sSymbols[StringTools.replace(_loc13_, "::", ".")] = {
						"parser": this,
						"id": _loc16_
					};
					_loc9_++;
				}
			} else if (_loc10_ == 2 || _loc10_ == 22 || _loc10_ == 32 || _loc10_ == 83) {
				_loc16_ = mBytes.readUnsignedShort();
				mBounds[Std.string(_loc16_)] = rect();
			} else if (frames != null && (_loc10_ == 26 || _loc10_ == 70)) {
				_loc8_ = mBytes.readUnsignedByte();
				_loc5_ = ASCompat.toInt(_loc10_ == 70 ? mBytes.readUnsignedByte() : 0);
				_loc12_ = mBytes.readUnsignedShort();
				_loc17_ = _loc14_[Std.string(_loc12_)];
				_loc17_ = _loc17_ != null ? {
					"depth": _loc12_,
					"id": _loc17_.id,
					"clip": _loc17_.clip,
					"matrix": _loc17_.matrix
				} : {
					"depth": _loc12_,
					"id": 0,
					"clip": 0,
					"matrix": new Matrix()
					};
				if ((_loc5_ & 8) != 0 || (_loc5_ & 0x10) != 0 && (_loc8_ & 2) != 0) {
					string();
				}
				if ((_loc8_ & 2) != 0) {
					ASCompat.setProperty(_loc17_, "id", mBytes.readUnsignedShort());
				}
				if ((_loc8_ & 4) != 0) {
					ASCompat.setProperty(_loc17_, "matrix", matrix());
				}
				if ((_loc8_ & 8) != 0) {
					color();
				}
				if ((_loc8_ & 0x10) != 0) {
					mBytes.position += (2 : UInt);
				}
				if ((_loc8_ & 0x20) != 0) {
					string();
				}
				if ((_loc8_ & 0x40) != 0) {
					ASCompat.setProperty(_loc17_, "clip", mBytes.readUnsignedShort());
				}
				_loc14_[Std.string(_loc12_)] = _loc17_;
			} else if (frames != null && _loc10_ == 28) {
				ASCompat.deleteProperty(_loc14_, Std.string(mBytes.readUnsignedShort()));
			} else if (frames != null && _loc10_ == 1) {
				_loc4_ = [];
				if (checkNullIteratee(_loc14_))
					for (_tmp_ in _loc14_.___keys()) {
						_loc18_ = _tmp_;
						_loc4_.push(_loc14_[_loc18_]);
					}
				ASCompat.ASArray.sortOn(_loc4_, "depth", 16);
				frames.push(_loc4_);
			}
			mBytes.position = _loc3_;
			if (_loc10_ == 0) {
				break;
			}
		}
	}

	function bits(count:Int, signed:Bool = false):Int {
		var _loc3_ = 0;
		var _loc4_ = 0;
		_loc3_ = 0;
		while (_loc3_ < count) {
			if (mBit == 0) {
				mByte = (mBytes.readUnsignedByte() : Int);
			}
			_loc4_ = _loc4_ << 1 | (mByte >> 7 - mBit & 1);
			mBit = mBit + 1 & 7;
			_loc3_++;
		}
		if (signed && count > 0 && (_loc4_ & 1 << count - 1) != 0) {
			_loc4_ -= 1 << count;
		}
		return _loc4_;
	}

	function rect():Rectangle {
		var _loc4_ = bits(5);
		var _loc2_ = bits(_loc4_, true) / 20;
		var _loc5_ = bits(_loc4_, true) / 20;
		var _loc1_ = bits(_loc4_, true) / 20;
		var _loc3_ = bits(_loc4_, true) / 20;
		mBit = 0;
		return new Rectangle(_loc2_, _loc1_, _loc5_ - _loc2_, _loc3_ - _loc1_);
	}

	function matrix():Matrix {
		var _loc2_ = 0;
		var _loc1_ = new Matrix();
		if (bits(1) != 0) {
			_loc2_ = bits(5);
			_loc1_.a = bits(_loc2_, true) / 65536;
			_loc1_.d = bits(_loc2_, true) / 65536;
		}
		if (bits(1) != 0) {
			_loc2_ = bits(5);
			_loc1_.b = bits(_loc2_, true) / 65536;
			_loc1_.c = bits(_loc2_, true) / 65536;
		}
		_loc2_ = bits(5);
		_loc1_.tx = bits(_loc2_, true) / 20;
		_loc1_.ty = bits(_loc2_, true) / 20;
		mBit = 0;
		return _loc1_;
	}

	function color() {
		var _loc4_ = 0;
		var _loc1_ = bits(1);
		var _loc2_ = bits(1);
		var _loc3_ = bits(4);
		_loc4_ = 0;
		while (_loc4_ < (_loc1_ + _loc2_) * 4) {
			bits(_loc3_);
			_loc4_++;
		}
		mBit = 0;
	}

	function string():String {
		var _loc1_ = mBytes.position;
		while (mBytes.readUnsignedByte() != 0) {}
		var _loc2_ = mBytes.position;
		mBytes.position = _loc1_;
		var _loc3_ = mBytes.readUTFBytes((ASCompat.floatToInt((_loc2_ : Float) - (_loc1_ : Float) - 1) : UInt));
		mBytes.position = _loc2_;
		return _loc3_;
	}
}
