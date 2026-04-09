class ASProxyBase {
	public function new() {}

	public dynamic function getProperty(name:Dynamic):Dynamic {
		return Reflect.getProperty(this, Std.string(name));
	}

	public dynamic function setProperty(name:Dynamic, value:Dynamic):Void {
		Reflect.setProperty(this, Std.string(name), value);
	}

	public dynamic function deleteProperty(name:Dynamic):Bool {
		return Reflect.deleteField(this, Std.string(name));
	}

	public dynamic function callProperty(name:Dynamic, ...rest:Dynamic):Dynamic {
		var method = ASCompat.getProperty(this, name);
		return Reflect.callMethod(this, method, rest);
	}

	public dynamic function getDescendants(name:Dynamic):Dynamic {
		return null;
	}

	public dynamic function hasProperty(name:Dynamic):Bool {
		return Reflect.hasField(this, Std.string(name));
	}

	public dynamic function isAttribute(name:Dynamic):Bool {
		return false;
	}

	public dynamic function nextName(index:Int):String {
		return null;
	}

	public dynamic function nextNameIndex(index:Int):Int {
		return 0;
	}

	public dynamic function nextValue(index:Int):Dynamic {
		return null;
	}
}
