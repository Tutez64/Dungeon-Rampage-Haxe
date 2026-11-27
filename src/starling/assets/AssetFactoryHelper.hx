package starling.assets;

import starling.utils.SystemUtil;

class AssetFactoryHelper {
	var _dataLoader:DataLoader;

	var _getNameFromUrlFunc:ASFunction;

	var _getExtensionFromUrlFunc:ASFunction;

	var _addPostProcessorFunc:ASFunction;

	var _addAssetFunc:ASFunction;

	var _onRestoreFunc:ASFunction;

	var _logFunc:ASFunction;

	public function new() {}

	public function getNameFromUrl(url:String):String {
		if (_getNameFromUrlFunc != null) {
			return _getNameFromUrlFunc(url);
		}
		return "";
	}

	public function getExtensionFromUrl(url:String):String {
		if (_getExtensionFromUrlFunc != null) {
			return _getExtensionFromUrlFunc(url);
		}
		return "";
	}

	public function loadDataFromUrl(url:String, onComplete:ASFunction, onError:ASFunction) {
		if (_dataLoader != null) {
			_dataLoader.load(url, onComplete, onError);
		}
	}

	public function addPostProcessor(processor:ASFunction, priority:Int = 0) {
		if (_addPostProcessorFunc != null) {
			_addPostProcessorFunc(processor, priority);
		}
	}

	public function onBeginRestore() {
		if (_onRestoreFunc != null) {
			_onRestoreFunc(false);
		}
	}

	public function onEndRestore() {
		if (_onRestoreFunc != null) {
			_onRestoreFunc(true);
		}
	}

	public function log(message:String) {
		if (_logFunc != null) {
			_logFunc(message);
		}
	}

	public function addComplementaryAsset(name:String, asset:ASObject, type:String = null) {
		if (_addAssetFunc != null) {
			_addAssetFunc(name, asset, type);
		}
	}

	public function executeWhenContextReady(call:ASFunction, ..._rest:ASAny) {
		var rest = ASCompat.restToArray(_rest);
		if (SystemUtil.isDesktop) {
			Reflect.callMethod(this, call, rest);
		} else {
			rest.unshift(call);
			Reflect.callMethod(this, SystemUtil.executeWhenApplicationIsActive, rest);
		}
	}

	@:allow(starling.assets) @:isVar var getNameFromUrlFunc(never, set):ASFunction;

	function set_getNameFromUrlFunc(value:ASFunction):ASFunction {
		return _getNameFromUrlFunc = value;
	}

	@:allow(starling.assets) @:isVar var getExtensionFromUrlFunc(never, set):ASFunction;

	function set_getExtensionFromUrlFunc(value:ASFunction):ASFunction {
		return _getExtensionFromUrlFunc = value;
	}

	@:allow(starling.assets) @:isVar var dataLoader(never, set):DataLoader;

	function set_dataLoader(value:DataLoader):DataLoader {
		return _dataLoader = value;
	}

	@:allow(starling.assets) @:isVar var logFunc(never, set):ASFunction;

	function set_logFunc(value:ASFunction):ASFunction {
		return _logFunc = value;
	}

	@:allow(starling.assets) @:isVar var addAssetFunc(never, set):ASFunction;

	function set_addAssetFunc(value:ASFunction):ASFunction {
		return _addAssetFunc = value;
	}

	@:allow(starling.assets) @:isVar var onRestoreFunc(never, set):ASFunction;

	function set_onRestoreFunc(value:ASFunction):ASFunction {
		return _onRestoreFunc = value;
	}

	@:allow(starling.assets) @:isVar var addPostProcessorFunc(never, set):ASFunction;

	function set_addPostProcessorFunc(value:ASFunction):ASFunction {
		return _addPostProcessorFunc = value;
	}
}
