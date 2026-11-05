package com.junkbyte.console.core;

import com.junkbyte.console.compat.ConsoleLib;
import com.junkbyte.console.utils.FlashRegex;
import com.junkbyte.console.vos.WeakObject;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;
import haxe.rtti.Rtti;
import flash.utils.QName;
import flash.utils.Namespace;

class Executer extends EventDispatcher {
	public static var RETURNED:String = "returned";

	public static var CLASSES:String = "((com.junkbyte.console.core::)?(ExeValue|Executer))";

	public static var VALKEY:String = "#";

	public static var AS3_NAMESPACE:String = "http://adobe.com/AS3/2006/builtin";

	public var autoScope:Bool = false;

	public var _values:Array<ASAny>;

	public var _scope:ASAny;

	public var _saved:ASAny;

	public var _running:Bool = false;

	public var _returned:ASAny;

	public var _reserved:Array<ASAny>;

	public function new(target:IEventDispatcher = /*undefined*/ null) {
		super(target);
	}

	public static function Exec(scope:ASAny, str:String, saved:ASAny = /*undefined*/ null):ASAny {
		var _loc4_ = new Executer();
		_loc4_.setStored(saved);
		return _loc4_.exec(scope, str);
	}

	public static function resolveAllFields(resolveClass:Dynamic):ASAny {
		var _loc4_ = 0;
		var _loc5_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc6_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc7_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc8_ = 0;
		var _loc9_:ASAny = null;
		var _loc10_:ASObject = null;
		var _loc11_ = false;
		var _loc12_ = false;
		var _loc13_:ASAny = ASCompat.asString(null);
		var _loc14_:ASAny = ASCompat.dynamicAs(null, IMap);
		var _loc15_:ASAny = ASCompat.asString(null);
		var _loc16_:ASAny = ASCompat.asString(null);
		var _loc17_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc18_ = 0;
		var _loc19_ = 0;
		var _loc20_ = 0;
		var _loc21_:ASAny = null;
		var _loc22_:ASAny = ASCompat.asString(null);
		var _loc23_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc24_ = 0;
		var _loc25_ = 0;
		var _loc26_ = 0;
		var _loc27_:ASAny = ASCompat.asString(null);
		var _loc28_:ASAny = null;
		if (resolveClass == null) {
			return null;
		}
		var _loc2_:ASObject = {};
		ASCompat.setProperty(_loc2_, "staticVariables", []);
		ASCompat.setProperty(_loc2_, "staticFunctions", []);
		ASCompat.setProperty(_loc2_, "variables", []);
		ASCompat.setProperty(_loc2_, "functions", []);
		ASCompat.setProperty(_loc2_, "superClasses", []);
		if (!Rtti.hasRtti(resolveClass)) {
			return null;
		}
		var _loc3_:ASAny = Rtti.getRtti(resolveClass);
		while (_loc3_ != null && Rtti.hasRtti(resolveClass)) {
			_loc4_ = 0;
			_loc5_ = [_loc3_.statics, _loc3_.fields];
			while (_loc4_ < ASCompat.toInt(_loc5_.length)) {
				_loc6_ = _loc5_[_loc4_];
				_loc4_++;
				_loc7_ = _loc6_;
				_loc8_ = 0;
				while (_loc8_ < ASCompat.toInt(_loc7_.length)) {
					_loc9_ = _loc7_[_loc8_];
					_loc8_++;
					if (_loc9_.name != "new") {
						_loc10_ = {};
						_loc11_ = Reflect.hasField(_loc9_.type, "args");
						_loc12_ = _loc7_ == _loc3_.statics;
						_loc13_ = "Dynamic";
						ASCompat.setProperty(_loc10_, "name", _loc9_.name);
						ASCompat.setProperty(_loc10_, "isFunction", _loc11_);
						ASCompat.setProperty(_loc10_, "isPublic", _loc9_.isPublic);
						ASCompat.setProperty(_loc10_, "isFinal", _loc9_.isFinal);
						ASCompat.setProperty(_loc10_, "isOverride", _loc9_.isOverride);
						ASCompat.setProperty(_loc10_, "isStatic", _loc12_);
						if (_loc11_) {
							_loc14_ = new StringMap<ASAny>();
							_loc15_ = "";
							_loc16_ = "Dynamic";
							_loc17_ = _loc9_.type.args;
							_loc18_ = 0;
							_loc19_ = ASCompat.toInt(_loc17_.length);
							while (_loc18_ < _loc19_) {
								_loc20_ = _loc18_++;
								_loc21_ = _loc17_[_loc20_];
								_loc22_ = "";
								if (_loc21_.name != null) {
									_loc23_ = null;
									_loc15_ = _loc21_.name;
									if (_loc21_.t.params != null) {
										_loc23_ = _loc21_.t.params;
										_loc22_ = _loc21_.t.name;
									}
									if (_loc21_.params != null) {
										_loc23_ = _loc21_.params;
									}
									if (_loc23_ != null && ASCompat.toInt(_loc23_.length) > 0) {
										_loc22_ += "<";
										_loc24_ = 0;
										_loc25_ = ASCompat.toInt(_loc23_.length);
										while (_loc24_ < _loc25_) {
											_loc26_ = _loc24_++;
											_loc27_ = _loc23_[_loc26_].name;
											if (_loc27_ == null) {
												_loc27_ = "Dynamic";
											}
											if (_loc26_ == 0) {
												_loc22_ += _loc27_;
											} else {
												_loc22_ += ", " + Std.string(_loc27_);
											}
										}
										_loc22_ += ">";
									}
								}
								_loc28_ = {
									"type": _loc22_,
									"optional": ASCompat.toBool(_loc21_.opt),
									"value": (_loc21_.value != null ? _loc21_.value : null)
								};
								{
									_loc14_.set(_loc15_, _loc28_);
								}
								if (_loc9_.type.ret.name != null) {
									_loc16_ = _loc9_.type.ret.name;
									_loc23_ = _loc9_.type.ret.params;
									if (_loc23_ != null && ASCompat.toInt(_loc23_.length) > 0) {
										_loc16_ += "<";
										_loc24_ = 0;
										_loc25_ = ASCompat.toInt(_loc23_.length);
										while (_loc24_ < _loc25_) {
											_loc26_ = _loc24_++;
											_loc28_ = _loc23_[_loc26_];
											_loc27_ = _loc28_.name;
											if (_loc27_ == null) {
												_loc27_ = "Dynamic";
											}
											if (_loc26_ == 0) {
												_loc16_ += _loc27_;
											} else {
												_loc16_ += ", " + Std.string(_loc27_);
											}
										}
										_loc16_ += ">";
									}
								}
							}
							ASCompat.setProperty(_loc10_, "variables", _loc14_);
						} else {
							if (Reflect.hasField(_loc9_.type, "name")) {
								_loc13_ = _loc9_.type.name;
							}
							_loc17_ = _loc9_.type.params;
							if (_loc17_ != null && ASCompat.toInt(_loc17_.length) > 0) {
								_loc13_ += "<";
								_loc18_ = 0;
								_loc19_ = ASCompat.toInt(_loc9_.type.params.length);
								while (_loc18_ < _loc19_) {
									_loc20_ = _loc18_++;
									_loc21_ = _loc9_.type.params[_loc20_];
									_loc15_ = _loc21_.name;
									if (_loc15_ == null) {
										_loc15_ = "Dynamic";
									}
									if (_loc20_ == 0) {
										_loc13_ += _loc15_;
									} else {
										_loc13_ += ", " + Std.string(_loc15_);
									}
								}
								_loc13_ += ">";
							}
						}
						ASCompat.setProperty(_loc10_, "type", _loc13_);
						if (_loc11_) {
							if (_loc12_) {
								ASCompat.dynPush(_loc2_.staticFunctions, _loc10_);
							} else {
								ASCompat.dynPush(_loc2_.functions, _loc10_);
							}
						} else if (_loc12_) {
							ASCompat.dynPush(_loc2_.staticVariables, _loc10_);
						} else {
							ASCompat.dynPush(_loc2_.variables, _loc10_);
						}
					}
				}
			}
			if (_loc3_.superClass != null) {
				resolveClass = Type.resolveClass(_loc3_.superClass.path);
				if (resolveClass != null && Rtti.hasRtti(resolveClass)) {
					ASCompat.dynPush(_loc2_.superClasses, _loc3_.superClass.path);
					_loc3_ = Rtti.getRtti(resolveClass);
				} else {
					_loc3_ = null;
				}
			} else {
				_loc3_ = null;
			}
		}
		return _loc2_;
	}

	public function tempValue(str:String, v:ASAny, indOpen:Int, indClose:Int):String {
		str = str.substring(0, indOpen) + "#" + _values.length + str.substring(indClose);
		_values.push(v);
		return str;
	}

	public function setStored(o:ASAny) {
		_saved = o;
	}

	public function setReserved(a:Array<ASAny>) {
		_reserved = a;
	}

	public function reset() {
		_saved = null;
		_reserved = null;
		_values = null;
		_running = false;
	}

	public function operate(v1:ExeValue, op:String, v2:ExeValue):ASAny {
		var _loc5_:ASAny = null;
		var _loc4_ = op;
		if (_loc4_ == "!") {
			return !ConsoleLib.truthy(v2.get_value());
		}
		if (_loc4_ == "!=") {
			return v1.get_value() != v2.get_value();
		}
		if (_loc4_ == "!==") {
			return !ConsoleLib.strictEquals(v1.get_value(), v2.get_value());
		}
		if (_loc4_ == "%") {
			return ASCompat.toNumber(v1.get_value()) % ASCompat.toNumber(v2.get_value());
		}
		if (_loc4_ == "&") {
			return ASCompat.toInt(v1.get_value()) & ASCompat.toInt(v2.get_value());
		}
		if (_loc4_ == "&&") {
			_loc5_ = v1.get_value();
			if (ConsoleLib.truthy(_loc5_)) {
				return v2.get_value();
			}
			return _loc5_;
		}
		if (_loc4_ == "*") {
			return ASCompat.toNumber(v1.get_value()) * ASCompat.toNumber(v2.get_value());
		}
		if (_loc4_ == "+") {
			return v1.get_value() + v2.get_value();
		}
		if (_loc4_ == "-") {
			return ASCompat.toNumber(v1.get_value()) - ASCompat.toNumber(v2.get_value());
		}
		if (_loc4_ == "/") {
			return ASCompat.toNumber(v1.get_value()) / ASCompat.toNumber(v2.get_value());
		}
		if (_loc4_ == "<") {
			return v1.get_value() < v2.get_value();
		}
		if (_loc4_ == "<<") {
			return ASCompat.toInt(v1.get_value()) << ASCompat.toInt(v2.get_value());
		}
		if (_loc4_ == "<=") {
			return v1.get_value() <= v2.get_value();
		}
		if (_loc4_ == "=") {
			return v2.get_value();
		}
		if (_loc4_ == "==") {
			return v1.get_value() == v2.get_value();
		}
		if (_loc4_ == "===") {
			return ConsoleLib.strictEquals(v1.get_value(), v2.get_value());
		}
		if (_loc4_ == ">") {
			return v1.get_value() > v2.get_value();
		}
		if (_loc4_ == ">=") {
			return v1.get_value() >= v2.get_value();
		}
		if (_loc4_ == ">>") {
			return ASCompat.toInt(v1.get_value()) >> ASCompat.toInt(v2.get_value());
		}
		if (_loc4_ == ">>>") {
			return (ASCompat.toInt(v1.get_value()) >>> ASCompat.toInt(v2.get_value()):UInt);
		}
		if (_loc4_ == "^") {
			return ASCompat.toInt(v1.get_value()) ^ ASCompat.toInt(v2.get_value());
		}
		if (_loc4_ == "delete") {
			return ASCompat.deleteProperty(v2.obj, v2.prop);
		}
		if (_loc4_ == "is") {
			return Std.isOfType(v1.get_value(), v2.get_value());
		}
		if (_loc4_ == "typeof") {
			return ConsoleLib.typeOf(v2.get_value());
		}
		if (_loc4_ == "|") {
			return ASCompat.toInt(v1.get_value()) | ASCompat.toInt(v2.get_value());
		}
		if (_loc4_ == "||") {
			_loc5_ = v1.get_value();
			if (ConsoleLib.truthy(_loc5_)) {
				return _loc5_;
			}
			return v2.get_value();
		}
		if (_loc4_ == "~") {
			return ~ASCompat.toInt(v2.get_value());
		}
		return null;
	}

	public function makeNew(str:String):ASAny {
		var _loc5_ = 0;
		var _loc6_ = ASCompat.asString(null);
		var _loc7_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc8_ = 0;
		var _loc2_ = str.indexOf("(");
		var _loc3_ = _loc2_ > 0 ? str.substring(0, _loc2_) : str;
		_loc3_ = ignoreWhite(_loc3_);
		var _loc4_ = (execValue(_loc3_).get_value() : Dynamic);
		if (_loc2_ > 0) {
			_loc5_ = str.indexOf(")", _loc2_);
			_loc6_ = str.substring(_loc2_ + 1, _loc5_);
			_loc6_ = ignoreWhite(_loc6_);
			_loc7_ = [];
			if (_loc6_ != null && _loc6_ != "") {
				_loc7_ = execValue(_loc6_).get_value();
			}
			_loc8_ = ASCompat.toInt(_loc7_.length);
			if (_loc8_ == 0) {
				return Type.createInstance(_loc4_, []);
			}
			if (_loc8_ == 1) {
				return Type.createInstance(_loc4_, [_loc7_[0]]);
			}
			if (_loc8_ == 2) {
				return Type.createInstance(_loc4_, [_loc7_[0], _loc7_[1]]);
			}
			if (_loc8_ == 3) {
				return Type.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2]]);
			}
			if (_loc8_ == 4) {
				return Type.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3]]);
			}
			if (_loc8_ == 5) {
				return Type.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4]]);
			}
			if (_loc8_ == 6) {
				return Type.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4], _loc7_[5]]);
			}
			if (_loc8_ == 7) {
				return Type.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4], _loc7_[5], _loc7_[6]]);
			}
			if (_loc8_ == 8) {
				return Type.createInstance(_loc4_, [
					_loc7_[0],
					_loc7_[1],
					_loc7_[2],
					_loc7_[3],
					_loc7_[4],
					_loc7_[5],
					_loc7_[6],
					_loc7_[7]
				]);
			}
			if (_loc8_ == 9) {
				return Type.createInstance(_loc4_, [
					_loc7_[0],
					_loc7_[1],
					_loc7_[2],
					_loc7_[3],
					_loc7_[4],
					_loc7_[5],
					_loc7_[6],
					_loc7_[7],
					_loc7_[8]
				]);
			}
			if (_loc8_ == 10) {
				return Type.createInstance(_loc4_, [
					_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4], _loc7_[5], _loc7_[6], _loc7_[7], _loc7_[8], _loc7_[9]]);
			}
			throw new Error("CommandLine can\'t create new class instances with more than 10 arguments.");
		}
		return null;
	}

	public function ignoreWhite(str:String):String {
		str = FlashRegex.replace(str, new EReg("\\s*(.*)", ""), "$1");
		var _loc2_:Float = str.length - 1;
		while (_loc2_ > 0) {
			if (!FlashRegex.match(str.charAt(ASCompat.floatToInt(_loc2_)), new EReg("\\s", ""))) {
				break;
			}
			str = str.substring(0, ASCompat.floatToInt(_loc2_));
			_loc2_--;
		}
		return str;
	}

	@:isVar public var scope(get, never):ASAny;

	public function get_scope():ASAny {
		return _scope;
	}

	@:isVar public var returned(get, never):ASAny;

	public function get_returned():ASAny {
		return _returned;
	}

	public function execValue(str:String, base:ASAny = /*undefined*/ null):ExeValue {
		var _loc5_ = Math.NaN;
		var _loc6_:ASAny = ASCompat.dynamicAs(null, ExeValue);
		var _loc7_ = ASCompat.asString(null);
		var _loc8_:ASAny = ASCompat.dynamicAs(null, WeakObject);
		var _loc9_:ASAny = null;
		var _loc4_ = new ExeValue();
		if (str == "true") {
			_loc4_.obj = true;
		} else if (str == "false") {
			_loc4_.obj = false;
		} else if (str == "this") {
			_loc4_.obj = _scope;
		} else if (str == "null") {
			_loc4_.obj = null;
		} else {
			_loc5_ = ConsoleLib.toNumber(str);
			if (_loc5_ == _loc5_) {
				_loc4_.obj = ConsoleLib.toNumber(str);
			} else if (str.indexOf("#") == 0) {
				_loc6_ = _values[ASCompat.toInt(ConsoleLib.parseInt(str.substring("#".length)))];
				_loc4_.obj = _loc6_.get_value();
			} else if (str.charAt(0) == "$") {
				_loc7_ = str.substring(1);
				if (_reserved.indexOf(_loc7_) < 0) {
					_loc4_.obj = _saved;
					_loc4_.prop = _loc7_;
				} else if (Std.isOfType(_saved, WeakObject)) {
					_loc8_ = _saved;
					_loc4_.obj = _loc8_.get(_loc7_);
				} else {
					_loc4_.obj = Reflect.field(_saved, _loc7_);
				}
			} else {
				try {
					_loc4_.obj = ConsoleLib.getDefinitionByName(str);
				} catch (_loc_e_:ASAny) {
					_loc9_ = _loc_e_;
					_loc4_.obj = base;
					_loc4_.prop = str;
				}
			}
		}
		return _loc4_;
	}

	public function execSimple(str:String):ExeValue {
		var _loc4_ = ASCompat.asString(null);
		var _loc5_ = 0;
		var _loc6_:ASAny = null;
		var _loc8_ = false;
		var _loc9_ = Math.NaN;
		var _loc11_:ASAny = null;
		var _loc12_ = false;
		var _loc15_ = 0;
		var _loc16_ = ASCompat.dynamicAs(null, ExeValue);
		var _loc17_ = 0;
		var _loc18_ = ASCompat.asString(null);
		var _loc19_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc20_:ASAny = null;
		var _loc3_ = new ExeValue(_scope);
		if (str.indexOf("new ") == 0) {
			_loc4_ = str;
			_loc5_ = str.indexOf(")");
			if (_loc5_ >= 0) {
				_loc4_ = str.substring(0, _loc5_ + 1);
			}
			_loc6_ = makeNew(_loc4_.substring(4));
			str = tempValue(str, new ExeValue(_loc6_), 0, ASCompat.toInt(_loc4_.length));
		}
		var _loc7_ = new EReg("\\.|\\(", "g");
		_loc6_ = FlashRegex.exec(str, _loc7_);
		if (_loc6_ != null) {
			_loc9_ = ConsoleLib.toNumber(str);
			_loc8_ = _loc9_ == _loc9_;
		} else {
			_loc8_ = true;
		}
		if (_loc8_) {
			return execValue(str, _scope);
		}
		var _loc10_:Array<ASAny> = (cast str.split("(")[0].split("."));
		if (_loc10_.length > 0) {
			while (_loc10_.length != 0) {
				_loc4_ = _loc10_.join(".");
				try {
					_loc11_ = ConsoleLib.getDefinitionByName(ignoreWhite(_loc4_));
					_loc12_ = str.length > ASCompat.toNumberField(_loc4_, "length");
					str = tempValue(str, new ExeValue(_loc11_), 0, ASCompat.toInt(_loc4_.length));
					if (_loc12_) {
						_loc6_ = FlashRegex.exec(str, _loc7_, 0);
						break;
					}
					return execValue(str);
				} catch (_loc_e_:ASAny) {
					_loc11_ = _loc_e_;
					_loc10_.pop();
				}
			}
		}
		_loc5_ = 0;
		var _loc13_ = 0;
		var _loc14_ = ASCompat.toInt(_loc6_.index);
		while (_loc6_ != null) {
			_loc15_ = ASCompat.toInt(_loc6_.index);
			_loc12_ = str.charAt(_loc15_) == "(";
			_loc4_ = ignoreWhite(str.substring(_loc5_, _loc15_));
			_loc16_ = _loc5_ == 0 ? execValue(_loc4_, _loc3_.get_value()) : new ExeValue(_loc3_.get_value(), _loc4_);
			if (_loc12_) {
				_loc11_ = _loc16_.get_value();
				_loc17_ = str.indexOf(")", _loc15_);
				_loc18_ = str.substring(_loc15_ + 1, _loc17_);
				_loc18_ = ignoreWhite(_loc18_);
				_loc19_ = [];
				if (_loc18_ != null && _loc18_ != "") {
					_loc19_ = execValue(_loc18_).get_value();
				}
				if (!Reflect.isFunction(_loc11_)) {
					try {
						_loc20_ = _loc3_.obj[new QName(new Namespace("http://adobe.com/AS3/2006/builtin"), _loc4_)];
						if (Reflect.isFunction(_loc20_)) {
							_loc11_ = _loc20_;
						}
					} catch (_loc_e_:ASAny) {
						_loc20_ = _loc_e_;
						null;
					}
					if (!Reflect.isFunction(_loc11_)) {
						throw new Error(_loc4_ + " is not a function.");
					}
				}
				_loc20_ = _loc3_.get_value();
				_loc3_.obj = Reflect.callMethod(_loc20_, _loc11_, _loc19_);
				_loc3_.prop = null;
				_loc15_ = _loc17_ + 1;
			} else {
				_loc3_ = _loc16_;
			}
			_loc5_ = _loc15_ + 1;
			_loc13_ = _loc15_ + 1;
			_loc6_ = FlashRegex.exec(str, _loc7_, _loc13_);
			if (_loc6_ == null) {
				if (_loc15_ + 1 < str.length) {
					_loc13_ = str.length;
					_loc6_ = {"index": str.length};
				}
			}
		}
		return _loc3_;
	}

	public function execOperations(str:String):ExeValue {
		var _loc5_ = 0;
		var _loc6_ = 0;
		var _loc7_:ASAny = ASCompat.asString(null);
		var _loc8_:ASAny = null;
		var _loc11_:ASAny = ASCompat.dynamicAs(null, ExeValue);
		var _loc13_:ASAny = ASCompat.dynamicAs(null, ExeValue);
		var _loc2_ = new EReg("\\s*(((\\|\\||\\&\\&|[+|\\-|*|\\/|\\%|\\||\\&|\\^]|\\=\\=?|\\!\\=|\\>\\>?\\>?|\\<\\<?)\\=?)|=|\\~|\\sis\\s|typeof|delete\\s)\\s*",
			"g");
		var _loc3_ = FlashRegex.exec(str, _loc2_);
		var _loc4_:Array<ASAny> = [];
		if (_loc3_ == null) {
			_loc4_.push(str);
		} else {
			_loc5_ = 0;
			while (_loc3_ != null) {
				_loc6_ = _loc3_.index;
				_loc7_ = _loc3_.elements[0];
				_loc3_ = FlashRegex.exec(str, _loc2_, ASCompat.toInt(_loc6_ + _loc7_.length));
				if (_loc3_ == null) {
					_loc4_.push(str.substring(_loc5_, _loc6_));
					_loc4_.push(ignoreWhite(_loc7_));
					_loc4_.push(str.substring(ASCompat.toInt(_loc6_ + _loc7_.length)));
				} else {
					_loc4_.push(str.substring(_loc5_, _loc6_));
					_loc4_.push(ignoreWhite(_loc7_));
					_loc5_ = ASCompat.toInt(_loc6_ + _loc7_.length);
				}
			}
		}
		_loc5_ = _loc4_.length;
		_loc6_ = 0;
		while (_loc6_ < _loc5_) {
			_loc4_[_loc6_] = execSimple(_loc4_[_loc6_]);
			_loc6_ += 2;
		}
		var _loc9_ = new EReg("((\\|\\||\\&\\&|[+|\\-|*|\\/|\\%|\\||\\&|\\^]|\\>\\>\\>?|\\<\\<)\\=)|=", "");
		var _loc10_ = 1;
		while (_loc10_ < _loc5_) {
			_loc7_ = _loc4_[_loc10_];
			if (FlashRegex.replace(_loc7_, _loc9_, "") != "") {
				_loc8_ = operate(ASCompat.coerce(_loc4_[_loc10_ - 1], com.junkbyte.console.core.ExeValue), _loc7_,
					ASCompat.coerce(_loc4_[_loc10_ + 1], com.junkbyte.console.core.ExeValue));
				_loc11_ = _loc4_[_loc10_ - 1];
				_loc11_.setValue(_loc8_);
				_loc4_.splice(_loc10_, (2 : UInt));
				_loc10_ -= 2;
				_loc5_ -= 2;
			}
			_loc10_ += 2;
		}
		ASCompat.ASArray.reverse(_loc4_);
		_loc11_ = _loc4_[0];
		var _loc12_ = 1;
		while (_loc12_ < _loc5_) {
			_loc7_ = _loc4_[_loc12_];
			if (FlashRegex.replace(_loc7_, _loc9_, "") == "") {
				_loc11_ = _loc4_[_loc12_ - 1];
				_loc13_ = _loc4_[_loc12_ + 1];
				if (ASCompat.toNumberField(_loc7_, "length") > 1) {
					_loc7_ = Std.string(_loc7_).substring(0, ASCompat.toInt(ASCompat.toNumberField(_loc7_, "length") - 1));
				}
				_loc8_ = operate(ASCompat.coerce(_loc13_, com.junkbyte.console.core.ExeValue), _loc7_,
					ASCompat.coerce(_loc11_, com.junkbyte.console.core.ExeValue));
				_loc13_.setValue(_loc8_);
			}
			_loc12_ += 2;
		}
		return ASCompat.coerce(_loc11_, com.junkbyte.console.core.ExeValue);
	}

	public function execNest(line:String):ASAny {
		var _loc3_ = 0;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc6_ = ASCompat.asString(null);
		var _loc7_ = false;
		var _loc8_ = 0;
		var _loc9_ = ASCompat.asString(null);
		var _loc10_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc11_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc12_ = 0;
		var _loc13_:ASAny = null;
		var _loc14_ = ASCompat.dynamicAs(null, ExeValue);
		line = ignoreWhite(line);
		var _loc2_ = line.lastIndexOf("(");
		while (_loc2_ >= 0) {
			_loc3_ = line.indexOf(")", _loc2_);
			if (FlashRegex.search(line.substring(_loc2_ + 1, _loc3_), new EReg("\\w", "")) >= 0) {
				_loc4_ = _loc2_;
				_loc5_ = _loc2_ + 1;
				while (_loc4_ >= 0 && _loc4_ < _loc5_) {
					_loc4_++;
					_loc4_ = line.indexOf("(", _loc4_);
					_loc5_ = line.indexOf(")", _loc5_ + 1);
				}
				_loc6_ = line.substring(_loc2_ + 1, _loc5_);
				_loc7_ = false;
				_loc8_ = _loc2_ - 1;
				while (true) {
					_loc9_ = line.charAt(_loc8_);
					if (FlashRegex.match(_loc9_, new EReg("[^\\s]", "")) || _loc8_ <= 0) {
						break;
					}
					_loc8_--;
				}
				if (FlashRegex.match(_loc9_, new EReg("\\w", ""))) {
					_loc7_ = true;
				}
				if (_loc7_) {
					_loc10_ = _loc6_.split(",");
					line = tempValue(line, new ExeValue(_loc10_), _loc2_ + 1, _loc5_);
					_loc11_ = [];
					_loc12_ = 0;
					while (_loc12_ < ASCompat.toInt(_loc10_.length)) {
						_loc13_ = _loc10_[_loc12_];
						_loc12_++;
						_loc11_.push(execOperations(ignoreWhite(_loc13_)).get_value());
					}
					ASCompat.dynSplice(_loc10_, 0, ASCompat.toInt(_loc10_.length));
					_loc12_ = 0;
					while (_loc12_ < ASCompat.toInt(_loc11_.length)) {
						_loc13_ = _loc11_[_loc12_];
						_loc12_++;
						ASCompat.dynPush(_loc10_, _loc13_);
					}
				} else {
					_loc14_ = new ExeValue();
					line = tempValue(line, _loc14_, _loc2_, _loc5_ + 1);
					_loc14_.setValue(execOperations(ignoreWhite(_loc6_)).get_value());
				}
			}
			_loc2_ = line.lastIndexOf("(", _loc2_ - 1);
		}
		_returned = execOperations(line).get_value();
		if (ConsoleLib.truthy(_returned) && autoScope) {
			_loc6_ = ConsoleLib.typeOf(_returned);
			if (_loc6_ == "object" || _loc6_ == "xml") {
				_scope = _returned;
			}
		}
		dispatchEvent(new Event(Event.COMPLETE));
		return _returned;
	}

	public function exec(s:ASAny, str:String):ASAny {
		var _loc4_ = ASCompat.dynamicAs(null, Error);
		if (_running) {
			throw new Error("CommandExec.exec() is already runnnig. Does not support loop backs.");
		}
		_running = true;
		_scope = s;
		_values = [];
		if (_saved == null) {
			_saved = {};
		}
		if (_reserved == null) {
			_reserved = [];
		}
		try {
			_exec(str);
		} catch (_loc_e_:Dynamic) {
			_loc4_ = _loc_e_;
			reset();
			throw _loc4_;
		}
		reset();
		return _returned;
	}

	public function _exec(str:String) {
		var _loc4_:ASAny = ASCompat.asString(null);
		var _loc5_:ASAny = ASCompat.asString(null);
		var _loc6_ = 0;
		var _loc7_ = 0;
		var _loc8_ = ASCompat.asString(null);
		var _loc10_:ASAny = null;
		var _loc2_ = new EReg("\'\'|\"\"|(\'(.*?)[^\\\\]\')|(\"(.*?)[^\\\\]\")", "");
		var _loc3_ = FlashRegex.exec(str, _loc2_);
		while (_loc3_ != null) {
			_loc4_ = _loc3_.elements[0];
			_loc5_ = Std.string(_loc4_).charAt(0);
			_loc6_ = ASCompat.toInt(_loc4_.indexOf(_loc5_));
			_loc7_ = ASCompat.toInt(_loc4_.lastIndexOf(_loc5_));
			_loc8_ = FlashRegex.replace(Std.string(_loc4_).substring(_loc6_ + 1, _loc7_), new EReg("\\\\(.)", "g"), "$1");
			str = tempValue(str, new ExeValue(_loc8_), _loc3_.index + _loc6_, _loc3_.index + _loc7_ + 1);
			_loc3_ = FlashRegex.exec(str, _loc2_);
		}
		if (FlashRegex.search(str, new EReg("\'|\"", "")) >= 0) {
			throw new Error("Bad syntax extra quotation marks");
		}
		var _loc9_ = FlashRegex.split(str, new EReg("\\s*;\\s*", ""));
		_loc6_ = 0;
		while (_loc6_ < _loc9_.length) {
			_loc4_ = _loc9_[_loc6_];
			_loc6_++;
			if (ASCompat.toNumberField(_loc4_, "length") != 0) {
				_loc10_ = new ExeValue(_saved, "returned").get_value();
				if (ConsoleLib.truthy(_loc10_) && _loc4_ == "/") {
					_scope = _loc10_;
					dispatchEvent(new Event(Event.COMPLETE));
				} else {
					execNest(_loc4_);
				}
			}
		}
	}
}
