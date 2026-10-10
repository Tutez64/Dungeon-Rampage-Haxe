package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import flash.system.System;

class MemoryMonitor extends ConsoleCore {
	var _namesList:ASObject;

	var _objectsList:ASDictionary<ASAny, ASAny>;

	var _count:UInt = 0;

	public function new(m:Console) {
		super(m);
		this._namesList = new ASObject();
		this._objectsList = new ASDictionary<ASAny, ASAny>(true);
		console.remoter.registerCallback("gc", this.gc);
	}

	public function watch(obj:ASObject, n:String):String {
		var _loc3_ = ASCompat.getQualifiedClassName(obj);
		if (!ASCompat.stringAsBool(n)) {
			n = _loc3_ + "@" + flash.Lib.getTimer();
		}
		if (ASCompat.toBool(this._objectsList[obj])) {
			if (ASCompat.toBool(this._namesList[this._objectsList[obj]])) {
				this.unwatch(this._objectsList[obj]);
			}
		}
		if (ASCompat.toBool(this._namesList[n])) {
			if (this._objectsList[obj] == n) {
				--this._count;
			} else {
				n = n + "@" + flash.Lib.getTimer() + "_" + Math.ffloor(Math.random() * 100);
			}
		}
		this._namesList[n] = true;
		++this._count;
		this._objectsList[obj] = n;
		return n;
	}

	public function unwatch(n:String) {
		var _loc2_:ASObject = null;
		final __ax4_iter_107 = this._objectsList;
		if (checkNullIteratee(__ax4_iter_107))
			for (_tmp_ in __ax4_iter_107.keys()) {
				_loc2_ = _tmp_;
				if (this._objectsList[_loc2_] == n) {
					this._objectsList.remove(_loc2_);
				}
			}
		if (ASCompat.toBool(this._namesList[n])) {
			ASCompat.deleteProperty(this._namesList, n);
			--this._count;
		}
	}

	public function update() {
		var _loc3_:ASObject = null;
		var _loc4_:String = null;
		if (this._count == 0) {
			return;
		}
		var _loc1_ = new Array<ASAny>();
		var _loc2_:ASObject = new ASObject();
		final __ax4_iter_108 = this._objectsList;
		if (checkNullIteratee(__ax4_iter_108))
			for (_tmp_ in __ax4_iter_108.keys()) {
				_loc3_ = _tmp_;
				_loc2_[this._objectsList[_loc3_]] = true;
			}
		final __ax4_iter_109:ASObject = this._namesList;
		if (checkNullIteratee(__ax4_iter_109))
			for (_tmp_ in __ax4_iter_109.___keys()) {
				_loc4_ = _tmp_;
				if (!ASCompat.toBool(_loc2_[_loc4_])) {
					_loc1_.push(_loc4_);
					ASCompat.deleteProperty(this._namesList, _loc4_);
					--this._count;
				}
			}
		if (_loc1_.length != 0) {
			report("<b>GARBAGE COLLECTED " + _loc1_.length + " item(s): </b>" + _loc1_.join(", "), -2);
		}
	}

	@:isVar public var count(get, never):UInt;

	public function get_count():UInt {
		return this._count;
	}

	public function gc() {
		var ok = false;
		var str:String = null;
		if (remoter.remoting == Remoting.RECIEVER) {
			try {
				remoter.send("gc");
			} catch (e:Dynamic) {
				report(e, 10);
			}
		} else {
			try {
				if ((System : ASAny)["gc"] != null) {
					(System : ASAny)["gc"]();
					ok = true;
				}
			} catch (e:Dynamic) {}
			str = "Manual garbage collection " + (ok ? "successful." : "FAILED. You need debugger version of flash player.");
			report(str, ok ? -1 : 10);
		}
	}
}
