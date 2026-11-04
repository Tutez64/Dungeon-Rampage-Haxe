package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.compat.ConsoleLib;
import flash.system.System;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;
import haxe.ds.WeakMap;

class MemoryMonitor extends ConsoleCore {
	public var _objectsList:WeakMap<{}, ASAny>;

	public var _namesList:IMap<ASAny, ASAny>;

	public var _count:UInt = 0;

	public function new(m:Console = /*undefined*/ null) {
		super(m);
		_namesList = new StringMap<ASAny>();
		_objectsList = new WeakMap<{}, ASAny>();
		console.get_remoter().registerCallback("gc", gc);
	}

	public function watch(obj:ASAny, n:String):String {
		var _loc4_:ASAny = ASCompat.asString(null);
		var _loc5_ = ASCompat.dynamicAs(null, StringMap);
		var _loc3_ = ConsoleLib.getQualifiedClassName(obj);
		if (_loc3_ == null) {
			_loc3_ = "Object";
		}
		if (n == null || n == "") {
			n = _loc3_ + "@" + flash.Lib.getTimer();
		}
		if ((_objectsList : ASAny)[obj] != null) {
			_loc4_ = (_objectsList : ASAny)[obj];
			_loc5_ = cast(_namesList, StringMap<Dynamic>);
			if (ASCompat.toBool(_loc5_.get(_loc4_))) {
				unwatch((_objectsList : ASAny)[obj]);
			}
		}
		_loc5_ = cast(_namesList, StringMap<Dynamic>);
		if (ASCompat.toBool(_loc5_.get(n))) {
			if ((_objectsList : ASAny)[obj] == n) {
				--_count;
			} else {
				n = n + "@" + flash.Lib.getTimer() + "_" + ASCompat.floatToInt(Math.ffloor(Math.random() * 100));
			}
		}
		var _loc6_ = cast(_namesList, StringMap<Dynamic>);
		{
			_loc6_.set(n, true);
		}
		++_count;
		(_objectsList : ASAny)[obj] = n;
		return n;
	}

	public function update() {
		var _loc4_:ASAny = ASCompat.asString(null);
		var _loc13_:ASAny = null;
		var _loc14_ = 0;
		var _loc15_ = false;
		var _loc16_:ASAny = ASCompat.asString(null);
		if (_count == 0) {
			return;
		}
		var _loc1_:Array<ASAny> = [];
		var _loc2_:ASObject = {};
		var _loc3_:ASAny = _objectsList.iterator();
		while (ASCompat.toBool(_loc3_.hasNext())) {
			_loc4_ = _loc3_.next();
			_loc2_[_loc4_] = true;
		}
		var _loc5_ = cast(_namesList, StringMap<Dynamic>);
		_loc3_ = ASCompat.haxeMapStorage(_loc5_);
		var _loc6_:ASAny = null;
		var _loc7_ = 0;
		var _loc8_ = false;
		var _loc9_:ASAny = _loc3_;
		var _loc10_ = _loc7_;
		var _loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		if (!_loc11_ && _loc6_ != null) {
			_loc3_ = _loc6_;
			_loc9_ = _loc3_;
			_loc10_ = _loc7_ = 0;
			_loc6_ = null;
			_loc8_ = true;
			_loc11_ = (_loc10_ = ASCompat.nextIndex(_loc9_, _loc10_)) != 0;
		}
		var _loc12_ = _loc10_;
		while (true) {
			_loc13_ = _loc3_;
			_loc14_ = _loc7_;
			_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			if (!_loc15_ && _loc6_ != null) {
				_loc3_ = _loc6_;
				_loc13_ = _loc3_;
				_loc14_ = _loc7_ = 0;
				_loc6_ = null;
				_loc8_ = true;
				_loc15_ = (_loc14_ = ASCompat.nextIndex(_loc13_, _loc14_)) != 0;
			}
			_loc12_ = _loc14_;
			if (!_loc15_) {
				break;
			}
			_loc4_ = ASCompat.nextName(_loc3_, _loc12_);
			_loc7_ = _loc12_;
			if (_loc8_) {
				_loc4_ = Std.string(_loc4_).substr(1);
			}
			_loc16_ = _loc4_;
			if (Reflect.field(_loc2_, _loc16_) == null) {
				_loc1_.push(_loc16_);
				cast(_namesList, StringMap<Dynamic>).remove(_loc16_);
				--_count;
			}
		}
		if (_loc1_.length != 0) {
			report("<b>GARBAGE COLLECTED " + _loc1_.length + " item(s): </b>" + _loc1_.join(", "), -2);
		}
	}

	public function unwatch(n:String) {
		var _loc3_:ASAny = null;
		var _loc4_:ASAny = null;
		var _loc2_:Array<ASAny> = [];
		_loc3_ = _objectsList.keys();
		while (ASCompat.toBool(_loc3_.hasNext())) {
			_loc4_ = _loc3_.next();
			_loc2_.push(_loc4_);
		}
		var _loc5_ = _loc2_;
		var _loc6_ = 0;
		while (_loc6_ < _loc5_.length) {
			_loc3_ = _loc5_[_loc6_];
			_loc6_++;
			if ((_objectsList : ASAny)[_loc3_] == n) {
				_objectsList.remove(_loc3_);
			}
		}
		var _loc7_ = cast(_namesList, StringMap<Dynamic>);
		if (ASCompat.toBool(_loc7_.get(n))) {
			cast(_namesList, StringMap<Dynamic>).remove(n);
			--_count;
		}
	}

	@:isVar public var count(get, never):UInt;

	public function get_count():UInt {
		return _count;
	}

	public function gc() {
		var _loc2_ = ASCompat.dynamicAs(null, Error);
		var _loc3_ = false;
		var _loc4_ = ASCompat.asString(null);
		if (get_remoter().get_remoting() == 2) {
			try {
				get_remoter().send("gc");
			} catch (_loc_e_:Dynamic) {
				_loc2_ = _loc_e_;
				report(_loc2_, 10);
			}
		} else {
			_loc3_ = false;
			try {
				if (Reflect.hasField(System, "gc")) {
					System.gc();
					_loc3_ = true;
				}
			} catch (_loc_e_:Dynamic) {
				_loc2_ = _loc_e_;
			}
			_loc4_ = "Manual garbage collection " + (_loc3_ ? "successful." : "FAILED. You need debugger version of flash player.");
			report(_loc4_, _loc3_ ? -1 : 10);
		}
	}
}
