class ASArrayBase {
	final data:Array<ASAny>;

	public var length(get, set):Int;

	public function new(...rest:ASAny) {
		data = [];
		initFromArgs(rest);
	}

	function initFromArgs(rest:Array<ASAny>):Void {
		if (rest.length == 1) {
			var len = readLengthArg(rest[0]);
			if (len != null) {
				if (len < 0) {
					throw "RangeError: Invalid array length";
				}
				data.resize(len);
				return;
			}
		}
		for (value in rest) {
			data.push(value);
		}
	}

	static function readLengthArg(value:ASAny):Null<Int> {
		var dyn:Dynamic = value;
		if (Std.isOfType(dyn, Int)) {
			return dyn;
		}
		if (Std.isOfType(dyn, Float)) {
			var f:Float = dyn;
			if (Math.isNaN(f) || f == Math.POSITIVE_INFINITY || f == Math.NEGATIVE_INFINITY) {
				return null;
			}
			if (Math.floor(f) != f) {
				return null;
			}
			return Std.int(f);
		}
		return null;
	}

	function get_length():Int {
		return data.length;
	}

	function set_length(value:Int):Int {
		if (value < 0) {
			throw "RangeError: Invalid array length";
		}
		data.resize(value);
		return value;
	}

	@:arrayAccess
	public function get(index:Int):ASAny {
		return data[index];
	}

	@:arrayAccess
	public function set(index:Int, value:ASAny):ASAny {
		data[index] = value;
		return value;
	}

	public function iterator() {
		return data.iterator();
	}

	public function push(...rest:ASAny):UInt {
		for (value in rest) {
			data.push(value);
		}
		return cast data.length;
	}

	public function pop():ASAny {
		return data.pop();
	}

	public function shift():ASAny {
		return data.shift();
	}

	public function unshift(...rest:ASAny):UInt {
		var values:Array<ASAny> = rest;
		for (i in 0...values.length) {
			data.insert(i, values[i]);
		}
		return cast data.length;
	}

	public function insert(pos:Int, value:ASAny):Void {
		data.insert(pos, value);
	}

	public function insertAt(pos:Int, value:ASAny):Void {
		data.insert(pos, value);
	}

	public function concat(...rest:ASAny):Array<ASAny> {
		var result = data.copy();
		for (value in rest) {
			if (Std.isOfType(value, ASArrayBase)) {
				var other:ASArrayBase = cast value;
				for (item in other.data) {
					result.push(item);
				}
			} else if (Std.isOfType(value, Array)) {
				var otherArray:Array<ASAny> = cast value;
				for (item in otherArray) {
					result.push(item);
				}
			} else {
				result.push(value);
			}
		}
		return result;
	}

	public function join(?sep:String):String {
		return joinWithSeparator(sep == null ? "," : sep);
	}

	public function reverse():ASArrayBase {
		data.reverse();
		return this;
	}

	public function slice(?startIndex:Int, ?endIndex:Int):Array<ASAny> {
		var start = startIndex == null ? 0 : startIndex;
		if (endIndex == null) {
			return data.slice(start);
		}
		return data.slice(start, endIndex);
	}

	public function splice(startIndex:Int, ?deleteCount:Int, ...rest:ASAny):Array<ASAny> {
		var values:Array<ASAny> = rest;
		if (deleteCount == null) {
			return ASCompat.arraySpliceAll(data, startIndex);
		}
		if (values.length == 0) {
			return data.splice(startIndex, deleteCount);
		}
		return ASCompat.arraySplice(data, startIndex, deleteCount, values);
	}

	public function sort(?compareOrOptions:Dynamic, ?options:Int):Dynamic {
		if (compareOrOptions == null) {
			data.sort(Reflect.compare);
			return this;
		}
		if (Reflect.isFunction(compareOrOptions)) {
			data.sort(cast compareOrOptions);
			return this;
		}
		var opt = readSortOptions(compareOrOptions);
		if (opt != null) {
			var result = ASCompat.ASArray.sortWithOptions(data, opt);
			if ((opt & ASCompat.ASArray.RETURNINDEXEDARRAY) != 0) {
				return result;
			}
		}
		return this;
	}

	public function sortOn(fieldName:Dynamic, ?options:Dynamic):Dynamic {
		var opts = options == null ? 0 : options;
		var result = ASCompat.ASArray.sortOn(data, fieldName, opts);
		if (hasReturnIndexed(opts)) {
			return result;
		}
		return this;
	}

	public function indexOf(search:ASAny, ?fromIndex:Int):Int {
		var len = data.length;
		var start = fromIndex == null ? 0 : fromIndex;
		if (start < 0) {
			start = len + start;
			if (start < 0) {
				start = 0;
			}
		}
		for (i in start...len) {
			if (data[i] == search) {
				return i;
			}
		}
		return -1;
	}

	public function lastIndexOf(search:ASAny, ?fromIndex:Int):Int {
		var len = data.length;
		if (len == 0) {
			return -1;
		}
		var start = fromIndex == null ? len - 1 : fromIndex;
		if (start < 0) {
			start = len + start;
		}
		if (start >= len) {
			start = len - 1;
		}
		var i = start;
		while (i >= 0) {
			if (data[i] == search) {
				return i;
			}
			i--;
		}
		return -1;
	}

	public function forEach(callback:Dynamic, ?thisObject:Dynamic):Void {
		for (i in 0...data.length) {
			callCallback(callback, thisObject, data[i], i);
		}
	}

	public function map(callback:Dynamic, ?thisObject:Dynamic):Array<ASAny> {
		var result:Array<ASAny> = [];
		for (i in 0...data.length) {
			result.push(callCallback(callback, thisObject, data[i], i));
		}
		return result;
	}

	public function filter(callback:Dynamic, ?thisObject:Dynamic):Array<ASAny> {
		var result:Array<ASAny> = [];
		for (i in 0...data.length) {
			if (callCallback(callback, thisObject, data[i], i)) {
				result.push(data[i]);
			}
		}
		return result;
	}

	public function every(callback:Dynamic, ?thisObject:Dynamic):Bool {
		for (i in 0...data.length) {
			if (!callCallback(callback, thisObject, data[i], i)) {
				return false;
			}
		}
		return true;
	}

	public function some(callback:Dynamic, ?thisObject:Dynamic):Bool {
		for (i in 0...data.length) {
			if (callCallback(callback, thisObject, data[i], i)) {
				return true;
			}
		}
		return false;
	}

	public function toString():String {
		return join(",");
	}

	public function toLocaleString():String {
		var parts:Array<String> = [];
		for (item in data) {
			var dyn:Dynamic = item;
			if (dyn == null) {
				parts.push("");
				continue;
			}
			if (Reflect.hasField(dyn, "toLocaleString")) {
				var method = Reflect.field(dyn, "toLocaleString");
				if (Reflect.isFunction(method)) {
					parts.push(Std.string(Reflect.callMethod(dyn, method, [])));
					continue;
				}
			}
			parts.push(Std.string(dyn));
		}
		return parts.join(",");
	}

	function joinWithSeparator(sep:String):String {
		var parts:Array<String> = [];
		for (item in data) {
			var dyn:Dynamic = item;
			parts.push(dyn == null ? "" : Std.string(dyn));
		}
		return parts.join(sep);
	}

	function callCallback(callback:Dynamic, thisObject:Dynamic, item:ASAny, index:Int):Dynamic {
		var target = thisObject != null ? thisObject : this;
		return Reflect.callMethod(target, callback, [item, index, this]);
	}

	static function readSortOptions(value:Dynamic):Null<Int> {
		if (value == null) {
			return null;
		}
		if (Std.isOfType(value, Int)) {
			return value;
		}
		if (Std.isOfType(value, Float)) {
			var f:Float = value;
			if (!Math.isNaN(f) && Math.floor(f) == f) {
				return Std.int(f);
			}
		}
		return null;
	}

	static function hasReturnIndexed(options:Dynamic):Bool {
		var opt = readSortOptions(options);
		if (opt != null) {
			return (opt & ASCompat.ASArray.RETURNINDEXEDARRAY) != 0;
		}
		if (Std.isOfType(options, Array)) {
			var values:Array<Dynamic> = cast options;
			for (value in values) {
				var item = readSortOptions(value);
				if (item != null && (item & ASCompat.ASArray.RETURNINDEXEDARRAY) != 0) {
					return true;
				}
			}
		}
		return false;
	}
}
