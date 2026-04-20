#if openfl
private typedef Dictionary<K,V> = openfl.utils.Dictionary<K,V>;
#else
private typedef Dictionary<K,V> = flash.utils.Dictionary;
#end

abstract ASDictionary<K,V>(Dictionary<K,V>) from Dictionary<K,V> to Dictionary<K,V> { //TODO: remove implicit cast?
	#if !flash
	static final primitiveStore:haxe.ds.ObjectMap<Dynamic, haxe.ds.StringMap<Dynamic>> = new haxe.ds.ObjectMap();

	static inline function isPrimitiveKey(key:Dynamic):Bool {
		return Std.isOfType(key, String) || Std.isOfType(key, Int) || Std.isOfType(key, Float) || Std.isOfType(key, Bool);
	}

	static function primitiveKeyId(key:Dynamic):String {
		if (Std.isOfType(key, Float)) {
			var n:Float = key;
			if (Math.isNaN(n)) return "NaN";
			if (!Math.isFinite(n)) return n > 0 ? "Infinity" : "-Infinity";
		}
		// Match Flash Dictionary semantics for primitive keys:
		// numeric/string/bool keys are effectively compared by string form.
		return ASCompat.toString(key);
	}

	inline function getPrimitiveEntries(createIfMissing:Bool):Null<haxe.ds.StringMap<Dynamic>> {
		var mapKey:Dynamic = this;
		var entries = primitiveStore.get(mapKey);
		if (entries == null && createIfMissing) {
			entries = new haxe.ds.StringMap<Dynamic>();
			primitiveStore.set(mapKey, entries);
		}
		return entries;
	}
	#end

	public extern inline function new(weakKeys : Bool = false) {
		this = new Dictionary<K,V>(weakKeys);
	}

	@:op([]) public inline function get(key:K):Null<V> {
		#if flash
		return untyped this[key];
		#else
		var result:Dynamic = null;
		if (isPrimitiveKey(key)) {
			var entries = getPrimitiveEntries(false);
			if (entries != null) {
				var entry:Dynamic = entries.get(primitiveKeyId(key));
				if (entry != null) {
					result = entry.value;
				} else {
					#if js
					result = js.Syntax.code("undefined");
					#else
					result = ASCompat.UNDEFINED;
					#end
				}
			} else {
				#if js
				result = js.Syntax.code("undefined");
				#else
				result = ASCompat.UNDEFINED;
				#end
			}
		} else {
			#if cpp
			result = this.exists(key) ? this.get(key) : ASCompat.UNDEFINED;
			#elseif js
			result = this.exists(key) ? this.get(key) : js.Syntax.code("undefined");
			#else
			result = this.get(key);
			#end
		}
		return cast result;
		#end
	}

	@:op([]) public inline function set(key:K, value:V):Null<V> {
		#if flash
		return untyped this[key] = value;
		#else
		var result:Dynamic = null;
		if (isPrimitiveKey(key)) {
			var entries = getPrimitiveEntries(true);
			entries.set(primitiveKeyId(key), {key: key, value: value});
			result = value;
		} else {
			result = this.set(key, value);
		}
		return cast result;
		#end
	}

	public inline function exists(key:K):Bool {
		#if flash
		return untyped __in__(key, this);
		#else
		var result = false;
		if (isPrimitiveKey(key)) {
			var entries = getPrimitiveEntries(false);
			result = entries != null && entries.exists(primitiveKeyId(key));
		} else {
			result = this.exists(key);
		}
		return result;
		#end
	}

	public inline function hasOwnProperty(key:K):Bool {
		return exists(key);
	}

	public inline function remove(key:K):Bool {
		#if flash
		return untyped __delete__(this, key);
		#else
		var result = false;
		if (isPrimitiveKey(key)) {
			var entries = getPrimitiveEntries(false);
			result = entries != null && entries.remove(primitiveKeyId(key));
		} else {
			result = this.remove(key);
		}
		return result;
		#end
	}

	public inline function keys():Iterator<K> {
		#if flash
		return new NativePropertyIterator<K>(this);
		#else
		var result:Dynamic = null;
		var entries = getPrimitiveEntries(false);
		if (entries == null || !entries.keys().hasNext()) {
			result = this.iterator();
		} else {
			var merged:Array<K> = [for (k in this.iterator()) k];
			for (entry in entries) {
				merged.push(cast entry.key);
			}
			result = merged.iterator();
		}
		return cast result;
		#end
	}

	public inline function iterator():Iterator<V> {
		#if flash
		return new NativeValueIterator<V>(this);
		#else
		var result:Dynamic = null;
		var entries = getPrimitiveEntries(false);
		if (entries == null || !entries.keys().hasNext()) {
			result = this.each();
		} else {
			var merged:Array<V> = [for (v in this.each()) v];
			for (entry in entries) {
				merged.push(cast entry.value);
			}
			result = merged.iterator();
		}
		return cast result;
		#end
	}

	public inline function keyValueIterator():KeyValueIterator<K,V> {
		#if flash
		return cast new NativePropertyValueIterator<K,V>(this);
		#else
		var pairs:Array<{key:K, value:V}> = [for (key in keys()) {key: key, value: this[key]}];
		return cast pairs.iterator();
		#end
	}

	public static inline function asDictionary<K,V>(v:Any):Null<Dictionary<K,V>> {
		#if flash
		return flash.Lib.as(v, flash.utils.Dictionary);
		#else
		return if (Std.isOfType(v, haxe.Constraints.IMap)) v else null;
		#end
	}

	public static final type = #if flash flash.utils.Dictionary #else haxe.Constraints.IMap #end;
}
