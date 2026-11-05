package uI.hud.starlingConverted;

import brain.starling.swfConverter.BakedPicture;
import flash.display.BitmapData;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

/*internal*/
class StarlingSweepArt {
	static inline final sDeg:Float = 0.017453292519943295;

	static inline final sBins = 360;

	static inline final sProbeSide:Float = 96;

	static inline final sMaxFrames = 200;

	static inline final sEdgePixels:Float = 1.5;

	static var sByClip:ASDictionary<ASAny, ASAny>;

	static var sByKey:ASObject;

	public static var lastRefusal:String;

	static var sDrawn:Int = 0;

	public var frames:Int = 0;

	public var cx:Float = Math.NaN;

	public var cy:Float = Math.NaN;

	public var arcs:Vector<Vector<Float>>;

	public var coverFrames:Vector<Int>;

	public var bounds:Rectangle;

	public function new() {}

	public static function of(clip:MovieClip, onSeek:ASFunction = null):StarlingSweepArt {
		if (sByClip == null) {
			sByClip = new ASDictionary<ASAny, ASAny>(true);
		}
		if (sByKey == null) {
			sByKey = {};
		}
		var _loc4_:ASAny = sByClip[clip];
		if (_loc4_ != /*undefined*/ null) {
			return ASCompat.dynamicAs(_loc4_, StarlingSweepArt);
		}
		var _loc3_:StarlingSweepArt = null;
		try {
			_loc3_ = analyse(clip, onSeek);
		} catch (error:Dynamic) {
			_loc3_ = null;
			lastRefusal = "error " + error.errorID;
		}
		sByClip[clip] = (_loc3_ : ASAny) ?? (false : ASAny);
		return _loc3_;
	}

	static function seek(clip:MovieClip, frame:Int, onSeek:ASFunction) {
		if (onSeek != null) {
			onSeek(clip);
		}
		clip.gotoAndStop(frame);
		if (onSeek != null) {
			onSeek(clip);
		}
	}

	static function analyse(clip:MovieClip, onSeek:ASFunction):StarlingSweepArt {
		var __finallyReturn0:StarlingSweepArt;
		var __finallyReturn1:StarlingSweepArt;
		var __finallyReturn2:StarlingSweepArt;
		var __finallyReturn3:StarlingSweepArt;
		var _loc9_ = 0;
		var _loc7_:Rectangle = null;
		var _loc12_:String = null;
		var _loc11_:Rectangle = null;
		var _loc5_:ASAny = /*undefined*/ null;
		var _loc4_:StarlingSweepArt = null;
		var _loc6_ = clip.totalFrames;
		if (_loc6_ < 2 || _loc6_ > 200) {
			lastRefusal = "frames " + _loc6_;
			return null;
		}
		var _loc8_ = clip.currentFrame;
		var _loc10_ = clip.isPlaying;
		var _loc3_ = clip.visible;
		{
			var __finallyReturn0:StarlingSweepArt;
			var __finallyReturn1:StarlingSweepArt;
			var __finallyReturn2:StarlingSweepArt;
			var __finallyReturn3:StarlingSweepArt;
			try {
				clip.visible = true;
				_loc7_ = new Rectangle();
				_loc12_ = _loc6_ + ":";
				_loc9_ = 1;
				while (true) {
					if (_loc9_ > _loc6_) {
						if (!(_loc7_.width > 0 && _loc7_.height > 0)) {
							lastRefusal = "no bounds";
							{
								__finallyReturn0 = null;
								{
									if (_loc10_) {
										clip.gotoAndPlay(_loc8_);
									} else {
										clip.gotoAndStop(_loc8_);
									}
									clip.visible = _loc3_;
								};
								return __finallyReturn0;
							};
						}
						_loc12_ += pictureKey(clip, _loc6_, _loc7_, onSeek);
						_loc5_ = sByKey[_loc12_];
						if (_loc5_ != /*undefined*/ null) {
							{
								__finallyReturn1 = ASCompat.dynamicAs(_loc5_, StarlingSweepArt);
								{
									if (_loc10_) {
										clip.gotoAndPlay(_loc8_);
									} else {
										clip.gotoAndStop(_loc8_);
									}
									clip.visible = _loc3_;
								};
								return __finallyReturn1;
							};
						}
						_loc4_ = analyseFrames(clip, _loc6_, _loc7_, onSeek);
						sByKey[_loc12_] = (_loc4_ : ASAny) ?? (false : ASAny);
						{
							__finallyReturn2 = _loc4_;
							{
								if (_loc10_) {
									clip.gotoAndPlay(_loc8_);
								} else {
									clip.gotoAndStop(_loc8_);
								}
								clip.visible = _loc3_;
							};
							return __finallyReturn2;
						};
					}
					seek(clip, _loc9_, onSeek);
					if (innerTimeline(clip, 0)) {
						lastRefusal = "inner timeline";
						{
							__finallyReturn3 = null;
							{
								if (_loc10_) {
									clip.gotoAndPlay(_loc8_);
								} else {
									clip.gotoAndStop(_loc8_);
								}
								clip.visible = _loc3_;
							};
							return __finallyReturn3;
						};
					}
					_loc11_ = clip.getBounds(clip);
					_loc12_ += Math.fround(_loc11_.x * 10) + "," + Math.fround(_loc11_.y * 10) + "," + Math.fround(_loc11_.width * 10) + ","
						+ Math.fround(_loc11_.height * 10) + ";";
					if (_loc11_.width > 0 && _loc11_.height > 0) {
						_loc7_ = _loc7_.width > 0 ? _loc7_.union(_loc11_) : _loc11_;
					}
					_loc9_++;
				}
			} catch (__finallyError4:Dynamic) {
				{
					if (_loc10_) {
						clip.gotoAndPlay(_loc8_);
					} else {
						clip.gotoAndStop(_loc8_);
					}
					clip.visible = _loc3_;
				};
				throw __finallyError4;
			};
			{
				if (_loc10_) {
					clip.gotoAndPlay(_loc8_);
				} else {
					clip.gotoAndStop(_loc8_);
				}
				clip.visible = _loc3_;
			};
		}
		return null;
	}

	static function innerTimeline(c:DisplayObjectContainer, depth:Int):Bool {
		var _loc3_ = 0;
		var _loc4_:DisplayObjectContainer = null;
		if (depth > 6) {
			return false;
		}
		_loc3_ = 0;
		while (_loc3_ < c.numChildren) {
			_loc4_ = ASCompat.reinterpretAs(c.getChildAt(_loc3_), DisplayObjectContainer);
			if (_loc4_ != null) {
				if (Std.isOfType(_loc4_, MovieClip) && cast(_loc4_, MovieClip).totalFrames > 1 || innerTimeline(_loc4_, depth + 1)) {
					return true;
				}
			}
			_loc3_++;
		}
		return false;
	}

	static function pictureKey(clip:MovieClip, total:Int, b:Rectangle, onSeek:ASFunction):String {
		var _loc5_ = 0;
		var _loc8_:Vector<UInt> = /*undefined*/ null;
		var _loc10_ = Math.NaN;
		var _loc9_ = 0;
		var _loc6_ = 16 / Math.max(b.width, b.height);
		var _loc7_ = new BitmapData(ASCompat.floatToInt(Math.fceil(b.width * _loc6_) + 2), ASCompat.floatToInt(Math.fceil(b.height * _loc6_) + 2), true,
			(0 : UInt));
		var _loc11_ = "";
		{
			try {
				_loc5_ = 1;
				while (_loc5_ <= 4) {
					seek(clip, ASCompat.floatToInt(Math.max(1, Math.fround(total * _loc5_ / 5))), onSeek);
					_loc7_.fillRect(_loc7_.rect, (0 : UInt));
					_loc7_.draw(clip, new Matrix(_loc6_, 0, 0, _loc6_, 1 - b.x * _loc6_, 1 - b.y * _loc6_), null, null, null, true);
					_loc8_ = _loc7_.getVector(_loc7_.rect);
					_loc10_ = 0;
					_loc9_ = 0;
					while (_loc9_ < _loc8_.length) {
						_loc10_ += (((_loc8_[_loc9_] : Int) >>> 24 : UInt)) * (_loc9_ % 7 + 1);
						_loc9_++;
					}
					_loc11_ += "|" + Math.fround(_loc10_ / 64);
					_loc5_++;
				}
			} catch (__finallyError0:Dynamic) {
				{
					_loc7_.dispose();
				};
				throw __finallyError0;
			};
			{
				_loc7_.dispose();
			};
		}
		return _loc11_;
	}

	static function analyseFrames(clip:MovieClip, total:Int, b:Rectangle, onSeek:ASFunction):StarlingSweepArt {
		var _loc30_:Int;
		var _loc7_:Int;
		var _loc6_:Int;
		var __finallyReturn0:StarlingSweepArt;
		var __finallyReturn1:StarlingSweepArt;
		var _loc20_:Float;
		var __finallyReturn2:StarlingSweepArt;
		var __finallyReturn3:StarlingSweepArt;
		var __finallyReturn4:StarlingSweepArt;
		var _loc13_:BitmapData = null;
		var _loc22_ = 0;
		var _loc25_ = 0;
		var _loc19_ = 0;
		var _loc5_ = Math.NaN;
		var _loc32_ = 0;
		var _loc21_ = 0;
		var _loc27_:Matrix = null;
		var _loc29_:Vector<Vector<UInt>> = /*undefined*/ null;
		var _loc26_:Vector<UInt> = /*undefined*/ null;
		var _loc8_:Vector<UInt> = /*undefined*/ null;
		var _loc31_ = 0;
		var _loc35_ = 0;
		var _loc34_ = 0;
		var _loc12_ = Math.NaN;
		var _loc17_ = Math.NaN;
		var _loc14_ = Math.NaN;
		var _loc18_ = Math.NaN;
		var _loc9_ = 0;
		var _loc37_ = 0;
		var _loc24_ = Math.NaN;
		var _loc23_ = Math.NaN;
		var _loc11_ = 0;
		var _loc10_:Vector<Float> = /*undefined*/ null;
		var _loc15_:StarlingSweepArt = null;
		var _loc16_:Vector<Vector<Bool>> = /*undefined*/ null;
		var _loc28_:Vector<Bool> = /*undefined*/ null;
		var _loc33_:Vector<Bool> = /*undefined*/ null;
		var _loc36_ = 0;
		{
			var __finallyReturn0:StarlingSweepArt;
			var __finallyReturn1:StarlingSweepArt;
			var __finallyReturn2:StarlingSweepArt;
			var __finallyReturn3:StarlingSweepArt;
			var __finallyReturn4:StarlingSweepArt;
			try {
				_loc5_ = Math.min(4, 96 / Math.max(b.width, b.height));
				_loc32_ = ASCompat.floatToInt(Math.fceil(b.width * _loc5_) + 2);
				_loc21_ = ASCompat.floatToInt(Math.fceil(b.height * _loc5_) + 2);
				_loc27_ = new Matrix(_loc5_, 0, 0, _loc5_, 1 - b.x * _loc5_, 1 - b.y * _loc5_);
				_loc13_ = new BitmapData(_loc32_, _loc21_, true, (0 : UInt));
				_loc29_ = new Vector<Vector<UInt>>((total + 1 : UInt), true);
				_loc26_ = new Vector<UInt>((_loc32_ * _loc21_ : UInt), true);
				_loc19_ = 1;
				while (_loc19_ <= total) {
					seek(clip, _loc19_, onSeek);
					_loc13_.fillRect(_loc13_.rect, (0 : UInt));
					_loc13_.draw(clip, _loc27_, null, null, null, true);
					_loc8_ = _loc13_.getVector(_loc13_.rect);
					_loc29_[_loc19_] = _loc8_;
					_loc22_ = 0;
					while (_loc22_ < _loc8_.length) {
						if (((_loc8_[_loc22_] : Int) >>> 24 : UInt) > ((_loc26_[_loc22_] : Int) >>> 24 : UInt)) {
							_loc26_[_loc22_] = _loc8_[_loc22_];
						}
						_loc22_++;
					}
					_loc19_++;
				}
				_loc31_ = _loc32_;
				_loc30_ = _loc21_;
				_loc7_ = -1;
				_loc6_ = -1;
				_loc35_ = 0;
				while (_loc35_ < _loc21_) {
					_loc34_ = 0;
					while (_loc34_ < _loc32_) {
						if (((_loc26_[_loc35_ * _loc32_ + _loc34_] : Int) >>> 24 : UInt) > 32) {
							if (_loc34_ < _loc31_) {
								_loc31_ = _loc34_;
							}
							if (_loc34_ > _loc7_) {
								_loc7_ = _loc34_;
							}
							if (_loc35_ < _loc30_) {
								_loc30_ = _loc35_;
							}
							if (_loc35_ > _loc6_) {
								_loc6_ = _loc35_;
							}
						}
						_loc34_++;
					}
					_loc35_++;
				}
				if (_loc7_ < 0) {
					lastRefusal = "draws nothing";
					{
						__finallyReturn0 = null;
						{
							if (_loc13_ != null) {
								_loc13_.dispose();
							}
						};
						return __finallyReturn0;
					};
				}
				_loc12_ = Math.min(_loc7_ - _loc31_ + 1, _loc6_ - _loc30_ + 1) / 2;
				if (_loc12_ < 6) {
					lastRefusal = "too small";
					{
						__finallyReturn1 = null;
						{
							if (_loc13_ != null) {
								_loc13_.dispose();
							}
						};
						return __finallyReturn1;
					};
				}
				_loc17_ = (_loc31_ + _loc7_ + 1) / 2;
				_loc14_ = (_loc30_ + _loc6_ + 1) / 2;
				_loc18_ = _loc17_;
				_loc20_ = _loc14_;
				_loc9_ = 2147483647;
				_loc37_ = ASCompat.floatToInt(Math.max(1, total / 6));
				_loc24_ = -2;
				while (_loc24_ <= 2) {
					_loc23_ = -2;
					while (_loc23_ <= 2) {
						_loc11_ = 0;
						_loc19_ = 1;
						while (_loc19_ <= total && _loc11_ < _loc9_) {
							_loc10_ = runs(coverage(_loc29_[_loc19_], _loc26_, _loc32_, _loc17_ + _loc23_, _loc14_ + _loc24_, _loc12_, null));
							_loc11_ += mismatches(_loc29_[_loc19_], _loc26_, _loc10_, _loc32_, _loc21_, _loc17_ + _loc23_, _loc14_ + _loc24_);
							_loc19_ += _loc37_;
						}
						if (_loc11_ < _loc9_) {
							_loc9_ = _loc11_;
							_loc18_ = _loc17_ + _loc23_;
							_loc20_ = _loc14_ + _loc24_;
						}
						_loc23_ += 1;
					}
					_loc24_ += 1;
				}
				_loc15_ = new StarlingSweepArt();
				_loc15_.frames = total;
				_loc15_.bounds = b;
				_loc15_.cx = (_loc18_ - 1) / _loc5_ + b.x;
				_loc15_.cy = (_loc20_ - 1) / _loc5_ + b.y;
				_loc15_.arcs = new Vector<Vector<Float>>((total + 1 : UInt), true);
				_loc16_ = new Vector<Vector<Bool>>((total + 1 : UInt), true);
				_loc28_ = new Vector<Bool>((360 : UInt), true);
				_loc19_ = 1;
				while (_loc19_ <= total) {
					_loc33_ = coverage(_loc29_[_loc19_], _loc26_, _loc32_, _loc18_, _loc20_, _loc12_, _loc28_);
					_loc16_[_loc19_] = _loc33_;
					_loc15_.arcs[_loc19_] = runs(_loc33_);
					_loc19_++;
				}
				_loc19_ = 1;
				while (true) {
					if (_loc19_ > total) {
						_loc15_.coverFrames = cover(_loc16_, _loc28_, total);
						if (_loc15_.coverFrames == null) {
							lastRefusal = "no cover";
							{
								__finallyReturn2 = null;
								{
									if (_loc13_ != null) {
										_loc13_.dispose();
									}
								};
								return __finallyReturn2;
							};
						}
						{
							__finallyReturn3 = _loc15_;
							{
								if (_loc13_ != null) {
									_loc13_.dispose();
								}
							};
							return __finallyReturn3;
						};
					}
					_loc36_ = mismatches(_loc29_[_loc19_], _loc26_, _loc15_.arcs[_loc19_], _loc32_, _loc21_, _loc18_, _loc20_);
					if (_loc36_ > Math.max(12, sDrawn / 100)) {
						lastRefusal = "frame " + _loc19_ + " differs by " + _loc36_ + "/" + sDrawn;
						{
							__finallyReturn4 = null;
							{
								if (_loc13_ != null) {
									_loc13_.dispose();
								}
							};
							return __finallyReturn4;
						};
					}
					_loc19_++;
				}
			} catch (__finallyError5:Dynamic) {
				{
					if (_loc13_ != null) {
						_loc13_.dispose();
					}
				};
				throw __finallyError5;
			};
			{
				if (_loc13_ != null) {
					_loc13_.dispose();
				}
			};
		}
		return null;
	}

	static function runs(covered:Vector<Bool>):Vector<Float> {
		var _loc5_ = 0;
		var _loc10_ = false;
		var _loc6_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc9_ = new Vector<Float>((0 : UInt));
		var _loc4_:Float = 1;
		var _loc7_ = 0;
		var _loc2_ = -1;
		_loc7_ = 0;
		while (_loc7_ < 360) {
			if (!covered[_loc7_]) {
				_loc2_ = _loc7_;
				break;
			}
			_loc7_++;
		}
		if (_loc2_ < 0) {
			ASCompat.ASArray.pushMultiple(_loc9_, 0, 360);
			return _loc9_;
		}
		var _loc3_ = -1;
		_loc5_ = 1;
		while (_loc5_ <= 360) {
			_loc7_ = _loc2_ + _loc5_;
			_loc10_ = covered[_loc7_ % 360];
			if (_loc10_ && _loc3_ < 0) {
				_loc3_ = _loc7_;
			}
			if ((!_loc10_ || _loc5_ == 360) && _loc3_ >= 0) {
				_loc6_ = _loc3_ * _loc4_;
				_loc8_ = (_loc10_ ? _loc7_ + 1 : _loc7_) * _loc4_;
				if (_loc6_ >= 360) {
					_loc6_ -= 360;
					_loc8_ -= 360;
				}
				ASCompat.ASArray.pushMultiple(_loc9_, _loc6_, _loc8_);
				_loc3_ = -1;
			}
			_loc5_++;
		}
		return _loc9_;
	}

	static function inArcs(arcs:Vector<Float>, deg:Float):Bool {
		var _loc3_ = 0;
		_loc3_ = 0;
		while (_loc3_ + 1 < arcs.length) {
			if (deg >= arcs[_loc3_] && deg < arcs[_loc3_ + 1] || deg + 360 >= arcs[_loc3_] && deg + 360 < arcs[_loc3_ + 1]) {
				return true;
			}
			_loc3_ += 2;
		}
		return false;
	}

	static function edgeDistance(arcs:Vector<Float>, deg:Float):Float {
		var _loc3_ = 0;
		var _loc4_ = Math.NaN;
		var _loc5_:Float = 360;
		_loc3_ = 0;
		while (_loc3_ < arcs.length) {
			_loc4_ = Math.abs(deg - arcs[_loc3_]) % 360;
			if (_loc4_ > 180) {
				_loc4_ = 360 - _loc4_;
			}
			if (_loc4_ < _loc5_) {
				_loc5_ = _loc4_;
			}
			_loc3_++;
		}
		return _loc5_;
	}

	static function coverage(px:Vector<UInt>, union:Vector<UInt>, w:Int, pcx:Float, pcy:Float, radius:Float, any:Vector<Bool>):Vector<Bool> {
		var _loc9_ = 0;
		var _loc12_ = Math.NaN;
		var _loc8_ = Math.NaN;
		var _loc15_ = 0;
		var _loc11_ = Math.NaN;
		var _loc13_ = 0;
		var _loc10_ = (0 : UInt);
		var _loc14_ = new Vector<Bool>((360 : UInt), true);
		_loc9_ = 0;
		while (_loc9_ < 360) {
			_loc12_ = Math.sin((_loc9_ + 0.5) * 360 / 360 * 0.017453292519943295);
			_loc8_ = Math.cos((_loc9_ + 0.5) * 360 / 360 * 0.017453292519943295);
			_loc15_ = 0;
			_loc11_ = 0.35;
			while (_loc11_ < 0.8) {
				_loc13_ = ASCompat.floatToInt(pcy - radius * _loc11_ * _loc8_) * w + ASCompat.floatToInt(pcx + radius * _loc11_ * _loc12_);
				if (!(_loc13_ < 0 || _loc13_ >= union.length)) {
					_loc10_ = (((union[_loc13_] : Int) >>> 24 : UInt) : UInt);
					if (_loc10_ >= 40) {
						_loc15_ += (((px[_loc13_] : Int) >>> 24 : UInt)) * 2 >= _loc10_ ? 1 : -1;
					}
				}
				_loc11_ += 0.2;
			}
			_loc14_[_loc9_] = _loc15_ > 0;
			if (_loc15_ > 0 && any != null) {
				any[_loc9_] = true;
			}
			_loc9_++;
		}
		return _loc14_;
	}

	static function mismatches(px:Vector<UInt>, union:Vector<UInt>, arcs:Vector<Float>, w:Int, h:Int, pcx:Float, pcy:Float):Int {
		var _loc16_:Float;
		var _loc18_ = 0;
		var _loc17_ = 0;
		var _loc12_ = 0;
		var _loc8_ = (0 : UInt);
		var _loc14_ = (0 : UInt);
		var _loc15_ = Math.NaN;
		var _loc13_ = Math.NaN;
		var _loc9_ = Math.NaN;
		var _loc10_ = (0 : UInt);
		var _loc11_ = 0;
		var _loc19_ = 0;
		_loc18_ = 0;
		while (_loc18_ < h) {
			_loc17_ = 0;
			while (_loc17_ < w) {
				_loc12_ = _loc18_ * w + _loc17_;
				_loc8_ = px[_loc12_];
				_loc14_ = union[_loc12_];
				if ((((_loc8_ : Int) | (_loc14_ : Int)) >>> 24 : UInt) != 0) {
					_loc19_++;
					_loc15_ = _loc17_ + 0.5 - pcx;
					_loc16_ = _loc18_ + 0.5 - pcy;
					_loc13_ = Math.sqrt(_loc15_ * _loc15_ + _loc16_ * _loc16_);
					if (_loc13_ >= 2) {
						_loc9_ = Math.atan2(_loc15_, -_loc16_) / 0.017453292519943295;
						if (_loc9_ < 0) {
							_loc9_ += 360;
						}
						if (!(arcs.length > 0 && edgeDistance(arcs, _loc9_) * 0.017453292519943295 * _loc13_ < 1.5)) {
							_loc10_ = (ASCompat.toInt(inArcs(arcs, _loc9_) ? _loc14_ : 0) : UInt);
							if (_loc10_ != _loc8_) {
								if (Math.abs(((((_loc10_ : Int) >>> 24 : UInt)) : Float) - ((((_loc8_ : Int) >>> 24 : UInt)) : Float)) > 64
									|| ((_loc8_ : Int) >>> 24 : UInt) > 64
										&& ((_loc10_ : Int) >>> 24 : UInt) > 64
											&& (Math.abs(((_loc10_ : Int) >>> 16 & 0xFF) - ((_loc8_ : Int) >>> 16 & 0xFF)) > 64
												|| Math.abs(((_loc10_ : Int) >>> 8 & 0xFF) - ((_loc8_ : Int) >>> 8 & 0xFF)) > 64
												|| Math.abs(((_loc10_ : Int) & 0xFF) - ((_loc8_ : Int) & 0xFF)) > 64)) {
									_loc11_++;
								}
							}
						}
					}
				}
				_loc17_++;
			}
			_loc18_++;
		}
		sDrawn = _loc19_;
		return _loc11_;
	}

	static function cover(bins:Vector<Vector<Bool>>, any:Vector<Bool>, total:Int):Vector<Int> {
		var _loc8_:Int;
		var _loc11_ = 0;
		var _loc10_ = 0;
		var _loc7_ = 0;
		var _loc9_ = 0;
		var _loc4_ = any.concat();
		var _loc5_ = 0;
		_loc11_ = 0;
		while (_loc11_ < 360) {
			if (_loc4_[_loc11_]) {
				_loc5_++;
			}
			_loc11_++;
		}
		if (_loc5_ == 0) {
			return null;
		}
		var _loc6_ = new Vector<Int>((0 : UInt));
		while (_loc5_ > 0 && _loc6_.length < 6) {
			_loc10_ = -1;
			_loc8_ = 0;
			_loc7_ = 1;
			while (_loc7_ <= total) {
				_loc9_ = 0;
				_loc11_ = 0;
				while (_loc11_ < 360) {
					if (_loc4_[_loc11_] && bins[_loc7_][_loc11_]) {
						_loc9_++;
					}
					_loc11_++;
				}
				if (_loc9_ > _loc8_) {
					_loc8_ = _loc9_;
					_loc10_ = _loc7_;
				}
				_loc7_++;
			}
			if (_loc10_ < 0) {
				break;
			}
			_loc6_.push(_loc10_);
			_loc11_ = 0;
			while (_loc11_ < 360) {
				if (bins[_loc10_][_loc11_] && _loc4_[_loc11_]) {
					_loc4_[_loc11_] = false;
					_loc5_--;
				}
				_loc11_++;
			}
		}
		return _loc5_ == 0 ? _loc6_ : null;
	}

	public function bakeDisc(clip:MovieClip, pixelScale:Float, onSeek:ASFunction = null):BakedPicture {
		var _loc8_:Int;
		var __ax4_iter_220:Vector<Int>;
		var __finallyReturn0:BakedPicture;
		var __finallyReturn1:BakedPicture;
		var __finallyReturn2:BakedPicture;
		var _loc6_:BitmapData = null;
		var _loc9_:ASAny = /*undefined*/ null;
		var _loc12_:Matrix = null;
		var _loc10_:Vector<UInt> = /*undefined*/ null;
		var _loc11_ = 0;
		var _loc13_:Rectangle = null;
		var _loc17_:BakedPicture = null;
		if (pixelScale <= 0) {
			return null;
		}
		var _loc5_ = pixelScale;
		var _loc14_ = 3;
		pixelScale = Math.min(pixelScale, (1024 - _loc14_ * 2 - 2) / Math.max(bounds.width, bounds.height));
		var _loc16_ = ASCompat.floatToInt(Math.ffloor(bounds.left * pixelScale) - _loc14_);
		var _loc15_ = ASCompat.floatToInt(Math.ffloor(bounds.top * pixelScale) - _loc14_);
		var _loc18_ = ASCompat.floatToInt(Math.fceil(bounds.right * pixelScale) + _loc14_ - _loc16_);
		var _loc20_ = ASCompat.floatToInt(Math.fceil(bounds.bottom * pixelScale) + _loc14_ - _loc15_);
		var _loc7_ = clip.currentFrame;
		var _loc19_ = clip.isPlaying;
		var _loc4_ = clip.visible;
		{
			var _loc8_:Int;
			var __ax4_iter_220:Vector<Int>;
			var __finallyReturn0:BakedPicture;
			var __finallyReturn1:BakedPicture;
			var __finallyReturn2:BakedPicture;
			try {
				try {
					clip.visible = true;
					_loc6_ = new BitmapData(_loc18_, _loc20_, true, (0 : UInt));
					_loc12_ = new Matrix(pixelScale, 0, 0, pixelScale, -_loc16_, -_loc15_);
					__ax4_iter_220 = coverFrames;
					if (checkNullIteratee(__ax4_iter_220))
						for (_tmp_ in __ax4_iter_220) {
							_loc8_ = _tmp_;
							seek(clip, _loc8_, onSeek);
							_loc6_.fillRect(_loc6_.rect, (0 : UInt));
							_loc6_.draw(clip, _loc12_, null, null, null, true);
							_loc10_ = _loc6_.getVector(_loc6_.rect);
							if (_loc9_ == null) {
								_loc9_ = _loc10_;
							} else {
								_loc11_ = 0;
								while (_loc11_ < _loc10_.length) {
									if (((_loc10_[_loc11_] : Int) >>> 24 : UInt) > (ASCompat.toInt(_loc9_[_loc11_]) >>> 24:UInt)) {
										_loc9_[_loc11_] = _loc10_[_loc11_];
									}
									_loc11_++;
								}
							}
						}
					_loc6_.setVector(_loc6_.rect, (_loc9_ : Vector<UInt>));
					_loc13_ = _loc6_.getColorBoundsRect((ASCompat.floatToInt(4278190080) : UInt), (0 : UInt), false);
					if (_loc13_.width <= 0 || _loc13_.height <= 0) {
						{
							__finallyReturn0 = null;
							{
								if (_loc19_) {
									clip.gotoAndPlay(_loc7_);
								} else {
									clip.gotoAndStop(_loc7_);
								}
								clip.visible = _loc4_;
								if (_loc6_ != null) {
									_loc6_.dispose();
								}
							};
							return __finallyReturn0;
						};
					}
					_loc17_ = new BakedPicture();
					_loc17_.bitmap = new BitmapData(ASCompat.floatToInt(_loc13_.width + 1 * 2), ASCompat.floatToInt(_loc13_.height + 1 * 2), true, (0 : UInt));
					_loc17_.bitmap.copyPixels(_loc6_, _loc13_, new Point(1, 1));
					_loc17_.originX = ASCompat.floatToInt(-_loc16_ - _loc13_.x + 1);
					_loc17_.originY = ASCompat.floatToInt(-_loc15_ - _loc13_.y + 1);
					_loc17_.pixelScale = pixelScale;
					StarlingRaster.limit(_loc17_, _loc5_);
					{
						__finallyReturn1 = _loc17_;
						{
							if (_loc19_) {
								clip.gotoAndPlay(_loc7_);
							} else {
								clip.gotoAndStop(_loc7_);
							}
							clip.visible = _loc4_;
							if (_loc6_ != null) {
								_loc6_.dispose();
							}
						};
						return __finallyReturn1;
					};
				} catch (error:Dynamic) {
					{
						__finallyReturn2 = null;
						{
							if (_loc19_) {
								clip.gotoAndPlay(_loc7_);
							} else {
								clip.gotoAndStop(_loc7_);
							}
							clip.visible = _loc4_;
							if (_loc6_ != null) {
								_loc6_.dispose();
							}
						};
						return __finallyReturn2;
					};
				};
			} catch (__finallyError3:Dynamic) {
				{
					if (_loc19_) {
						clip.gotoAndPlay(_loc7_);
					} else {
						clip.gotoAndStop(_loc7_);
					}
					clip.visible = _loc4_;
					if (_loc6_ != null) {
						_loc6_.dispose();
					}
				};
				throw __finallyError3;
			};
			{
				if (_loc19_) {
					clip.gotoAndPlay(_loc7_);
				} else {
					clip.gotoAndStop(_loc7_);
				}
				clip.visible = _loc4_;
				if (_loc6_ != null) {
					_loc6_.dispose();
				}
			};
		}
		return null;
	}
}
