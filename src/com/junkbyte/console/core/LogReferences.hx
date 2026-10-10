package com.junkbyte.console.core;

import com.junkbyte.console.Console;
import com.junkbyte.console.vos.WeakObject;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.events.Event;
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;
import flash.utils.ByteArray;
import flash.utils.QName;

class LogReferences extends ConsoleCore {
	public static inline final INSPECTING_CHANNEL = "⌂";

	var _refMap:WeakObject;

	var _refRev:ASDictionary<ASAny, ASAny>;

	var _refIndex:UInt = (1 : UInt);

	var _dofull:Bool = false;

	var _current:ASAny;

	var _history:Array<ASAny>;

	var _hisIndex:UInt = 0;

	var _prevBank:Array<ASAny>;

	var _currentBank:Array<ASAny>;

	var _lastWithdraw:UInt = 0;

	public function new(console:Console) {
		this._refMap = new WeakObject();
		this._refRev = new ASDictionary<ASAny, ASAny>(true);
		this._prevBank = new Array<ASAny>();
		this._currentBank = new Array<ASAny>();
		super(console);
		remoter.registerCallback("ref", function(bytes:ByteArray) {
			handleString(bytes.readUTF());
		});
		remoter.registerCallback("focus", this.handleFocused);
	}

	public static function EscHTML(str:String):String {
		return new compat.RegExp("\\x00", "g").replace(new compat.RegExp("\\>", "g").replace(new compat.RegExp("<", "g").replace(str, "&lt;"), "&gt;"), "");
	}

	public static function ShortClassName(obj:ASObject, eschtml:Bool = true):String {
		var _loc3_ = ASCompat.getQualifiedClassName(obj);
		var _loc4_ = _loc3_.indexOf("::");
		var _loc5_ = Std.isOfType(obj, Class) ? "*" : "";
		_loc3_ = _loc5_ + _loc3_.substring(_loc4_ >= 0 ? _loc4_ + 2 : 0) + _loc5_;
		if (eschtml) {
			return EscHTML(_loc3_);
		}
		return _loc3_;
	}

	public function update(time:UInt) {
		if (this._currentBank.length != 0 || this._prevBank.length != 0) {
			if (time > this._lastWithdraw + config.objectHardReferenceTimer * 1000) {
				this._prevBank = this._currentBank;
				this._currentBank = new Array<ASAny>();
				this._lastWithdraw = time;
			}
		}
	}

	public function setLogRef(o:ASAny):UInt {
		var _loc3_ = 0;
		if (!config.useObjectLinking) {
			return (0 : UInt);
		}
		var _loc2_ = (ASCompat.toInt(this._refRev[o]) : UInt);
		if (_loc2_ == 0) {
			_loc2_ = this._refIndex;
			(this._refMap : ASAny)[_loc2_] = o;
			this._refRev[o] = _loc2_;
			if (config.objectHardReferenceTimer != 0) {
				this._currentBank.push(o);
			}
			++this._refIndex;
			_loc3_ = (_loc2_ - 50 : Int);
			while (_loc3_ >= 0) {
				if ((this._refMap : ASAny)[_loc3_] == null) {
					ASCompat.deleteProperty(this._refMap, Std.string(_loc3_));
				}
				_loc3_ -= 50;
			}
		}
		return _loc2_;
	}

	public function getRefId(o:ASAny):UInt {
		return (ASCompat.toInt(this._refRev[o]) : UInt);
	}

	public function getRefById(ind:UInt):ASAny {
		return (this._refMap : ASAny)[ind];
	}

	public function makeString(o:ASAny, prop:ASAny = null, html:Bool = false, maxlen:Int = -1):String {
		var txt:String = null;
		var v:ASAny = /*undefined*/ null;
		var err:Error = null;
		var stackstr:String = null;
		var str:String = null;
		var len = 0;
		var hasmaxlen = false;
		var i = 0;
		var strpart:String = null;
		var add:String = null;
		try {
			v = ASCompat.toBool(prop) ? o[prop] : o;
		} catch (err:Dynamic) {
			return "<p0><i>" + Std.string(err) + "</i></p0>";
		}
		if (Std.isOfType(v, Error)) {
			err = ASCompat.dynamicAs(v, Error);
			stackstr = (err : ASAny).hasOwnProperty("getStackTrace") ? err.getStackTrace() : Std.string(err);
			if (ASCompat.stringAsBool(stackstr)) {
				return stackstr;
			}
			return Std.string(err);
		}
		if (Std.isOfType(v, compat.XML.typeReference()) || Std.isOfType(v, compat.XMLList.typeReference())) {
			return this.shortenString(EscHTML(v.toXMLString()), maxlen, o, prop);
		}
		if (Std.isOfType(v, QName)) {
			return ASCompat.toString(v);
		}
		if (Std.isOfType(v, Array) || ASCompat.getQualifiedClassName(v).indexOf("__AS3__.vec::Vector.") == 0) {
			str = "[";
			len = ASCompat.toInt(v.length);
			hasmaxlen = maxlen >= 0;
			i = 0;
			while (i < len) {
				strpart = this.makeString(v[i], null, false, maxlen);
				str += (i != 0 ? ", " : "") + strpart;
				maxlen -= strpart.length;
				if (hasmaxlen && maxlen <= 0 && i < len - 1) {
					str += ", " + this.genLinkString(o, prop, "...");
					break;
				}
				i++;
			}
			return str + "]";
		}
		if (config.useObjectLinking && ASCompat.toBool(v) && ASCompat.typeof(v) == "object") {
			add = "";
			if (ASCompat.isByteArray(v)) {
				add = " position:" + Std.string(v.position) + " length:" + Std.string(v.length);
			} else if (Std.isOfType(v, Date) || Std.isOfType(v, Rectangle) || Std.isOfType(v, Point) || Std.isOfType(v, Matrix) || Std.isOfType(v, Event)) {
				add = " " + ASCompat.toString(v);
			} else if (Std.isOfType(v, DisplayObject) && ASCompat.toBool(v.name)) {
				add = " " + Std.string(v.name);
			}
			txt = "{" + this.genLinkString(o, prop, ShortClassName(v)) + EscHTML(add) + "}";
		} else {
			if (ASCompat.isByteArray(v)) {
				txt = "[ByteArray position:" + cast(v, ByteArray).position + " length:" + cast(v, ByteArray).length + "]";
			} else {
				txt = ASCompat.toString(v);
			}
			if (!html) {
				return this.shortenString(EscHTML(txt), maxlen, o, prop);
			}
		}
		return txt;
	}

	public function makeRefTyped(v:ASAny):String {
		if (ASCompat.toBool(v) && ASCompat.typeof(v) == "object" && !Std.isOfType(v, QName)) {
			return "{" + this.genLinkString(v, null, ShortClassName(v)) + "}";
		}
		return ShortClassName(v);
	}

	function genLinkString(o:ASAny, prop:ASAny, str:String):String {
		if (ASCompat.toBool(prop) && !Std.isOfType(prop, String)) {
			o = o[prop];
			prop = null;
		}
		var _loc4_ = this.setLogRef(o);
		if (_loc4_ != 0) {
			return "<menu><a href=\'event:ref_"
				+ _loc4_
				+ (ASCompat.toBool(prop) ? "_" + Std.string(prop) : "")
				+ "\'>"
				+ str
				+ "</a></menu>";
		}
		return str;
	}

	function shortenString(str:String, maxlen:Int, o:ASAny, prop:ASAny = null):String {
		if (maxlen >= 0 && str.length > maxlen) {
			str = str.substring(0, maxlen);
			return str + this.genLinkString(o, prop, " ...");
		}
		return str;
	}

	function historyInc(i:Int) {
		this._hisIndex += (i : UInt);
		var _loc2_:ASAny = this._history[(this._hisIndex : Int)];
		if (ASCompat.toBool(_loc2_)) {
			this.focus(_loc2_, this._dofull);
		}
	}

	public function handleRefEvent(str:String) {
		var _loc2_:ByteArray = null;
		if (remoter.remoting == Remoting.RECIEVER) {
			_loc2_ = new ByteArray();
			_loc2_.writeUTF(str);
			remoter.send("ref", _loc2_);
		} else {
			this.handleString(str);
		}
	}

	function handleString(str:String) {
		var _loc2_ = 0;
		var _loc3_ = (0 : UInt);
		var _loc4_:String = null;
		var _loc5_ = 0;
		var _loc6_:ASObject = null;
		if (str == "refexit") {
			this.exitFocus();
			console.setViewingChannels();
		} else if (str == "refprev") {
			this.historyInc(-2);
		} else if (str == "reffwd") {
			this.historyInc(0);
		} else if (str == "refi") {
			this.focus(this._current, !this._dofull);
		} else {
			_loc2_ = str.indexOf("_") + 1;
			if (_loc2_ > 0) {
				_loc4_ = "";
				_loc5_ = str.indexOf("_", _loc2_);
				if (_loc5_ > 0) {
					_loc3_ = (ASCompat.toInt(str.substring(_loc2_, _loc5_)) : UInt);
					_loc4_ = str.substring(_loc5_ + 1);
				} else {
					_loc3_ = (ASCompat.toInt(str.substring(_loc2_)) : UInt);
				}
				_loc6_ = this.getRefById(_loc3_);
				if (ASCompat.stringAsBool(_loc4_)) {
					_loc6_ = _loc6_[_loc4_];
				}
				if (ASCompat.toBool(_loc6_)) {
					if (str.indexOf("refe_") == 0) {
						console.explodech(console.panels.mainPanel.reportChannel, _loc6_);
					} else {
						this.focus(_loc6_, this._dofull);
					}
					return;
				}
			}
			report("Reference no longer exist (garbage collected).", -2);
		}
	}

	public function focus(o:ASAny, full:Bool = false) {
		remoter.send("focus");
		console.clear(LogReferences.INSPECTING_CHANNEL);
		console.setViewingChannels(LogReferences.INSPECTING_CHANNEL);
		if (this._history == null) {
			this._history = new Array<ASAny>();
		}
		if (this._current != o) {
			this._current = o;
			if ((this._history.length : UInt) <= this._hisIndex) {
				this._history.push(o);
			} else {
				this._history[(this._hisIndex : Int)] = o;
			}
			++this._hisIndex;
		}
		this._dofull = full;
		this.inspect(o, this._dofull);
	}

	function handleFocused() {
		console.clear(LogReferences.INSPECTING_CHANNEL);
		console.setViewingChannels(LogReferences.INSPECTING_CHANNEL);
	}

	public function exitFocus() {
		var _loc1_:ByteArray = null;
		this._current = null;
		this._dofull = false;
		this._history = null;
		this._hisIndex = (0 : UInt);
		if (remoter.remoting == Remoting.SENDER) {
			_loc1_ = new ByteArray();
			_loc1_.writeUTF("refexit");
			remoter.send("ref", _loc1_);
		}
		console.clear(LogReferences.INSPECTING_CHANNEL);
	}

	public function inspect(obj:ASAny, viewAll:Bool = true, ch:String = null) {
		var refIndex:UInt;
		var showInherit:String;
		var V:compat.XML;
		var cls:ASObject;
		var clsV:compat.XML;
		var self:String;
		var isClass:Bool;
		var st:String;
		var str:String;
		var props:Array<ASAny>;
		var inherit:UInt;
		var menuStr:String = null;
		var nodes:compat.XMLList = null;
		var constantX:compat.XML = null;
		var hasstuff = false;
		var isstatic = false;
		var methodX:compat.XML = null;
		var accessorX:compat.XML = null;
		var variableX:compat.XML = null;
		var extendX:compat.XML = null;
		var implementX:compat.XML = null;
		var metadataX:compat.XML = null;
		var mn:compat.XMLList = null;
		var en:String = null;
		var et:String = null;
		var disp:DisplayObject = null;
		var theParent:DisplayObjectContainer = null;
		var pr:DisplayObjectContainer = null;
		var indstr:String = null;
		var cont:DisplayObjectContainer = null;
		var clen = 0;
		var ci = 0;
		var child:DisplayObject = null;
		var params:Array<ASAny> = null;
		var mparamsList:compat.XMLList = null;
		var paraX:compat.XML = null;
		var access:String = null;
		var X:ASAny = /*undefined*/ null;
		if (!ASCompat.toBool(obj)) {
			report(obj, -2, true, ch);
			return;
		}
		refIndex = this.setLogRef(obj);
		showInherit = "";
		if (!viewAll) {
			showInherit = " [<a href=\'event:refi\'>show inherited</a>]";
		}
		if (this._history != null) {
			menuStr = "<b>[<a href=\'event:refexit\'>exit</a>]";
			if (this._hisIndex > 1) {
				menuStr += " [<a href=\'event:refprev\'>previous</a>]";
			}
			if (this._history != null && this._hisIndex < (this._history.length:UInt)) {
				menuStr += " [<a href=\'event:reffwd\'>forward</a>]";
			}
			menuStr += "</b> || [<a href=\'event:ref_" + refIndex + "\'>refresh</a>]";
			menuStr += "</b> [<a href=\'event:refe_" + refIndex + "\'>explode</a>]";
			if (config.commandLineAllowed) {
				menuStr += " [<a href=\'event:cl_" + refIndex + "\'>scope</a>]";
			}
			if (viewAll) {
				menuStr += " [<a href=\'event:refi\'>hide inherited</a>]";
			} else {
				menuStr += showInherit;
			}
			report(menuStr, -1, true, ch);
			report("", 1, true, ch);
		}
		V = ASCompat.describeType(obj);
		cls = Std.isOfType(obj, Class) ? obj : (obj : ASAny).constructor;
		clsV = ASCompat.describeType(cls);
		self = V.attribute("name");
		isClass = Std.isOfType(obj, Class);
		st = isClass ? "*" : "";
		str = "<b>{" + st + this.genLinkString(obj, null, EscHTML(self)) + st + "}</b>";
		props = [];
		if (V.attribute("isStatic") == "true") {
			props.push("<b>static</b>");
		}
		if (V.attribute("isDynamic") == "true") {
			props.push("dynamic");
		}
		if (V.attribute("isFinal") == "true") {
			props.push("final");
		}
		if (props.length > 0) {
			str += " <p-1>" + props.join(" | ") + "</p-1>";
		}
		report(str, -2, true, ch);
		nodes = V.child("extendsClass");
		if (nodes.length() != 0) {
			props = [];
			if (checkNullIteratee(nodes))
				for (_tmp_ in nodes) {
					extendX = _tmp_;
					st = extendX.attribute("type").toString();
					props.push(st.indexOf("*") < 0 ? this.makeValue(Type.resolveClass(st)) : EscHTML(st));
					if (!viewAll) {
						break;
					}
				}
			report("<p10>Extends:</p10> " + props.join(" &gt; "), 1, true, ch);
		}
		nodes = V.child("implementsInterface");
		if (nodes.length() != 0) {
			props = [];
			if (checkNullIteratee(nodes))
				for (_tmp_ in nodes) {
					implementX = _tmp_;
					props.push(this.makeValue(Type.resolveClass(implementX.attribute("type").toString())));
				}
			report("<p10>Implements:</p10> " + props.join(", "), 1, true, ch);
		}
		report("", 1, true, ch);
		props = [];
		nodes = ASCompat.filterXmlList(V.child("metadata"), function(__xml:compat.XML):Bool {
			return __xml.attribute("name") == "Event";
		});
		if (nodes.length() != 0) {
			if (checkNullIteratee(nodes))
				for (_tmp_ in nodes) {
					metadataX = _tmp_;
					mn = metadataX.child("arg");
					en = ASCompat.filterXmlList(mn, function(__xml:compat.XML):Bool {
						return __xml.attribute("key") == "name";
					}).attribute("value");
					et = ASCompat.filterXmlList(mn, function(__xml:compat.XML):Bool {
						return __xml.attribute("key") == "type";
					}).attribute("value");
					if (refIndex != 0) {
						props.push("<a href=\'event:cl_"
							+ refIndex
							+ "_dispatchEvent(new "
							+ et
							+ "(\""
							+ en
							+ "\"))\'>"
							+ en
							+ "</a><p0>("
							+ et
							+ ")</p0>");
					} else {
						props.push(en + "<p0>(" + et + ")</p0>");
					}
				}
			report("<p10>Events:</p10> " + props.join("<p-1>; </p-1>"), 1, true, ch);
			report("", 1, true, ch);
		}
		if (Std.isOfType(obj, DisplayObject)) {
			disp = ASCompat.dynamicAs(obj, DisplayObject);
			theParent = disp.parent;
			if (theParent != null) {
				props = ["@" + theParent.getChildIndex(disp)];
				while (theParent != null) {
					pr = theParent;
					theParent = theParent.parent;
					indstr = theParent != null ? "@" + theParent.getChildIndex(pr) : "";
					props.push("<b>" + pr.name + "</b>" + indstr + this.makeValue(pr));
				}
				report("<p10>Parents:</p10> " + props.join("<p-1> -> </p-1>") + "<br/>", 1, true, ch);
			}
		}
		if (Std.isOfType(obj, DisplayObjectContainer)) {
			props = [];
			cont = ASCompat.dynamicAs(obj, DisplayObjectContainer);
			clen = cont.numChildren;
			ci = 0;
			while (ci < clen) {
				child = cont.getChildAt(ci);
				props.push("<b>" + child.name + "</b>@" + ci + this.makeValue(child));
				ci++;
			}
			if (clen != 0) {
				report("<p10>Children:</p10> " + props.join("<p-1>; </p-1>") + "<br/>", 1, true, ch);
			}
		}
		props = [];
		nodes = clsV.descendants("constant");
		if (checkNullIteratee(nodes))
			for (_tmp_ in nodes) {
				constantX = _tmp_;
				report(" const <p3>"
					+ constantX.attribute("name")
					+ "</p3>:"
					+ constantX.attribute("type")
					+ " = "
					+ this.makeValue(cls, constantX.attribute("name").toString())
					+ "</p0>",
					1, true, ch);
			}
		if (nodes.length() != 0) {
			report("", 1, true, ch);
		}
		inherit = (0 : UInt);
		props = [];
		nodes = clsV.descendants("method");
		if (checkNullIteratee(nodes))
			for (_tmp_ in nodes) {
				methodX = _tmp_;
				if (viewAll || self == methodX.attribute("declaredBy")) {
					hasstuff = true;
					isstatic = methodX.parent().name() != "factory";
					str = " " + (isstatic ? "static " : "") + "function ";
					params = [];
					mparamsList = methodX.child("parameter");
					if (checkNullIteratee(mparamsList))
						for (_tmp_ in mparamsList) {
							paraX = _tmp_;
							params.push(paraX.attribute("optional") == "true" ? "<i>" + paraX.attribute("type") + "</i>" : paraX.attribute("type"));
						}
					if (refIndex != 0 && (isstatic || !isClass)) {
						str += "<a href=\'event:cl_"
							+ refIndex
							+ "_"
							+ methodX.attribute("name")
							+ "()\'><p3>"
							+ methodX.attribute("name")
							+ "</p3></a>";
					} else {
						str += "<p3>" + methodX.attribute("name") + "</p3>";
					}
					str += "(" + params.join(", ") + "):" + methodX.attribute("returnType");
					report(str, 1, true, ch);
				} else {
					inherit++;
				}
			}
		if (inherit != 0) {
			report("   \t + " + inherit + " inherited methods." + showInherit, 1, true, ch);
		} else if (hasstuff) {
			report("", 1, true, ch);
		}
		hasstuff = false;
		inherit = (0 : UInt);
		props = [];
		nodes = clsV.descendants("accessor");
		if (checkNullIteratee(nodes))
			for (_tmp_ in nodes) {
				accessorX = _tmp_;
				if (viewAll || self == accessorX.attribute("declaredBy")) {
					hasstuff = true;
					isstatic = accessorX.parent().name() != "factory";
					str = " ";
					if (isstatic) {
						str += "static ";
					}
					access = accessorX.attribute("access");
					if (access == "readonly") {
						str += "get";
					} else if (access == "writeonly") {
						str += "set";
					} else {
						str += "assign";
					}
					if (refIndex != 0 && (isstatic || !isClass)) {
						str += " <a href=\'event:cl_" + refIndex + "_" + accessorX.attribute("name") + "\'><p3>" + accessorX.attribute("name")
							+ "</p3></a>:" + accessorX.attribute("type");
					} else {
						str += " <p3>" + accessorX.attribute("name") + "</p3>:" + accessorX.attribute("type");
					}
					if (access != "writeonly" && (isstatic || !isClass)) {
						str += " = " + this.makeValue(isstatic ? cls : obj, accessorX.attribute("name").toString());
					}
					report(str, 1, true, ch);
				} else {
					inherit++;
				}
			}
		if (inherit != 0) {
			report("   \t + " + inherit + " inherited accessors." + showInherit, 1, true, ch);
		} else if (hasstuff) {
			report("", 1, true, ch);
		}
		nodes = clsV.descendants("variable");
		if (checkNullIteratee(nodes))
			for (_tmp_ in nodes) {
				variableX = _tmp_;
				isstatic = variableX.parent().name() != "factory";
				str = isstatic ? " static" : "";
				if (refIndex != 0) {
					str += " var <p3><a href=\'event:cl_"
						+ refIndex
						+ "_"
						+ variableX.attribute("name")
						+ " = \'>"
						+ variableX.attribute("name")
						+ "</a>";
				} else {
					str += " var <p3>" + variableX.attribute("name");
				}
				str += "</p3>:"
					+ variableX.attribute("type")
					+ " = "
					+ this.makeValue(isstatic ? cls : obj, variableX.attribute("name").toString());
				report(str, 1, true, ch);
			}
		try {
			props = [];
			if (checkNullIteratee(obj))
				for (_tmp_ in obj.___keys()) {
					X = _tmp_;
					if (Std.isOfType(X, String)) {
						if (refIndex != 0) {
							str = "<a href=\'event:cl_" + refIndex + "_" + Std.string(X) + " = \'>" + Std.string(X) + "</a>";
						} else {
							str = X;
						}
						report(" dynamic var <p3>" + str + "</p3> = " + this.makeValue(obj, X), 1, true, ch);
					} else {
						report(" dictionary <p3>" + this.makeValue(X) + "</p3> = " + this.makeValue(obj, X), 1, true, ch);
					}
				}
		} catch (e:Dynamic) {
			report("Could not get dynamic values. " + Std.string(e.message), 9, false, ch);
		}
		if (Std.isOfType(obj, String)) {
			report("", 1, true, ch);
			report("String", 10, true, ch);
			report(EscHTML(obj), 1, true, ch);
		} else if (Std.isOfType(obj, compat.XML.typeReference()) || Std.isOfType(obj, compat.XMLList.typeReference())) {
			report("", 1, true, ch);
			report("XMLString", 10, true, ch);
			report(EscHTML(obj.toXMLString()), 1, true, ch);
		}
		if (ASCompat.stringAsBool(menuStr)) {
			report("", 1, true, ch);
			report(menuStr, -1, true, ch);
		}
	}

	public function getPossibleCalls(obj:ASAny):Array<ASAny> {
		var _loc5_:compat.XML = null;
		var _loc6_:compat.XML = null;
		var _loc7_:compat.XML = null;
		var _loc8_:Array<ASAny> = null;
		var _loc9_:compat.XMLList = null;
		var _loc10_:compat.XML = null;
		var _loc2_ = new Array<ASAny>();
		var _loc3_ = ASCompat.describeType(obj);
		var _loc4_ = _loc3_.child("method");
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc5_ = _tmp_;
				_loc8_ = [];
				_loc9_ = _loc5_.child("parameter");
				if (checkNullIteratee(_loc9_))
					for (_tmp_ in _loc9_) {
						_loc10_ = _tmp_;
						_loc8_.push(_loc10_.attribute("optional") == "true" ? "<i>" + _loc10_.attribute("type") + "</i>" : _loc10_.attribute("type"));
					}
				_loc2_.push([
					_loc5_.attribute("name") + "(",
					_loc8_.join(", ") + " ):" + _loc5_.attribute("returnType")
				]);
			}
		_loc4_ = _loc3_.child("accessor");
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc6_ = _tmp_;
				_loc2_.push([_loc6_.attribute("name"), _loc6_.attribute("type")]);
			}
		_loc4_ = _loc3_.child("variable");
		if (checkNullIteratee(_loc4_))
			for (_tmp_ in _loc4_) {
				_loc7_ = _tmp_;
				_loc2_.push([_loc7_.attribute("name"), _loc7_.attribute("type")]);
			}
		return _loc2_;
	}

	function makeValue(obj:ASAny, prop:ASAny = null):String {
		return this.makeString(obj, prop, false, config.useObjectLinking ? 100 : -1);
	}
}
