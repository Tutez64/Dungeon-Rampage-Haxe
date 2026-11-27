package starling.assets;

import flash.system.Capabilities;
import starling.errors.AbstractClassError;

class AssetFactory {
	var _priority:Int = 0;

	var _mimeTypes:Vector<String>;

	var _extensions:Vector<String>;

	public function new() {
		if (Capabilities.isDebugger && ASCompat.getQualifiedClassName(this) == "starling.assets::AssetFactory") {
			throw new AbstractClassError();
		}
		_mimeTypes = new Vector<String>((0 : UInt));
		_extensions = new Vector<String>((0 : UInt));
	}

	public function canHandle(reference:AssetReference):Bool {
		var _loc3_ = reference.mimeType;
		var _loc2_ = reference.extension;
		return ASCompat.isByteArray(reference.data)
			&& (ASCompat.stringAsBool(_loc3_)
				&& _mimeTypes.indexOf(reference.mimeType.toLowerCase()) != -1
				|| ASCompat.stringAsBool(_loc2_)
				&& _extensions.indexOf(reference.extension.toLowerCase()) != -1);
	}

	public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:ASFunction, onError:ASFunction) {}

	public function addMimeTypes(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc2_:String;
		if (checkNullIteratee(rest))
			for (_tmp_ in rest) {
				_loc2_ = _tmp_;
				_loc2_ = _loc2_.toLowerCase();
				if (_mimeTypes.indexOf(_loc2_) == -1) {
					_mimeTypes[_mimeTypes.length] = _loc2_;
				}
			}
	}

	public function addExtensions(..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		var _loc2_:String;
		if (checkNullIteratee(rest))
			for (_tmp_ in rest) {
				_loc2_ = _tmp_;
				_loc2_ = _loc2_.toLowerCase();
				if (_extensions.indexOf(_loc2_) == -1) {
					_extensions[_extensions.length] = _loc2_;
				}
			}
	}

	public function getMimeTypes(out:Vector<String> = null):Vector<String> {
		var _loc2_ = 0;
		if (out == null) {
			out = new Vector<String>();
		}
		_loc2_ = 0;
		while (_loc2_ < _mimeTypes.length) {
			out[_loc2_] = _mimeTypes[_loc2_];
			_loc2_++;
		}
		return out;
	}

	public function getExtensions(out:Vector<String> = null):Vector<String> {
		var _loc2_ = 0;
		if (out == null) {
			out = new Vector<String>();
		}
		_loc2_ = 0;
		while (_loc2_ < _extensions.length) {
			out[_loc2_] = _extensions[_loc2_];
			_loc2_++;
		}
		return out;
	}

	@:allow(starling.assets) @:allow(starling.assets) @:isVar var priority(get, set):Int;

	function get_priority():Int {
		return _priority;
	}

	function set_priority(value:Int):Int {
		return _priority = value;
	}
}
