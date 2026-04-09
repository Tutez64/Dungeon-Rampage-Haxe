package compat;
#if js
import js.lib.RegExp.RegExpMatch;
#end
import haxe.extern.EitherType;
import haxe.Constraints.Function;

private typedef RegExpImpl = #if js js.lib.RegExp #elseif flash flash.utils.RegExp #else Dynamic #end;

class RegExp {
	#if (!js && !flash)
	var regex:EReg;
	var global:Bool;
	#end

	#if (js || flash)
	var impl:RegExpImpl;
	public var lastIndex(get, set):Int;
	inline function get_lastIndex():Int return impl.lastIndex;
	inline function set_lastIndex(v:Int):Int return impl.lastIndex = v;
	#else
	public var lastIndex:Int = 0;
	#end

	public function new(pattern:String, options = "") {
		#if (js || flash)
		impl = new RegExpImpl(pattern, options);
		#else
		global = options.indexOf("g") >= 0;
		regex = new EReg(pattern, options);
		#end
	}

	public function exec(s:String):RegExpResult {
		#if js
		return impl.exec(s);
		#elseif flash
		return impl.exec(s);
		#else
		var start = global ? lastIndex : 0;
		if (!regex.matchSub(s, start)) {
			if (global) lastIndex = 0;
			return null;
		}
		var pos = regex.matchedPos();
		if (global) {
			lastIndex = pos.pos + (pos.len > 0 ? pos.len : 1);
		}
		return [regex.matched(0)];
		#end
	}

	public function test(s:String):Bool {
		#if (js || flash)
		return impl.test(s);
		#else
		return exec(s) != null;
		#end
	}

	public function match(s:String):Array<String> {
		#if js
		var match = (cast s).match(impl);
		return if (match == null) [] else match;
		#elseif flash
		return (cast s).match(impl);
		#else
		if (!global) {
			var result = exec(s);
			return result == null ? [] : cast result;
		}
		var out:Array<String> = [];
		var index = 0;
		while (regex.matchSub(s, index)) {
			var pos = regex.matchedPos();
			out.push(regex.matched(0));
			index = pos.pos + (pos.len > 0 ? pos.len : 1);
			if (index > s.length) break;
		}
		lastIndex = 0;
		return out;
		#end
	}

	public function search(s:String):Int {
		#if (js || flash)
		return (cast s).search(impl);
		#else
		return if (regex.match(s)) regex.matchedPos().pos else -1;
		#end
	}

	// TODO: have separate function for String and Function values of `by`?
	public function replace(s:String, by:EitherType<String, Function>):String {
		#if (js || flash)
		return (cast s).replace(impl, by);
		#else
		if (Reflect.isFunction(by)) {
			var fn:Dynamic = by;
			if (!regex.matchSub(s, 0)) return s;
			var pos = regex.matchedPos();
			var repl = Std.string(Reflect.callMethod(null, fn, [regex.matched(0), pos.pos, s]));
			return s.substr(0, pos.pos) + repl + s.substr(pos.pos + pos.len);
		}
		return regex.replace(s, cast by);
		#end
	}

	public function split(s:String):Array<String> {
		#if (js || flash)
		return (cast s).split(impl);
		#else
		return regex.split(s);
		#end
	}
}

#if js
abstract RegExpResult(RegExpMatch) from RegExpMatch to RegExpMatch {
	@:to public function toString():Null<String> return this != null ? this[0] : null;
}
#elseif flash
typedef RegExpResult = Dynamic;
#else
typedef RegExpResult = Array<String>;
#end
