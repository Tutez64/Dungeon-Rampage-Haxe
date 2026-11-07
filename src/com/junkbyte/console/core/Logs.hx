package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.Log;
import flash.events.Event;
import flash.utils.ByteArray;

class Logs extends ConsoleCore {
	public var last:Log;

	public var hasNewLog:Bool = false;

	public var first:Log;

	public var _timer:UInt = 0;

	public var _repeating:UInt = 0;

	public var _newRepeat:Log;

	public var _lines:UInt = 0;

	public var _length:UInt = 0;

	public var _lastRepeat:Log;

	public var _channels:Array<ASAny>;

	public function new(console:Console = /*undefined*/ null) {
		var _gthis:Logs;
		_gthis = this;
		super(console);
		_channels = [];
		get_remoter().addEventListener(Event.CONNECT, onRemoteConnection);
		get_remoter().registerCallback("log", function(bytes:ByteArray) {
			_gthis.registerLog(Log.FromBytes(bytes));
		});
	}

	public function update(time:UInt) {
		_timer = time;
		if (_repeating > 0) {
			--_repeating;
		}
		if (_newRepeat != null) {
			if (_lastRepeat != null) {
				remove(_lastRepeat);
			}
			_lastRepeat = _newRepeat;
			_newRepeat = null;
			push(_lastRepeat);
		}
	}

	public function send2Remote(line:Log) {
		var _loc2_ = (null : ByteArray);
		if (get_remoter().get_canSend()) {
			_loc2_ = new ByteArray();
			line.toBytes(_loc2_);
			get_remoter().send("log", _loc2_);
		}
	}

	public function remove(log:Log) {
		if (first == log) {
			first = log.next;
		}
		if (last == log) {
			last = log.prev;
		}
		if (log == _lastRepeat) {
			_lastRepeat = null;
		}
		if (log == _newRepeat) {
			_newRepeat = null;
		}
		if (log.next != null) {
			log.next.prev = log.prev;
		}
		if (log.prev != null) {
			log.prev.next = log.next;
		}
		--_length;
	}

	public function registerLog(line:Log) {
		hasNewLog = true;
		addChannel(line.ch);
		line.lineStr = "" + line.line + " ";
		line.chStr = "[<a href=\"event:channel_" + line.ch + "\">" + line.ch + "</a>] ";
		line.timeStr = Std.string(config.timeStampFormatter(line.time)) + " ";
		send2Remote(line);
		if (line.repeat) {
			if (_repeating > 0 && _lastRepeat != null) {
				line.line = _lastRepeat.line;
				_newRepeat = line;
				return;
			}
			_repeating = (config.maxRepeats : UInt);
			_lastRepeat = line;
		}
		push(line);
		while (_length > config.maxLines && config.maxLines > 0) {
			remove(first);
		}
		if (config.tracing && config.traceCall != null) {
			config.traceCall(line.ch, line.plainText(), line.priority);
		}
	}

	public function push(v:Log) {
		if (last == null) {
			first = v;
		} else {
			last.next = v;
			v.prev = last;
		}
		last = v;
		++_length;
	}

	public function onRemoteConnection(e:Event) {
		var _loc2_ = first;
		while (_loc2_ != null) {
			send2Remote(_loc2_);
			_loc2_ = _loc2_.next;
		}
	}

	public function getLogsAsString(splitter:String, incChNames:Bool = true, filter:ASAny = /*undefined*/ null):String {
		var _loc4_:Array<ASAny> = [];
		var _loc5_ = first;
		while (_loc5_ != null) {
			if (filter == null || ASCompat.toBool(filter(_loc5_))) {
				_loc4_.push(incChNames ? _loc5_.toString() : _loc5_.plainText());
			}
			_loc5_ = _loc5_.next;
		}
		return _loc4_.join(splitter);
	}

	public function getChannels():Array<ASAny> {
		var _loc5_:ASAny = ASCompat.asString(null);
		var _loc1_:Array<ASAny> = [" * "];
		addIfexist("-", _loc1_);
		addIfexist("~", _loc1_);
		addIfexist("⌂", _loc1_);
		addIfexist("C", _loc1_);
		var _loc2_:Array<ASAny> = [];
		var _loc3_ = 0;
		var _loc4_ = _channels;
		while (_loc3_ < _loc4_.length) {
			_loc5_ = _loc4_[_loc3_];
			_loc3_++;
			if (_loc1_.indexOf(_loc5_) < 0) {
				_loc2_.push(_loc5_);
			}
		}
		ASCompat.ASArray.sort(_loc2_, function(a:String, b:String):Int {
			a = a.toLowerCase();
			b = b.toLowerCase();
			if (a < b) {
				return -1;
			}
			if (a > b) {
				return 1;
			}
			return 0;
		});
		return _loc1_.concat(_loc2_);
	}

	public function clear(channel:String = /*undefined*/ null) {
		var _loc2_:ASAny = ASCompat.dynamicAs(null, Log);
		if (channel != null) {
			_loc2_ = first;
			while (_loc2_ != null) {
				if (_loc2_.ch == channel) {
					remove(ASCompat.coerce(_loc2_, com.junkbyte.console.vos.Log));
				}
				_loc2_ = _loc2_.next;
			}
			_channels.remove(channel);
		} else {
			first = null;
			last = null;
			_length = (0 : UInt);
			_channels = [];
		}
	}

	public function cleanChannels() {
		_channels = [];
		var _loc1_ = first;
		while (_loc1_ != null) {
			addChannel(_loc1_.ch);
			_loc1_ = _loc1_.next;
		}
	}

	public function addIfexist(n:String, arr:Array<ASAny>) {
		if (_channels.indexOf(n) != -1) {
			arr.push(n);
		}
	}

	public function addChannel(n:String) {
		if (_channels.indexOf(n) == -1) {
			_channels.push(n);
		}
	}

	public function add(line:Log) {
		++_lines;
		line.line = _lines;
		line.time = _timer;
		registerLog(line);
	}
}
