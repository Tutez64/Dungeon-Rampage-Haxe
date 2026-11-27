package dungeon;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.logger.Logger;
import collections.Map;
import facade.DBFacade;
import gameMasterDictionary.GMProp;
import starling.SwfFallbackDebug;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
import flash.display.MovieClip;
import starling.extensions.animate.Animation;
import starling.textures.Texture;

class PropFactory {
	var mDBFacade:DBFacade;

	var mLibraryJson:Array<ASAny>;

	var mConstantToJsonMap:Map;

	var mAssetClassToJsonMap:Map;

	var mAssetLoadingComponent:AssetLoadingComponent;

	public function new(facade:DBFacade, libraryJson:Array<ASAny>) {
		mDBFacade = facade;
		mLibraryJson = libraryJson;
		mConstantToJsonMap = new Map();
		mAssetClassToJsonMap = new Map();
		mAssetLoadingComponent = facade.assetLoadingComponent;
		buildLibraryMap();
	}

	public function destroy() {
		mDBFacade = null;
		mLibraryJson = null;
		mConstantToJsonMap.clear();
		mConstantToJsonMap = null;
		mAssetClassToJsonMap.clear();
		mAssetClassToJsonMap = null;
		mAssetLoadingComponent = null;
	}

	function buildLibraryMap() {
		var _loc2_ = 0;
		var _loc1_:ASObject = null;
		while (_loc2_ < mLibraryJson.length) {
			_loc1_ = mLibraryJson[_loc2_];
			mConstantToJsonMap.add(_loc1_.constant, _loc1_);
			if (_loc1_.assetClassName != null) {
				mAssetClassToJsonMap.add(_loc1_.assetClassName, _loc1_);
			}
			_loc2_++;
		}
	}

	public function getNavCollisionJson(constant:String):Array<ASAny> {
		var _loc2_:ASObject = mConstantToJsonMap.itemFor(constant);
		if (ASCompat.toBool(_loc2_)) {
			return ASCompat.coerce(_loc2_.navCollisions, Array);
		}
		return null;
	}

	public function getNavCollisionTriggerOffJson(constant:String):Array<ASAny> {
		var _loc2_:ASObject = mConstantToJsonMap.itemFor(constant);
		if (ASCompat.toBool(_loc2_)) {
			return ASCompat.coerce(_loc2_.navCollisions_off, Array);
		}
		return null;
	}

	public function isPropAnimated(assetClassName:String):Bool {
		var _loc2_:ASObject = mAssetClassToJsonMap.itemFor(assetClassName);
		if (ASCompat.toBool(_loc2_) && _loc2_.hasOwnProperty("isAnimated")) {
			return ASCompat.toBool(_loc2_.isAnimated);
		}
		return false;
	}

	public function createProp(constant:String, assetLoadedCallback:ASFunction, textureLoadedCallback:ASFunction = null,
			animationLoadedCallback:ASFunction = null) {
		var swfPath:String;
		var assetClassName:String;
		var isAnimated:Bool;
		var libraryKey:String;
		var gmProp = ASCompat.dynamicAs(mDBFacade.gameMaster.propByConstant.itemFor(constant), GMProp);
		if (gmProp == null) {
			Logger.warn("createProp constant not found in GM data: " + constant);
			return;
		}
		swfPath = DBFacade.buildFullDownloadPath(gmProp.SwfFilepath);
		assetClassName = gmProp.AssetClassName;
		isAnimated = isPropAnimated(assetClassName);
		libraryKey = StarlingAssetMapper.getBiomeKeyFromPath(swfPath);
		mAssetLoadingComponent.queueStarlingAssetsForProps(swfPath, isAnimated ? [assetClassName] : [], function() {
			var _loc3_:Animation = null;
			var _loc2_:Texture = null;
			if (mAssetLoadingComponent == null) {
				return;
			}
			var _loc1_:String = null;
			if (isAnimated) {
				_loc3_ = mAssetLoadingComponent.createAnimationFromAtlas(StarlingAssetMapper.getActorAtlasKeyFromPath(swfPath), assetClassName);
				if (_loc3_ == null) {
					_loc3_ = mAssetLoadingComponent.createAnimationFromAssetManager(assetClassName, libraryKey);
				}
				if (_loc3_ != null && animationLoadedCallback != null) {
					animationLoadedCallback(_loc3_);
					return;
				}
				_loc1_ = _loc3_ == null ? "no Starling animation for animated prop" : "animation resolved but no animationLoadedCallback was provided";
			} else {
				_loc2_ = mAssetLoadingComponent.getTextureFromAssetManager(assetClassName, libraryKey);
				if (_loc2_ != null && textureLoadedCallback != null) {
					textureLoadedCallback(_loc2_);
					return;
				}
				_loc1_ = _loc2_ == null ? "no atlas texture for static prop" : "texture resolved but no textureLoadedCallback was provided";
			}
			SwfFallbackDebug.report(mDBFacade, "PROP", constant + " (" + assetClassName + ")", swfPath, _loc1_);
			loadSwfAsset(swfPath, assetClassName, assetLoadedCallback);
		});
	}

	function loadSwfAsset(swfPath:String, assetClassName:String, assetLoadedCallback:ASFunction) {
		mAssetLoadingComponent.getSwfAsset(swfPath, function(param1:brain.assetRepository.SwfAsset) {
			var _loc2_ = param1.getClass(assetClassName);
			var _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
			if (_loc3_.totalFrames <= 1 && !hasAnimatedDescendant(_loc3_)) {
				Logger.warnch("Starling", "Prop did not load into Starling Pipeline: " + assetClassName);
			}
			assetLoadedCallback(_loc3_);
		});
	}

	function hasAnimatedDescendant(container:DisplayObjectContainer):Bool {
		var _loc2_ = 0;
		var _loc3_:DisplayObject = null;
		_loc2_ = 0;
		while (_loc2_ < container.numChildren) {
			_loc3_ = container.getChildAt(_loc2_);
			if (Std.isOfType(_loc3_, MovieClip) && cast(_loc3_, MovieClip).totalFrames > 1) {
				return true;
			}
			if (Std.isOfType(_loc3_, DisplayObjectContainer) && hasAnimatedDescendant(cast(_loc3_, DisplayObjectContainer))) {
				return true;
			}
			_loc2_++;
		}
		return false;
	}
}
