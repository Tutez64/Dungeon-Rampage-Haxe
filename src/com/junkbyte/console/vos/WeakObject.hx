package com.junkbyte.console.vos;

/*use*/ /*namespace*/ /*flash_proxy*/ /*dynamic*/
class WeakObject extends ASProxyBase {
	var _item:Array<ASAny>;

	var _dir:ASObject;

	public function new() {
		super();
		this._dir = new ASObject();
	}

	public function set(n:String, obj:ASObject, strong:Bool = false) {
		if (obj == null) {
			ASCompat.deleteProperty(this._dir, n);
		} else {
			this._dir[n] = new WeakRef(obj, strong);
		}
	}

	public function get(n:String):ASAny {
		var _loc2_ = this.getWeakRef(n);
		return _loc2_ != null ? _loc2_.reference : /*undefined*/ null;
	}

	public function getWeakRef(n:String):WeakRef {
		return ASCompat.dynamicAs(this._dir[n], WeakRef);
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function getProperty(n:Dynamic):Dynamic {
		return this.get(n);
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function callProperty(n:Dynamic, ..._rest:Dynamic):Dynamic {
		var rest = ASCompat.restToArray(_rest);
		var _loc3_:ASObject = this.get(n);
		return Reflect.callMethod(this, _loc3_, rest);
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function setProperty(n:Dynamic, v:Dynamic) {
		this.set(n, v);
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function nextName(index:Int):String {
		return this._item[index - 1];
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function nextValue(index:Int):Dynamic {
		return (this : ASAny)[this.nextName(index)];
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function nextNameIndex(index:Int):Int {
		var __ax4_iter_46:ASObject;
		var _loc2_:String = /*undefined*/ null;
		if (index == 0) {
			this._item = new Array<ASAny>();
			__ax4_iter_46 = this._dir;
			if (checkNullIteratee(__ax4_iter_46))
				for (_tmp_ in __ax4_iter_46.___keys()) {
					_loc2_ = _tmp_;
					this._item.push(_loc2_);
				}
		}
		if (index < this._item.length) {
			return index + 1;
		}
		return 0;
	}

	@:ns("http://www.adobe.com/2006/actionscript/flash/proxy") override public function deleteProperty(name:Dynamic):Bool {
		return ASCompat.deleteProperty(this._dir, name);
	}

	public function toString():String {
		return "[WeakObject]";
	}
}
