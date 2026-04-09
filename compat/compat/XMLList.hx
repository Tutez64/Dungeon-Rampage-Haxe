package compat;

import haxe.Exception;
import Xml as StdXml;

private typedef XMLListImpl = #if flash flash.xml.XMLList #else Array<XML> #end;

abstract XMLList(XMLListImpl) from XMLListImpl to XMLListImpl {
	public static inline function typeReference() {
		#if flash
		return flash.xml.XMLList;
		#else
		return Array;
		#end
	}

	public function child(name:String):XMLList {
		#if flash
		return this.child(name);
		#else
		return [for (x in this) for (child in (x : StdXml).elementsNamed(name)) child];
		#end
	}

	#if flash inline #end
	public function attribute(name:String):Attribute {
		#if flash
		return this.attribute(name).toString();
		#else
		return [for (x in this) x.attribute(name)].join("");
		#end
	}

	#if flash inline #end
	public function appendChild(v:XML):Void {
		#if flash
		this.appendChild(v);
		#else
		for (x in this) x.appendChild(v);
		#end
	}

	#if flash inline #end
	public function children():XMLList {
		#if flash
		return this.children();
		#else
		final r: Array<XML> = [];
		for (x in this) for (e in x.children()) r.push(e);
		return r;
		#end
	}

	public function parent():XML {
		#if flash
		return this.parent();
		#else
		if (this.length == 0) {
			return null;
		}
		var first:StdXml = this[0];
		var parent = first.parent;
		if (parent == null) {
			return null;
		}
		for (i in 1...this.length) {
			var p = (this[i] : StdXml).parent;
			if (p != parent) {
				return null;
			}
		}
		return parent;
		#end
	}

	#if flash inline #end
	public function toXMLString():String {
		#if flash
		return this.toXMLString();
		#else
		return [for (x in this) x.toXMLString()].join("\n");
		#end
	}

	#if flash inline #end
	public function toString():String {
		#if flash
		return this.toString();
		#else
		return if (this.length > 1) toXMLString() else this[0].toString();
		#end
	}

	public function deleteAt(index:Int):Bool {
		#if flash
		return untyped __delete__(this, index);
		#else
		if (index < 0 || index >= this.length) {
			return true;
		}
		var node:StdXml = this[index];
		var parent = node.parent;
		if (parent != null) {
			parent.removeChild(node);
		}
		this.splice(index, 1);
		return true;
		#end
	}

	@:op([]) inline function get(index:Int):XML {
		return this[index];
	}

	public inline function length():Int {
		#if flash
		return this.length();
		#else
		return this.length;
		#end
	}

	public inline function iterator() {
		#if flash
		return new std.NativeValueIterator<XML>(this);
		#else
		return this.iterator();
		#end
	}

	public function hasOwnProperty(name:String):Bool {
		#if flash
		return untyped this.hasOwnProperty(name);
		#else
		for (x in this) {
			var xml:StdXml = x;
			var it = xml.elementsNamed(name);
			if (it.hasNext()) {
				return true;
			}
		}
		return false;
		#end
	}
}
