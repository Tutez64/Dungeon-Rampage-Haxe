#if macro
import haxe.macro.Expr;
#end

import haxe.Constraints.Function;
import haxe.ds.IntMap;
import haxe.ds.ObjectMap;
import haxe.ds.StringMap;
import haxe.Timer;
using StringTools;

class ASCompat {
	#if (flash || js)
	public static inline final UNDEFINED:Dynamic = null;
	#else
	public static final UNDEFINED:Dynamic = {__as3_undefined__: true};
	#end

	public static inline final MAX_INT = 2147483647;
	public static inline final MIN_INT = -2147483648;

	public static inline final MAX_FLOAT = 1.7976931348623157e+308;
	// Represents the smallest positive Number value in AS3 (Number.MIN_VALUE)
	public static inline final MIN_FLOAT = 4.9406564584124654e-324;

	static final reflectedFieldCacheByClass:StringMap<StringMap<Bool>> = new StringMap();

	#if !flash
	#if cpp
	static final dynamicPropertyStore:haxe.ds.WeakMap<{}, StringMap<Dynamic>> = new haxe.ds.WeakMap();
	#else
	static final dynamicPropertyStore:ObjectMap<{}, StringMap<Dynamic>> = new ObjectMap();
	#end
	#end

	public static inline function checkNullIteratee<T>(v:Null<T>, ?pos:haxe.PosInfos):Bool {
		if (v == null) {
			reportNullIteratee(pos);
			return false;
		}
		return true;
	}

	public static function iterateDynamicValues(v:Dynamic):Iterator<ASAny> {
		if (Std.isOfType(v, Array)) {
			return (cast v : Array<ASAny>).iterator();
		}
		if (Std.isOfType(v, ASArrayBase)) {
			return (cast v : ASArrayBase).iterator();
		}

		#if flash
		return new NativeValueIterator<ASAny>(v);
		#else
		return (cast v : haxe.DynamicAccess<ASAny>).iterator();
		#end
	}

	static function reportNullIteratee(pos:haxe.PosInfos) {
		haxe.Log.trace("FIXME: Null value passed as an iteratee for for-in/for-each expression!", pos);
	}

	public static inline function escape(s:String):String {
		#if flash
		return untyped __global__["escape"](s);
		#elseif js
		return js.Lib.global.escape(s);
		#else
		return StringTools.urlEncode(s);
		#end
	}

	public static inline function unescape(s:String):String {
		#if flash
		return untyped __global__["unescape"](s);
		#elseif js
		return js.Lib.global.unescape(s);
		#else
		return StringTools.urlDecode(s);
		#end
	}

	public static inline function describeType(value:Any):compat.XML {
		#if flash
		return flash.Lib.describeType(value);
		#else
		return describeTypeNonFlash(value);
		#end
	}

	public static inline function getQualifiedClassName(value:Any):String {
		#if flash
		return untyped __global__["flash.utils.getQualifiedClassName"](value);
		#else
		return getQualifiedClassNameNonFlash(value);
		#end
	}

	public static inline function showRedrawRegions(show:Bool, color:Int):Void {
		#if flash
		untyped __global__["flash.profiler.showRedrawRegions"](show, color);
		#end
	}

	#if !flash
	static function describeTypeNonFlash(value:Dynamic):compat.XML {
		var isClassObject = Std.isOfType(value, Class);
		var cls:Class<Dynamic> = isClassObject ? cast value : Type.getClass(value);
		var root = Xml.createElement("type");
		root.set("name", describeTypeName(value, cls, isClassObject));
		root.set("isDynamic", isDynamicType(value, cls, isClassObject) ? "true" : "false");
		root.set("isStatic", isClassObject ? "true" : "false");
		root.set("isFinal", "false");

		if (cls != null) {
			appendInheritance(root, cls);
			if (isClassObject) {
				appendMembers(root, cls, cls, true);
				var factory = Xml.createElement("factory");
				factory.set("type", Type.getClassName(cls));
				root.addChild(factory);
				appendMembers(factory, null, cls, false);
			} else {
				appendMembers(root, value, cls, false);
			}
		} else if (value != null) {
			appendDynamicMembers(root, value);
		}

		return cast root;
	}

	static function getQualifiedClassNameNonFlash(value:Dynamic):String {
		if (value == null) return "null";
		if (Std.isOfType(value, Int)) return "int";
		if (Std.isOfType(value, Float)) return "Number";
		if (Std.isOfType(value, Bool)) return "Boolean";
		if (Std.isOfType(value, String)) return "String";
		if (Std.isOfType(value, Array)) return "Array";
		if (Reflect.isFunction(value)) return "Function";
		if (Std.isOfType(value, Class)) {
			var className = Type.getClassName(cast value);
			return className != null ? className : "Class";
		}

		var cls = Type.getClass(value);
		if (cls != null) {
			var className = Type.getClassName(cls);
			if (isVectorClassName(className)) {
				return "__AS3__.vec::Vector.<*>";
			}
			return className != null ? className : "Object";
		}

		return "Object";
	}

	static inline function isVectorClassName(className:Null<String>):Bool {
		if (className == null) return false;
		return className == "flash.Vector" || className == "openfl.Vector" || className.indexOf("Vector") != -1;
	}

	static function describeTypeName(value:Dynamic, cls:Class<Dynamic>, isClassObject:Bool):String {
		if (value == null) return "null";
		if (isClassObject) return Type.getClassName(cast value);
		if (cls != null) return Type.getClassName(cls);
		return "Object";
	}

	static function isDynamicType(value:Dynamic, cls:Class<Dynamic>, isClassObject:Bool):Bool {
		if (value == null || isClassObject) return false;
		if (cls == null) return true;
		return Reflect.fields(value).length > 0;
	}

	static function appendInheritance(root:Xml, cls:Class<Dynamic>):Void {
		var current = Type.getSuperClass(cls);
		while (current != null) {
			var node = Xml.createElement("extendsClass");
			node.set("type", Type.getClassName(current));
			root.addChild(node);
			current = Type.getSuperClass(current);
		}
	}

	static function appendDynamicMembers(root:Xml, value:Dynamic):Void {
		for (field in Reflect.fields(value)) {
			var fieldValue = Reflect.field(value, field);
			if (Reflect.isFunction(fieldValue)) {
				root.addChild(createMethodNode(field, "Object"));
			} else {
				root.addChild(createVariableNode(field, "Object"));
			}
		}
	}

	static function appendMembers(root:Xml, value:Dynamic, cls:Class<Dynamic>, isStatic:Bool):Void {
		var declaredBy = Type.getClassName(cls);
		var fieldNames = isStatic ? Type.getClassFields(cls) : Type.getInstanceFields(cls);
		var accessorNames = new Map<String, {hasGetter:Bool, hasSetter:Bool}>();
		var ignored = new Map<String, Bool>();

		for (name in fieldNames) {
			if (name == "__name__" || name == "__constructs__" || name == "new") {
				ignored.set(name, true);
				continue;
			}
			if (StringTools.startsWith(name, "get_")) {
				var prop = name.substr(4);
				var state = accessorNames.exists(prop) ? accessorNames.get(prop) : {hasGetter: false, hasSetter: false};
				state.hasGetter = true;
				accessorNames.set(prop, state);
				ignored.set(name, true);
				continue;
			}
			if (StringTools.startsWith(name, "set_")) {
				var prop = name.substr(4);
				var state = accessorNames.exists(prop) ? accessorNames.get(prop) : {hasGetter: false, hasSetter: false};
				state.hasSetter = true;
				accessorNames.set(prop, state);
				ignored.set(name, true);
				continue;
			}
		}

		for (name => state in accessorNames) {
			root.addChild(createAccessorNode(name, state, declaredBy));
		}

		for (name in fieldNames) {
			if (ignored.exists(name)) {
				continue;
			}

			var shouldBeVariable = false;
			if (value != null && Reflect.hasField(value, name)) {
				shouldBeVariable = !Reflect.isFunction(Reflect.field(value, name));
			}

			if (shouldBeVariable) {
				root.addChild(createVariableNode(name, declaredBy));
			} else {
				root.addChild(createMethodNode(name, declaredBy));
			}
		}
	}

	static function createAccessorNode(name:String, state:{hasGetter:Bool, hasSetter:Bool}, declaredBy:String):Xml {
		var node = Xml.createElement("accessor");
		node.set("name", name);
		node.set("access", state.hasGetter && state.hasSetter ? "readwrite" : state.hasGetter ? "readonly" : "writeonly");
		node.set("type", "*");
		node.set("declaredBy", declaredBy);
		return node;
	}

	static function createVariableNode(name:String, declaredBy:String):Xml {
		var node = Xml.createElement("variable");
		node.set("name", name);
		node.set("type", "*");
		node.set("declaredBy", declaredBy);
		return node;
	}

	static function createMethodNode(name:String, declaredBy:String):Xml {
		var node = Xml.createElement("method");
		node.set("name", name);
		node.set("returnType", "*");
		node.set("declaredBy", declaredBy);
		return node;
	}
	#end

	#if flash
	// classObject is Any and not Class<Dynamic>, because in Flash we also want to pass Bool to it
	// this is also the reason this function is not automatically added to Globals.hx
	public static inline function registerClassAlias(aliasName:String, classObject:Any) {
		untyped __global__["flash.net.registerClassAlias"](aliasName, classObject);
	}
	#end

	// int(d), uint(d)
	public static inline function toInt(d:Dynamic):Int {
		#if flash
		return untyped __global__["int"](d);
		#else
		var n = toNumber(d);
		return if (Math.isNaN(n)) 0 else Std.int(n);
		#end
	}

	// Number(d)
	public static inline function toNumber(d:Dynamic):Float {
		#if flash
		return untyped __global__["Number"](d);
		#elseif js
		return js.Syntax.code("Number")(d);
		#else
		return toNumberNative(d);
		#end
	}

	// Number(obj.fieldName) - handles undefined fields correctly
	// When accessing a field on a Dynamic object, Haxe converts undefined to null
	// but AS3 Number(undefined) = NaN while Number(null) = 0
	public static function toNumberField(obj:Dynamic, fieldName:String):Float {
		#if flash
		// 1. Use Reflect.getProperty to ensure Haxe getters are called correctly.
		// Standard untyped access obj[fieldName] might return the raw backing field (0) instead of the getter value.
		var v:Dynamic = (obj == null) ? null : Reflect.getProperty(obj, fieldName);

		// 2. To match AS3, missing fields (undefined) must return NaN, but existing null fields must return 0.
		// Since both come back as null in Haxe, we use the __in__ operator to check existence.
		// return (missing) ? NaN : Number(v)
		return if (obj == null || (v == null && !untyped __in__(fieldName, obj))) Math.NaN else untyped __global__["Number"](v);
		#else
		if (fieldName == "length") {
			if (Std.isOfType(obj, Array)) return (cast obj : Array<Dynamic>).length;
			var getLen = Reflect.field(obj, "get_length");
			if (getLen != null && Reflect.isFunction(getLen)) {
				return toNumber(Reflect.callMethod(obj, getLen, []));
			}
		}
		if (obj == null) {
			return Math.NaN;
		}
		var value:Dynamic = null;
		try {
			value = Reflect.getProperty(obj, fieldName);
			// Native OpenFL objects often expose properties via getters/setters without Reflect.hasField.
			// Preserve explicit null getter results, and only fall through when the property is truly missing.
			if (value != null || hasReflectedProperty(obj, fieldName)) {
				return toNumber(value);
			}
		} catch (_:Dynamic) {
		}
		var dynamicProperties = getDynamicProperties(obj, false);
		if (dynamicProperties != null && dynamicProperties.exists(fieldName)) {
			return toNumber(dynamicProperties.get(fieldName));
		}
		return Math.NaN;
		#end
	}

	public static function getProperty(obj:Dynamic, fieldName:Dynamic):Dynamic {
		if (obj == null) {
			return null;
		}
		#if !flash
		var proxyGetter = Reflect.field(obj, "getProperty");
		if (proxyGetter != null && Reflect.isFunction(proxyGetter)) {
			return Reflect.callMethod(obj, proxyGetter, [fieldName]);
		}
		var name = propertyName(fieldName);
		if (name == "length" && Std.isOfType(obj, Array)) {
			return (cast obj : Array<Dynamic>).length;
		}
		var value:Dynamic = null;
		try {
			value = Reflect.getProperty(obj, name);
			// Preserve explicit null fields/getters; fallback only for missing properties.
			if (value != null || hasReflectedProperty(obj, name)) {
				return value;
			}
		} catch (_:Dynamic) {
		}
		// OpenFL native bindings (e.g. symbols from SWF) often expose timeline instances via children names.
		// Cache them so they remain reachable after being detached from the display list, like in Flash.
		var namedChild = getCachedNamedChildProperty(obj, name);
		if (namedChild != null) {
			return namedChild;
		}
		return value;
		#end
		return Reflect.getProperty(obj, propertyName(fieldName));
	}

	public static function setProperty(obj:Dynamic, fieldName:Dynamic, value:Dynamic):Dynamic {
		if (obj == null) {
			return value;
		}
		#if !flash
		var proxySetter = Reflect.field(obj, "setProperty");
		if (proxySetter != null && Reflect.isFunction(proxySetter)) {
			Reflect.callMethod(obj, proxySetter, [fieldName, value]);
			return value;
		}
		var name = propertyName(fieldName);
		var setError:Dynamic = null;
		try {
			Reflect.setProperty(obj, name, value);
			return value;
		} catch (e:Dynamic) {
			setError = e;
		}
		if (!hasReflectedProperty(obj, name) && setDynamicProperty(obj, name, value)) {
			return value;
		}
		throw setError;
		#end
		Reflect.setProperty(obj, propertyName(fieldName), value);
		return value;
	}

	public static function deleteProperty(obj:Dynamic, fieldName:Dynamic):Bool {
		if (obj == null) {
			return true;
		}
		#if !flash
		var proxyDelete = Reflect.field(obj, "deleteProperty");
		if (proxyDelete != null && Reflect.isFunction(proxyDelete)) {
			return toBool(Reflect.callMethod(obj, proxyDelete, [fieldName]));
		}
		var name = propertyName(fieldName);
		var deleted = false;
		try {
			deleted = Reflect.deleteField(obj, name);
		} catch (_:Dynamic) {
		}
		var dynamicProperties = getDynamicProperties(obj, false);
		if (dynamicProperties != null && dynamicProperties.exists(name)) {
			dynamicProperties.remove(name);
			return true;
		}
		return deleted;
		#end
		return Reflect.deleteField(obj, propertyName(fieldName));
	}

	public static function hasProperty(obj:Dynamic, fieldName:Dynamic):Bool {
		if (obj == null) {
			return false;
		}
		var name = propertyName(fieldName);
		if (hasReflectedProperty(obj, name)) {
			return true;
		}
		#if !flash
		var dynamicProperties = getDynamicProperties(obj, false);
		if (dynamicProperties != null && dynamicProperties.exists(name)) {
			return true;
		}
		if (getCachedNamedChildProperty(obj, name) != null) {
			return true;
		}
		#end
		return false;
	}

	static inline function propertyName(fieldName:Dynamic):String {
		return Std.string(fieldName);
	}

	static function hasReflectedProperty(obj:Dynamic, name:String):Bool {
		try {
			if (Reflect.hasField(obj, name)) {
				return true;
			}
		} catch (_:Dynamic) {
		}
		try {
			var clazz = Type.getClass(obj);
			if (clazz != null) {
				var className = Type.getClassName(clazz);
				if (className != null) {
					var cachedFields = reflectedFieldCacheByClass.get(className);
					if (cachedFields == null) {
						cachedFields = new StringMap<Bool>();
						var fields = Type.getInstanceFields(clazz);
						for (field in fields) {
							cachedFields.set(field, true);
						}
						reflectedFieldCacheByClass.set(className, cachedFields);
					}
					return cachedFields.exists(name) || cachedFields.exists("get_" + name) || cachedFields.exists("set_" + name);
				}
			}
		} catch (_:Dynamic) {
		}
		return false;
	}

	#if !flash
	static function getCachedNamedChildProperty(obj:Dynamic, name:String):Dynamic {
		var dynamicProperties = getDynamicProperties(obj, false);
		var cachedValue:Dynamic = null;
		if (dynamicProperties != null && dynamicProperties.exists(name)) {
			cachedValue = dynamicProperties.get(name);
		}
		var getChildByName = Reflect.field(obj, "getChildByName");
		if (getChildByName != null && Reflect.isFunction(getChildByName)) {
			try {
				var child = Reflect.callMethod(obj, getChildByName, [name]);
				if (child != null) {
					if (cachedValue != child) {
						setDynamicProperty(obj, name, child);
					}
					return child;
				}
			} catch (_:Dynamic) {
			}
		}
		return cachedValue;
	}

	static function getDynamicProperties(obj:Dynamic, createIfMissing:Bool):Null<StringMap<Dynamic>> {
		if (!canUseDynamicPropertyStore(obj)) {
			return null;
		}
		var key:{} = cast obj;
		var dynamicProperties = dynamicPropertyStore.get(key);
		if (dynamicProperties == null && createIfMissing) {
			dynamicProperties = new StringMap<Dynamic>();
			dynamicPropertyStore.set(key, dynamicProperties);
		}
		return dynamicProperties;
	}

	static function setDynamicProperty(obj:Dynamic, name:String, value:Dynamic):Bool {
		var dynamicProperties = getDynamicProperties(obj, true);
		if (dynamicProperties == null) {
			return false;
		}
		dynamicProperties.set(name, value);
		return true;
	}

	static function canUseDynamicPropertyStore(obj:Dynamic):Bool {
		return !Std.isOfType(obj, String) && !Std.isOfType(obj, Int) && !Std.isOfType(obj, Float) && !Std.isOfType(obj, Bool);
	}
	#end

	// Boolean(d)
	public static inline function toBool(d:Dynamic):Bool {
		#if flash
		return untyped __global__["Boolean"](d);
		#elseif js
		return js.Syntax.code("Boolean")(d);
		#else
		return toBoolNative(d);
		#end
	}

	// String(d)
	public static inline function toString(d:Dynamic):String {
		#if flash
		return untyped __global__["String"](d);
		#elseif js
		return js.Syntax.code("String")(d);
		#else
		if (isUndefinedValue(d)) {
			return "undefined";
		}
		if (Std.isOfType(d, Float) && Math.isNaN(cast d)) return "NaN";
		return Std.string(d);
		#end
	}

	public static inline function asString(v:Any):Null<String> {
		return if (Std.isOfType(v, String)) cast v else null;
	}

	public static inline function asNumber(v:Any):Null<Float> {
		return if (Std.isOfType(v, Float)) cast v else null;
	}

	public static inline function asInt(v:Any):Null<Int> {
		return if (Std.isOfType(v, Int)) cast v else null;
	}

	public static inline function asUint(v:Any):Null<Int> {
		#if flash
		return if (untyped __is__(v, untyped __global__["uint"])) cast v else null;
		#else
		return if (Std.isOfType(v, Int) && (cast v : Int) >= 0) cast v else null;
		#end
	}

	public static inline function asBool(v:Any):Null<Bool> {
		#if flash
		return if (untyped __is__(v, untyped __global__["Boolean"])) cast v else null;
		#elseif js
		return if (js.Syntax.typeof(v) == "boolean") cast v else null;
		#else
		return if (Std.isOfType(v, Bool)) cast v else null;
		#end
	}

	public static inline function asXML(v:Any):Null<compat.XML> {
		#if flash
		return if (Std.isOfType(v, flash.xml.XML)) cast v else null;
		#else
		return if (Std.isOfType(v, Xml)) cast v else null;
		#end
	}

	public static function asXMLList(v:Any):Null<compat.XMLList> {
		#if flash
		return if (Std.isOfType(v, flash.xml.XMLList)) cast v else null;
		#else
		if (Std.isOfType(v, Array)) {
			var list:compat.XMLList = cast (v : Dynamic);
			return list;
		}
		return null;
		#end
	}

	public static inline function isByteArray(v:Any):Bool {
		#if flash
		return Std.isOfType(v, flash.utils.ByteArray);
		#else
		return Std.isOfType(v, openfl.utils.ByteArray.ByteArrayData);
		#end
	}

	public static inline function asByteArray(v:Dynamic):flash.utils.ByteArray {
		#if flash
		return flash.Lib.as(v, flash.utils.ByteArray);
		#else
		return cast flash.Lib.as(v, openfl.utils.ByteArray.ByteArrayData);
		#end
	}

	public static inline function typeof(value:Dynamic):String {
		#if js
		return js.Syntax.typeof(value);
		#elseif flash
		return untyped __typeof__(value);
		#else
		if (isUndefinedValue(value)) {
			return "undefined";
		}
		if (Std.isOfType(value, String)) {
			return "string";
		}
		return switch (Type.typeof(value)) {
			case TNull: "object";
			case TInt | TFloat: "number";
			case TBool: "boolean";
			case TObject | TClass(_) | TEnum(_): "object";
			case TFunction: "function";
			case TUnknown: "undefined";
		}
		#end
	}

	public static inline function isUndefinedValue(value:Dynamic):Bool {
		#if js
		return js.Syntax.code("typeof {0} === 'undefined'", value);
		#elseif flash
		return false;
		#else
		return value == UNDEFINED;
		#end
	}

	// Preserves AS3 behavior for loose null checks on Dictionary lookups:
	// missing key (undefined) should behave like null for `== null` / `!= null`.
	public static function dictionaryLookupEqNull(dict:Dynamic, key:Dynamic):Bool {
		if (dict == null) {
			return true;
		}
		#if flash
		if (!untyped __in__(key, dict)) {
			return true;
		}
		var value:Dynamic = untyped dict[key];
		return value == null || isUndefinedValue(value);
		#else
		try {
			var asDict:ASDictionary<Dynamic, Dynamic> = cast dict;
			if (!asDict.exists(cast key)) {
				return true;
			}
			var value:Dynamic = asDict[cast key];
			return value == null || isUndefinedValue(value);
		} catch (_:Dynamic) {
		}
		var fallback = getProperty(dict, key);
		return fallback == null || isUndefinedValue(fallback);
		#end
	}

	public static inline function dictionaryLookupNeNull(dict:Dynamic, key:Dynamic):Bool {
		return !dictionaryLookupEqNull(dict, key);
	}

	// Preserves AS3 behavior for loose null checks on map-style itemFor lookups.
	public static function mapItemForEqNull(map:Dynamic, key:Dynamic):Bool {
		if (map == null) {
			return true;
		}
		#if flash
		var hasKeyMethod:Dynamic = null;
		try {
			hasKeyMethod = untyped map.hasKey;
		} catch (_:Dynamic) {
		}
		if (hasKeyMethod != null) {
			var hasKeyValue = false;
			try {
				hasKeyValue = toBool(untyped map.hasKey(key));
			} catch (_:Dynamic) {
			}
			if (!hasKeyValue) {
				return true;
			}
		}
		var itemForMethod:Dynamic = null;
		try {
			itemForMethod = untyped map.itemFor;
		} catch (_:Dynamic) {
		}
		if (itemForMethod != null) {
			var value:Dynamic = null;
			try {
				value = untyped map.itemFor(key);
			} catch (_:Dynamic) {
				return true;
			}
			return value == null || isUndefinedValue(value);
		}
		return true;
		#else
		var hasKey = Reflect.field(map, "hasKey");
		if (hasKey != null && Reflect.isFunction(hasKey)) {
			if (!toBool(Reflect.callMethod(map, hasKey, [key]))) {
				return true;
			}
		}
		var itemFor = Reflect.field(map, "itemFor");
		if (itemFor != null && Reflect.isFunction(itemFor)) {
			var value = Reflect.callMethod(map, itemFor, [key]);
			return value == null || isUndefinedValue(value);
		}
		return true;
		#end
	}

	public static inline function mapItemForNeNull(map:Dynamic, key:Dynamic):Bool {
		return !mapItemForEqNull(map, key);
	}

	public static inline function as<T>(v:Dynamic, c:Class<T>):T {
		return flash.Lib.as(v, c);
	}

	public static inline function dynamicAs<T>(v:Dynamic, c:Class<T>):T {
		return flash.Lib.as(v, c);
	}

	public static inline function reinterpretAs<T>(v:Dynamic, c:Class<T>):T {
		return flash.Lib.as(v, c);
	}

	public static inline function createInstance(cl:Dynamic, args:Array<Dynamic>):Dynamic {
		if (cl == null) {
			return null;
		}
		#if flash
		return Type.createInstance(cast cl, args);
		#else
		if (Std.isOfType(cl, Class)) {
			return Type.createInstance(cast cl, args);
		}
		// Generic factory protocol for non-Class values (e.g. runtime symbol proxies).
		// If an object exposes `create(args:Array<Dynamic>)`, use it.
		var factory = Reflect.field(cl, "create");
		if (factory != null && Reflect.isFunction(factory)) {
			return Reflect.callMethod(cl, factory, [args]);
		}
		if (Reflect.isFunction(cl)) {
			return Reflect.callMethod(null, cl, args);
		}
		return Type.createInstance(cast cl, args);
		#end
	}

	public static inline function toExponential(n:Float, ?digits:Int):String {
		#if (js || flash)
		return (cast n).toExponential(digits);
		#else
		return Std.string(n);
		#end
	}

	public static inline function toFixed(n:Float, ?digits:Int):String {
		#if (js || flash)
		return (cast n).toFixed(digits);
		#else
		if (digits == null) return Std.string(n);
		return toFixedNative(n, digits);
		#end
	}

	public static inline function toPrecision(n:Float, precision:Int):String {
		#if (js || flash)
		return (cast n).toPrecision(precision);
		#else
		if (precision <= 0) return Std.string(n);
		return Std.string(n);
		#end
	}

	public static inline function toRadix(n:Float, radix:Int = 10):String {
		#if (js || flash)
		return (cast n).toString(radix);
		#else
		if (radix == 10) return Std.string(n);
		var iv = Std.int(n);
		if (iv == 0) return "0";
		var neg = iv < 0;
		var value = if (neg) -iv else iv;
		var baseChars = "0123456789abcdefghijklmnopqrstuvwxyz";
		var out = "";
		while (value > 0) {
			var d = value % radix;
			out = baseChars.charAt(d) + out;
			value = Std.int(value / radix);
		}
		return if (neg) "-" + out else out;
		#end
	}

	public static inline function xmlToList(xml:compat.XML):compat.XMLList {
		#if flash
		var out:flash.xml.XMLList = new flash.xml.XMLList();
		if (xml != null) {
			untyped out[untyped out.length()] = xml;
		}
		return out;
		#else
		return if (xml == null) [] else [xml];
		#end
	}

	public static inline function filterXmlList(list:compat.XMLList, predicate:compat.XML->Bool):compat.XMLList {
		#if flash
		var out:flash.xml.XMLList = new flash.xml.XMLList();
		for (x in list) {
			if (predicate(x)) {
				untyped out[untyped out.length()] = x;
			}
		}
		return out;
		#else
		var out:Array<compat.XML> = [];
		for (x in list) {
			if (predicate(x)) {
				out.push(x);
			}
		}
		return out;
		#end
	}

	// TODO: this is temporary
	public static inline function thisOrDefault<T>(value:T, def:T):T {
		return if ((value : ASAny)) value else def;
	}

	public static inline function stringAsBool(s:Null<String>):Bool {
		return (s : ASAny);
	}

	public static inline function floatAsBool(f:Null<Float>):Bool {
		return (f : ASAny);
	}

	public static inline function intAsBool(i:Null<Int>):Bool {
		return (i : ASAny);
	}

	public static inline function allocArray<T>(length:Int):Array<T> {
		var a = new Array<T>();
		a.resize(length);
		return a;
	}

	public static inline function arraySetLength<T>(a:Array<T>, newLength:Int):Int {
		a.resize(newLength);
		return newLength;
	}

	public static inline function arraySpliceAll<T>(a:Array<T>, startIndex:Int):Array<T> {
		return a.splice(startIndex, a.length);
	}

	public static function arraySplice<T>(a:Array<T>, startIndex:Int, deleteCount:Int, ?values:Array<T>):Array<T> {
		var result = a.splice(startIndex, deleteCount);
		if (values != null) {
			for (i in 0...values.length) {
				a.insert(startIndex + i, values[i]);
			}
		}
		return result;
	}

	public static macro function vectorSpliceAll<T>(a:ExprOf<flash.Vector<T>>, startIndex:ExprOf<Int>):ExprOf<flash.Vector<T>>;

	public static macro function vectorSplice<T>(a:ExprOf<flash.Vector<T>>, startIndex:ExprOf<Int>, deleteCount:ExprOf<Int>, ?values:ExprOf<Array<T>>):ExprOf<flash.Vector<T>>;

	public static macro function vectorClass<T>(typecheck:Expr):ExprOf<Class<flash.Vector<T>>>;
	public static macro function asVector<T>(value:Expr, typecheck:Expr):ExprOf<Null<flash.Vector<T>>>;
	public static macro function isVector<T>(value:Expr, typecheck:Expr):ExprOf<Bool>;

	@:noCompletion public static inline function _asVector<T>(value:Any):Null<flash.Vector<T>> return if (_isVector(value)) value else null;
	@:noCompletion public static inline function _isVector(value:Any):Bool
	return (Reflect.hasField(value, '__array') && Reflect.hasField(value, 'fixed'))
		|| (Reflect.hasField(value, 'get_length') && Reflect.hasField(value, 'get') && Reflect.hasField(value, 'set'))
		|| {
			var cls = Type.getClass(value);
			var className = if (cls == null) null else Type.getClassName(cls);
			className != null && className.startsWith("openfl._Vector.");
		};

	public static inline function asFunction(v:Any):Null<ASFunction> {
		return if (Reflect.isFunction(v)) v else null;
	}

	public static function urlLoaderBytesAvailable(loader:Dynamic):UInt {
		if (loader == null) {
			return 0;
		}
		var bytesAvailable = Reflect.field(loader, "bytesAvailable");
		if (bytesAvailable != null) {
			return Std.int(toNumber(bytesAvailable));
		}
		var data = Reflect.field(loader, "data");
		if (data == null) {
			return 0;
		}
		if (Std.isOfType(data, haxe.io.Bytes)) {
			return cast(data, haxe.io.Bytes).length;
		}
		var text = toString(data);
		return if (text == null) 0 else text.length;
	}

	public static function urlLoaderReadUTFBytes(loader:Dynamic, length:UInt):String {
		if (loader == null) {
			return "";
		}
		var readUTFBytes = Reflect.field(loader, "readUTFBytes");
		if (readUTFBytes != null && Reflect.isFunction(readUTFBytes)) {
			try {
				// Prefer direct invocation for better cross-target behavior.
				return toString(untyped loader.readUTFBytes(length));
			} catch (_:Dynamic) {}
			try {
				return toString(Reflect.callMethod(loader, readUTFBytes, [length]));
			} catch (_:Dynamic) {}
		}
		var data = Reflect.field(loader, "data");
		if (data == null) {
			return "";
		}
		if (Std.isOfType(data, haxe.io.Bytes)) {
			var bytes:haxe.io.Bytes = cast data;
			var limit = Std.int(Math.min(length, bytes.length));
			return bytes.getString(0, limit);
		}
		var text = toString(data);
		if (text == null) {
			return "";
		}
		var limit = Std.int(length);
		if (limit <= 0) {
			return "";
		}
		return if (limit >= text.length) text else text.substr(0, limit);
	}

	/**
	 * Normalizes runtime values used for converted AS3 rest arguments.
	 * Generated code can reach this path through dynamic/callable calls where
	 * the rest container is not always a standard haxe.Rest instance.
	 */
	public static function restToArray(rest:Dynamic):Array<Dynamic> {
		if (rest == null) {
			return [];
		}
		if (Std.isOfType(rest, Array)) {
			return cast rest;
		}

		var toArray = Reflect.field(rest, "toArray");
		if (toArray != null && Reflect.isFunction(toArray)) {
			var converted:Dynamic = null;
			var hasConverted = false;
			try {
				// Prefer direct invocation for better cross-target behavior.
				converted = untyped rest.toArray();
				hasConverted = true;
			} catch (_:Dynamic) {}

			if (!hasConverted) {
				try {
					converted = Reflect.callMethod(rest, toArray, []);
					hasConverted = true;
				} catch (_:Dynamic) {}
			}

			if (hasConverted) {
				if (converted == null) {
					return [];
				}
				if (Std.isOfType(converted, Array)) {
					return cast converted;
				}
				return [converted];
			}
		}

		return [rest];
	}

	public static function pauseForGCIfCollectionImminent(?imminence:Float):Void {
		var threshold = normalizeGcImminence(imminence);
		#if flash
		#if air
		try {
			flash.system.System.pauseForGCIfCollectionImminent(threshold);
			return;
		} catch (_:Dynamic) {}
		#end
		try {
			flash.system.System.gc();
		} catch (_:Dynamic) {}
		#elseif cpp
		var reserved = cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_RESERVED);
		var current = cpp.vm.Gc.memInfo(cpp.vm.Gc.MEM_INFO_CURRENT);
		var pressure = if (reserved <= 0) 1.0 else clamp01(current / reserved);
		if (pressure >= threshold && shouldRunManualGcNow(threshold)) {
			cpp.vm.Gc.run(false);
			markManualGcRun();
		}
		#elseif (hl || neko || java || cs || php || python || lua)
		if (shouldRunManualGcNow(threshold)) {
			Sys.gc();
			markManualGcRun();
		}
		#elseif js
		if (shouldRunManualGcNow(threshold)) {
			var gcMethod = Reflect.field(js.Lib.global, "gc");
			if (gcMethod != null && Reflect.isFunction(gcMethod)) {
				Reflect.callMethod(js.Lib.global, gcMethod, []);
				markManualGcRun();
			}
		}
		#end
	}

	static inline function normalizeGcImminence(imminence:Null<Float>):Float {
		// Match AIR semantics:
		// - null or NaN => 0.75
		// - < 0 => 0.25
		// - > 1 => 1.0
		if (imminence == null || Math.isNaN(imminence)) return 0.75;
		if (imminence < 0) return 0.25;
		if (imminence > 1) return 1.0;
		return imminence;
	}

	static inline function clamp01(v:Float):Float {
		return if (v < 0) 0 else if (v > 1) 1 else v;
	}

	#if !flash
	static var _lastManualGcAt:Float = -1.0;

	static inline function markManualGcRun():Void {
		_lastManualGcAt = Timer.stamp();
	}

	static inline function shouldRunManualGcNow(threshold:Float):Bool {
		if (_lastManualGcAt < 0) return true;
		var elapsed = Timer.stamp() - _lastManualGcAt;
		return elapsed >= gcMinIntervalSeconds(threshold);
	}

	static inline function gcMinIntervalSeconds(threshold:Float):Float {
		// Lower threshold => more aggressive GC requests.
		return 0.1 + threshold * 4.9;
	}
	#end

	public static macro function setTimeout(closure:ExprOf<haxe.Constraints.Function>, delay:ExprOf<Float>, arguments:Array<Expr>):ExprOf<UInt>;

	public static inline function clearTimeout(id:UInt):Void {
		#if flash
		untyped __global__["flash.utils.clearTimeout"](id);
		#elseif js
		js.Browser.window.clearTimeout(id);
		#else
		_clearTimeoutNative(id);
		#end
	}

	public static macro function setInterval(closure:ExprOf<haxe.Constraints.Function>, delay:ExprOf<Float>, arguments:Array<Expr>):ExprOf<UInt>;

	public static inline function clearInterval(id:UInt):Void {
		#if flash
		untyped __global__["flash.utils.clearInterval"](id);
		#elseif js
		js.Browser.window.clearInterval(id);
		#else
		_clearIntervalNative(id);
		#end
	}

	public static inline function textFieldGetXMLText(field:flash.text.TextField, ?beginIndex:Int, ?endIndex:Int):String {
		#if flash
		if (beginIndex == null) {
			return untyped field.getXMLText();
		}
		if (endIndex == null) {
			return untyped field.getXMLText(beginIndex);
		}
		return untyped field.getXMLText(beginIndex, endIndex);
		#else
		var text = field.text;
		if (beginIndex == null) return text;
		if (endIndex == null) return text.substr(beginIndex);
		return text.substring(beginIndex, endIndex);
		#end
	}

	public static macro function processNull<T>(e:ExprOf<Null<T>>):ExprOf<T>;

	public static inline function processNullInt(v:Null<Int>):Int {
		#if flash
		return v;
		#else
		return cast v | 0;
		#end
	}

	public static inline function processNullFloat(v:Null<Float>):Float {
		#if flash
		return v;
		#else
		return toNumber(v);
		#end
	}

	public static inline function processNullBool(v:Null<Bool>):Bool {
		#if flash
		return v;
		#else
		return !!v;
		#end
	}

	/**
	 * https://github.com/HaxeFoundation/as3hx/blob/829f661777d0458c7902c4235a4c944de4c8cc6d/src/as3hx/Compat.hx#L114
	 */
	public static function parseInt(s:String, ?base:Int):Null<Int> {
		#if js
		if (base == null) base = s.indexOf("0x") == 0 ? 16 : 10;
		var v:Int = js.Syntax.code("parseInt({0}, {1})", s, base);
		return Math.isNaN(v) ? null : v;
		#elseif flash
		if (base == null) base = 0;
		var v:Int = untyped __global__["parseInt"](s, base);
		return Math.isNaN(v) ? null : v;
		#else
		var BASE = "0123456789abcdefghijklmnopqrstuvwxyz";
		if (base != null && (base < 2 || base > BASE.length))
			return throw 'invalid base ${base}, it must be between 2 and ${BASE.length}';
		s = s.trim().toLowerCase();
		var sign = if (s.startsWith("+")) {
			s = s.substring(1);
			1;
		} else if (s.startsWith("-")) {
			s = s.substring(1);
			-1;
		} else {
			1;
		};
		if (s.length == 0) return null;
		if (s.startsWith('0x')) {
			if (base != null && base != 16) return null; // attempting at converting a hex using a different base
			base = 16;
			s = s.substring(2);
		} else if (base == null) {
			base = 10;
		}
		var acc = 0;
		var chars = s.split("");
		for (c in chars) {
			var i = BASE.indexOf(c);
			if (i < 0 || i >= base) {
				break;
			}
			acc = (acc * base) + i;
		}
		return acc * sign;
		#end
	}

	// -------------------------------------------------------------------------
	// Dynamic array methods - for calling array methods on TTAny/ASAny objects
	// These methods handle array operations on dynamically-typed objects
	// -------------------------------------------------------------------------

	static function readDynamicIndex(index:Dynamic):Null<Int> {
		if (index == null) {
			return null;
		}
		if (Std.isOfType(index, Int)) {
			return index;
		}
		if (Std.isOfType(index, Float)) {
			var f:Float = cast index;
			if (Math.isNaN(f) || Math.floor(f) != f) {
				return null;
			}
			return Std.int(f);
		}
		if (Std.isOfType(index, String)) {
			var text:String = cast index;
			if (~/^-?\d+$/.match(text)) {
				return Std.parseInt(text);
			}
		}
		return null;
	}

	/**
	 * Reads obj[index] on dynamically-typed values while preserving array semantics
	 * when a prior dynamic lookup produced an Array/ASArrayBase/vector-like value.
	 * Falls back to normal dynamic property access for non-numeric indices.
	 */
	public static function dynGetIndex(obj:Dynamic, index:Dynamic):Dynamic {
		if (obj == null) {
			return null;
		}
		var numericIndex = readDynamicIndex(index);
		if (numericIndex != null) {
			if (Std.isOfType(obj, ASArrayBase)) {
				return (cast obj : ASArrayBase).get(numericIndex);
			}
			if (Std.isOfType(obj, Array)) {
				return (cast obj : Array<Dynamic>)[numericIndex];
			}
			var getMethod = Reflect.field(obj, "get");
			if (getMethod != null && Reflect.isFunction(getMethod)) {
				return Reflect.callMethod(obj, getMethod, [numericIndex]);
			}
		}
		return getProperty(obj, index);
	}

	/**
	 * Calls push() on a dynamically-typed object that may be an Array or ASArrayBase.
	 * Returns the new length of the array.
	 */
	public static function dynPush(obj:Dynamic, value:Dynamic):UInt {
		if (obj == null) {
			return 0;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).push(value);
		}
		if (Std.isOfType(obj, Array)) {
			var arr:Array<Dynamic> = cast obj;
			arr.push(value);
			return arr.length;
		}
		// Fallback: try to call push via Reflect
		var pushMethod = Reflect.field(obj, "push");
		if (pushMethod != null && Reflect.isFunction(pushMethod)) {
			return Reflect.callMethod(obj, pushMethod, [value]);
		}
		return 0;
	}

	/**
	 * Calls push() with multiple arguments on a dynamically-typed object.
	 * Returns the new length of the array.
	 */
	public static function dynPushMultiple(obj:Dynamic, first:Dynamic, rest:Array<Dynamic>):UInt {
		if (obj == null) {
			return 0;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			var arr:ASArrayBase = cast obj;
			arr.push(first);
			for (v in rest) {
				arr.push(v);
			}
			return arr.length;
		}
		if (Std.isOfType(obj, Array)) {
			var arr:Array<Dynamic> = cast obj;
			arr.push(first);
			for (v in rest) {
				arr.push(v);
			}
			return arr.length;
		}
		// Fallback: try to call push via Reflect
		var pushMethod = Reflect.field(obj, "push");
		if (pushMethod != null && Reflect.isFunction(pushMethod)) {
			var args = [first].concat(rest);
			return Reflect.callMethod(obj, pushMethod, args);
		}
		return 0;
	}

	/**
	 * Calls pop() on a dynamically-typed object that may be an Array or ASArrayBase.
	 * Returns the removed element, or null if the array is empty or obj is null.
	 */
	public static function dynPop(obj:Dynamic):Dynamic {
		if (obj == null) {
			return null;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).pop();
		}
		if (Std.isOfType(obj, Array)) {
			return (cast obj : Array<Dynamic>).pop();
		}
		// Fallback: try to call pop via Reflect
		var popMethod = Reflect.field(obj, "pop");
		if (popMethod != null && Reflect.isFunction(popMethod)) {
			return Reflect.callMethod(obj, popMethod, []);
		}
		return null;
	}

	/**
	 * Calls shift() on a dynamically-typed object that may be an Array or ASArrayBase.
	 * Returns the removed element, or null if the array is empty or obj is null.
	 */
	public static function dynShift(obj:Dynamic):Dynamic {
		if (obj == null) {
			return null;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).shift();
		}
		if (Std.isOfType(obj, Array)) {
			return (cast obj : Array<Dynamic>).shift();
		}
		// Fallback: try to call shift via Reflect
		var shiftMethod = Reflect.field(obj, "shift");
		if (shiftMethod != null && Reflect.isFunction(shiftMethod)) {
			return Reflect.callMethod(obj, shiftMethod, []);
		}
		return null;
	}

	/**
	 * Calls unshift() on a dynamically-typed object.
	 * Returns the new length of the array.
	 */
	public static function dynUnshift(obj:Dynamic, value:Dynamic):UInt {
		if (obj == null) {
			return 0;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).unshift(value);
		}
		if (Std.isOfType(obj, Array)) {
			var arr:Array<Dynamic> = cast obj;
			arr.unshift(value);
			return arr.length;
		}
		// Fallback: try to call unshift via Reflect
		var unshiftMethod = Reflect.field(obj, "unshift");
		if (unshiftMethod != null && Reflect.isFunction(unshiftMethod)) {
			return Reflect.callMethod(obj, unshiftMethod, [value]);
		}
		return 0;
	}

	/**
	 * Calls unshift() with multiple arguments on a dynamically-typed object.
	 * Returns the new length of the array.
	 */
	public static function dynUnshiftMultiple(obj:Dynamic, first:Dynamic, rest:Array<Dynamic>):UInt {
		if (obj == null) {
			return 0;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			var arr:ASArrayBase = cast obj;
			// Insert in reverse order: rest first (reversed), then first
			var i = rest.length - 1;
			while (i >= 0) {
				arr.unshift(rest[i]);
				i--;
			}
			arr.unshift(first);
			return arr.length;
		}
		if (Std.isOfType(obj, Array)) {
			var arr:Array<Dynamic> = cast obj;
			// Insert in reverse order: rest first (reversed), then first
			var i = rest.length - 1;
			while (i >= 0) {
				arr.unshift(rest[i]);
				i--;
			}
			arr.unshift(first);
			return arr.length;
		}
		// Fallback: try to call unshift via Reflect
		var unshiftMethod = Reflect.field(obj, "unshift");
		if (unshiftMethod != null && Reflect.isFunction(unshiftMethod)) {
			var args = [first].concat(rest);
			return Reflect.callMethod(obj, unshiftMethod, args);
		}
		return 0;
	}

	/**
	 * Returns the length of a dynamically-typed array-like object.
	 */
	public static function dynLength(obj:Dynamic):Int {
		if (obj == null) {
			return 0;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).length;
		}
		if (Std.isOfType(obj, Array)) {
			return (cast obj : Array<Dynamic>).length;
		}
		// Fallback: try to access length field
		var len = Reflect.field(obj, "length");
		return if (len != null) Std.int(len) else 0;
	}

	/**
	 * Calls reverse() on a dynamically-typed object.
	 * Returns the object itself (for chaining).
	 */
	public static function dynReverse(obj:Dynamic):Dynamic {
		if (obj == null) {
			return null;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).reverse();
		}
		if (Std.isOfType(obj, Array)) {
			(cast obj : Array<Dynamic>).reverse();
			return obj;
		}
		// Fallback: try to call reverse via Reflect
		var reverseMethod = Reflect.field(obj, "reverse");
		if (reverseMethod != null && Reflect.isFunction(reverseMethod)) {
			return Reflect.callMethod(obj, reverseMethod, []);
		}
		return obj;
	}

	/**
	 * Calls splice() on a dynamically-typed object.
	 */
	public static function dynSplice(obj:Dynamic, startIndex:Int, ?deleteCount:Int, ?values:Array<Dynamic>):Dynamic {
		if (obj == null) {
			return null;
		}
		if (deleteCount == null) {
			// Remove everything from startIndex
			if (Std.isOfType(obj, ASArrayBase)) {
				return (cast obj : ASArrayBase).splice(startIndex);
			}
			if (Std.isOfType(obj, Array)) {
				return (cast obj : Array<Dynamic>).splice(startIndex, (cast obj : Array<Dynamic>).length);
			}
		} else if (values == null || values.length == 0) {
			// Standard splice with deleteCount
			if (Std.isOfType(obj, ASArrayBase)) {
				return (cast obj : ASArrayBase).splice(startIndex, deleteCount);
			}
			if (Std.isOfType(obj, Array)) {
				return (cast obj : Array<Dynamic>).splice(startIndex, deleteCount);
			}
		} else {
			// Splice with insertion
			if (Std.isOfType(obj, ASArrayBase)) {
				var arr:ASArrayBase = cast obj;
				arr.splice(startIndex, deleteCount);
				for (i in 0...values.length) {
					arr.insert(startIndex + i, values[i]);
				}
				return arr;
			}
			if (Std.isOfType(obj, Array)) {
				return ASCompat.arraySplice(cast obj, startIndex, deleteCount, values);
			}
		}
		// Fallback: try to call splice via Reflect
		var spliceMethod = Reflect.field(obj, "splice");
		if (spliceMethod != null && Reflect.isFunction(spliceMethod)) {
			var args = [startIndex];
			if (deleteCount != null) {
				args.push(deleteCount);
			}
			if (values != null) {
				for (v in values) {
					args.push(v);
				}
			}
			return Reflect.callMethod(obj, spliceMethod, args);
		}
		return null;
	}

	/**
	 * Calls concat() on a dynamically-typed object.
	 */
	public static function dynConcat(obj:Dynamic, ?value:Dynamic):Dynamic {
		if (obj == null) {
			return null;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			if (value != null) {
				return (cast obj : ASArrayBase).concat(value);
			} else {
				return (cast obj : ASArrayBase).concat();
			}
		}
		if (Std.isOfType(obj, Array)) {
			var arr:Array<Dynamic> = cast obj;
			if (value != null) {
				return arr.concat(value);
			} else {
				return arr.copy();
			}
		}
		// Fallback: try to call concat via Reflect
		var concatMethod = Reflect.field(obj, "concat");
		if (concatMethod != null && Reflect.isFunction(concatMethod)) {
			var args = value != null ? [value] : [];
			return Reflect.callMethod(obj, concatMethod, args);
		}
		return null;
	}

	/**
	 * Calls join() on a dynamically-typed object.
	 */
	public static function dynJoin(obj:Dynamic, ?separator:String):String {
		if (obj == null) {
			return "";
		}
		var sep = separator != null ? separator : ",";
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).join(sep);
		}
		if (Std.isOfType(obj, Array)) {
			return (cast obj : Array<Dynamic>).join(sep);
		}
		// Fallback: try to call join via Reflect
		var joinMethod = Reflect.field(obj, "join");
		if (joinMethod != null && Reflect.isFunction(joinMethod)) {
			return Reflect.callMethod(obj, joinMethod, [sep]);
		}
		return "";
	}

	/**
	 * Calls slice() on a dynamically-typed object.
	 */
	public static function dynSlice(obj:Dynamic, ?startIndex:Int, ?endIndex:Int):Dynamic {
		if (obj == null) {
			return null;
		}
		if (Std.isOfType(obj, ASArrayBase)) {
			return (cast obj : ASArrayBase).slice(startIndex, endIndex);
		}
		if (Std.isOfType(obj, Array)) {
			return (cast obj : Array<Dynamic>).slice(startIndex, endIndex);
		}
		// Fallback: try to call slice via Reflect
		var sliceMethod = Reflect.field(obj, "slice");
		if (sliceMethod != null && Reflect.isFunction(sliceMethod)) {
			var args = [];
			if (startIndex != null) {
				args.push(startIndex);
				if (endIndex != null) {
					args.push(endIndex);
				}
			}
			return Reflect.callMethod(obj, sliceMethod, args);
		}
		return null;
	}

	static inline function toNumberNative(d:Dynamic):Float {
		if (isUndefinedValue(d)) {
			return Math.NaN;
		}
		if (d == null) {
			return 0;
		}
		if (Std.isOfType(d, Float)) {
			return cast d;
		}
		if (Std.isOfType(d, Int)) {
			return cast d;
		}
		if (Std.isOfType(d, Bool)) {
			return (cast d : Bool) ? 1 : 0;
		}
		if (Std.isOfType(d, String)) {
			var s = StringTools.trim(cast d);
			if (s == "NaN") return Math.NaN;
			if (s == "") {
				return 0;
			}
			var f = Std.parseFloat(s);
			return if (Math.isNaN(f)) Math.NaN else f;
		}
		if (Std.isOfType(d, Array)) {
			var a:Array<Dynamic> = cast d;
			return switch a.length {
				case 0: 0;
				case 1: toNumberNative(a[0]);
				default: Math.NaN;
			}
		}
		return Math.NaN;
	}

	static function toFixedNative(n:Float, digits:Int):String {
		if (digits < 0) {
			digits = 0;
		}
		var factor = Math.pow(10, digits);
		var rounded = Math.round(n * factor) / factor;
		var s = Std.string(rounded);
		var dotIndex = s.indexOf(".");
		if (digits == 0) {
			return if (dotIndex == -1) s else s.substring(0, dotIndex);
		}
		if (dotIndex == -1) {
			s += ".";
			dotIndex = s.length - 1;
		}
		var decimals = s.length - dotIndex - 1;
		while (decimals < digits) {
			s += "0";
			decimals++;
		}
		return s;
	}

	static inline function toBoolNative(d:Dynamic):Bool {
		if (isUndefinedValue(d)) {
			return false;
		}
		if (d == null) {
			return false;
		}
		if (Std.isOfType(d, Bool)) {
			return cast d;
		}
		if (Std.isOfType(d, Int)) {
			return (cast d : Int) != 0;
		}
		if (Std.isOfType(d, Float)) {
			var f:Float = cast d;
			return f != 0 && !Math.isNaN(f);
		}
		if (Std.isOfType(d, String)) {
			return (cast d : String).length > 0;
		}
		return true;
	}

	#if !(flash || js)
	static var _timeoutId:UInt = 1;
	static var _intervalId:UInt = 1;
	static var _timeouts:IntMap<Timer> = new IntMap();
	static var _intervals:IntMap<Timer> = new IntMap();

	@:noCompletion public static function _setTimeoutNative(closure:Function, delay:Float, args:Array<Dynamic>):UInt {
		var id = _timeoutId++;
		var timer = Timer.delay(function() {
			_timeouts.remove(id);
			Reflect.callMethod(null, closure, args);
		}, Std.int(delay));
		_timeouts.set(id, timer);
		return id;
	}

	@:noCompletion public static function _clearTimeoutNative(id:UInt):Void {
		var timer = _timeouts.get(id);
		if (timer != null) {
			timer.stop();
			_timeouts.remove(id);
		}
	}

	@:noCompletion public static function _setIntervalNative(closure:Function, delay:Float, args:Array<Dynamic>):UInt {
		var id = _intervalId++;
		var timer = new Timer(Std.int(delay));
		timer.run = function() {
			Reflect.callMethod(null, closure, args);
		};
		_intervals.set(id, timer);
		return id;
	}

	@:noCompletion public static function _clearIntervalNative(id:UInt):Void {
		var timer = _intervals.get(id);
		if (timer != null) {
			timer.stop();
			_intervals.remove(id);
		}
	}
	#end

}

class ASArray {
	public static inline final CASEINSENSITIVE = 1;
	public static inline final DESCENDING = 2;
	public static inline final NUMERIC = 16;
	public static inline final RETURNINDEXEDARRAY = 8;
	public static inline final UNIQUESORT = 4;

	public static inline function reverse<T>(a:Array<T>):Array<T> {
		a.reverse();
		return a;
	}

	public static function some<T>(a:Array<T>, callback:(item:T, index:Int, array:Array<T>)->Bool, ?thisObj:Dynamic):Bool {
		for (i in 0...a.length) {
			var result:Bool =
				if (thisObj != null) Reflect.callMethod(thisObj, callback, [a[i], i, a])
				else callback(a[i], i, a);
			if (result) {
				return true;
			}
		}
		return false;
	}

	public static function forEach<T>(a:Array<T>, callback:(item:T, index:Int, array:Array<T>)->Void, ?thisObj:Dynamic):Void {
		for (i in 0...a.length) {
			if (thisObj != null) Reflect.callMethod(thisObj, callback, [a[i], i, a])
			else callback(a[i], i, a);
		}
	}

	public static inline function map<T, U>(a:Array<T>, callback:(item:T, index:Int, array:Array<T>)->U, ?thisObj:Dynamic):Array<U> {
		var out:Array<U> = [];
		for (i in 0...a.length) {
			var value:U =
				if (thisObj != null) Reflect.callMethod(thisObj, callback, [a[i], i, a])
				else callback(a[i], i, a);
			out.push(value);
		}
		return out;
	}

	public static function sort<T>(a:Array<T>, f:Dynamic):Array<T> {
		if (f == null) {
			a.sort(Reflect.compare);
			return a;
		}
		a.sort(function(x, y) {
			var result:Dynamic = f(x, y);
			return coerceSortResult(result);
		});
		return a;
	}

	static inline function coerceSortResult(value:Dynamic):Int {
		if (Std.isOfType(value, Int)) return value;
		if (Std.isOfType(value, Float)) return Std.int(value);
		if (Std.isOfType(value, Bool)) return value ? 1 : 0;
		return Std.int(ASCompat.toNumber(value));
	}

	public static inline function sortOn<T>(a:Array<T>, fieldName:Dynamic, options:Dynamic):Array<T> {
		#if flash
		return (cast a).sortOn(fieldName, options);
		#else
		return ASSortTools.sortOn(a, fieldName, options);
		#end
	}

	public static inline function sortWithOptions<T>(a:Array<T>, options:Int):Array<T> {
		#if flash
		return (cast a).sort(options);
		#else
		return ASSortTools.sortWithOptions(a, options, function(v) return v);
		#end
	}

	public static macro function pushMultiple<T>(a:ExprOf<Array<T>>, first:ExprOf<T>, rest:Array<ExprOf<T>>):ExprOf<Int>;
	public static macro function unshiftMultiple<T>(a:ExprOf<Array<T>>, first:ExprOf<T>, rest:Array<ExprOf<T>>):ExprOf<Int>;
}


class ASVector {
	static inline function coerceSortResult(value:Dynamic):Int {
		if (Std.isOfType(value, Int)) return value;
		if (Std.isOfType(value, Float)) return Std.int(value);
		if (Std.isOfType(value, Bool)) return value ? 1 : 0;
		return Std.int(ASCompat.toNumber(value));
	}

	#if (flash || js)
	public static inline function reverse<T>(a:flash.Vector<T>):flash.Vector<T> {
		#if flash
		return (cast a).reverse();
		#else
		var items = [for (i in 0...a.length) a[i]];
		items.reverse();
		for (i in 0...items.length) {
			a[i] = items[i];
		}
		return a;
		#end
	}

	public static function forEach<T>(a:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->Void, ?thisObj:Dynamic):Void {
		for (i in 0...a.length) {
			if (thisObj != null) Reflect.callMethod(thisObj, callback, [a[i], i, a])
			else callback(a[i], i, a);
		}
	}

	public static inline function map<T, U>(a:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->U, ?thisObj:Dynamic):flash.Vector<U> {
		var out = new flash.Vector<U>();
		for (i in 0...a.length) {
			var value:U =
				if (thisObj != null) Reflect.callMethod(thisObj, callback, [a[i], i, a])
				else callback(a[i], i, a);
			out.push(value);
		}
		return out;
	}

	public static function sort<T>(a:flash.Vector<T>, f:Dynamic):flash.Vector<T> {
		if (f == null) {
			a.sort(Reflect.compare);
			return a;
		}
		a.sort(function(x, y) {
			var result:Dynamic = f(x, y);
			return coerceSortResult(result);
		});
		return a;
	}

	public static inline function sortWithOptions<T>(a:flash.Vector<T>, options:Int):flash.Vector<T> {
		#if flash
		return (cast a).sort(options);
		#else
		if ((options & ASArray.RETURNINDEXEDARRAY) != 0) {
			return a;
		}
		var items = [for (i in 0...a.length) a[i]];
		ASSortTools.sortWithOptions(items, options, function(v) return v);
		for (i in 0...items.length) {
			a[i] = items[i];
		}
		return a;
		#end
	}
	#else
	static inline function getLen(v:Dynamic):Int {
		var getLengthMethod = Reflect.field(v, "get_length");
		if (getLengthMethod != null && Reflect.isFunction(getLengthMethod)) {
			return Std.int(Reflect.callMethod(v, getLengthMethod, []));
		}
		return Std.int(Reflect.field(v, "length"));
	}

	static inline function getAt(v:Dynamic, index:Int):Dynamic {
		var getMethod = Reflect.field(v, "get");
		return if (getMethod != null) Reflect.callMethod(v, getMethod, [index]) else v[index];
	}

	static inline function setAt(v:Dynamic, index:Int, value:Dynamic):Void {
		var setMethod = Reflect.field(v, "set");
		if (setMethod != null) Reflect.callMethod(v, setMethod, [index, value]); else v[index] = value;
	}

	public static function reverse(a:Dynamic):Dynamic {
		var len = getLen(a);
		var i = 0;
		var j = len - 1;
		while (i < j) {
			var left = getAt(a, i);
			var right = getAt(a, j);
			setAt(a, i, right);
			setAt(a, j, left);
			i++;
			j--;
		}
		return a;
	}

	public static function forEach(a:Dynamic, callback:Dynamic, ?thisObj:Dynamic):Void {
		for (i in 0...getLen(a)) {
			var item = getAt(a, i);
			if (thisObj != null) Reflect.callMethod(thisObj, callback, [item, i, a])
			else callback(item, i, a);
		}
	}

	public static function map(a:Dynamic, callback:Dynamic, ?thisObj:Dynamic):Dynamic {
		var out:Array<Dynamic> = [];
		for (i in 0...getLen(a)) {
			var item = getAt(a, i);
			var value:Dynamic =
				if (thisObj != null) Reflect.callMethod(thisObj, callback, [item, i, a])
				else callback(item, i, a);
			out.push(value);
		}
		return out;
	}

	public static function sort(a:Dynamic, f:Dynamic):Dynamic {
		if (f == null) {
			a.sort(Reflect.compare);
			return a;
		}
		a.sort(function(x, y) {
			var result:Dynamic = f(x, y);
			return coerceSortResult(result);
		});
		return a;
	}

	public static function sortWithOptions(a:Dynamic, options:Int):Dynamic {
		if ((options & ASArray.RETURNINDEXEDARRAY) != 0) {
			return a;
		}
		var items = [for (i in 0...getLen(a)) getAt(a, i)];
		ASSortTools.sortWithOptions(items, options, function(v) return v);
		for (i in 0...items.length) {
			setAt(a, i, items[i]);
		}
		return a;
	}
	#end
}

class ASVectorTools {
	#if flash inline #end
	public static function forEach<T>(v:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->Void):Void {
		#if flash
		(cast v).forEach(callback);
		#else
		for (i in 0...v.length) {
			callback(v[i], i, v);
		}
		#end
	}

	#if flash inline #end
	public static function filter<T>(v:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->Bool):flash.Vector<T> {
		#if flash
		return (cast v).filter(callback);
		#else
		var result = new flash.Vector<T>();
		for (i in 0...v.length) {
			var item = v[i];
			if (callback(item, i, v)) {
				result.push(item);
			}
		}
		return result;
		#end
	}

	#if flash inline #end
	public static function map<T,T2>(v:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->T2):flash.Vector<T2> {
		#if flash
		return (cast v).map(callback);
		#else
		var result = new flash.Vector<T2>(v.length);
		for (i in 0...v.length) {
			result[i] = callback(v[i], i, v);
		}
		return result;
		#end
	}

	#if flash inline #end
	public static function every<T>(v:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->Bool):Bool {
		#if flash
		return (cast v).every(callback);
		#else
		for (i in 0...v.length) {
			if (!callback(v[i], i, v)) {
				return false;
			}
		}
		return true;
		#end
	}

	#if flash inline #end
	public static function some<T>(v:flash.Vector<T>, callback:(item:T, index:Int, vector:flash.Vector<T>)->Bool):Bool {
		#if flash
		return (cast v).some(callback);
		#else
		for (i in 0...v.length) {
			if (callback(v[i], i, v)) {
				return true;
			}
		}
		return false;
		#end
	}
}

private class ASSortTools {
	public static function sortOn<T>(a:Array<T>, fieldName:Dynamic, options:Dynamic):Array<T> {
		var fields = normalizeFieldNames(fieldName);
		var opts = normalizeOptions(options, fields.length);
		var fieldOptions = opts.fieldOptions;
		var globalOptions = opts.globalOptions;

		if (fields.length == 0) {
			return a;
		}

		if ((globalOptions & ASArray.RETURNINDEXEDARRAY) != 0) {
			var indices = [for (i in 0...a.length) i];
			indices.sort(function(i, j) {
				return compareByFields(a[i], a[j], fields, fieldOptions);
			});
			if ((globalOptions & ASArray.UNIQUESORT) != 0 && hasDuplicateIndicesByFields(indices, a, fields, fieldOptions)) {
				return a;
			}
			return cast indices;
		}

		var sorted = a.copy();
		sorted.sort(function(x, y) {
			return compareByFields(x, y, fields, fieldOptions);
		});
		if ((globalOptions & ASArray.UNIQUESORT) != 0 && hasDuplicateValuesByFields(sorted, fields, fieldOptions)) {
			return a;
		}
		for (i in 0...sorted.length) {
			a[i] = sorted[i];
		}
		return a;
	}

	public static function sortWithOptions<T>(a:Array<T>, options:Int, valueFn:T->Dynamic):Array<T> {
		if ((options & ASArray.RETURNINDEXEDARRAY) != 0) {
			var indices = [for (i in 0...a.length) i];
			indices.sort(function(i, j) {
				return compareValues(valueFn(a[i]), valueFn(a[j]), options);
			});
			if ((options & ASArray.UNIQUESORT) != 0 && hasDuplicateIndices(indices, a, valueFn, options)) {
				return a;
			}
			return cast indices;
		}

		var sorted = a.copy();
		sorted.sort(function(x, y) {
			return compareValues(valueFn(x), valueFn(y), options);
		});
		if ((options & ASArray.UNIQUESORT) != 0 && hasDuplicateValues(sorted, valueFn, options)) {
			return a;
		}
		for (i in 0...sorted.length) {
			a[i] = sorted[i];
		}
		return a;
	}

	static function normalizeFieldNames(fieldName:Dynamic):Array<String> {
		if (fieldName == null) {
			return [];
		}
		if (Std.isOfType(fieldName, Array)) {
			var values:Array<Dynamic> = cast fieldName;
			return [for (v in values) Std.string(v)];
		}
		return [Std.string(fieldName)];
	}

	static function normalizeOptions(options:Dynamic, fieldCount:Int):{fieldOptions:Array<Int>, globalOptions:Int} {
		var fieldOptions:Array<Int> = [];
		var globalOptions = 0;
		if (options == null) {
			for (i in 0...fieldCount) {
				fieldOptions.push(0);
			}
			return {fieldOptions: fieldOptions, globalOptions: 0};
		}

		if (Std.isOfType(options, Array)) {
			var values:Array<Dynamic> = cast options;
			for (i in 0...fieldCount) {
				var v = if (i < values.length && values[i] != null) Std.int(values[i]) else 0;
				fieldOptions.push(v);
				globalOptions |= v;
			}
			return {fieldOptions: fieldOptions, globalOptions: globalOptions};
		}

		var v = Std.int(options);
		for (i in 0...fieldCount) {
			fieldOptions.push(v);
		}
		return {fieldOptions: fieldOptions, globalOptions: v};
	}

	static function compareByFields(a:Dynamic, b:Dynamic, fields:Array<String>, options:Array<Int>):Int {
		for (i in 0...fields.length) {
			var key = fields[i];
			var opts = if (i < options.length) options[i] else 0;
			var left = Reflect.getProperty(a, key);
			var right = Reflect.getProperty(b, key);
			var result = compareValues(left, right, opts);
			if (result != 0) {
				return result;
			}
		}
		return 0;
	}

	static function hasDuplicateValuesByFields<T>(sorted:Array<T>, fields:Array<String>, options:Array<Int>):Bool {
		if (sorted.length < 2) {
			return false;
		}
		var prev = sorted[0];
		for (i in 1...sorted.length) {
			var cur = sorted[i];
			if (compareByFields(prev, cur, fields, options) == 0) {
				return true;
			}
			prev = cur;
		}
		return false;
	}

	static function hasDuplicateIndicesByFields<T>(indices:Array<Int>, a:Array<T>, fields:Array<String>, options:Array<Int>):Bool {
		if (indices.length < 2) {
			return false;
		}
		var prev = indices[0];
		for (i in 1...indices.length) {
			var cur = indices[i];
			if (compareByFields(a[prev], a[cur], fields, options) == 0) {
				return true;
			}
			prev = cur;
		}
		return false;
	}

	static function hasDuplicateValues<T>(sorted:Array<T>, valueFn:T->Dynamic, options:Int):Bool {
		if (sorted.length < 2) {
			return false;
		}
		var prev = valueFn(sorted[0]);
		for (i in 1...sorted.length) {
			var cur = valueFn(sorted[i]);
			if (compareValues(prev, cur, options) == 0) {
				return true;
			}
			prev = cur;
		}
		return false;
	}

	static function hasDuplicateIndices<T>(indices:Array<Int>, a:Array<T>, valueFn:T->Dynamic, options:Int):Bool {
		if (indices.length < 2) {
			return false;
		}
		var prev = valueFn(a[indices[0]]);
		for (i in 1...indices.length) {
			var cur = valueFn(a[indices[i]]);
			if (compareValues(prev, cur, options) == 0) {
				return true;
			}
			prev = cur;
		}
		return false;
	}

	static function compareValues(a:Dynamic, b:Dynamic, options:Int):Int {
		if (a == b) {
			return 0;
		}
		if (a == null) {
			return -1;
		}
		if (b == null) {
			return 1;
		}

		var result = if ((options & ASArray.NUMERIC) != 0) {
			compareNumeric(a, b, options);
		} else {
			compareStrings(Std.string(a), Std.string(b), (options & ASArray.CASEINSENSITIVE) != 0);
		}

		if ((options & ASArray.DESCENDING) != 0) {
			result = -result;
		}
		return result;
	}

	static function compareNumeric(a:Dynamic, b:Dynamic, options:Int):Int {
		var fa = Std.parseFloat(Std.string(a));
		var fb = Std.parseFloat(Std.string(b));
		if (Math.isNaN(fa) || Math.isNaN(fb)) {
			return compareStrings(Std.string(a), Std.string(b), (options & ASArray.CASEINSENSITIVE) != 0);
		}
		return if (fa < fb) -1 else if (fa > fb) 1 else 0;
	}

	static function compareStrings(a:String, b:String, caseInsensitive:Bool):Int {
		if (caseInsensitive) {
			a = a.toLowerCase();
			b = b.toLowerCase();
		}
		return if (a < b) -1 else if (a > b) 1 else 0;
	}
}

class ASDate {
	public static inline function toDateString(d:Date):String {
		return DateTools.format(Date.fromTime(0), "%a %b %d %Y");
	}

	public static inline function setTime(d:Date, millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setTime(millisecond);
		#elseif cpp
		untyped d.mSeconds = millisecond * 0.001;
		return millisecond;
		#else
		return millisecond;
		#end
	}

	public static inline function setDate(d:Date, day:Float):Float {
		return setTime(d, DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), Std.int(day), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
	}

	public static inline function setMonth(d:Date, month:Float, ?day:Float):Float {
		#if (js || flash || python)
		return (cast d).setMonth(month, day);
		#else
		var dayValue = if (day == null) d.getUTCDate() else Std.int(day);
		return setTime(d, DateTools.makeUtc(d.getUTCFullYear(), Std.int(month), dayValue, d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
		#end
	}

	public static inline function setHours(d:Date, hour:Float, ?minute:Int, ?second:Int, ?millisecond:Int):Float {
		#if (js || flash || python)
		return (cast d).setHours(hour, minute, second, millisecond);
		#else
		var minValue = if (minute == null) d.getUTCMinutes() else minute;
		var secValue = if (second == null) d.getUTCSeconds() else second;
		var base = DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), Std.int(hour), minValue, secValue);
		return setTime(d, base + if (millisecond == null) 0 else millisecond);
		#end
	}

	public static inline function setMinutes(d:Date, minute:Float, ?second:Float, ?millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setMinutes(minute, second, millisecond);
		#else
		var secValue = if (second == null) d.getUTCSeconds() else Std.int(second);
		var base = DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), Std.int(minute), secValue);
		return setTime(d, base + if (millisecond == null) 0 else millisecond);
		#end
	}

	public static inline function setSeconds(d:Date, second:Float, ?millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setSeconds(second, millisecond);
		#else
		var base = DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), Std.int(second));
		return setTime(d, base + if (millisecond == null) 0 else millisecond);
		#end
	}

	public static inline function getMilliseconds(d:Date):Float {
		#if (js || flash || python)
		return (cast d).getMilliseconds();
		#else
		var ms = Std.int(d.getTime() % 1000);
		return if (ms < 0) ms + 1000 else ms;
		#end
	}

	public static inline function setMilliseconds(d:Date, millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setMilliseconds(millisecond);
		#else
		return setTime(d, d.getTime() - getMilliseconds(d) + millisecond);
		#end
	}

	public static inline function setUTCDate(d:Date, day:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCDate(day);
		#else
		return setTime(d, DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), Std.int(day), d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
		#end
	}

	public static inline function setFullYear(d:Date, year:Float, ?month:Float, ?day:Float):Float {
		#if (js || flash || python)
		return (cast d).setFullYear(year, month, day);
		#else
		var monthValue = if (month == null) d.getUTCMonth() else Std.int(month);
		var dayValue = if (day == null) d.getUTCDate() else Std.int(day);
		return setTime(d, DateTools.makeUtc(Std.int(year), monthValue, dayValue, d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
		#end
	}

	public static inline function setUTCFullYear(d:Date, year:Float, ?month:Float, ?day:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCFullYear(year, month, day);
		#else
		var monthValue = if (month == null) d.getUTCMonth() else Std.int(month);
		var dayValue = if (day == null) d.getUTCDate() else Std.int(day);
		return setTime(d, DateTools.makeUtc(Std.int(year), monthValue, dayValue, d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
		#end
	}

	public static inline function setUTCHours(d:Date, hour:Float, ?minute:Float, ?second:Float, ?millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCHours(hour, minute, second, millisecond);
		#else
		var minValue = if (minute == null) d.getUTCMinutes() else Std.int(minute);
		var secValue = if (second == null) d.getUTCSeconds() else Std.int(second);
		var base = DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), Std.int(hour), minValue, secValue);
		return setTime(d, base + if (millisecond == null) 0 else millisecond);
		#end
	}

	public static inline function getUTCMilliseconds(d:Date):Float {
		#if (js || flash || python)
		return (cast d).getUTCMilliseconds();
		#else
		return getMilliseconds(d);
		#end
	}

	public static inline function setUTCMilliseconds(d:Date, millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCMilliseconds(millisecond);
		#else
		return setMilliseconds(d, millisecond);
		#end
	}

	public static inline function setUTCMinutes(d:Date, minute:Float, ?second:Float, ?millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCMinutes(minute, second, millisecond);
		#else
		var secValue = if (second == null) d.getUTCSeconds() else Std.int(second);
		var base = DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), Std.int(minute), secValue);
		return setTime(d, base + if (millisecond == null) 0 else millisecond);
		#end
	}

	public static inline function setUTCMonth(d:Date, month:Float, ?day:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCMonth(month, day);
		#else
		var dayValue = if (day == null) d.getUTCDate() else Std.int(day);
		return setTime(d, DateTools.makeUtc(d.getUTCFullYear(), Std.int(month), dayValue, d.getUTCHours(), d.getUTCMinutes(), d.getUTCSeconds()));
		#end
	}

	public static inline function setUTCSeconds(d:Date, second:Float, ?millisecond:Float):Float {
		#if (js || flash || python)
		return (cast d).setUTCSeconds(second, millisecond);
		#else
		var base = DateTools.makeUtc(d.getUTCFullYear(), d.getUTCMonth(), d.getUTCDate(), d.getUTCHours(), d.getUTCMinutes(), Std.int(second));
		return setTime(d, base + if (millisecond == null) 0 else millisecond);
		#end
	}

	public static inline function UTC(year:Float, month:Float, ?day:Float, ?hour:Float, ?minute:Float, ?second:Float, ?millisecond:Float):Float {
		#if (js || flash || python)
		return (cast Date).UTC(year, month, day, hour, minute, second, millisecond);
		#elseif (php || cpp)
		var dayValue = if (day == null) 1 else Std.int(day);
		var hourValue = if (hour == null) 0 else Std.int(hour);
		var minuteValue = if (minute == null) 0 else Std.int(minute);
		var secondValue = if (second == null) 0 else Std.int(second);
		var base = DateTools.makeUtc(Std.int(year), Std.int(month), dayValue, hourValue, minuteValue, secondValue);
		return base + if (millisecond == null) 0 else millisecond;
		#else
		return 0.;
		#end
	}
}
