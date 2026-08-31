package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.Log;
import flash.events.Event;
import flash.utils.ByteArray;

class Logs extends ConsoleCore {
	var _channels:ASObject;

	var _repeating:UInt = 0;

	var _lastRepeat:Log;

	var _newRepeat:Log;

	var _hasNewLog:Bool = false;

	var _timer:UInt = 0;

	public var first:Log;

	public var last:Log;

	var _length:UInt = 0;

	var _lines:UInt = 0;

	public function new(console:Console) {
		super(console);
		this._channels = new ASObject();
		remoter.addEventListener(Event.CONNECT, this.onRemoteConnection);
		remoter.registerCallback("log", function(bytes:ByteArray) {
			registerLog(Log.FromBytes(bytes));
		});
	}

	function onRemoteConnection(e:Event) {
		var _loc2_ = this.first;
		while (_loc2_ != null) {
			this.send2Remote(_loc2_);
			_loc2_ = _loc2_.next;
		}
	}

	function send2Remote(line:Log) {
		var _loc2_:ByteArray = null;
		if (remoter.canSend) {
			_loc2_ = new ByteArray();
			line.toBytes(_loc2_);
			remoter.send("log", _loc2_);
		}
	}

	public function update(time:UInt):Bool {
		this._timer = time;
		if (this._repeating > 0) {
			--this._repeating;
		}
		if (this._newRepeat != null) {
			if (this._lastRepeat != null) {
				this.remove(this._lastRepeat);
			}
			this._lastRepeat = this._newRepeat;
			this._newRepeat = null;
			this.push(this._lastRepeat);
		}
		var _loc2_ = this._hasNewLog;
		this._hasNewLog = false;
		return _loc2_;
	}

	public function add(line:Log) {
		++this._lines;
		line.line = this._lines;
		line.time = this._timer;
		this.registerLog(line);
	}

	function registerLog(line:Log) {
		this._hasNewLog = true;
		this.addChannel(line.ch);
		line.lineStr = line.line + " ";
		line.chStr = "[<a href=\"event:channel_" + line.ch + "\">" + line.ch + "</a>] ";
		line.timeStr = config.timeStampFormatter(line.time) + " ";
		this.send2Remote(line);
		if (line.repeat) {
			if (this._repeating > 0 && this._lastRepeat != null) {
				line.line = this._lastRepeat.line;
				this._newRepeat = line;
				return;
			}
			this._repeating = (config.maxRepeats : UInt);
			this._lastRepeat = line;
		}
		this.push(line);
		while (this._length > config.maxLines && config.maxLines > 0) {
			this.remove(this.first);
		}
		if (config.tracing && config.traceCall != null) {
			config.traceCall(line.ch, line.plainText(), line.priority);
		}
	}

	public function clear(channel:String = null) {
		var _loc2_:Log = null;
		if (ASCompat.stringAsBool(channel)) {
			_loc2_ = this.first;
			while (_loc2_ != null) {
				if (_loc2_.ch == channel) {
					this.remove(_loc2_);
				}
				_loc2_ = _loc2_.next;
			}
			ASCompat.deleteProperty(this._channels, channel);
		} else {
			this.first = null;
			this.last = null;
			this._length = (0 : UInt);
			this._channels = new ASObject();
		}
	}

	public function getLogsAsString(splitter:String, incChNames:Bool = true, filter:ASFunction = null):String {
		var _loc4_ = "";
		var _loc5_ = this.first;
		while (_loc5_ != null) {
			if (filter == null || ASCompat.toBool(filter(_loc5_))) {
				if (this.first != _loc5_) {
					_loc4_ += splitter;
				}
				_loc4_ += incChNames ? _loc5_.toString() : _loc5_.plainText();
			}
			_loc5_ = _loc5_.next;
		}
		return _loc4_;
	}

	public function getChannels():Array<ASAny> {
		var _loc3_:String = null;
		var _loc1_:Array<ASAny> = [Console.GLOBAL_CHANNEL];
		this.addIfexist(Console.DEFAULT_CHANNEL, _loc1_);
		this.addIfexist(Console.FILTER_CHANNEL, _loc1_);
		this.addIfexist(LogReferences.INSPECTING_CHANNEL, _loc1_);
		this.addIfexist(Console.CONSOLE_CHANNEL, _loc1_);
		var _loc2_ = new Array<ASAny>();
		final __ax4_iter_116:ASObject = this._channels;
		if (checkNullIteratee(__ax4_iter_116))
			for (_tmp_ in __ax4_iter_116.___keys()) {
				_loc3_ = _tmp_;
				if (_loc1_.indexOf(_loc3_) < 0) {
					_loc2_.push(_loc3_);
				}
			}
		return _loc1_.concat(ASCompat.ASArray.sortWithOptions(_loc2_, ASCompat.ASArray.CASEINSENSITIVE));
	}

	function addIfexist(n:String, arr:Array<ASAny>) {
		if (this._channels.hasOwnProperty(n)) {
			arr.push(n);
		}
	}

	public function cleanChannels() {
		this._channels = new ASObject();
		var _loc1_ = this.first;
		while (_loc1_ != null) {
			this.addChannel(_loc1_.ch);
			_loc1_ = _loc1_.next;
		}
	}

	public function addChannel(n:String) {
		this._channels[n] = null;
	}

	function push(v:Log) {
		if (this.last == null) {
			this.first = v;
		} else {
			this.last.next = v;
			v.prev = this.last;
		}
		this.last = v;
		++this._length;
	}

	function remove(log:Log) {
		if (this.first == log) {
			this.first = log.next;
		}
		if (this.last == log) {
			this.last = log.prev;
		}
		if (log == this._lastRepeat) {
			this._lastRepeat = null;
		}
		if (log == this._newRepeat) {
			this._newRepeat = null;
		}
		if (log.next != null) {
			log.next.prev = log.prev;
		}
		if (log.prev != null) {
			log.prev.next = log.next;
		}
		--this._length;
	}
}
