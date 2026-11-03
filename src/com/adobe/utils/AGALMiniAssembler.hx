package com.adobe.utils;

import flash.display3D.*;
import flash.utils.*;

class AGALMiniAssembler {
	static var initialized:Bool = false;

	static inline final MAX_NESTING = 4;

	static inline final MAX_OPCODES = 4096;

	static inline final FRAGMENT = "fragment";

	static inline final VERTEX = "vertex";

	static inline final SAMPLER_TYPE_SHIFT = (8 : UInt);

	static inline final SAMPLER_DIM_SHIFT = (12 : UInt);

	static inline final SAMPLER_SPECIAL_SHIFT = (16 : UInt);

	static inline final SAMPLER_REPEAT_SHIFT = (20 : UInt);

	static inline final SAMPLER_MIPMAP_SHIFT = (24 : UInt);

	static inline final SAMPLER_FILTER_SHIFT = (28 : UInt);

	static inline final REG_WRITE = (1 : UInt);

	static inline final REG_READ = (2 : UInt);

	static inline final REG_FRAG = (32 : UInt);

	static inline final REG_VERT = (64 : UInt);

	static inline final OP_SCALAR = (1 : UInt);

	static inline final OP_SPECIAL_TEX = (8 : UInt);

	static inline final OP_SPECIAL_MATRIX = (16 : UInt);

	static inline final OP_FRAG_ONLY = (32 : UInt);

	static inline final OP_VERT_ONLY = (64 : UInt);

	static inline final OP_NO_DEST = (128 : UInt);

	static inline final OP_VERSION2 = (256 : UInt);

	static inline final OP_INCNEST = (512 : UInt);

	static inline final OP_DECNEST = (1024 : UInt);

	static inline final MOV = "mov";

	static inline final ADD = "add";

	static inline final SUB = "sub";

	static inline final MUL = "mul";

	static inline final DIV = "div";

	static inline final RCP = "rcp";

	static inline final MIN_cpp /*cpp macro conflict*/ = "min";

	static inline final MAX_cpp /*cpp macro conflict*/ = "max";

	static inline final FRC = "frc";

	static inline final SQT = "sqt";

	static inline final RSQ = "rsq";

	static inline final POW = "pow";

	static inline final LOG = "log";

	static inline final EXP = "exp";

	static inline final NRM = "nrm";

	static inline final SIN = "sin";

	static inline final COS = "cos";

	static inline final CRS = "crs";

	static inline final DP3 = "dp3";

	static inline final DP4 = "dp4";

	static inline final ABS = "abs";

	static inline final NEG = "neg";

	static inline final SAT = "sat";

	static inline final M33 = "m33";

	static inline final M44 = "m44";

	static inline final M34 = "m34";

	static inline final DDX = "ddx";

	static inline final DDY = "ddy";

	static inline final IFE = "ife";

	static inline final INE = "ine";

	static inline final IFG = "ifg";

	static inline final IFL = "ifl";

	static inline final ELS = "els";

	static inline final EIF = "eif";

	static inline final TED = "ted";

	static inline final KIL = "kil";

	static inline final TEX = "tex";

	static inline final SGE = "sge";

	static inline final SLT = "slt";

	static inline final SGN = "sgn";

	static inline final SEQ = "seq";

	static inline final SNE = "sne";

	static inline final TLD = "tld";

	static inline final VA = "va";

	static inline final VC = "vc";

	static inline final VT = "vt";

	static inline final VO = "vo";

	static inline final VI = "vi";

	static inline final FC = "fc";

	static inline final FT = "ft";

	static inline final FS = "fs";

	static inline final FO = "fo";

	static inline final FD = "fd";

	static inline final IID = "iid";

	static inline final VS = "vs";

	static inline final D2 = "2d";

	static inline final D3 = "3d";

	static inline final CUBE = "cube";

	static inline final MIPNEAREST = "mipnearest";

	static inline final MIPLINEAR = "miplinear";

	static inline final MIPNONE = "mipnone";

	static inline final NOMIP = "nomip";

	static inline final NEAREST = "nearest";

	static inline final LINEAR = "linear";

	static inline final ANISOTROPIC2X = "anisotropic2x";

	static inline final ANISOTROPIC4X = "anisotropic4x";

	static inline final ANISOTROPIC8X = "anisotropic8x";

	static inline final ANISOTROPIC16X = "anisotropic16x";

	static inline final CENTROID = "centroid";

	static inline final SINGLE = "single";

	static inline final IGNORESAMPLER = "ignoresampler";

	static inline final REPEAT = "repeat";

	static inline final WRAP = "wrap";

	static inline final CLAMP = "clamp";

	static inline final REPEAT_U_CLAMP_V = "repeat_u_clamp_v";

	static inline final CLAMP_U_REPEAT_V = "clamp_u_repeat_v";

	static inline final RGBA = "rgba";

	static inline final COMPRESSED = "compressed";

	static inline final COMPRESSEDALPHA = "compressedalpha";

	static inline final DXT1 = "dxt1";

	static inline final DXT5 = "dxt5";

	static inline final VIDEO = "video";

	static final REGEXP_OUTER_SPACES:compat.RegExp = new compat.RegExp("^\\s+|\\s+$", "g");

	static final OPMAP:ASDictionary<ASAny, ASAny> = new ASDictionary();

	static final REGMAP:ASDictionary<ASAny, ASAny> = new ASDictionary();

	static final SAMPLEMAP:ASDictionary<ASAny, ASAny> = new ASDictionary();

	var _agalcode:ByteArray = null;

	var _error:String = "";

	var debugEnabled:Bool = false;

	public var verbose:Bool = false;

	public function new(debugging:Bool = false) {
		debugEnabled = debugging;
		if (!initialized) {
			init();
		}
	}

	static function init() {
		initialized = true;
		OPMAP["mov"] = new OpCode("mov", (2 : UInt), (0 : UInt), (0 : UInt));
		OPMAP["add"] = new OpCode("add", (3 : UInt), (1 : UInt), (0 : UInt));
		OPMAP["sub"] = new OpCode("sub", (3 : UInt), (2 : UInt), (0 : UInt));
		OPMAP["mul"] = new OpCode("mul", (3 : UInt), (3 : UInt), (0 : UInt));
		OPMAP["div"] = new OpCode("div", (3 : UInt), (4 : UInt), (0 : UInt));
		OPMAP["rcp"] = new OpCode("rcp", (2 : UInt), (5 : UInt), (0 : UInt));
		OPMAP["min"] = new OpCode("min", (3 : UInt), (6 : UInt), (0 : UInt));
		OPMAP["max"] = new OpCode("max", (3 : UInt), (7 : UInt), (0 : UInt));
		OPMAP["frc"] = new OpCode("frc", (2 : UInt), (8 : UInt), (0 : UInt));
		OPMAP["sqt"] = new OpCode("sqt", (2 : UInt), (9 : UInt), (0 : UInt));
		OPMAP["rsq"] = new OpCode("rsq", (2 : UInt), (10 : UInt), (0 : UInt));
		OPMAP["pow"] = new OpCode("pow", (3 : UInt), (11 : UInt), (0 : UInt));
		OPMAP["log"] = new OpCode("log", (2 : UInt), (12 : UInt), (0 : UInt));
		OPMAP["exp"] = new OpCode("exp", (2 : UInt), (13 : UInt), (0 : UInt));
		OPMAP["nrm"] = new OpCode("nrm", (2 : UInt), (14 : UInt), (0 : UInt));
		OPMAP["sin"] = new OpCode("sin", (2 : UInt), (15 : UInt), (0 : UInt));
		OPMAP["cos"] = new OpCode("cos", (2 : UInt), (16 : UInt), (0 : UInt));
		OPMAP["crs"] = new OpCode("crs", (3 : UInt), (17 : UInt), (0 : UInt));
		OPMAP["dp3"] = new OpCode("dp3", (3 : UInt), (18 : UInt), (0 : UInt));
		OPMAP["dp4"] = new OpCode("dp4", (3 : UInt), (19 : UInt), (0 : UInt));
		OPMAP["abs"] = new OpCode("abs", (2 : UInt), (20 : UInt), (0 : UInt));
		OPMAP["neg"] = new OpCode("neg", (2 : UInt), (21 : UInt), (0 : UInt));
		OPMAP["sat"] = new OpCode("sat", (2 : UInt), (22 : UInt), (0 : UInt));
		OPMAP["m33"] = new OpCode("m33", (3 : UInt), (23 : UInt), (16 : UInt));
		OPMAP["m44"] = new OpCode("m44", (3 : UInt), (24 : UInt), (16 : UInt));
		OPMAP["m34"] = new OpCode("m34", (3 : UInt), (25 : UInt), (16 : UInt));
		OPMAP["ddx"] = new OpCode("ddx", (2 : UInt), (26 : UInt), (0x0100 | 0x20 : UInt));
		OPMAP["ddy"] = new OpCode("ddy", (2 : UInt), (27 : UInt), (0x0100 | 0x20 : UInt));
		OPMAP["ife"] = new OpCode("ife", (2 : UInt), (28 : UInt), (0x80 | 0x0100 | 0x0200 | 1 : UInt));
		OPMAP["ine"] = new OpCode("ine", (2 : UInt), (29 : UInt), (0x80 | 0x0100 | 0x0200 | 1 : UInt));
		OPMAP["ifg"] = new OpCode("ifg", (2 : UInt), (30 : UInt), (0x80 | 0x0100 | 0x0200 | 1 : UInt));
		OPMAP["ifl"] = new OpCode("ifl", (2 : UInt), (31 : UInt), (0x80 | 0x0100 | 0x0200 | 1 : UInt));
		OPMAP["els"] = new OpCode("els", (0 : UInt), (32 : UInt), (0x80 | 0x0100 | 0x0200 | 0x0400 | 1 : UInt));
		OPMAP["eif"] = new OpCode("eif", (0 : UInt), (33 : UInt), (0x80 | 0x0100 | 0x0400 | 1 : UInt));
		OPMAP["kil"] = new OpCode("kil", (1 : UInt), (39 : UInt), (0x80 | 0x20 : UInt));
		OPMAP["tex"] = new OpCode("tex", (3 : UInt), (40 : UInt), (0x20 | 8 : UInt));
		OPMAP["sge"] = new OpCode("sge", (3 : UInt), (41 : UInt), (0 : UInt));
		OPMAP["slt"] = new OpCode("slt", (3 : UInt), (42 : UInt), (0 : UInt));
		OPMAP["sgn"] = new OpCode("sgn", (2 : UInt), (43 : UInt), (0 : UInt));
		OPMAP["seq"] = new OpCode("seq", (3 : UInt), (44 : UInt), (0 : UInt));
		OPMAP["sne"] = new OpCode("sne", (3 : UInt), (45 : UInt), (0 : UInt));
		OPMAP["tld"] = new OpCode("tld", (3 : UInt), (46 : UInt), (0x40 | 8 : UInt));
		SAMPLEMAP["rgba"] = new Sampler("rgba", (8 : UInt), (0 : UInt));
		SAMPLEMAP["compressed"] = new Sampler("compressed", (8 : UInt), (1 : UInt));
		SAMPLEMAP["compressedalpha"] = new Sampler("compressedalpha", (8 : UInt), (2 : UInt));
		SAMPLEMAP["dxt1"] = new Sampler("dxt1", (8 : UInt), (1 : UInt));
		SAMPLEMAP["dxt5"] = new Sampler("dxt5", (8 : UInt), (2 : UInt));
		SAMPLEMAP["video"] = new Sampler("video", (8 : UInt), (3 : UInt));
		SAMPLEMAP["2d"] = new Sampler("2d", (12 : UInt), (0 : UInt));
		SAMPLEMAP["3d"] = new Sampler("3d", (12 : UInt), (2 : UInt));
		SAMPLEMAP["cube"] = new Sampler("cube", (12 : UInt), (1 : UInt));
		SAMPLEMAP["mipnearest"] = new Sampler("mipnearest", (24 : UInt), (1 : UInt));
		SAMPLEMAP["miplinear"] = new Sampler("miplinear", (24 : UInt), (2 : UInt));
		SAMPLEMAP["mipnone"] = new Sampler("mipnone", (24 : UInt), (0 : UInt));
		SAMPLEMAP["nomip"] = new Sampler("nomip", (24 : UInt), (0 : UInt));
		SAMPLEMAP["nearest"] = new Sampler("nearest", (28 : UInt), (0 : UInt));
		SAMPLEMAP["linear"] = new Sampler("linear", (28 : UInt), (1 : UInt));
		SAMPLEMAP["anisotropic2x"] = new Sampler("anisotropic2x", (28 : UInt), (2 : UInt));
		SAMPLEMAP["anisotropic4x"] = new Sampler("anisotropic4x", (28 : UInt), (3 : UInt));
		SAMPLEMAP["anisotropic8x"] = new Sampler("anisotropic8x", (28 : UInt), (4 : UInt));
		SAMPLEMAP["anisotropic16x"] = new Sampler("anisotropic16x", (28 : UInt), (5 : UInt));
		SAMPLEMAP["centroid"] = new Sampler("centroid", (16 : UInt), (1 : UInt));
		SAMPLEMAP["single"] = new Sampler("single", (16 : UInt), (2 : UInt));
		SAMPLEMAP["ignoresampler"] = new Sampler("ignoresampler", (16 : UInt), (4 : UInt));
		SAMPLEMAP["repeat"] = new Sampler("repeat", (20 : UInt), (1 : UInt));
		SAMPLEMAP["wrap"] = new Sampler("wrap", (20 : UInt), (1 : UInt));
		SAMPLEMAP["clamp"] = new Sampler("clamp", (20 : UInt), (0 : UInt));
		SAMPLEMAP["clamp_u_repeat_v"] = new Sampler("clamp_u_repeat_v", (20 : UInt), (2 : UInt));
		SAMPLEMAP["repeat_u_clamp_v"] = new Sampler("repeat_u_clamp_v", (20 : UInt), (3 : UInt));
	}

	@:isVar public var error(get, never):String;

	public function get_error():String {
		return _error;
	}

	@:isVar public var agalcode(get, never):ByteArray;

	public function get_agalcode():ByteArray {
		return _agalcode;
	}

	public function assemble2(ctx3d:Context3D, version:UInt, vertexsrc:String, fragmentsrc:String):Program3D {
		var _loc5_ = assemble("vertex", vertexsrc, version);
		var _loc6_ = assemble("fragment", fragmentsrc, version);
		var _loc7_ = ctx3d.createProgram();
		_loc7_.upload(_loc5_, _loc6_);
		return _loc7_;
	}

	public function assemble(mode:String, source:String, version:UInt = (1 : UInt), ignorelimits:Bool = false):ByteArray {
		var _loc41_ = 0;
		var _loc29_:String = null;
		var _loc32_ = 0;
		var _loc13_ = 0;
		var _loc9_:Array<ASAny> = null;
		var _loc34_:Array<ASAny> = null;
		var _loc15_:OpCode = null;
		var _loc42_:Array<ASAny> = null;
		var _loc23_ = false;
		var _loc8_ = (0 : UInt);
		var _loc49_ = (0 : UInt);
		var _loc43_ = 0;
		var _loc25_ = false;
		var _loc7_:Array<ASAny> = null;
		var _loc16_:Array<ASAny> = null;
		var _loc18_:Register = null;
		var _loc10_:Array<ASAny> = null;
		var _loc38_ = (0 : UInt);
		var _loc26_ = (0 : UInt);
		var _loc50_:Array<ASAny> = null;
		var _loc31_ = false;
		var _loc39_ = false;
		var _loc35_ = (0 : UInt);
		var _loc45_ = (0 : UInt);
		var _loc27_ = 0;
		var _loc47_ = (0 : UInt);
		var _loc48_ = (0 : UInt);
		var _loc46_ = 0;
		var _loc17_:Array<ASAny> = null;
		var _loc30_:Register = null;
		var _loc37_:Array<ASAny> = null;
		var _loc5_:Array<ASAny> = null;
		var _loc21_ = (0 : UInt);
		var _loc11_ = (0 : UInt);
		var _loc12_ = Math.NaN;
		var _loc6_:Sampler = null;
		var _loc28_:String = null;
		var _loc33_ = (0 : UInt);
		var _loc22_ = (0 : UInt);
		var _loc20_:String = null;
		var _loc40_ = (flash.Lib.getTimer() : UInt);
		_agalcode = new ByteArray();
		_error = "";
		var _loc14_ = false;
		if (mode == "fragment") {
			_loc14_ = true;
		} else if (mode != "vertex") {
			_error = "ERROR: mode needs to be \"fragment\" or \"vertex\" but is \"" + mode + "\".";
		}
		agalcode.endian = "littleEndian";
		agalcode.writeByte(160);
		agalcode.writeUnsignedInt(version);
		agalcode.writeByte(161);
		agalcode.writeByte(_loc14_ ? 1 : 0);
		initregmap(version, ignorelimits);
		var _loc36_:Array<ASAny> = (cast new compat.RegExp("[\\f\\n\\r\\v]+", "g").replace(source, "\n").split("\n"));
		var _loc44_ = 0;
		var _loc24_ = 0;
		var _loc19_ = _loc36_.length;
		_loc41_ = 0;
		while (_loc41_ < _loc19_ && _error == "") {
			_loc29_ = ASCompat.toString(_loc36_[_loc41_]);
			_loc29_ = REGEXP_OUTER_SPACES.replace(_loc29_, "");
			_loc32_ = _loc29_.indexOf("//");
			if (_loc32_ != -1) {
				_loc29_ = _loc29_.substring(0, _loc32_);
			}
			_loc13_ = new compat.RegExp("<.*>", "g").search(_loc29_);
			if (_loc13_ != -1) {
				_loc9_ = (cast new compat.RegExp("([\\w\\.\\-\\+]+)", "gi").match(_loc29_.substring(_loc13_)));
				_loc29_ = _loc29_.substring(0, _loc13_);
			}
			_loc34_ = (cast new compat.RegExp("^\\w{3}", "gi").match(_loc29_));
			if (_loc34_ == null) {
				if (_loc29_.length >= 3) {}
			} else {
				_loc15_ = ASCompat.coerce(OPMAP[_loc34_[0]], OpCode);
				if (debugEnabled) {}
				if (_loc15_ == null) {
					if (_loc29_.length >= 3) {}
				} else {
					_loc29_ = _loc29_.substring(_loc29_.indexOf(_loc15_.name) + _loc15_.name.length);
					if (((_loc15_.flags : Int) & 0x0100) != 0 && version < 2) {
						_error = "error: opcode requires version 2.";
						break;
					}
					if (((_loc15_.flags : Int) & 0x40) != 0 && _loc14_) {
						_error = "error: opcode is only allowed in vertex programs.";
						break;
					}
					if (((_loc15_.flags : Int) & 0x20) != 0 && !_loc14_) {
						_error = "error: opcode is only allowed in fragment programs.";
						break;
					}
					if (verbose) {}
					agalcode.writeUnsignedInt(_loc15_.emitCode);
					if (++_loc24_ > 4096) {
						_error = "error: too many opcodes. maximum is 4096.";
						break;
					}
					_loc42_ = (cast new compat.RegExp("vc\\[([vofi][acostdip]?[d]?)(\\d*)?((\\.[xyzw])?(\\+\\d{1,3})?)?\\](\\.[xyzw]{1,4})?|([vofi][acostdip]?[d]?)(\\d*)?(\\.[xyzw]{1,4})?",
						"gi").match(_loc29_));
					if (_loc42_ == null || (_loc42_.length : UInt) != _loc15_.numRegister) {
						_error = "error: wrong number of operands. found " + _loc42_.length + " but expected " + _loc15_.numRegister + ".";
						break;
					}
					_loc23_ = false;
					_loc8_ = (160 : UInt);
					_loc49_ = (_loc42_.length : UInt);
					_loc43_ = 0;
					while ((_loc43_ : UInt) < _loc49_) {
						_loc25_ = false;
						_loc7_ = ASCompat.coerce(new compat.RegExp("\\[.*\\]", "gi").match(Std.string(_loc42_[_loc43_])), Array);
						if (_loc7_ != null && _loc7_.length > 0) {
							_loc42_[_loc43_] = ASCompat.stringReplace(Std.string(_loc42_[_loc43_]), _loc7_[0], "0");
							if (verbose) {}
							_loc25_ = true;
						}
						_loc16_ = ASCompat.coerce(new compat.RegExp("^\\b[A-Za-z]{1,3}", "gi").match(Std.string(_loc42_[_loc43_])), Array);
						if (_loc16_ == null) {
							_error = "error: could not parse operand " + _loc43_ + " (" + Std.string(_loc42_[_loc43_]) + ").";
							_loc23_ = true;
							break;
						}
						_loc18_ = ASCompat.coerce(REGMAP[_loc16_[0]], Register);
						if (debugEnabled) {}
						if (_loc18_ == null) {
							_error = "error: could not find register name for operand " + _loc43_ + " (" + Std.string(_loc42_[_loc43_]) + ").";
							_loc23_ = true;
							break;
						}
						if (_loc14_) {
							if (((_loc18_.flags : Int) & 0x20) == 0) {
								_error = "error: register operand " + _loc43_ + " (" + Std.string(_loc42_[_loc43_]) + ") only allowed in vertex programs.";
								_loc23_ = true;
								break;
							}
							if (_loc25_) {
								_error = "error: register operand " + _loc43_ + " (" + Std.string(_loc42_[_loc43_])
									+ ") relative adressing not allowed in fragment programs.";
								_loc23_ = true;
								break;
							}
						} else if (((_loc18_.flags : Int) & 0x40) == 0) {
							_error = "error: register operand " + _loc43_ + " (" + Std.string(_loc42_[_loc43_]) + ") only allowed in fragment programs.";
							_loc23_ = true;
							break;
						}
						_loc42_[_loc43_] = ASCompat.dynSlice(_loc42_[_loc43_], Std.string(_loc42_[_loc43_]).indexOf(_loc18_.name) + _loc18_.name.length);
						_loc10_ = ASCompat.coerce(_loc25_ ? ASCompat.coerce(new compat.RegExp("\\d+").match(Std.string(_loc7_[0])),
							Array) : ASCompat.coerce(new compat.RegExp("\\d+").match(Std.string(_loc42_[_loc43_])), Array),
							Array);
						_loc38_ = (0 : UInt);
						if (_loc10_ != null) {
							_loc38_ = (ASCompat.toInt(_loc10_[0]) : UInt);
						}
						if (_loc18_.range < _loc38_) {
							_error = "error: register operand " + _loc43_ + " (" + Std.string(_loc42_[_loc43_]) + ") index exceeds limit of "
								+ (_loc18_.range + 1) + ".";
							_loc23_ = true;
							break;
						}
						_loc26_ = (0 : UInt);
						_loc50_ = ASCompat.coerce(new compat.RegExp("(\\.[xyzw]{1,4})").match(Std.string(_loc42_[_loc43_])), Array);
						_loc31_ = _loc43_ == 0 && ((_loc15_.flags : Int) & 0x80) == 0;
						_loc39_ = _loc43_ == 2 && ((_loc15_.flags : Int) & 8) != 0;
						_loc35_ = (0 : UInt);
						_loc45_ = (0 : UInt);
						_loc27_ = 0;
						if (_loc31_ && _loc25_) {
							_error = "error: relative can not be destination";
							_loc23_ = true;
							break;
						}
						if (_loc50_ != null) {
							_loc26_ = (0 : UInt);
							_loc48_ = (ASCompat.toInt(_loc50_[0].length) : UInt);
							_loc46_ = 1;
							while ((_loc46_ : UInt) < _loc48_) {
								_loc47_ = (ASCompat.floatToInt(ASCompat.toNumber(Std.string(_loc50_[0]).charCodeAt(_loc46_)) - "x".charCodeAt(0)) : UInt);
								if (_loc47_ > 2) {
									_loc47_ = (3 : UInt);
								}
								if (_loc31_) {
									_loc26_ = ((_loc26_ | (1 << (_loc47_ : Int) : UInt) : UInt) : UInt);
								} else {
									_loc26_ = ((_loc26_ | ((_loc47_ : Int) << (_loc46_ - 1 << 1) : UInt) : UInt) : UInt);
								}
								_loc46_++;
							}
							if (!_loc31_) {
								while (_loc46_ <= 4) {
									_loc26_ = ((_loc26_ | ((_loc47_ : Int) << (_loc46_ - 1 << 1) : UInt) : UInt) : UInt);
									_loc46_++;
								}
							}
						} else {
							_loc26_ = (_loc31_ ? (15 : UInt) : (228 : UInt) : UInt);
						}
						if (_loc25_) {
							_loc17_ = ASCompat.coerce(new compat.RegExp("[A-Za-z]{1,3}", "gi").match(Std.string(_loc7_[0])), Array);
							_loc30_ = ASCompat.coerce(REGMAP[_loc17_[0]], Register);
							if (_loc30_ == null) {
								_error = "error: bad index register";
								_loc23_ = true;
								break;
							}
							_loc35_ = _loc30_.emitCode;
							_loc37_ = ASCompat.coerce(new compat.RegExp("(\\.[xyzw]{1,1})").match(Std.string(_loc7_[0])), Array);
							if (_loc37_.length == 0) {
								_error = "error: bad index register select";
								_loc23_ = true;
								break;
							}
							_loc45_ = (ASCompat.floatToInt(ASCompat.toNumber(Std.string(_loc37_[0]).charCodeAt(1)) - "x".charCodeAt(0)) : UInt);
							if (_loc45_ > 2) {
								_loc45_ = (3 : UInt);
							}
							_loc5_ = ASCompat.coerce(new compat.RegExp("\\+\\d{1,3}", "gi").match(Std.string(_loc7_[0])), Array);
							if (_loc5_.length > 0) {
								_loc27_ = ASCompat.toInt(_loc5_[0]);
							}
							if (_loc27_ < 0 || _loc27_ > 255) {
								_error = "error: index offset " + _loc27_ + " out of bounds. [0..255]";
								_loc23_ = true;
								break;
							}
							if (verbose) {}
						}
						if (verbose) {}
						if (_loc31_) {
							agalcode.writeShort((_loc38_ : Int));
							agalcode.writeByte((_loc26_ : Int));
							agalcode.writeByte((_loc18_.emitCode : Int));
							_loc8_ -= (32 : UInt);
						} else if (_loc39_) {
							if (verbose) {}
							_loc21_ = (5 : UInt);
							_loc11_ = (ASCompat.toInt(_loc9_?.length) : UInt);
							_loc12_ = 0;
							_loc46_ = 0;
							while ((_loc46_ : UInt) < _loc11_) {
								if (verbose) {}
								_loc6_ = ASCompat.coerce(SAMPLEMAP[_loc9_[_loc46_]], Sampler);
								if (_loc6_ == null) {
									_loc12_ = ASCompat.toNumber(_loc9_[_loc46_]);
									if (verbose) {}
								} else {
									if (_loc6_.flag != 16) {
										_loc21_ = ((_loc21_ & (~(15 << (_loc6_.flag : Int)) : UInt) : UInt) : UInt);
									}
									_loc21_ = ((_loc21_ | ((_loc6_.mask : Int) << (_loc6_.flag : Int) : UInt) : UInt) : UInt);
								}
								_loc46_++;
							}
							agalcode.writeShort((_loc38_ : Int));
							agalcode.writeByte(ASCompat.floatToInt(_loc12_ * 8));
							agalcode.writeByte(0);
							agalcode.writeUnsignedInt(_loc21_);
							if (verbose) {}
							_loc8_ -= (64 : UInt);
						} else {
							if (_loc43_ == 0) {
								agalcode.writeUnsignedInt((0 : UInt));
								_loc8_ -= (32 : UInt);
							}
							agalcode.writeShort((_loc38_ : Int));
							agalcode.writeByte(_loc27_);
							agalcode.writeByte((_loc26_ : Int));
							agalcode.writeByte((_loc18_.emitCode : Int));
							agalcode.writeByte((_loc35_ : Int));
							agalcode.writeShort(_loc25_ ? (_loc45_ : Int) | 0x8000 : 0);
							_loc8_ -= (64 : UInt);
						}
						_loc43_++;
					}
					_loc43_ = 0;
					while ((_loc43_ : UInt) < _loc8_) {
						agalcode.writeByte(0);
						_loc43_ += 8;
					}
					if (_loc23_) {
						break;
					}
				}
			}
			_loc41_++;
		}
		if (_error != "") {
			_error += "\n  at line " + _loc41_ + " " + Std.string(_loc36_[_loc41_]);
			agalcode.length = (0 : UInt);
		}
		if (debugEnabled) {
			_loc28_ = "generated bytecode:";
			_loc33_ = agalcode.length;
			_loc22_ = (0 : UInt);
			while (_loc22_ < _loc33_) {
				if (_loc22_ % 16 == 0) {
					_loc28_ += "\n";
				}
				if (_loc22_ % 4 == 0) {
					_loc28_ += " ";
				}
				_loc20_ = ASCompat.toRadix(agalcode[_loc22_], (16 : UInt));
				if (_loc20_.length < 2) {
					_loc20_ = "0" + _loc20_;
				}
				_loc28_ += _loc20_;
				_loc22_++;
			}
		}
		if (verbose) {}
		return agalcode;
	}

	function initregmap(version:UInt, ignorelimits:Bool) {
		REGMAP["va"] = new Register("va", "vertex attribute", (0 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 || version == 2 ? (7 : UInt) : (15 : UInt) : UInt)) : UInt), (0x40 | 2 : UInt));
		REGMAP["vc"] = new Register("vc", "vertex constant", (1 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 ? (127 : UInt) : (249 : UInt) : UInt)) : UInt), (0x40 | 2 : UInt));
		REGMAP["vt"] = new Register("vt", "vertex temporary", (2 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 ? (7 : UInt) : (25 : UInt) : UInt)) : UInt), (0x40 | 1 | 2 : UInt));
		REGMAP["vo"] = new Register("vo", "vertex output", (3 : UInt), (ignorelimits ? (1024 : UInt) : (0 : UInt) : UInt), (0x40 | 1 : UInt));
		REGMAP["vi"] = new Register("vi", "varying", (4 : UInt), (ignorelimits ? (1024 : UInt) : ((version == 1 ? (7 : UInt) : (9 : UInt) : UInt)) : UInt),
			(0x40 | 0x20 | 2 | 1 : UInt));
		REGMAP["fc"] = new Register("fc", "fragment constant", (1 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 ? (27 : UInt) : ((version == 2 ? (63 : UInt) : (199 : UInt) : UInt)) : UInt)) : UInt),
			(0x20 | 2 : UInt));
		REGMAP["ft"] = new Register("ft", "fragment temporary", (2 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 ? (7 : UInt) : (25 : UInt) : UInt)) : UInt), (0x20 | 1 | 2 : UInt));
		REGMAP["fs"] = new Register("fs", "texture sampler", (5 : UInt), (ignorelimits ? (1024 : UInt) : (15 : UInt) : UInt), (0x20 | 2 : UInt));
		REGMAP["fo"] = new Register("fo", "fragment output", (3 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 ? (0 : UInt) : (3 : UInt) : UInt)) : UInt), (0x20 | 1 : UInt));
		REGMAP["fd"] = new Register("fd", "fragment depth output", (6 : UInt),
			(ignorelimits ? (1024 : UInt) : ((version == 1 ? (-1 : UInt) : (0 : UInt) : UInt)) : UInt), (0x20 | 1 : UInt));
		REGMAP["iid"] = new Register("iid", "instance id", (7 : UInt), (ignorelimits ? (1024 : UInt) : (0 : UInt) : UInt), (0x40 | 2 : UInt));
		REGMAP["vs"] = new Register("vs", "vertex texture sampler", (5 : UInt), (ignorelimits ? (1024 : UInt) : (3 : UInt) : UInt), (0x40 | 2 : UInt));
		REGMAP["op"] = REGMAP["vo"];
		REGMAP["i"] = REGMAP["vi"];
		REGMAP["v"] = REGMAP["vi"];
		REGMAP["oc"] = REGMAP["fo"];
		REGMAP["od"] = REGMAP["fd"];
		REGMAP["fi"] = REGMAP["vi"];
	}
}

private class OpCode {
	var _emitCode:UInt = 0;

	var _flags:UInt = 0;

	var _name:String;

	var _numRegister:UInt = 0;

	public function new(name:String, numRegister:UInt, emitCode:UInt, flags:UInt) {
		_name = name;
		_numRegister = numRegister;
		_emitCode = emitCode;
		_flags = flags;
	}

	@:isVar public var emitCode(get, never):UInt;

	public function get_emitCode():UInt {
		return _emitCode;
	}

	@:isVar public var flags(get, never):UInt;

	public function get_flags():UInt {
		return _flags;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return _name;
	}

	@:isVar public var numRegister(get, never):UInt;

	public function get_numRegister():UInt {
		return _numRegister;
	}

	public function toString():String {
		return "[OpCode name=\"" + _name + "\", numRegister=" + _numRegister + ", emitCode=" + _emitCode + ", flags=" + _flags + "]";
	}
}

private class Register {
	var _emitCode:UInt = 0;

	var _name:String;

	var _longName:String;

	var _flags:UInt = 0;

	var _range:UInt = 0;

	public function new(name:String, longName:String, emitCode:UInt, range:UInt, flags:UInt) {
		_name = name;
		_longName = longName;
		_emitCode = emitCode;
		_range = range;
		_flags = flags;
	}

	@:isVar public var emitCode(get, never):UInt;

	public function get_emitCode():UInt {
		return _emitCode;
	}

	@:isVar public var longName(get, never):String;

	public function get_longName():String {
		return _longName;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return _name;
	}

	@:isVar public var flags(get, never):UInt;

	public function get_flags():UInt {
		return _flags;
	}

	@:isVar public var range(get, never):UInt;

	public function get_range():UInt {
		return _range;
	}

	public function toString():String {
		return "[Register name=\""
			+ _name
			+ "\", longName=\""
			+ _longName
			+ "\", emitCode="
			+ _emitCode
			+ ", range="
			+ _range
			+ ", flags="
			+ _flags
			+ "]";
	}
}

private class Sampler {
	var _flag:UInt = 0;

	var _mask:UInt = 0;

	var _name:String;

	public function new(name:String, flag:UInt, mask:UInt) {
		_name = name;
		_flag = flag;
		_mask = mask;
	}

	@:isVar public var flag(get, never):UInt;

	public function get_flag():UInt {
		return _flag;
	}

	@:isVar public var mask(get, never):UInt;

	public function get_mask():UInt {
		return _mask;
	}

	@:isVar public var name(get, never):String;

	public function get_name():String {
		return _name;
	}

	public function toString():String {
		return "[Sampler name=\"" + _name + "\", flag=\"" + _flag + "\", mask=" + mask + "]";
	}
}
