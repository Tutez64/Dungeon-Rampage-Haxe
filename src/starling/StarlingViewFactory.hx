package starling;

import brain.assetRepository.AssetLoadingComponent;
import brain.assetRepository.StarlingAssetMapper;
import brain.logger.Logger;
import brain.starling.*;
import collections.Map;
import facade.DBFacade;
import gameMasterDictionary.GMProp;
import flash.display.BitmapData;
import flash.display.DisplayObject;
import flash.display.MovieClip;
import flash.geom.Matrix;
import starling.display.Image;
import starling.extensions.animate.Animation;
import starling.textures.Texture;

class StarlingViewFactory {
	var mFacade:DBFacade;

	var mAssetLoadingComponent:AssetLoadingComponent;

	var mStarlingLayerManager:StarlingLayerManager;

	var mLibraryMap:Map;

	var mDisposed:Bool = false;

	var mFloorBackgrounds:ASDictionary<ASAny, ASAny>;

	public function new(inFacade:DBFacade) {
		mFacade = inFacade;
		mStarlingLayerManager = mFacade.starlingLayerManager;
		mAssetLoadingComponent = mFacade.assetLoadingComponent;
		mLibraryMap = new Map();
		mFloorBackgrounds = new ASDictionary<ASAny, ASAny>(true);
		buildLibraryMap();
	}

	@:isVar public var starlingLayerManager(get, never):StarlingLayerManager;

	public function get_starlingLayerManager():StarlingLayerManager {
		return mStarlingLayerManager;
	}

	@:isVar public var assetLoadingComponent(get, never):AssetLoadingComponent;

	public function get_assetLoadingComponent():AssetLoadingComponent {
		return mAssetLoadingComponent;
	}

	public function initializeBatch() {
		starlingLayerManager.cleanLayers();
	}

	function buildLibraryMap() {
		var _loc3_ = 0;
		var _loc1_:ASObject = null;
		var _loc2_ = mFacade.libraryJson;
		while (_loc3_ < _loc2_.length) {
			_loc1_ = _loc2_[_loc3_];
			mLibraryMap.add(_loc1_.constant, _loc1_);
			_loc3_++;
		}
	}

	public function getPivotJson(constant:String):ASObject {
		var _loc2_:ASObject = mLibraryMap.itemFor(constant);
		if (ASCompat.toBool(_loc2_)) {
			return _loc2_.pivot;
		}
		return null;
	}

	public function buildViewFromAsset(inMovieClipKey:String, inX:Float, inY:Float, inScaleX:Float, inScaleY:Float, inRotation:Float, inIsOnStage:Bool,
			inIsFiller:Bool = false) {
		var swfPath:String;
		var assetClassName:String;
		var gmProp = ASCompat.dynamicAs(mFacade.gameMaster.propByConstant.itemFor(inMovieClipKey), GMProp);
		if (gmProp == null) {
			Logger.warn("createProp constant not found in GM data: " + inMovieClipKey);
			return;
		}
		swfPath = DBFacade.buildFullDownloadPath(gmProp.SwfFilepath);
		assetClassName = gmProp.AssetClassName;
		assetLoadingComponent.queueStarlingAssetsForPath(swfPath, function() {
			if (mDisposed || mAssetLoadingComponent == null) {
				return;
			}
			var _loc1_ = mAssetLoadingComponent.getTextureFromAssetManager(assetClassName, StarlingAssetMapper.getBiomeKeyFromPath(swfPath));
			if (_loc1_ == null) {
				SwfFallbackDebug.report(mFacade, "TILE", inMovieClipKey + " (" + assetClassName + ")", swfPath,
					"no Starling texture for tile background in the floor biome atlas");
				loadSwfAsset(swfPath, assetClassName, inMovieClipKey, inX, inY, inScaleX, inScaleY, inRotation, inIsOnStage, inIsFiller);
			} else {
				placeBackground(onTextureAssetLoaded(_loc1_, inMovieClipKey, inX, inY, inScaleX, inScaleY, inRotation, inIsOnStage, 5, "none"), inIsFiller);
			}
		}, true);
	}

	function loadSwfAsset(swfPath:String, assetClassName:String, inMovieClipKey:String, inX:Float, inY:Float, inScaleX:Float, inScaleY:Float,
			inRotation:Float, inIsOnStage:Bool, inIsFiller:Bool) {
		mAssetLoadingComponent.getSwfAsset(swfPath, function(param1:brain.assetRepository.SwfAsset) {
			if (mDisposed) {
				return;
			}
			var _loc2_ = param1.getClass(assetClassName);
			var _loc3_ = ASCompat.dynamicAs(ASCompat.createInstance(_loc2_, []), MovieClip);
			placeBackground(onAssetLoaded(_loc3_, inMovieClipKey, inX, inY, inScaleX, inScaleY, inRotation, inIsOnStage), inIsFiller);
		});
	}

	public function onTextureAssetLoaded(inTexture:Texture, inMovieClipKey:String, inX:Float, inY:Float, inScaleX:Float, inScaleY:Float, inRotation:Float,
			inIsOnStage:Bool, inTargetLayer:Int = 10, inBlendMode:String = null):StarlingView {
		inTargetLayer = resolveTargetLayer(inTargetLayer, "onTextureAssetLoaded");
		var _loc13_ = new StarlingView(mFacade, inMovieClipKey);
		var _loc11_:Image = new StarlingSceneryImage(inTexture);
		_loc11_.name = inMovieClipKey;
		_loc11_.scaleX = inScaleX;
		_loc11_.scaleY = inScaleY;
		var _loc12_:ASObject = getPivotJson(inMovieClipKey);
		if (_loc12_ != null) {
			_loc11_.pivotX = ASCompat.toNumberField(_loc12_, "pivotX");
			_loc11_.pivotY = ASCompat.toNumberField(_loc12_, "pivotY");
		}
		_loc11_.touchable = false;
		_loc11_.pixelSnapping = false;
		if (inBlendMode != null) {
			_loc11_.blendMode = inBlendMode;
		}
		_loc11_.visible = true;
		_loc13_.image = _loc11_;
		_loc13_.x = inX;
		_loc13_.y = inY;
		_loc13_.rotation = inRotation;
		addChildToLayer(_loc13_, inTargetLayer);
		return _loc13_;
	}

	public function onAnimationLoaded(inAnimation:Animation, inMovieClipKey:String, inX:Float, inY:Float, inScaleX:Float, inScaleY:Float, inRotation:Float,
			inIsOnStage:Bool, inTargetLayer:Int = 10, inBlendMode:String = null):StarlingView {
		inTargetLayer = resolveTargetLayer(inTargetLayer, "onAnimationLoaded");
		var _loc11_ = new StarlingView(mFacade, inMovieClipKey);
		if (inBlendMode != null) {
			inAnimation.blendMode = inBlendMode;
		}
		_loc11_.animation = inAnimation;
		_loc11_.x = inX;
		_loc11_.y = inY;
		_loc11_.scaleX = inScaleX;
		_loc11_.scaleY = inScaleY;
		_loc11_.rotation = inRotation;
		addChildToLayer(_loc11_, inTargetLayer);
		return _loc11_;
	}

	public function onAssetLoaded(inMovieClip:MovieClip, inMovieClipKey:String, inX:Float, inY:Float, inScaleX:Float, inScaleY:Float, inRotation:Float,
			inIsOnStage:Bool, inBlendMode:String = null):StarlingView {
		var _loc13_:DisplayObject;
		final __ax4_iter_373 = StarlingHelper.findNavCollisions(inMovieClip);
		if (checkNullIteratee(__ax4_iter_373))
			for (_tmp_ in __ax4_iter_373) {
				_loc13_ = ASCompat.coerce(_tmp_, flash.display.DisplayObject);
				_loc13_.parent.removeChild(_loc13_);
			}
		var _loc12_:DisplayObject;
		final __ax4_iter_374 = StarlingHelper.findCombatCollisions(inMovieClip);
		if (checkNullIteratee(__ax4_iter_374))
			for (_tmp_ in __ax4_iter_374) {
				_loc12_ = ASCompat.coerce(_tmp_, flash.display.DisplayObject);
				_loc12_.parent.removeChild(_loc12_);
			}
		var _loc15_ = inMovieClip.getBounds(inMovieClip);
		var _loc16_ = new BitmapData(Math.ceil(_loc15_.width), Math.ceil(_loc15_.height), true, (0 : UInt));
		var _loc14_ = new Matrix();
		_loc14_.translate(-_loc15_.x, -_loc15_.y);
		_loc16_.draw(inMovieClip, _loc14_);
		SwfFallbackDebug.markFallbackBitmap(mFacade, _loc16_, "TILE");
		var _loc11_ = starlingLayerManager.sourceCache.getOrCreate(inMovieClipKey, _loc16_);
		var _loc17_ = new StarlingView(mFacade, inMovieClipKey);
		var _loc10_:Image = new StarlingSceneryImage(_loc11_);
		_loc10_.name = inMovieClipKey;
		_loc10_.scaleX = inScaleX;
		_loc10_.scaleY = inScaleY;
		_loc10_.touchable = false;
		_loc10_.pixelSnapping = false;
		if (inBlendMode != null) {
			_loc10_.blendMode = inBlendMode;
		}
		_loc10_.visible = true;
		_loc17_.image = _loc10_;
		_loc17_.x = inX + _loc15_.x * inScaleX;
		_loc17_.y = inY + _loc15_.y * inScaleY;
		_loc17_.rotation = inRotation;
		addChildToLayer(_loc17_, 5);
		return _loc17_;
	}

	function resolveTargetLayer(inTargetLayer:Int, inCallerName:String):Int {
		if (starlingLayerManager.getLayer(inTargetLayer) == null) {
			Logger.warn(inCallerName + ": no Starling layer for index " + inTargetLayer + ", falling back to SORTED");
			return 20;
		}
		return inTargetLayer;
	}

	function addChildToLayer(inChild:StarlingView, inLayer:Int) {
		starlingLayerManager.getLayer(inLayer).addChild(inChild);
		starlingLayerManager.markLayerDirty(inLayer);
	}

	function placeBackground(inChild:StarlingView, inIsFiller:Bool) {
		var _loc4_ = 0;
		var _loc5_ = inChild.parent;
		if (!inIsFiller) {
			mFloorBackgrounds[inChild] = true;
			_loc5_.setChildIndex(inChild, 0);
			return;
		}
		var _loc3_ = 0;
		_loc4_ = 0;
		while (_loc4_ < _loc5_.numChildren) {
			if (ASCompat.toBool(mFloorBackgrounds[_loc5_.getChildAt(_loc4_)])) {
				_loc3_++;
			}
			_loc4_++;
		}
		_loc5_.setChildIndex(inChild, _loc3_);
	}

	public function destroy() {
		mDisposed = true;
		mFacade = null;
		mAssetLoadingComponent = null;
		mStarlingLayerManager.cleanLayers();
		mStarlingLayerManager = null;
		mLibraryMap = null;
		mFloorBackgrounds = null;
	}
}
