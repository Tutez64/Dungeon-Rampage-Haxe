package compat;

import Xml as StdXml;
import haxe.ds.ObjectMap;

private typedef XMLImpl = #if flash flash.xml.XML #else StdXml #end;

abstract XML(XMLImpl) from XMLImpl to XMLImpl {
	#if !flash
	static final attrOrder = new ObjectMap<StdXml, Array<String>>();
	#end

	public static inline function typeReference() {
		#if flash
		return flash.xml.XML;
		#else
		return StdXml;
		#end
	}

	public inline function new(x:String) {
		#if flash
		this = new flash.xml.XML(x);
		#else
		this = StdXml.parse(x).firstElement();
		#end
	}

	public inline function appendChild(x:XML) {
		#if flash
		this.appendChild(x);
		#else
		this.addChild(x);
		#end
	}

	public inline function attribute(name:String):Attribute {
		#if flash
		return this.attribute(name).toString();
		#else
		var attr = this.get(name);
		return if (attr == null) "" else attr; // preserve Flash behaviour
		#end
	}

	public inline function attributes() {
		#if flash
		return this.attributes();
		#else
		return [for (a in this.attributes()) {name: () -> a, localName: () -> a, toString: () -> a}];
		#end
	}

	public inline function setAttribute(name:String, value:String):String {
		#if flash
		this.attribute(name)[0] = new flash.xml.XML(value);
		#else
		var existing = getAttrOrder(this);
		var hadAttribute = existing.indexOf(name) != -1;
		if (!hadAttribute) {
			existing.push(name);
		}
		attrOrder.set(this, existing);
		this.set(name, value);
		#end
		return value;
	}

	public function child(name:String):XMLList {
		#if flash
		return this.child(name);
		#else
		return [for (x in this.elementsNamed(name)) x];
		#end
	}

	public function elements():XMLList {
		#if flash
		return this.elements();
		#else
		return [for (x in this.elements()) x];
		#end
	}

	public function children():XMLList {
		#if flash
		return this.children();
		#else
		return [for (x in this.elements()) x];
		#end
	}

	public inline function parent():XML {
		#if flash
		return this.parent();
		#else
		return this.parent;
		#end
	}

	public function localName():String {
		#if flash
		return this.localName();
		#else
		return this.nodeName;
		#end
	}

	public function name():String {
		#if flash
		return this.localName();
		#else
		return this.nodeName;
		#end
	}

	public function descendants(name:String):XMLList {
		#if flash
		return this.descendants(name);
		#else
		var result = [];
		fillDescendants(this, name, result);
		return result;
		#end
	}

	#if !flash
	static function getAttrOrder(x:StdXml):Array<String> {
		if (attrOrder.exists(x)) {
			return attrOrder.get(x).copy();
		}
		return [for (a in x.attributes()) a];
	}

	static inline function escapeAttrValue(s:String):String {
		return s.split("&").join("&amp;").split("\"").join("&quot;").split("<").join("&lt;");
	}

	static function serializeXml(x:StdXml):String {
		if (x == null) return null;
		return switch x.nodeType {
			case Element:
				var order = getAttrOrder(x);
				var buf = new StringBuf();
				buf.add("<");
				buf.add(x.nodeName);
				for (a in order) {
					var v = x.get(a);
					if (v != null) {
						buf.add(" ");
						buf.add(a);
						buf.add("=\"");
						buf.add(escapeAttrValue(v));
						buf.add("\"");
					}
				}
				var children = [for (child in x) child];
				if (children.length == 0) {
					buf.add("/>");
				} else {
					buf.add(">");
					for (child in children) {
						buf.add(switch child.nodeType {
							case Element: serializeXml(child);
							default: child.toString();
						});
					}
					buf.add("</");
					buf.add(x.nodeName);
					buf.add(">");
				}
				buf.toString();
			default:
				x.toString();
		}
	}

	static function fillDescendants(x:StdXml, name:String, acc:Array<XML>) {
		for (child in x.elements()) {
			if (name == "*" || child.nodeName == name) {
				acc.push(child);
			}
			fillDescendants(child, name, acc);
		}
	}
	#end

	@:to public #if flash inline #end function toString():String {
		if (this == null) return null;
		#if flash
		return this.toString();
		#else
		var buf = new StringBuf();
		for (child in this) {
			if (child.nodeType == Element) {
				// if it has child elements, then it's "complex"
				return this.toString();
			} else {
				buf.add(child.nodeValue);
			}
		}
		return buf.toString();
		#end
	}

	public inline function toXMLString():String {
		#if flash
		return this.toXMLString();
		#else
		return serializeXml(this);
		#end
	}

	public function hasOwnProperty(name:String):Bool {
		#if flash
		return untyped this.hasOwnProperty(name);
		#else
		if (this == null) {
			return false;
		}
		var it = this.elementsNamed(name);
		return it.hasNext();
		#end
	}

	public inline function namespace():Any return null; // todo

}
