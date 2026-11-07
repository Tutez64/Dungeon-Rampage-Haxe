package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.GraphGroup;
import com.junkbyte.console.vos.GraphInterest;
import flash.geom.Rectangle;
import flash.system.System;
import flash.utils.ByteArray;
import haxe.Constraints.IMap;
import haxe.ds.StringMap;

class Graphing extends ConsoleCore {
	public var _previousTime:Int = 0;

	public var _memGroup:GraphGroup;

	public var _map:IMap<ASAny, ASAny>;

	public var _hadGraph:Bool = false;

	public var _groups:Array<ASAny>;

	public var _fpsGroup:GraphGroup;

	public function new(m:Console = /*undefined*/ null) {
		var _gthis:Graphing;
		_previousTime = -1;
		_map = new StringMap<ASAny>();
		_groups = [];
		_gthis = this;
		super(m);
		get_remoter().registerCallback("fps", function(bytes:ByteArray) {
			_gthis.set_fpsMonitor(bytes.readBoolean());
		});
		get_remoter().registerCallback("mem", function(bytes:ByteArray) {
			_gthis.set_memoryMonitor(bytes.readBoolean());
		});
		get_remoter().registerCallback("removeGroup", function(bytes:ByteArray) {
			_gthis.removeGroup(bytes.readUTF());
		});
		get_remoter().registerCallback("graph", handleRemoteGraph, true);
	}

	public function updateExternalGraphGroup(group:GraphGroup) {
		var _loc5_:ASAny = ASCompat.dynamicAs(null, GraphInterest);
		var _loc6_ = Math.NaN;
		var _loc7_ = ASCompat.dynamicAs(null, Error);
		var _loc3_ = 0;
		var _loc4_ = group.interests;
		while (_loc3_ < _loc4_.length) {
			_loc5_ = _loc4_[_loc3_];
			_loc3_++;
			_loc6_ = 0;
			try {
				_loc6_ = ASCompat.toNumber(_loc5_.getCurrentValue());
				_loc5_.setValue(_loc6_, group.averaging);
			} catch (_loc_e_:Dynamic) {
				_loc7_ = ASCompat.asError(_loc_e_);
				report("Error with graph value for key [" + Std.string(_loc5_.key) + "] in [" + group.name + "]. " + Std.string(_loc7_), 10);
				remove(group.name, _loc5_.get_obj(), _loc5_.get_prop());
			}
			group.updateMinMax(_loc6_);
		}
	}

	public function update(fps:Int = 0):Array<ASAny> {
		var _loc2_:ASAny = ASCompat.dynamicAs(null, GraphInterest);
		var _loc3_ = Math.NaN;
		var _loc4_ = 0;
		var _loc6_:ASAny = ASCompat.dynamicAs(null, GraphGroup);
		var _loc7_ = false;
		var _loc8_ = (0 : UInt);
		var _loc9_ = (0 : UInt);
		var _loc10_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc11_ = 0;
		var _loc12_ = Math.NaN;
		var _loc13_ = (null : ByteArray);
		var _loc14_ = 0;
		_loc4_ = 0;
		var _loc5_ = _groups;
		while (_loc4_ < _loc5_.length) {
			_loc6_ = _loc5_[_loc4_];
			_loc4_++;
			_loc7_ = true;
			if (ASCompat.toNumberField(_loc6_, "freq") > 1) {
				_loc6_.idle = ASCompat.toInt(_loc6_.idle) + 1;
				if (_loc6_.idle < _loc6_.freq) {
					_loc7_ = false;
				} else {
					ASCompat.setProperty(_loc6_, "idle", 0);
				}
			}
			if (_loc7_) {
				_loc8_ = (ASCompat.toInt(_loc6_.type) : UInt);
				_loc9_ = (ASCompat.toInt(_loc6_.averaging) : UInt);
				_loc10_ = _loc6_.interests;
				if (_loc8_ == 1) {
					ASCompat.setProperty(_loc6_, "hi", fps);
					_loc2_ = _loc10_[0];
					_loc11_ = flash.Lib.getTimer();
					if (_previousTime >= 0) {
						_loc12_ = _loc11_ - _previousTime;
						_loc3_ = 1000 / _loc12_;
						_loc2_.setValue(_loc3_, _loc9_);
					}
					_previousTime = _loc11_;
				} else if (_loc8_ == 2) {
					_loc2_ = _loc10_[0];
					_loc3_ = ASCompat.floatToInt(Math.fround(System.totalMemory / 10485.76)) / 100;
					_loc6_.updateMinMax(_loc3_);
					_loc2_.setValue(_loc3_, _loc9_);
				} else {
					updateExternalGraphGroup(ASCompat.coerce(_loc6_, com.junkbyte.console.vos.GraphGroup));
				}
			}
		}
		if (get_remoter().get_canSend() && (_hadGraph || _groups.length != 0)) {
			_loc8_ = (_groups.length : UInt);
			_loc13_ = new ByteArray();
			_loc4_ = 0;
			_loc11_ = _loc8_;
			while (_loc4_ < _loc11_) {
				_loc14_ = _loc4_++;
				_groups[_loc14_].toBytes(_loc13_);
			}
			get_remoter().send("graph", _loc13_);
			_hadGraph = _groups.length > 0;
		}
		return _groups;
	}

	@:isVar public var memoryMonitor(get, set):Bool;

	public function set_memoryMonitor(b:Bool):Bool {
		var _loc2_ = (null : ByteArray);
		var _loc3_ = 0;
		if (get_remoter().get_remoting() == 2) {
			_loc2_ = new ByteArray();
			_loc2_.writeBoolean(b);
			get_remoter().send("mem", _loc2_);
		} else if (b != get_memoryMonitor()) {
			if (b) {
				_memGroup = addSpecialGroup(2);
				_memGroup.freq = 20;
			} else {
				_loc3_ = _groups.indexOf(_memGroup);
				if (_loc3_ >= 0) {
					_groups.splice(_loc3_, (1 : UInt));
				}
				_memGroup = null;
			}
			console.get_panels().get_mainPanel().updateMenu();
		}
		return b;
	}

	@:isVar public var fpsMonitor(get, set):Bool;

	public function set_fpsMonitor(b:Bool):Bool {
		var _loc2_ = (null : ByteArray);
		var _loc3_ = 0;
		if (get_remoter().get_remoting() == 2) {
			_loc2_ = new ByteArray();
			_loc2_.writeBoolean(b);
			get_remoter().send("fps", _loc2_);
		} else if (b != get_fpsMonitor()) {
			if (b) {
				_fpsGroup = addSpecialGroup(1);
				_fpsGroup.low = 0;
				_fpsGroup.fixed = true;
				_fpsGroup.averaging = (30 : UInt);
			} else {
				_previousTime = -1;
				_loc3_ = _groups.indexOf(_fpsGroup);
				if (_loc3_ >= 0) {
					_groups.splice(_loc3_, (1 : UInt));
				}
				_fpsGroup = null;
			}
			console.get_panels().get_mainPanel().updateMenu();
		}
		return b;
	}

	public function removeGroup(n:String) {
		var _loc2_ = (null : ByteArray);
		var _loc3_ = ASCompat.dynamicAs(null, StringMap);
		var _loc4_:ASAny = ASCompat.dynamicAs(null, GraphGroup);
		var _loc5_ = 0;
		if (get_remoter().get_remoting() == 2) {
			_loc2_ = new ByteArray();
			_loc2_.writeUTF(n);
			get_remoter().send("removeGroup", _loc2_);
		} else {
			_loc3_ = cast(_map, StringMap<Dynamic>);
			_loc4_ = _loc3_.get(n);
			_loc5_ = _groups.indexOf(_loc4_);
			if (_loc5_ >= 0) {
				_groups.splice(_loc5_, (1 : UInt));
			}
			cast(_map, StringMap<Dynamic>).remove(n);
		}
	}

	public function remove(n:String, obj:ASAny = /*undefined*/ null, prop:String = /*undefined*/ null) {
		var _loc4_ = ASCompat.dynamicAs(null, StringMap);
		var _loc5_ = ASCompat.dynamicAs(null, StringMap);
		var _loc6_:ASAny = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		var _loc7_ = 0;
		var _loc8_:ASAny = ASCompat.dynamicAs(null, GraphInterest);
		if (obj == null && prop == null) {
			removeGroup(n);
		} else {
			_loc4_ = cast(_map, StringMap<Dynamic>);
			if (_loc4_.get(n) != null) {
				_loc5_ = cast(_map, StringMap<Dynamic>);
				_loc6_ = _loc5_.get(n).interests;
				_loc7_ = ASCompat.toInt(_loc6_.length) - 1;
				while (_loc7_ >= 0) {
					_loc8_ = _loc6_[_loc7_];
					if ((obj == null || _loc8_.get_obj() == obj) && (prop == null || _loc8_.get_prop() == prop)) {
						ASCompat.dynSplice(_loc6_, _loc7_, 1);
					}
					_loc7_--;
				}
				if (ASCompat.toInt(_loc6_.length) == 0) {
					removeGroup(n);
				}
			}
		}
	}

	public function handleRemoteGraph(bytes:ByteArray = /*undefined*/ null) {
		var _loc2_ = (ASCompat.dynamicAs(null, Array) : Array<ASAny>);
		if (bytes != null && bytes.length != 0) {
			bytes.position = (0 : UInt);
			_loc2_ = [];
			while (bytes.bytesAvailable != 0) {
				_loc2_.push(GraphGroup.FromBytes(bytes));
			}
			console.get_panels().updateGraphs(_loc2_);
		} else {
			console.get_panels().updateGraphs([]);
		}
	}

	public function get_memoryMonitor():Bool {
		if (get_remoter().get_remoting() == 2) {
			return console.get_panels().get_memoryMonitor();
		}
		return _memGroup != null;
	}

	public function get_fpsMonitor():Bool {
		if (get_remoter().get_remoting() == 2) {
			return console.get_panels().get_fpsMonitor();
		}
		return _fpsGroup != null;
	}

	public function fixRange(n:String, low:ASObject = /*undefined*/ null, high:ASObject = /*undefined*/ null) {
		var _loc6_ = false;
		var _loc8_ = Math.NaN;
		if (low == null) {
			low = Math.NaN;
		}
		if (high == null) {
			high = Math.NaN;
		}
		var _loc4_ = cast(_map, StringMap<Dynamic>);
		var _loc5_ = ASCompat.coerce(_loc4_.get(n), com.junkbyte.console.vos.GraphGroup);
		if (_loc5_ == null) {
			return;
		}
		_loc5_.low = ASCompat.toNumber(low);
		_loc5_.hi = ASCompat.toNumber(high);
		var _loc7_ = ASCompat.toNumber(low);
		if (_loc7_ == _loc7_) {
			_loc8_ = ASCompat.toNumber(high);
			_loc6_ = _loc8_ != _loc8_;
		} else {
			_loc6_ = true;
		}
		_loc5_.fixed = !_loc6_;
	}

	public function addSpecialGroup(type:Int):GraphGroup {
		var _loc2_ = new GraphGroup("special");
		_loc2_.type = (type : UInt);
		_groups.push(_loc2_);
		var _loc3_ = new GraphInterest("special");
		if (type == 1) {
			_loc3_.col = 16724787;
		} else {
			_loc3_.col = 5267711;
		}
		_loc2_.interests.push(_loc3_);
		return _loc2_;
	}

	public function add(n:String, obj:ASAny, prop:String, col:Int = -1, key:String = /*undefined*/ null, rect:Rectangle = /*undefined*/ null,
			inverse:Bool = false) {
		var _loc14_:ASAny = ASCompat.dynamicAs(null, GraphInterest);
		var _loc16_ = ASCompat.dynamicAs(null, Error);
		var _loc17_ = ASCompat.dynamicAs(null, StringMap);
		if (obj == null) {
			report("ERROR: Graph [" + n + "] received a null object to graph property [" + prop + "].", 10);
			return;
		}
		var _loc9_ = cast(_map, StringMap<Dynamic>);
		var _loc10_ = ASCompat.coerce(_loc9_.get(n), com.junkbyte.console.vos.GraphGroup);
		var _loc11_ = false;
		if (_loc10_ == null) {
			_loc11_ = true;
			_loc10_ = new GraphGroup(n);
		}
		var _loc12_ = _loc10_.interests;
		if (col != col || col < 0) {
			if (_loc12_.length <= 5) {
				col = ASCompat.toInt(Reflect.field(config.get_style(), "priority" + (10 - _loc12_.length * 2)));
			} else {
				col = ASCompat.floatToInt(Math.random() * 16777215);
			}
		}
		if (key == null) {
			key = prop;
		}
		var _loc13_ = 0;
		while (_loc13_ < _loc12_.length) {
			_loc14_ = _loc12_[_loc13_];
			_loc13_++;
			if (_loc14_.key == key) {
				report("Graph with key [" + key + "] already exists in [" + n + "]", 10);
				return;
			}
		}
		if (rect != null) {
			_loc10_.rect = rect;
		}
		if (inverse) {
			_loc10_.inv = inverse;
		}
		_loc14_ = new GraphInterest(key, col);
		var _loc15_ = Math.NaN;
		try {
			_loc15_ = ASCompat.toNumber(_loc14_.setObject(obj, prop));
		} catch (_loc_e_:Dynamic) {
			_loc16_ = ASCompat.asError(_loc_e_);
			report("Error with graph value for [" + key + "] in [" + n + "]. " + Std.string(_loc16_), 10);
			return;
		}
		if (_loc15_ != _loc15_) {
			report("Graph value for key [" + key + "] in [" + n + "] is not a number (NaN).", 10);
		} else {
			_loc10_.interests.push(_loc14_);
			if (_loc11_) {
				_loc17_ = cast(_map, StringMap<Dynamic>);
				{
					_loc17_.set(n, _loc10_);
				}
				_groups.push(_loc10_);
			}
		}
	}
}
