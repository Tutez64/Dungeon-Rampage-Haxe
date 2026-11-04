package com.junkbyte.console.core;

import com.junkbyte.console.Cc;
import com.junkbyte.console.Console;
import com.junkbyte.console.compat.ConsoleLib;
import com.junkbyte.console.utils.FlashRegex;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

class ConsoleTools extends ConsoleCore {
	public function new(console:Console = /*undefined*/ null) {
		super(console);
	}

	public function stepExp(o:ASAny, n:ASAny, d:Int, p:Int):String {
		return Std.string(n) + ":" + explode(o[n], d - 1, p - 1);
	}

	public function map(base:DisplayObjectContainer, maxstep:Int = 0, ch:String = /*undefined*/ null) {
		var _loc9_:ASAny = ASCompat.dynamicAs(null, DisplayObject);
		var _loc10_:ASAny = ASCompat.dynamicAs(null, DisplayObjectContainer);
		var _loc11_ = 0;
		var _loc12_ = 0;
		var _loc13_ = 0;
		var _loc14_ = 0;
		var _loc15_:ASAny = ASCompat.dynamicAs(null, DisplayObject);
		var _loc16_ = ASCompat.asString(null);
		var _loc17_ = (0 : UInt);
		var _loc18_:ASAny = ASCompat.asString(null);
		if (base == null) {
			report("Not a DisplayObjectContainer.", 10, true, ch);
			return;
		}
		var _loc4_ = 0;
		var _loc5_ = false;
		var _loc6_ = 0;
		var _loc7_:DisplayObject = null;
		var _loc8_:Array<ASAny> = [];
		_loc8_.push(base);
		while (_loc6_ < _loc8_.length) {
			_loc9_ = _loc8_[_loc6_];
			_loc6_++;
			if (Std.isOfType(_loc9_, DisplayObjectContainer)) {
				_loc10_ = _loc9_;
				_loc11_ = ASCompat.toInt(cast(_loc10_, flash.display.DisplayObjectContainer).numChildren);
				_loc12_ = 0;
				_loc13_ = _loc11_;
				while (_loc12_ < _loc13_) {
					_loc14_ = _loc12_++;
					_loc15_ = _loc10_.getChildAt(_loc14_);
					ASCompat.arraySplice(_loc8_, _loc6_ + _loc14_, (0 : UInt), [_loc15_]);
				}
			}
			if (_loc7_ != null) {
				if (Std.isOfType(_loc7_, DisplayObjectContainer) && ASCompat.toBool((_loc7_ : ASAny).contains(_loc9_))) {
					_loc4_++;
				} else {
					while (_loc7_ != null) {
						_loc7_ = _loc7_.parent;
						if (Std.isOfType(_loc7_, DisplayObjectContainer)) {
							if (_loc4_ > 0) {
								_loc4_--;
							}
							if (ASCompat.toBool((_loc7_ : ASAny).contains(_loc9_))) {
								_loc4_++;
								break;
							}
						}
					}
				}
			}
			_loc16_ = "";
			_loc11_ = 0;
			_loc12_ = _loc4_;
			while (_loc11_ < _loc12_) {
				_loc13_ = _loc11_++;
				_loc16_ += _loc13_ == _loc4_ - 1 ? " ∟ " : " - ";
			}
			if (maxstep <= 0 || _loc4_ <= maxstep) {
				_loc5_ = false;
				_loc17_ = console.get_refs().setLogRef(_loc9_);
				_loc18_ = _loc9_.name;
				if (_loc17_ != 0) {
					_loc18_ = "<a href=\'event:cl_" + ("" + _loc17_) + "\'>" + Std.string(_loc18_) + "</a>";
				}
				if (Std.isOfType(_loc9_, DisplayObjectContainer)) {
					_loc18_ = "<b>" + Std.string(_loc18_) + "</b>";
				} else {
					_loc18_ = "<i>" + Std.string(_loc18_) + "</i>";
				}
				_loc16_ += Std.string(_loc18_) + " " + console.get_refs().makeRefTyped(_loc9_);
				report(_loc16_, Std.isOfType(_loc9_, DisplayObjectContainer) ? 5 : 2, true, ch);
			} else if (!_loc5_) {
				_loc5_ = true;
				report(_loc16_ + "...", 5, true, ch);
			}
			_loc7_ = ASCompat.coerce(_loc9_, flash.display.DisplayObject);
		}
		report(base.name + ":" + console.get_refs().makeRefTyped(base) + " has " + (_loc8_.length - 1) + " children/sub-children.", 9, true, ch);
		if (config.commandLineAllowed) {
			report("Click on the child display\'s name to set scope.", -2, true, ch);
		}
	}

	public function getStack(depth:Int, priority:Int):String {
		var _loc12_ = 0;
		var _loc3_ = new Error();
		var _loc4_ = _loc3_.getStackTrace();
		if (_loc4_ == null || _loc4_ == "") {
			return "";
		}
		var _loc5_ = "";
		var _loc6_ = FlashRegex.split(_loc4_, new EReg("\n\\sat\\s", ""));
		var _loc7_ = _loc6_.length;
		var _loc8_ = new EReg("Function|" + ConsoleLib.getQualifiedClassName(Console) + "|" + ConsoleLib.getQualifiedClassName(Cc), "");
		var _loc9_ = false;
		var _loc10_ = 2;
		var _loc11_ = _loc7_;
		while (_loc10_ < _loc11_) {
			_loc12_ = _loc10_++;
			if (!_loc9_ && FlashRegex.search(_loc6_[_loc12_], _loc8_) != 0) {
				_loc9_ = true;
			}
			if (_loc9_) {
				_loc5_ += "\n<p" + priority + "> @ " + Std.string(_loc6_[_loc12_]) + "</p" + priority + ">";
				if (priority > 0) {
					priority--;
				}
				if (--depth <= 0) {
					break;
				}
			}
		}
		return _loc5_;
	}

	public function explode(obj:ASAny, depth:Int = 3, p:Int = 9):String {
		var _temp_1:ASAny;
		var _loc9_ = 0;
		var _loc11_ = 0;
		var _loc12_:ASAny = ASCompat.asXML(null);
		var _loc13_ = ASCompat.asString(null);
		var _loc14_:ASAny = null;
		var _loc15_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc16_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc5_ = ConsoleLib.typeOf(obj);
		if (obj == null) {
			return "<p-2>" + Std.string(obj) + "</p-2>";
		}
		if (Std.isOfType(obj, String)) {
			_temp_1 = obj;
			if (!Std.isOfType(_temp_1, String)) {
				throw "Class cast error";
			}
			return "\"" + LogReferences.EscHTML(_temp_1) + "\"";
		}
		if (_loc5_ != "object" || depth == 0 || ASCompat.isByteArray(obj)) {
			return console.get_refs().makeString(obj);
		}
		if (p < 0) {
			p = 0;
		}
		var _loc6_ = ASCompat.describeType(obj);
		var _loc7_:Array<ASAny> = [];
		var _loc8_ = _loc6_.child("accessor");
		_loc9_ = 0;
		var _loc10_ = _loc8_.length();
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc12_ = _loc8_[_loc11_];
			_loc13_ = Std.string(_loc12_.attribute("name"));
			if (Std.string(_loc12_.attribute("access")) != "writeonly") {
				try {
					_loc7_.push(stepExp(obj, _loc13_, depth, p));
				} catch (_loc_e_:ASAny) {
					_loc14_ = _loc_e_;
					null;
				}
			} else {
				_loc7_.push(_loc13_);
			}
		}
		_loc8_ = _loc6_.child("variable");
		_loc9_ = 0;
		_loc10_ = _loc8_.length();
		while (_loc9_ < _loc10_) {
			_loc11_ = _loc9_++;
			_loc7_.push(stepExp(obj, Std.string(_loc8_[_loc11_].attribute("name")), depth, p));
		}
		try {
			_loc9_ = 0;
			_loc16_ = [];
			_loc14_ = obj;
			if (checkNullIteratee(_loc14_))
				for (_tmp_ in _loc14_.___keys()) {
					_loc9_ = ASCompat.toInt(_tmp_);
					_loc16_.push(_loc9_);
				}
			_loc15_ = _loc16_;
			_loc9_ = 0;
			while (_loc9_ < ASCompat.toInt(_loc15_.length)) {
				_loc14_ = _loc15_[_loc9_];
				_loc9_++;
				_loc7_.push(stepExp(obj, _loc14_, depth, p));
			}
		} catch (_loc_e_:ASAny) {
			_loc14_ = _loc_e_;
			null;
		}
		return "<p"
			+ p
			+ ">{"
			+ LogReferences.ShortClassName(obj)
			+ "</p"
			+ p
			+ "> "
			+ _loc7_.join(", ")
			+ "<p"
			+ p
			+ ">}</p"
			+ p
			+ ">";
	}
}
