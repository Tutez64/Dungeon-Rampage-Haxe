@:callable // TODO it's a bit unsafe because @:callable takes and returns Dynamic, not ASAny
           // I'm not sure how much can we do about it, maybe wrap the TTAny arguments and the return value in ASAny on the converter level?
abstract ASAny(Dynamic)
	from Dynamic
{
	public inline function new() this = cast {};

	@:noCompletion
	public inline function ___keys() {
		#if flash
		return new NativePropertyIterator<ASAny>(this);
		#else
		return (cast this : haxe.DynamicAccess<ASAny>).keys();
		#end
	}

	@:to public inline function iterator() {
		#if flash
		return new NativeValueIterator<ASAny>(this);
		#else
		return (cast this : haxe.DynamicAccess<ASAny>).iterator();
		#end
	}

	public function hasOwnProperty(name:String):Bool {
		return ASCompat.hasProperty(this, name);
	}

	#if flash
	@:to public function ___toString():String return cast this;
	@:to function ___toBool():Bool return cast this;
	@:to function ___toFloat():Float return cast this;
	@:to function ___toInt():Int return cast this;
	#elseif js
	@:to public inline function ___toString():String return if (this == null) null else "" + this;
	@:to inline function ___toBool():Bool return js.Syntax.code("Boolean")(this);
	@:to inline function ___toFloat():Float return js.Syntax.code("Number")(this);
	@:to inline function ___toInt():Int return Std.int(___toFloat());
	#else
	@:to public inline function ___toString():String return if (this == null) null else ASCompat.toString(this);

	@:to function ___toBool():Bool {
		return ASCompat.toBool(this);
	}

	@:to function ___toFloat():Float {
		return ASCompat.toNumber(this);
	}

	@:to function ___toInt():Int {
		var n = ASCompat.toNumber(this);
		return if (Math.isNaN(n)) 0 else Std.int(n);
	}
	#end

	@:to inline function ___toOther():Dynamic {
		return this;
	}

	// use use native equality check, because AS3 and JS behave the same
	// but if we want to build for other targets, we gotta implement the loose equality crap
	// (or not, because there should be no ASAny in the final code)
	@:op(a == b) inline function ___eq(that:Dynamic):Bool return this == that;
	@:op(a != b) inline function ___neq(that:Dynamic):Bool return this != that;

	@:op(a.b) inline function ___get(name:String):ASAny return ASAny.getPropertyOrBoundMethod(this, name);

	#if flash inline #end
	public static function getPropertyOrBoundMethod(obj:Any, name:String):ASAny {
		var handled = false;
		var result:ASAny = null;
		if (Std.isOfType(obj, ASArrayBase)) {
			var index = parseArrayIndex(name);
			if (index != null) {
				result = (cast obj : ASArrayBase).get(index);
				handled = true;
			}
		}
		if (!handled) {
			#if flash
			result = ASCompat.getProperty(obj, name);
			#elseif js
			var value:Dynamic = ASCompat.getProperty(obj, name);
			if (Reflect.isFunction(value)) {
				result = value.bind(obj); // TODO: maybe we should (ab)use Haxe/JS $bind here for caching the bound methods?
			} else {
				result = value;
			}
			#else
			var value:Dynamic = ASCompat.getProperty(obj, name);
			if (Reflect.isFunction(value)) {
				result = Reflect.makeVarArgs(function(args:Array<Dynamic>):Dynamic {
					return Reflect.callMethod(obj, value, args);
				});
			} else {
				result = value;
			}
			#end
		}
		return result;
	}

	@:op(a.b) function ___set(name:String, value:ASAny):ASAny {
		if (Std.isOfType(this, ASArrayBase)) {
			var index = parseArrayIndex(name);
			if (index != null) {
				(cast this : ASArrayBase).set(index, value);
				return value;
			}
		}
		return ASCompat.setProperty(this, name, value);
	}

	@:op(!a) function __not():Bool {
		return !___toBool();
	}

	@:op(a || b) static inline function __orBool(a:Bool, b:ASAny):ASAny {
		return if (a) a else b;
	}

	@:op(a || b) static inline function __or(a:ASAny, b:ASAny):ASAny {
		return if (a.___toBool()) a else b;
	}

	@:op(a && b) static inline function __andBool(a:Bool, b:ASAny):ASAny {
		return if (a) b else a;
	}

	@:op(a && b) static inline function __and(a:ASAny, b:ASAny):ASAny {
		return if (a.___toBool()) b else a;
	}

	// TODO: this (with Dynamic) will only really work on JS and Flash, but oh well
	#if (flash || js)
	@:op(a - b) static inline function ___subAny(a:ASAny, b:ASAny):ASAny return (a:Dynamic) - (b:Dynamic);
	@:op(a + b) static inline function ___addAny(a:ASAny, b:ASAny):ASAny return (a:Dynamic) + (b:Dynamic);
	@:op(a / b) static inline function ___divAny(a:ASAny, b:ASAny):ASAny return (a:Dynamic) / (b:Dynamic);
	@:op(a * b) static inline function ___mulAny(a:ASAny, b:ASAny):ASAny return (a:Dynamic) * (b:Dynamic);
	#else
	@:op(a + b) static inline function ___addAny(a:ASAny, b:ASAny):ASAny {
		var left:Dynamic = a;
		var right:Dynamic = b;
		if (Std.isOfType(left, String) || Std.isOfType(right, String)) {
			return cast (ASCompat.toString(left) + ASCompat.toString(right));
		}
		return cast (ASCompat.toNumber(left) + ASCompat.toNumber(right));
	}
	@:op(a - b) static inline function ___subAny(a:ASAny, b:ASAny):ASAny return cast (ASCompat.toNumber(a) - ASCompat.toNumber(b));
	@:op(a / b) static inline function ___divAny(a:ASAny, b:ASAny):ASAny return cast (ASCompat.toNumber(a) / ASCompat.toNumber(b));
	@:op(a * b) static inline function ___mulAny(a:ASAny, b:ASAny):ASAny return cast (ASCompat.toNumber(a) * ASCompat.toNumber(b));
	#end

	@:op(a > b) static function ___gt(a:ASAny, b:Float):Bool return a.___toFloat() > b;
	@:op(a < b) static function ___lt(a:ASAny, b:Float):Bool return a.___toFloat() < b;
	@:op(a >= b) static function ___gte(a:ASAny, b:Float):Bool return a.___toFloat() >= b;
	@:op(a <= b) static function ___lte(a:ASAny, b:Float):Bool return a.___toFloat() <= b;

	@:op(a > b) static function ___gt2(a:Float, b:ASAny):Bool return a > b.___toFloat();
	@:op(a < b) static function ___lt2(a:Float, b:ASAny):Bool return a < b.___toFloat();
	@:op(a >= b) static function ___gte2(a:Float, b:ASAny):Bool return a >= b.___toFloat();
	@:op(a <= b) static function ___lte2(a:Float, b:ASAny):Bool return a <= b.___toFloat();

	@:op([]) function ___arrayGet(name:ASAny):ASAny {
		if (Std.isOfType(this, Array)) {
			var index = parseArrayIndex(ASCompat.toString(name));
			if (index != null) {
				return (cast this : Array<Dynamic>)[index];
			}
		}
		if (Std.isOfType(this, ASArrayBase)) {
			var index = parseArrayIndex(ASCompat.toString(name));
			if (index != null) {
				return (cast this : ASArrayBase).get(index);
			}
		}

		// Preserve object keys for Dictionary access (important on cpp target).
		var dict = ASDictionary.asDictionary(this);
		if (dict != null) {
			#if flash
			return (cast this : ASDictionary<Dynamic, Dynamic>)[name];
			#else
			return (cast dict : haxe.Constraints.IMap<Dynamic, Dynamic>).get(name);
			#end
		}

		return ASAny.getPropertyOrBoundMethod(this, ASCompat.toString(name));
	}

	@:op([]) function ___arraySet(name:ASAny, value:ASAny):ASAny {
		if (Std.isOfType(this, Array)) {
			var index = parseArrayIndex(ASCompat.toString(name));
			if (index != null) {
				(cast this : Array<Dynamic>)[index] = value;
				return value;
			}
		}
		if (Std.isOfType(this, ASArrayBase)) {
			var index = parseArrayIndex(ASCompat.toString(name));
			if (index != null) {
				(cast this : ASArrayBase).set(index, value);
				return value;
			}
		}

		// Preserve object keys for Dictionary access (important on cpp target).
		var dict = ASDictionary.asDictionary(this);
		if (dict != null) {
			#if flash
			(cast this : ASDictionary<Dynamic, Dynamic>)[name] = value;
			#else
			(cast dict : haxe.Constraints.IMap<Dynamic, Dynamic>).set(name, value);
			#end
			return value;
		}

		return ASCompat.setProperty(this, ASCompat.toString(name), value);
	}

	static function parseArrayIndex(name:String):Null<Int> {
		if (name == null) {
			return null;
		}
		var length = name.length;
		if (length == 0) {
			return null;
		}
		if (length > 1 && name.charCodeAt(0) == 48) {
			return null;
		}
		for (i in 0...length) {
			var code = name.charCodeAt(i);
			if (code < 48 || code > 57) {
				return null;
			}
		}
		return Std.parseInt(name);
	}
}
