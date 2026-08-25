package com.junkbyte.console.core;

import com.junkbyte.console.vos.WeakObject;
import flash.events.Event;
import flash.events.EventDispatcher;

class Executer extends EventDispatcher {
	public static inline final RETURNED = "returned";

	public static inline final CLASSES = "ExeValue|((com.junkbyte.console.core::)?Executer)";

	static inline final VALKEY = "#";

	var _values:Array<ASAny>;

	var _running:Bool = false;

	var _scope:ASAny;

	var _returned:ASAny;

	var _saved:ASObject;

	var _reserved:Array<ASAny>;

	public var autoScope:Bool = false;

	public function new() {
		super();
	}

	public static function Exec(scope:ASObject, str:String, saved:ASObject = null):ASAny {
		var _loc4_ = new Executer();
		_loc4_.setStored(saved);
		return _loc4_.exec(scope, str);
	}

	@:isVar public var returned(get, never):ASAny;

	public function get_returned():ASAny {
		return this._returned;
	}

	@:isVar public var scope(get, never):ASAny;

	public function get_scope():ASAny {
		return this._scope;
	}

	public function setStored(o:ASObject) {
		this._saved = o;
	}

	public function setReserved(a:Array<ASAny>) {
		this._reserved = a;
	}

	public function exec(s:ASAny, str:String):ASAny {
		if (this._running) {
			throw new Error("CommandExec.exec() is already runnnig. Does not support loop backs.");
		}
		this._running = true;
		this._scope = s;
		this._values = [];
		if (!ASCompat.toBool(this._saved)) {
			this._saved = new ASObject();
		}
		if (this._reserved == null) {
			this._reserved = new Array<ASAny>();
		}
		try {
			this._exec(str);
		} catch (e:Dynamic) {
			reset();
			throw e;
		}
		this.reset();
		return this._returned;
	}

	function reset() {
		this._saved = null;
		this._reserved = null;
		this._values = null;
		this._running = false;
	}

	function _exec(str:String) {
		var _loc5_:String = null;
		var _loc6_:String = null;
		var _loc7_:String = null;
		var _loc8_ = 0;
		var _loc9_ = 0;
		var _loc10_:String = null;
		var _loc11_:ASAny = /*undefined*/ null;
		var _loc2_ = new compat.RegExp("''|\"\"|('(.*?)[^\\\\]')|(\"(.*?)[^\\\\]\")");
		var _loc3_:ASObject = _loc2_.exec(str);
		while (_loc3_ != null) {
			_loc6_ = _loc3_[Std.string(0)];
			_loc7_ = _loc6_.charAt(0);
			_loc8_ = _loc6_.indexOf(_loc7_);
			_loc9_ = _loc6_.lastIndexOf(_loc7_);
			_loc10_ = new compat.RegExp("\\\\(.)", "g").replace(_loc6_.substring(_loc8_ + 1, _loc9_), "$1");
			str = this.tempValue(str, new ExeValue(_loc10_), ASCompat.toInt(_loc3_.index + _loc8_), ASCompat.toInt(_loc3_.index + _loc9_ + 1));
			_loc3_ = _loc2_.exec(str);
		}
		if (new compat.RegExp("'|\"").search(str) >= 0) {
			throw new Error("Bad syntax extra quotation marks");
		}
		var _loc4_:Array<ASAny> = (cast new compat.RegExp("\\s*;\\s*").split(str));
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc5_ = _tmp_;
				if (_loc5_.length != 0) {
					_loc11_ = this._saved[RETURNED];
					if (ASCompat.toBool(_loc11_) && _loc5_ == "/") {
						this._scope = _loc11_;
						dispatchEvent(new Event(Event.COMPLETE));
					} else {
						this.execNest(_loc5_);
					}
				}
			}
	}

	function execNest(line:String):ASAny {
		var _loc3_ = 0;
		var _loc4_ = 0;
		var _loc5_ = 0;
		var _loc6_:String = null;
		var _loc7_ = false;
		var _loc8_ = 0;
		var _loc9_:String = null;
		var _loc10_:Array<ASAny> = null;
		var _loc11_:String = null;
		var _loc12_:ExeValue = null;
		var _loc13_:String = null;
		line = this.ignoreWhite(line);
		var _loc2_ = line.lastIndexOf("(");
		while (_loc2_ >= 0) {
			_loc3_ = line.indexOf(")", _loc2_);
			if (new compat.RegExp("\\w").search(line.substring(_loc2_ + 1, _loc3_)) >= 0) {
				_loc4_ = _loc2_;
				_loc5_ = _loc2_ + 1;
				while (_loc4_ >= 0 && _loc4_ < _loc5_) {
					_loc4_ = ASCompat.toInt(_loc4_) + 1;
					_loc4_ = line.indexOf("(", _loc4_);
					_loc5_ = line.indexOf(")", _loc5_ + 1);
				}
				_loc6_ = line.substring(_loc2_ + 1, _loc5_);
				_loc7_ = false;
				_loc8_ = _loc2_ - 1;
				while (true) {
					_loc9_ = line.charAt(_loc8_);
					if (new compat.RegExp("[^\\s]").match(_loc9_) != null || _loc8_ <= 0) {
						break;
					}
					_loc8_ = ASCompat.toInt(_loc8_) - 1;
				}
				if (new compat.RegExp("\\w").match(_loc9_) != null) {
					_loc7_ = true;
				}
				if (_loc7_) {
					_loc10_ = (cast _loc6_.split(","));
					line = this.tempValue(line, new ExeValue(_loc10_), _loc2_ + 1, _loc5_);
					if (checkNullIteratee(_loc10_))
						for (_tmp_ in 0..._loc10_.length) {
							_loc11_ = Std.string(_tmp_);
							(_loc10_ : ASAny)[ASCompat.toInt(_loc11_)] = this.execOperations(this.ignoreWhite((_loc10_ : ASAny)[ASCompat.toInt(_loc11_)]))
								.value;
						}
				} else {
					_loc12_ = new ExeValue(_loc12_);
					line = this.tempValue(line, _loc12_, _loc2_, _loc5_ + 1);
					_loc12_.setValue(this.execOperations(this.ignoreWhite(_loc6_)).value);
				}
			}
			_loc2_ = line.lastIndexOf("(", _loc2_ - 1);
		}
		this._returned = this.execOperations(line).value;
		if (ASCompat.toBool(this._returned) && this.autoScope) {
			_loc13_ = ASCompat.typeof(this._returned);
			if (_loc13_ == "object" || _loc13_ == "xml") {
				this._scope = this._returned;
			}
		}
		dispatchEvent(new Event(Event.COMPLETE));
		return this._returned;
	}

	function tempValue(str:String, v:ASAny, indOpen:Int, indClose:Int):String {
		str = str.substring(0, indOpen) + VALKEY + this._values.length + str.substring(indClose);
		this._values.push(v);
		return str;
	}

	function execOperations(str:String):ExeValue {
		var _loc7_:String = null;
		var _loc8_:ASAny = /*undefined*/ null;
		var _loc11_ = 0;
		var _loc12_ = 0;
		var _loc13_:String = null;
		var _loc14_:ExeValue = null;
		var _loc15_:ExeValue = null;
		var _loc2_ = new compat.RegExp("\\s*(((\\|\\||\\&\\&|[+|\\-|*|\\/|\\%|\\||\\&|\\^]|\\=\\=?|\\!\\=|\\>\\>?\\>?|\\<\\<?)\\=?)|=|\\~|\\sis\\s|typeof|delete\\s)\\s*",
			"g");
		var _loc3_:ASObject = _loc2_.exec(str);
		var _loc4_:Array<ASAny> = [];
		if (_loc3_ == null) {
			_loc4_.push(str);
		} else {
			_loc11_ = 0;
			while (_loc3_ != null) {
				_loc12_ = ASCompat.toInt(_loc3_.index);
				_loc13_ = _loc3_[Std.string(0)];
				_loc3_ = _loc2_.exec(str);
				if (_loc3_ == null) {
					_loc4_.push(str.substring(_loc11_, _loc12_));
					_loc4_.push(this.ignoreWhite(_loc13_));
					_loc4_.push(str.substring(_loc12_ + _loc13_.length));
				} else {
					_loc4_.push(str.substring(_loc11_, _loc12_));
					_loc4_.push(this.ignoreWhite(_loc13_));
					_loc11_ = _loc12_ + _loc13_.length;
				}
			}
		}
		var _loc5_ = _loc4_.length;
		var _loc6_ = 0;
		while (_loc6_ < _loc5_) {
			_loc4_[_loc6_] = this.execSimple(_loc4_[_loc6_]);
			_loc6_ += 2;
		}
		var _loc9_ = new compat.RegExp("((\\|\\||\\&\\&|[+|\\-|*|\\/|\\%|\\||\\&|\\^]|\\>\\>\\>?|\\<\\<)\\=)|=");
		_loc6_ = 1;
		while (_loc6_ < _loc5_) {
			_loc7_ = _loc4_[_loc6_];
			if (_loc9_.replace(_loc7_, "") != "") {
				_loc8_ = this.operate(ASCompat.dynamicAs(_loc4_[_loc6_ - 1], ExeValue), _loc7_, ASCompat.dynamicAs(_loc4_[_loc6_ + 1], ExeValue));
				_loc14_ = cast(_loc4_[_loc6_ - 1], ExeValue);
				_loc14_.setValue(_loc8_);
				_loc4_.splice(_loc6_, (2 : UInt));
				_loc6_ -= 2;
				_loc5_ -= 2;
			}
			_loc6_ += 2;
		}
		ASCompat.ASArray.reverse(_loc4_);
		var _loc10_ = ASCompat.dynamicAs(_loc4_[0], ExeValue);
		_loc6_ = 1;
		while (_loc6_ < _loc5_) {
			_loc7_ = _loc4_[_loc6_];
			if (_loc9_.replace(_loc7_, "") == "") {
				_loc10_ = ASCompat.dynamicAs(_loc4_[_loc6_ - 1], ExeValue);
				_loc15_ = ASCompat.dynamicAs(_loc4_[_loc6_ + 1], ExeValue);
				if (_loc7_.length > 1) {
					_loc7_ = _loc7_.substring(0, _loc7_.length - 1);
				}
				_loc8_ = this.operate(_loc15_, _loc7_, _loc10_);
				_loc15_.setValue(_loc8_);
			}
			_loc6_ += 2;
		}
		return _loc10_;
	}

	function execSimple(str:String):ExeValue {
		var reg:compat.RegExp;
		var result:ASObject;
		var previndex:Int;
		var firstparts:Array<ASAny> = null;
		var newstr:String = null;
		var defclose = 0;
		var newobj:ASAny = /*undefined*/ null;
		var classstr:String = null;
		var def:Dynamic = /*undefined*/ null;
		var havemore = false;
		var index = 0;
		var isFun = false;
		var basestr:String = null;
		var newv:ExeValue = null;
		var newbase:ASAny = /*undefined*/ null;
		var closeindex = 0;
		var paramstr:String = null;
		var params:Array<ASAny> = null;
		var nss:Array<ASAny> = null;
		var ns:ASAny = null;
		var nsv:ASAny = /*undefined*/ null;
		var v = new ExeValue(this._scope);
		if (str.indexOf("new ") == 0) {
			newstr = str;
			defclose = str.indexOf(")");
			if (defclose >= 0) {
				newstr = str.substring(0, defclose + 1);
			}
			newobj = this.makeNew(newstr.substring(4));
			str = this.tempValue(str, new ExeValue(newobj), 0, newstr.length);
		}
		reg = new compat.RegExp("\\.|\\(", "g");
		result = reg.exec(str);
		if (result == null || !Math.isNaN(ASCompat.toNumber(str))) {
			return this.execValue(str, this._scope);
		}
		firstparts = (cast str.split("(")[0].split("."));
		if (firstparts.length > 0) {
			while (firstparts.length != 0) {
				classstr = firstparts.join(".");
				try {
					def = Type.resolveClass(this.ignoreWhite(classstr));
					havemore = str.length > classstr.length;
					str = this.tempValue(str, new ExeValue(def), 0, classstr.length);
					if (havemore) {
						reg.lastIndex = 0;
						result = reg.exec(str);
						break;
					}
					return this.execValue(str);
				} catch (e:Dynamic) {
					firstparts.pop();
				}
			}
		}
		previndex = 0;
		while (result != null) {
			index = ASCompat.toInt(result.index);
			isFun = str.charAt(index) == "(";
			basestr = this.ignoreWhite(str.substring(previndex, index));
			newv = previndex == 0 ? this.execValue(basestr, v.value) : new ExeValue(v.value, basestr);
			if (isFun) {
				newbase = newv.value;
				closeindex = str.indexOf(")", index);
				paramstr = str.substring(index + 1, closeindex);
				paramstr = this.ignoreWhite(paramstr);
				params = [];
				if (ASCompat.stringAsBool(paramstr)) {
					params = ASCompat.dynamicAs(this.execValue(paramstr).value, Array);
				}
				if (!Reflect.isFunction(newbase)) {
					try {
						nss = [null];
						if (checkNullIteratee(nss))
							for (_tmp_ in nss) {
								ns = _tmp_;
								nsv = v.obj /*ns::*/ [basestr];
								if (Reflect.isFunction(nsv)) {
									newbase = nsv;
									break;
								}
							}
					} catch (e:Dynamic) {}
					if (!Reflect.isFunction(newbase)) {
						throw new Error(basestr + " is not a function.");
					}
				}
				v.obj = Reflect.callMethod(v.value, ASCompat.asFunction(newbase), params);
				v.prop = null;
				index = closeindex + 1;
			} else {
				v = newv;
			}
			previndex = index + 1;
			reg.lastIndex = index + 1;
			result = reg.exec(str);
			if (result == null) {
				if (index + 1 < str.length) {
					reg.lastIndex = str.length;
					result = {"index": str.length};
				}
			}
		}
		return v;
	}

	function execValue(str:String, base:ASAny = null):ExeValue {
		var v:ExeValue = null;
		var vv:ExeValue = null;
		var key:String = null;
		v = new ExeValue();
		if (str == "true") {
			v.obj = true;
		} else if (str == "false") {
			v.obj = false;
		} else if (str == "this") {
			v.obj = this._scope;
		} else if (str == "null") {
			v.obj = null;
		} else if (!Math.isNaN(ASCompat.toNumber(str))) {
			v.obj = ASCompat.toNumber(str);
		} else if (str.indexOf(VALKEY) == 0) {
			vv = ASCompat.dynamicAs((this._values : ASAny)[ASCompat.toInt(str.substring(VALKEY.length))], ExeValue);
			v.obj = vv.value;
		} else if (str.charAt(0) == "$") {
			key = str.substring(1);
			if (this._reserved.indexOf(key) < 0) {
				v.obj = this._saved;
				v.prop = key;
			} else if (Std.isOfType(this._saved, WeakObject)) {
				v.obj = cast(this._saved, WeakObject).get(key);
			} else {
				v.obj = this._saved[key];
			}
		} else {
			try {
				v.obj = Type.resolveClass(str);
			} catch (e:Dynamic) {
				v.obj = base;
				v.prop = str;
			}
		}
		return v;
	}

	function operate(v1:ExeValue, op:String, v2:ExeValue):ASAny {
		switch (op) {
			case "=":
				return v2.value;
			case "+":
				return v1.value + v2.value;
			case "-":
				return ASCompat.toNumberField(v1, "value") - ASCompat.toNumberField(v2, "value");
			case "*":
				return ASCompat.toNumberField(v1, "value") * ASCompat.toNumberField(v2, "value");
			case "/":
				return ASCompat.toNumberField(v1, "value") / ASCompat.toNumberField(v2, "value");
			case "%":
				return ASCompat.toNumberField(v1, "value") % ASCompat.toNumberField(v2, "value");
			case "^":
				return ASCompat.toInt(v1.value) ^ ASCompat.toInt(v2.value);
			case "&":
				return ASCompat.toInt(v1.value) & ASCompat.toInt(v2.value);
			case ">>":
				return ASCompat.toInt(v1.value) >> ASCompat.toInt(v2.value);
			case ">>>":
				return ASCompat.toInt(v1.value) >>> ASCompat.toInt(v2.value);
			case "<<":
				return ASCompat.toInt(v1.value) << ASCompat.toInt(v2.value);
			case "~":
				return ~ASCompat.toInt(v2.value);
			case "|":
				return ASCompat.toInt(v1.value) | ASCompat.toInt(v2.value);
			case "!":
				return !ASCompat.toBool(v2.value);
			case ">":
				return v1.value > v2.value;
			case ">=":
				return v1.value >= v2.value;
			case "<":
				return v1.value < v2.value;
			case "<=":
				return v1.value <= v2.value;
			case "||":
				return if (ASCompat.toBool(v1.value)) v1.value else v2.value;
			case "&&":
				return v1.value && v2.value;
			case "is":
				return Std.isOfType(v1.value, v2.value);
			case "typeof":
				return ASCompat.typeof(v2.value);
			case "delete":
				return ASCompat.deleteProperty(v2.obj, v2.prop);
			case "==":
				return v1.value == v2.value;
			case "===":
				return v1.value == v2.value;
			case "!=":
				return v1.value != v2.value;
			case "!==":
				return v1.value != v2.value;
			default:
				return null;
		}
		return null;
	}

	function makeNew(str:String):ASAny {
		var _loc5_ = 0;
		var _loc6_:String = null;
		var _loc7_:Array<ASAny> = null;
		var _loc8_ = 0;
		var _loc2_ = str.indexOf("(");
		var _loc3_ = _loc2_ > 0 ? str.substring(0, _loc2_) : str;
		_loc3_ = this.ignoreWhite(_loc3_);
		var _loc4_:ASAny = this.execValue(_loc3_).value;
		if (_loc2_ > 0) {
			_loc5_ = str.indexOf(")", _loc2_);
			_loc6_ = str.substring(_loc2_ + 1, _loc5_);
			_loc6_ = this.ignoreWhite(_loc6_);
			_loc7_ = [];
			if (ASCompat.stringAsBool(_loc6_)) {
				_loc7_ = ASCompat.dynamicAs(this.execValue(_loc6_).value, Array);
			}
			_loc8_ = _loc7_.length;
			if (_loc8_ == 0) {
				return ASCompat.createInstance(_loc4_, []);
			}
			if (_loc8_ == 1) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0]]);
			}
			if (_loc8_ == 2) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0], _loc7_[1]]);
			}
			if (_loc8_ == 3) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2]]);
			}
			if (_loc8_ == 4) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3]]);
			}
			if (_loc8_ == 5) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4]]);
			}
			if (_loc8_ == 6) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4], _loc7_[5]]);
			}
			if (_loc8_ == 7) {
				return ASCompat.createInstance(_loc4_, [_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4], _loc7_[5], _loc7_[6]]);
			}
			if (_loc8_ == 8) {
				return ASCompat.createInstance(_loc4_, [
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
				return ASCompat.createInstance(_loc4_, [
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
				return ASCompat.createInstance(_loc4_, [
					_loc7_[0], _loc7_[1], _loc7_[2], _loc7_[3], _loc7_[4], _loc7_[5], _loc7_[6], _loc7_[7], _loc7_[8], _loc7_[9]]);
			}
			throw new Error("CommandLine can\'t create new class instances with more than 10 arguments.");
		}
		return null;
	}

	function ignoreWhite(str:String):String {
		str = new compat.RegExp("\\s*(.*)").replace(str, "$1");
		var _loc2_ = str.length - 1;
		while (_loc2_ > 0) {
			if (new compat.RegExp("\\s").match(str.charAt(_loc2_)) == null) {
				break;
			}
			str = str.substring(0, _loc2_);
			_loc2_ = ASCompat.toInt(_loc2_) - 1;
		}
		return str;
	}
}

private class ExeValue {
	public var obj:ASAny;

	public var prop:String;

	public function new(b:ASObject = null, p:String = null) {
		this.obj = b;
		this.prop = p;
	}

	@:isVar public var value(get, never):ASAny;

	public function get_value():ASAny {
		return ASCompat.stringAsBool(this.prop) ? this.obj[this.prop] : this.obj;
	}

	public function setValue(v:ASAny) {
		if (ASCompat.stringAsBool(this.prop)) {
			this.obj[this.prop] = v;
		} else {
			this.obj = v;
		}
	}
}
